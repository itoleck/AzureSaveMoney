function global:Get-AzSMTrafficManagerProfilesWithNoEndpoints {

  <#
      .SYNOPSIS
      List TrafficManager Profiles without endpoints in a subscription.
      .DESCRIPTION
      List TrafficManager Profiles without endpoints in a subscription.
      .PARAMETER SubscriptionID
      Azure subscription ID in the format, 00000000-0000-0000-0000-000000000000
      .OUTPUTS
      Microsoft.Azure.Commands.TrafficManager.Models.TrafficManagerProfile
      .EXAMPLE
      Get-AzSMTrafficManagerProfilesWithNoEndpoints -SubscriptionID 00000000-0000-0000-0000-000000000000
      .NOTES
      * CAN be piped to Remove-AzTrafficManagerProfile.
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

    $dtmpro=Get-AzTrafficManagerProfile|Where-Object{$_.Endpoints.Count -lt 1}

    Return $dtmpro
}
Export-ModuleMember -Function Get-AzSMTrafficManagerProfilesWithNoEndpoints