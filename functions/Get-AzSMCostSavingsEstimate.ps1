function global:Get-AzSMCostSavingsEstimate {

    <#
        .SYNOPSIS
        Estimates the monthly and yearly cost savings of removing Azure resources.
        .DESCRIPTION
        Estimates the monthly and yearly cost savings of removing Azure resources that are piped from other AzureSaveMoney commands, Az cmdlets or resource IDs.
        The cost of each resource for the last number of days is queried from Cost Management, averaged to a daily cost and extrapolated to a month and a year.
        The daily cost is averaged from the first day the resource had cost in the period, so resources created during the period are not underestimated.
        One Cost Management query is sent per subscription for up to 100 resources.
        .PARAMETER InputObject
        Azure resources with a ResourceId or Id property, objects with ResourceGroupName or RG and Name properties, or Azure resource ID strings.
        Accepts a single resource or an array of resources.
        .PARAMETER Days
        Number of days of cost to query, ending yesterday. Default is 30 days.
        .PARAMETER CostType
        AmortizedCost spreads reservation and savings plan purchases across the resources that use them. ActualCost shows purchases on the day they are billed.
        Default is AmortizedCost.
        .OUTPUTS
        System.Management.Automation.PSCustomObject
        .EXAMPLE
        Get-AzSMUnusedAppServicePlans -SubscriptionID 00000000-0000-0000-0000-000000000000|Get-AzSMCostSavingsEstimate
        Estimate the monthly and yearly savings of removing unused App Service Plans in a subscription.
        .EXAMPLE
        Get-AzSMUnusedDisks -SubscriptionID 00000000-0000-0000-0000-000000000000|Get-AzSMCostSavingsEstimate|Measure-Object -Property EstimatedMonthlySavings -Sum
        Total the estimated monthly savings of removing unused disks in a subscription.
        .EXAMPLE
        Get-AzSMCostSavingsEstimate -InputObject $disk1, $disk2 -Days 90
        Estimate the savings of removing two disks from the last 90 days of cost.
        .NOTES
        * Requires the Az.CostManagement module and Cost Management Reader access to the subscriptions of the resources.
        * Estimates are based on past cost. Usage based charges, such as data transfer and transactions, can change month to month.
        * Cost data can take 8 to 24 hours to appear, resources created in the last day may show no cost.
        * Free resources, such as network interfaces and network security groups, and child resources, such as subnets, return 0 savings.
        * Objects with only a resource group and name are looked up in the subscription of the current Az context.
        * CANNOT pipe to Remove- command.
        .LINK
    #>

    [CmdletBinding(
        DefaultParameterSetName='InputObject',
        ConfirmImpact='Low'
    )]

    param(
      [Parameter(Mandatory=$true, ValueFromPipeline=$true)][AllowNull()][object[]] $InputObject,
      [Parameter(Mandatory=$false)][ValidateRange(1,365)][int] $Days = 30,
      [Parameter(Mandatory=$false)][ValidateSet('AmortizedCost','ActualCost')][string] $CostType = 'AmortizedCost'
    )

    begin {
      #Resource IDs keyed by lower case ID to remove duplicates and keep the input order.
      $resourceIds = [ordered]@{}
      $resourceIdPattern = '^/subscriptions/[^/]+/resourceGroups/[^/]+/providers/.+'
    }

    process {
      foreach ($item in $InputObject) {
        if ($null -eq $item) { continue }

        $resourceId = $null
        if ($item -is [string]) {
          if ($item -match $resourceIdPattern) { $resourceId = $item }
        } else {
          foreach ($propertyName in 'ResourceId','Id') {
            $property = $item.PSObject.Properties[$propertyName]
            if ($property -and $property.Value -is [string] -and $property.Value -match $resourceIdPattern) {
              $resourceId = $property.Value
              break
            }
          }

          #Objects like AzureSaveMoney.MyRGandName only have a resource group and name, look up the resource ID.
          if (-not $resourceId) {
            $rgProperty = $item.PSObject.Properties['ResourceGroupName']
            if (-not $rgProperty) { $rgProperty = $item.PSObject.Properties['RG'] }
            $nameProperty = $item.PSObject.Properties['Name']
            if ($rgProperty -and $rgProperty.Value -and $nameProperty -and $nameProperty.Value) {
              $found = @(Get-AzResource -ResourceGroupName $rgProperty.Value -Name $nameProperty.Value -ErrorAction SilentlyContinue)
              if ($found.Count -eq 1) {
                $resourceId = $found[0].ResourceId
              } elseif ($found.Count -gt 1) {
                Write-Warning ('Skipping {0} in resource group {1}, more than one resource has this name.' -f $nameProperty.Value, $rgProperty.Value)
                continue
              } else {
                Write-Warning ('Skipping {0} in resource group {1}, the resource was not found.' -f $nameProperty.Value, $rgProperty.Value)
                continue
              }
            }
          }
        }

        if (-not $resourceId) {
          if ($item -is [string]) {
            $description = $item
          } else {
            $description = $item.GetType().FullName
            $nameProperty = $item.PSObject.Properties['Name']
            if ($nameProperty -and $nameProperty.Value) { $description = '{0} {1}' -f $description, $nameProperty.Value }
          }
          Write-Warning ('Skipping input that is not an Azure resource: {0}' -f $description)
          continue
        }

        $key = $resourceId.ToLowerInvariant()
        if (-not $resourceIds.Contains($key)) { $resourceIds[$key] = $resourceId }
      }
    }

    end {
      if ($resourceIds.Count -eq 0) { return }

      #Cost data for today is not complete, so the period ends yesterday. Cost Management uses UTC dates.
      $periodEnd = [DateTime]::UtcNow.Date.AddDays(-1)
      $periodStart = $periodEnd.AddDays(1 - $Days)
      $daysPerMonth = 365 / 12
      $batchSize = 100

      foreach ($subscription in ($resourceIds.Keys | Group-Object { ($_ -split '/')[2] })) {
        $subscriptionId = $subscription.Name
        $resourceKeys = @($subscription.Group)
        $costs = @{}
        $currency = $null
        $queryFailed = $false
        Write-Verbose ('Querying {0} for {1} resources in subscription {2} from {3:yyyy-MM-dd} to {4:yyyy-MM-dd}.' -f $CostType, $resourceKeys.Count, $subscriptionId, $periodStart, $periodEnd)

        #Query in batches to keep the resource ID filter small.
        for ($batchStart = 0; $batchStart -lt $resourceKeys.Count; $batchStart += $batchSize) {
          $batch = $resourceKeys[$batchStart..([Math]::Min($batchStart + $batchSize, $resourceKeys.Count) - 1)]
          $result = $null

          #Invoke-AzCostManagementQuery returns a result with no columns instead of an error when the query fails.
          #Retry once with the Cost column after a short wait, for throttling and billing accounts that do not use PreTaxCost.
          foreach ($costColumn in 'PreTaxCost','Cost') {
            if ($costColumn -eq 'Cost') {
              Write-Verbose 'Cost query with the PreTaxCost column returned no data, retrying with the Cost column in 10 seconds.'
              Start-Sleep -Seconds 10
            }

            $queryParameters = @{
              Scope              = "/subscriptions/$subscriptionId"
              Type               = $CostType
              Timeframe          = 'Custom'
              TimePeriodFrom     = $periodStart
              TimePeriodTo       = $periodEnd.AddDays(1).AddSeconds(-1)
              DatasetGranularity = 'Daily'
              DatasetAggregation = @{ totalCost = @{ name = $costColumn; function = 'Sum' } }
              DatasetGrouping    = @(@{ type = 'Dimension'; name = 'ResourceId' })
              DatasetFilter      = New-AzCostManagementQueryFilterObject -Dimensions (New-AzCostManagementQueryComparisonExpressionObject -Name 'ResourceId' -Value $batch)
            }

            try {
              $result = Invoke-AzCostManagementQuery @queryParameters -ErrorAction Stop
            } catch {
              Write-Verbose ('Cost query error: {0}' -f $_.Exception.Message)
              $result = $null
            }
            if ($result -and @($result.Column).Count -gt 0) { break }
          }

          $costIndex = -1; $dateIndex = -1; $idIndex = -1; $currencyIndex = -1
          if ($result) {
            $columns = @($result.Column)
            for ($c = 0; $c -lt $columns.Count; $c++) {
              switch ($columns[$c].Name) {
                'PreTaxCost' { $costIndex = $c }
                'Cost'       { $costIndex = $c }
                'UsageDate'  { $dateIndex = $c }
                'ResourceId' { $idIndex = $c }
                'Currency'   { $currencyIndex = $c }
              }
            }
          }

          if ($costIndex -lt 0 -or $dateIndex -lt 0 -or $idIndex -lt 0) {
            Write-Error ('Cost Management query for subscription {0} returned no cost data. Check for Cost Management Reader access and that the subscription type supports Cost Management, or retry later if requests are throttled.' -f $subscriptionId)
            $queryFailed = $true
            break
          }

          foreach ($row in $result.Row) {
            if ($null -eq $row[$costIndex] -or $null -eq $row[$idIndex]) { continue }
            $key = $row[$idIndex].ToLowerInvariant()
            #Invoke-AzCostManagementQuery returns row values as strings formatted with the current culture.
            $cost = [double]::Parse($row[$costIndex], [Globalization.NumberStyles]::Float, [Globalization.CultureInfo]::CurrentCulture)
            $date = [DateTime]::ParseExact($row[$dateIndex], 'yyyyMMdd', [Globalization.CultureInfo]::InvariantCulture)
            if ($currencyIndex -ge 0 -and $row[$currencyIndex]) { $currency = $row[$currencyIndex] }

            if ($costs.ContainsKey($key)) {
              $costs[$key].Total += $cost
              if ($date -lt $costs[$key].FirstDate) { $costs[$key].FirstDate = $date }
            } else {
              $costs[$key] = @{ Total = $cost; FirstDate = $date }
            }
          }
        }

        if ($queryFailed) { continue }

        foreach ($key in $resourceKeys) {
          $resourceId = $resourceIds[$key]
          $segments = $resourceId -split '/'
          $typeNames = @($segments[6])
          for ($s = 7; $s -lt $segments.Count - 1; $s += 2) { $typeNames += $segments[$s] }

          $daysAveraged = 0
          $periodCost = 0.0
          $dailyCost = 0.0
          if ($costs.ContainsKey($key)) {
            $periodCost = $costs[$key].Total
            #Average from the first day with cost, so resources created during the period are not underestimated.
            $daysAveraged = ($periodEnd - $costs[$key].FirstDate).Days + 1
            $dailyCost = $periodCost / $daysAveraged
          }

          [PSCustomObject]@{
            ResourceName            = $segments[-1]
            ResourceType            = $typeNames -join '/'
            ResourceGroupName       = $segments[4]
            SubscriptionId          = $segments[2]
            ResourceId              = $resourceId
            CostType                = $CostType
            PeriodStart             = $periodStart
            PeriodEnd               = $periodEnd
            DaysAveraged            = $daysAveraged
            PeriodCost              = [Math]::Round($periodCost, 2)
            DailyCost               = [Math]::Round($dailyCost, 4)
            EstimatedMonthlySavings = [Math]::Round($dailyCost * $daysPerMonth, 2)
            EstimatedYearlySavings  = [Math]::Round($dailyCost * 365, 2)
            Currency                = $currency
          }
        }
      }
    }
}
Export-ModuleMember -Function Get-AzSMCostSavingsEstimate
