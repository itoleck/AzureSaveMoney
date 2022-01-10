function global:Get-AzSMVMScaleinfo {

    <#
        .SYNOPSIS
        List all Virtual Machine scaling recommendations for a subscription.
        .DESCRIPTION
        List all Virtual Machine scaling recommendations for a subscription.
        .PARAMETER SubscriptionID
        Azure subscription ID in the format, 00000000-0000-0000-0000-000000000000
        .PARAMETER ResourceGroupName
        A single Azure resource group name to scope query to
        .PARAMETER TimeframeHours
        An integer in hours to go back in time for metrics (e.g 24 = 1 day)
        Default 24 hours
        .OUTPUTS
        String recommendations.
        .EXAMPLE
        Get-AzSMVMScaleinfo -Subscription 00000000-0000-0000-0000-000000000000 -TimeframeHours 48
        VMNAME - Low average CPU usage detected (8.00125)%. Scale down VM size.
        VMNAME - Average CPU usage normal (64.4690909090909)%. Stay at current VM size.
        VMNAME - High average CPU use detected (84.2233333333333)%. Scale up VM size.
        VMNAME - No CPU data found. VM not running?
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
      [Parameter(Mandatory=$true)][string] $SubscriptionID,
      [Parameter(Mandatory=$false)][string] $ResourceGroupName,
      [Parameter(Mandatory=$false)][int] $TimeframeHours = 24
    )
  
    $null = Set-AzContext -SubscriptionId $SubscriptionID
    Write-Debug ('Subscription ID: {0}' -f $SubscriptionID)
    
    $time_back = (Get-Date).AddHours(-$TimeframeHours)
    
    $grain = "00:01:00"
    if ($TimeframeHours -gt 24) {
      $grain = "00:05:00"
    }

    if ($ResourceGroupName.Length -gt 0) {
      $rgs=Get-AzResourceGroup -Name $ResourceGroupName
    } else {
      $rgs=Get-AzResourceGroup
    }

    foreach ($r in $rgs)
    {
      $vms=get-azvm -ResourceGroupName $r.ResourceGroupName
      
      foreach ($vm in $vms) {
      
        $met=Get-AzMetric -ResourceId $vm.Id -MetricName "Percentage CPU" -TimeGrain $grain -EndTime (Get-Date) -StartTime $time_back -AggregationType Average -WarningAction SilentlyContinue
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
  
  
        if ($null -eq $vmusage -or $vmusage -eq 0){Write-Output ('{0} - Not enough CPU usage data. Is VM not running or just started?' -f $vm.Name)} else {
          if ($vmusage -gt 79) {
            Write-Output ('{1} - High average CPU use detected ({0})%. Scale up VM size.' -f $vmusage,$vm.Name)
          } else {
            if ($vmusage -lt 20) {
              Write-Output ('{1} - Low average CPU usage detected ({0})%. Scale down VM size.' -f $vmusage,$vm.Name)
            } else {
              Write-Output ('{1} - Average CPU usage normal ({0})%. Stay at current VM size.' -f $vmusage,$vm.Name)
            }
          }
        }
      }
    }
}
Export-ModuleMember -Function Get-AzSMVMScaleinfo