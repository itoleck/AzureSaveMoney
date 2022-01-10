function global:Get-AzSMCostReport {

    <#
        .SYNOPSIS
        Create cost reports for next 31 days in a storage account in a subscription.
        .DESCRIPTION
        Create cost reports for next 31 days in a storage account in a subscription.
        .PARAMETER SubscriptionID
        Azure subscription ID in the format, 00000000-0000-0000-0000-000000000000
        .OUTPUTS
        
        .EXAMPLE
        Get-AzSMCostReport -Subscription 00000000-0000-0000-0000-000000000000 -StorageAccountResourceGroupName <> `
        -StorageAccountName <> -ConfirmRPInstall $true
        Create cost reports in a storage account in a subscription.
        .NOTES
        * CANNOT pipe to Remove- command. Output is text based only.
        .LINK
    #>
  
    [CmdletBinding(
        DefaultParameterSetName='SubscriptionID',
        ConfirmImpact='low'
    )]

    param(
        [Parameter(Mandatory=$true)][string] $SubscriptionID,
        [Parameter(Mandatory=$true)][string] $StorageAccountResourceGroupName,
        [Parameter(Mandatory=$true)][string] $StorageAccountName,
        [Parameter(Mandatory=$false)][boolean] $ConfirmRPInstall = $false
      )
    
    $null = Set-AzContext -SubscriptionId $SubscriptionID
     Write-Debug ('Subscription: {0}' -f $SubscriptionID)

    if ((Get-AzResourceProvider -ProviderNamespace "Microsoft.CostManagementExports").RegistrationState -ne "Registered") {
        if ($ConfirmRPInstall){
            Register-AzResourceProvider -ProviderNamespace "Microsoft.CostManagementExports"
        } else {
            Register-AzResourceProvider -ProviderNamespace "Microsoft.CostManagementExports" -Confirm
            Write-Host "If running this automated, you will need to add -ConfirmRPInstall $true parameter to confirm registration of Resource Provider in the subscription."
        }
        
        Write-Host "Registering CostManagementExports Resource Provider..."
        do {
            Start-Sleep -s 5
        } until ((Get-AzResourceProvider -ProviderNamespace "Microsoft.CostManagementExports").RegistrationState -eq "Registered")
    } else {
        Write-Host "CostManagementExports provider already registered."
    }

    #$StartDate = (Get-Date).AddHours(1).ToString("yyyyMMddTHH:mm:ssZ")
    #$EndDate = (Get-Date).AddDays(31).ToString("yyyyMMddTHH:mm:ssZ")
    $StartDate = (Get-Date).AddHours(1)
    $EndDate = (Get-Date).AddDays(31)

    #Verify if a report export is already created for AzureSaveMoney exports
    
    try {
        #Try to get the AzureSaveMoney report, if no exists error, no way to silence error
        $rpt = Get-AzCostManagementExport -Name "AzSM-CostManagementExport" -Scope "subscriptions/$SubscriptionID"
        if ($rpt.Name.Length -gt 1) {
            Write-Host "Report already exists at: https://portal.azure.com/#blade/Microsoft_Azure_CostManagement/Menu/overview"
        } else {
            Write-Host "Creating report export, AzSM-CostManagementExport @ $StorageAccountName"
            New-AzCostManagementExport -Scope "subscriptions/$SubscriptionID" -Name "AzSM-CostManagementExport" -ScheduleStatus "Active" -ScheduleRecurrence "Daily" -RecurrencePeriodFrom $StartDate -RecurrencePeriodTo $EndDate -Format "Csv" -DestinationResourceId "/subscriptions/$SubscriptionID/resourceGroups/$StorageAccountResourceGroupName/providers/Microsoft.Storage/storageAccounts/$StorageAccountName" -DestinationContainer "azsmcostexports" -DestinationRootFolderPath "Reports" -DefinitionType "Usage" -DefinitionTimeframe "MonthToDate" -DatasetGranularity "Daily"
        }
        
    }
    catch {
        #Create a report export if none exist
        Write-Host "Creating report export, AzSM-CostManagementExport @ $StorageAccountName"
        New-AzCostManagementExport -Scope "subscriptions/$SubscriptionID" -Name "AzSM-CostManagementExport" -ScheduleStatus "Active" -ScheduleRecurrence "Daily" -RecurrencePeriodFrom $StartDate -RecurrencePeriodTo $EndDate -Format "Csv" -DestinationResourceId "/subscriptions/$SubscriptionID/resourceGroups/$StorageAccountResourceGroupName/providers/Microsoft.Storage/storageAccounts/$StorageAccountName" -DestinationContainer "azsmcostexports" -DestinationRootFolderPath "Reports" -DefinitionType "Usage" -DefinitionTimeframe "MonthToDate" -DatasetGranularity "Daily"
    }

    #Run a report export
    Invoke-AzCostManagementExecuteExport -ExportName "AzSM-CostManagementExport" -Scope "subscriptions/$SubscriptionID"
    
    #Find the latest report export
    

    
}