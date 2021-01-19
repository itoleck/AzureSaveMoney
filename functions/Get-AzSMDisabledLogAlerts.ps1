function global:Get-AzSMDisabledLogAlerts {

    <#
        .SYNOPSIS
        List disabled Activity Log alerts in a subscription.
        .DESCRIPTION
        List disabled Activity Log alerts in a subscription.
        .PARAMETER SubscriptionID
        Azure subscription ID in the format, 00000000-0000-0000-0000-000000000000
        .PARAMETER ResourceGroupName
        A single Azure resource group name to scope query to
        .OUTPUTS
        AzureSaveMoney.MyRGandName
        .EXAMPLE
        Get-AzSMDisabledLogAlerts -Subscription 00000000-0000-0000-0000-000000000000
        Get a list of disabled Activity Log alerts in a subscription.
        .NOTES
        * CANNOT pipe to Remove- command. Output is text based only.
        .LINK
    #>
  
    [CmdletBinding(
        DefaultParameterSetName='SubscriptionID',
        ConfirmImpact='Low'
    )]
  
    param(
      [Parameter(Mandatory=$true)][string] $SubscriptionID,
      [Parameter(Mandatory=$true)][string] $ResourceGroupName
    )
  
    $null = Set-AzContext -SubscriptionId $SubscriptionID
    Write-Debug ('Subscription: {0}' -f $SubscriptionID)
  
    $logalerts = New-Object System.Collections.ArrayList
    
    if ($ResourceGroupName.Length -gt 0) {
      $rgs=Get-AzResourceGroup -Name $ResourceGroupName
    } else {
      $rgs=Get-AzResourceGroup
    }
    
    foreach ($r in $rgs)
    {
      $a=Get-AzActivityLogAlert -ResourceGroupName $r.ResourceGroupName -WarningAction Ignore -ErrorAction Ignore|Where-Object{$_.Enabled -eq $false}
  
      if ($a.Enabled -eq $false){
        $al=New-Object MyRGandName
        $al.RG=$r.ResourceGroupName
        $al.Name=$a.Name
        $null = $logalerts.Add($al)
      }
    }
      
    Return $logalerts
 }
 Export-ModuleMember -Function Get-AzSMDisabledLogAlerts