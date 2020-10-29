function global:Get-AzSMAppServicePlanScaleinfo {

    <#
        .SYNOPSIS
        List all App Service Plan scaling recommendations for a subscription.
        .DESCRIPTION
        List all App Service Plan scaling recommendations for a subscription.
        .PARAMETER SubscriptionID
        Azure subscription ID in the format, 00000000-0000-0000-0000-000000000000
        .OUTPUTS
        String recommendations.
        .EXAMPLE
        Get-AzSMAppServicePlanScaleinfo -Subscription 00000000-0000-0000-0000-000000000000
        APPPLANNAME - Low average CPU usage detected (8.00125)%. Scale down VM size.
        APPPLANNAME - Average CPU usage normal (64.4690909090909)%. Stay at current VM size.
        APPPLANNAME - High average CPU use detected (84.2233333333333)%. Scale up VM size.
        APPPLANNAME - No CPU data found. VM not running?
        .NOTES
        * CANNOT be piped to any Remove- Azure command.
        High CPU uasage is > 80%
        Low CPU usage is < 20%
        Normal CPU usage is 20% - 79%
        .LINK
    #>
  
    [CmdletBinding(
        DefaultParameterSetName='SubscriptionID',
        ConfirmImpact='Low'
    )]
  
    param(
      [Parameter(Mandatory=$true)][string] $SubscriptionID
    )
  
    $null = Set-AzContext -SubscriptionId $SubscriptionID
    Write-Debug ('Subscription ID: {0}' -f $SubscriptionID)
    
    $rgs=Get-AzResourceGroup
    foreach ($r in $rgs)
    {
      $vms=Get-AzAppServicePlan -ResourceGroupName $r.ResourceGroupName
      
      foreach ($vm in $vms) {
      
        $met=Get-AzMetric -ResourceId $vm.Id -WarningAction SilentlyContinue
        $avg=$met.Data|Where-Object {$_.Average -gt 0}|Select-Object Average
  
        foreach ($a in $avg) {
          $t=$t+$a.Average
        }
        try {
          $cputimeavg=$t/$avg.Count
        } catch {}
        
  
  
        if ($avg.Count -lt 5) {
          $vmusage = 0
        } else {
          try{
            $vmusage=($avg.Average |Measure-Object -Average).Average
          }catch{}
          
        }
  
  
        if ($null -eq $vmusage -or $vmusage -eq 0){Write-Output ('{0} - Not enough CPU usage data. Is app not running or just started?' -f $vm.Name)} else {
          if ($vmusage -gt 79) {
            Write-Output ('{1} - High average CPU use detected ({0})%. Scale up App Service Plan size.' -f $vmusage,$vm.Name)
          } else {
            if ($vmusage -lt 20) {
              Write-Output ('{1} - Low average CPU usage detected ({0})%. Scale down App Service Plan size.' -f $vmusage,$vm.Name)
            } else {
              Write-Output ('{1} - Average CPU usage normal ({0})%. Stay at current App Service Plan size.' -f $vmusage,$vm.Name)
            }
          }
        }
      }
    }
  }
  Export-ModuleMember -Function Get-AzSMAppServicePlanScaleinfo