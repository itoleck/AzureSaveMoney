function global:Get-AzSMUnusedNICs {
    <#
        .SYNOPSIS
        Lists unused NICs in a subscription.
        .DESCRIPTION
        Lists unused NICs in a subscription.
        .PARAMETER SubscriptionID
        Azure subscription ID in the format, 00000000-0000-0000-0000-000000000000
        .OUTPUTS
        Microsoft.Azure.Commands.Network.Models.PSNetworkInterface
        .EXAMPLE
        Get-AzSMUnusedNICs -Subscription 00000000-0000-0000-0000-000000000000
        Get a list of unused network interfaces in a subscription.
        .EXAMPLE
        Get-AzSMUnusedNICs -Subscription 00000000-0000-0000-0000-000000000000 | Remove-AzNetworkInterface
        Remove unused network interfaces in a subscription with confirmation.
        .EXAMPLE
        Get-AzSMUnusedNICs -Subscription 00000000-0000-0000-0000-000000000000 | Remove-AzNetworkInterface -force
        Remove unused network interfaces in a subscription without confirmation.
        .NOTES
        * CAN be piped to Remove-AzNetworkInterface.
        * When piping to remove resources, include the -force parameter to supress prompts.
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
    Write-Debug ('Subscription: {0}' -f $SubscriptionID)
  
    $nics=Get-AzNetworkInterface|Where-Object{!$_.VirtualMachine}
      
      Return $nics
  }
  Export-ModuleMember -Function Get-AzSMUnusedNICs