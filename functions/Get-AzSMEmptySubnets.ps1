function global:Get-AzSMEmptySubnets {

    <#
        .SYNOPSIS
        Lists empty subnets in a subscription.
        .DESCRIPTION
        Lists empty subnets in a subscription.
        .PARAMETER SubscriptionID
        Azure subscription ID in the format, 00000000-0000-0000-0000-000000000000
        .OUTPUTS
        Selected.Microsoft.Azure.Commands.Network.Models.PSVirtualNetwork
        .EXAMPLE
        Get-AzSMEmptySubnets -Subscription 00000000-0000-0000-0000-000000000000
        Get a list of unused subnets in a subscription.
        .EXAMPLE
        *
        .NOTES
        *
        *
        .LINK
    #>
  
    [CmdletBinding(
        DefaultParameterSetName='SubscriptionID',
        ConfirmImpact='low'
    )]
  
    param(
      [Parameter(Mandatory=$true)][string] $SubscriptionID
    )
  
      $null = Set-AzContext -SubscriptionId $SubscriptionID
    Write-Debug ('Subscription: {0}' -f $SubscriptionID)
  
    $vn=Get-AzVirtualNetwork
    $emptysubnets=$vn|Where-Object{$_.Subnets.IpConfigurations.count -eq 0}|select-object @{n="VNet";e="Name"},Subnets
    
    Return $emptysubnets
 }
 Export-ModuleMember -Function Get-AzSMEmptySubnets