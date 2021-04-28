function global:Get-AzSMUnconnectedVirtualNetworkGateways {

    <#
        .SYNOPSIS
        List Virtual Network Gateway Connections in states other than 'Connected' in a subscription.
        .DESCRIPTION
        List Virtual Network Gateway Connections in states other than 'Connected' in a subscription.
        .PARAMETER SubscriptionID
        Azure subscription ID in the format, 00000000-0000-0000-0000-000000000000
        .PARAMETER ResourceGroupName
        A single Azure resource group name to scope query to
        .OUTPUTS
        Microsoft.Azure.Commands.Network.Models.PSVirtualNetworkGatewayConnection
        .EXAMPLE
        Get-AzSMUnconnectedVirtualNetworkGateways -SubscriptionID 00000000-0000-0000-0000-000000000000
        .EXAMPLE
        Get-AzSMUnconnectedVirtualNetworkGateways -SubscriptionID 00000000-0000-0000-0000-000000000000|Remove-AzVirtualNetworkGatewayConnection
        .NOTES
        * CAN be piped to Remove-AzVirtualNetworkGatewayConnection but may show erroneous error. Use -ErrorAction SilentlyContinue to suppress error.
        "Remove-AzVirtualNetworkGatewayConnection : The input object cannot be bound to any parameters for the command either because the command does not take pipeline input or
        the input and its properties do not match any of the parameters that take pipeline input."
        .LINK
    #>
  
    [CmdletBinding(
        DefaultParameterSetName='SubscriptionID',
        ConfirmImpact='Low'
    )]
  
    param(
      [Parameter(Mandatory=$true)][string] $SubscriptionID,
      [Parameter(Mandatory=$false)][string] $ResourceGroupName
    )
  
    $null = Set-AzContext -SubscriptionId $SubscriptionID
    Write-Debug ('Subscription ID: {0}' -f $SubscriptionID)
  
    $vngwconns = New-Object System.Collections.ArrayList
    
    if ($ResourceGroupName.Length -gt 0) {
      $rgs=Get-AzResourceGroup -Name $ResourceGroupName
    } else {
      $rgs=Get-AzResourceGroup
    }

    $rgs|ForEach-Object {
  
      $rg=$_.ResourceGroupName
      $vngwconn=Get-AzVirtualNetworkGatewayConnection -ResourceGroupName $rg
  
      if ($vngwconn.name.Length -gt 0) {
        #$vngwconnname=$vngwconn.name
  
        $vngwconn|ForEach-Object {
          $vngwconn2=Get-AzVirtualNetworkGatewayConnection -ResourceGroupName $rg -Name $_.Name|Where-Object {$_.ConnectionStatus -ne 'Connected'}
          $null = $vngwconns.Add($vngwconn2)
  
        }
      }
    }
  
    Return $vngwconns
}
Export-ModuleMember -Function Get-AzSMUnconnectedVirtualNetworkGateways