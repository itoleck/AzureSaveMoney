function global:Get-AzSMUnusedPIPs {

    <#
        .SYNOPSIS
        Lists unused Public IPs in a subscription.
        .DESCRIPTION
        Lists unused Public IPs in a subscription.
        .PARAMETER SubscriptionID
        Azure subscription ID in the format, 00000000-0000-0000-0000-000000000000
        .PARAMETER ResourceGroupName
        A single Azure resource group name to scope query to
        .OUTPUTS
        Microsoft.Azure.Commands.Network.Models.PSPublicIpAddress
        .EXAMPLE
        Get-AzSMUnusedPIPs -Subscription 00000000-0000-0000-0000-000000000000
        Gets a list of unused public IP addresses in a subscription.
        .EXAMPLE
        Get-AzSMUnusedPIPs -Subscription 00000000-0000-0000-0000-000000000000 | Remove-AzPublicIpAddress
        Remove unused public IP addresses in a subscription with confirmation.
        .EXAMPLE
        Get-AzSMUnusedPIPs -Subscription 00000000-0000-0000-0000-000000000000 | Remove-AzPublicIpAddress -force
        Remove unused public IP addresses in a subscription without confirmation.
        .NOTES
        * CAN be piped to Remove-AzPublicIpAddress.
        * When piping to remove resources, include the -force parameter to supress prompts.
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
  
    if ($ResourceGroupName.Length -gt 0) {
      $pip=Get-AzPublicIpAddress -ResourceGroupName $ResourceGroupName|Where-Object{!$_.IpConfiguration}
    } else {
      $pip=Get-AzPublicIpAddress|Where-Object{!$_.IpConfiguration}
    }

    Return $pip
}
Export-ModuleMember -Function Get-AzSMUnusedPIPs