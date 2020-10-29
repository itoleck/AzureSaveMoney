function global:Get-AzSMDisabledTrafficManagerProfiles {

    <#
        .SYNOPSIS
        List disabled TrafficManager Profiles in a subscription.
        .DESCRIPTION
        List disabled TrafficManager Profiles in a subscription.
        .PARAMETER SubscriptionID
        Azure subscription ID in the format, 00000000-0000-0000-0000-000000000000
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
      [Parameter(Mandatory=$true)][string] $SubscriptionID
    )
  
      $null = Set-AzContext -SubscriptionId $SubscriptionID
    Write-Debug ('Subscription ID: {0}' -f $SubscriptionID)
  
      $dtmpro=Get-AzTrafficManagerProfile|Where-Object{$_.ProfileStatus -eq 'Disabled'}
  
      Return $dtmpro
  }function global:Get-AzSMDisabledTrafficManagerProfiles {

  <#
      .SYNOPSIS
      List disabled TrafficManager Profiles in a subscription.
      .DESCRIPTION
      List disabled TrafficManager Profiles in a subscription.
      .PARAMETER SubscriptionID
      Azure subscription ID in the format, 00000000-0000-0000-0000-000000000000
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
    [Parameter(Mandatory=$true)][string] $SubscriptionID
  )

    $null = Set-AzContext -SubscriptionId $SubscriptionID
  Write-Debug ('Subscription ID: {0}' -f $SubscriptionID)

    $dtmpro=Get-AzTrafficManagerProfile|Where-Object{$_.ProfileStatus -eq 'Disabled'}

    Return $dtmpro
}
Export-ModuleMember -Function Get-AzSMDisabledTrafficManagerProfiles