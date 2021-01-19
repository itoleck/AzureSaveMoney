function global:Get-AzSMDisabledTrafficManagerProfiles {

    <#
        .SYNOPSIS
        List disabled TrafficManager Profiles in a subscription.
        .DESCRIPTION
        List disabled TrafficManager Profiles in a subscription.
        .PARAMETER SubscriptionID
        Azure subscription ID in the format, 00000000-0000-0000-0000-000000000000
        .PARAMETER ResourceGroupName
        A single Azure resource group name to scope query to
        .OUTPUTS
        Microsoft.Azure.Commands.TrafficManager.Models.TrafficManagerProfile
        .EXAMPLE
        Get-AzSMDisabledTrafficManagerProfiles -SubscriptionID 00000000-0000-0000-0000-000000000000
        .NOTES
        * CAN be piped to Remove-AzTrafficManagerProfile.
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
    Write-Debug ('Subscription ID: {0}' -f $SubscriptionID)
  
    if ($ResourceGroupName.Length -gt 0) {
      $dtmpro=Get-AzTrafficManagerProfile -ResourceGroupName $ResourceGroupName|Where-Object{$_.ProfileStatus -eq 'Disabled'}
    } else {
      $dtmpro=Get-AzTrafficManagerProfile|Where-Object{$_.ProfileStatus -eq 'Disabled'}
    }

    Return $dtmpro
  }

Export-ModuleMember -Function Get-AzSMDisabledTrafficManagerProfiles