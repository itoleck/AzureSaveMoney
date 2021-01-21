function global:Get-AzSMDisabledAlerts {

    <#
        .SYNOPSIS
        Lists disabled "classic" alerts in a subscription.
        .DESCRIPTION
        Lists disabled "classic" alerts in a subscription.
        .PARAMETER SubscriptionID
        Azure subscription ID in the format, 00000000-0000-0000-0000-000000000000
        .PARAMETER ResourceGroupName
        A single Azure resource group name to scope query to
        .OUTPUTS
        AzureSaveMoney.MyRGandName
        .EXAMPLE
        Get-AzSMDisabledAlerts -Subscription 00000000-0000-0000-0000-000000000000
        Get a list of disabled classic alerts in a subscription.
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
      [Parameter(Mandatory=$false)][string] $ResourceGroupName
    )
  
      $null = Set-AzContext -SubscriptionId $SubscriptionID
    Write-Debug ('Subscription: {0}' -f $SubscriptionID)
  
    $alerts = New-Object System.Collections.ArrayList
    
    if ($ResourceGroupName.Length -gt 0) {
      $rgs=Get-AzResourceGroup -Name $ResourceGroupName
    } else {
      $rgs=Get-AzResourceGroup
    }    
    
    foreach ($r in $rgs)
    {
      $a=Get-AzAlertRule -ResourceGroupName $r.ResourceGroupName -WarningAction Ignore|Where-Object{$_.IsEnabled -eq $false}
      
      if ($a.IsEnabled -eq $false) {
        $al=New-Object MyRGandName
        $al.RG=$r.ResourceGroupName
        $al.Name=$a.Name
        $null = $alerts.Add($al)
      }
    }
    Return $alerts
 }
 Export-ModuleMember -Function Get-AzSMDisabledAlerts