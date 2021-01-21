function global:Get-AzSMVNetsWithoutSubnets {

    <#
        .SYNOPSIS
        List VNets without any subnets defined in a subscription.
        .DESCRIPTION
        List VNets without any subnets defined in a subscription.
        .PARAMETER SubscriptionID
        Azure subscription ID in the format, 00000000-0000-0000-0000-000000000000
        .PARAMETER ResourceGroupName
        A single Azure resource group name to scope query to
        .OUTPUTS
        Microsoft.Azure.Commands.Network.Models.PSVirtualNetwork
        .EXAMPLE
        Get-AzSMVNetsWithoutSubnets -SubscriptionID 00000000-0000-0000-0000-000000000000
        .NOTES
        * CAN be piped to Remove-AzVirtualNetwork
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
  
    if ($ResourceGroupName.Length -gt 0) {
      $vnets=Get-AzVirtualNetwork -ResourceGroupName $ResourceGroupName
    } else {
      $vnets=Get-AzVirtualNetwork
    }

    $emptysubnets=New-Object System.Collections.ArrayList
    
    foreach ($vnet in $vnets) {
      if ($vnet.Subnets.Count -eq 0) {
        $null = $emptysubnets.add($vnet)
      }
    }
  
      Return $emptysubnets
}
Export-ModuleMember -Function Get-AzSMVNetsWithoutSubnets