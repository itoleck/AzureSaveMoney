function global:Get-AzSMIlbNoBackendPoolVMs {

    <#
        .SYNOPSIS
        List Internal load balancers that have no backend pool virtual machines in a subscription.
        .DESCRIPTION
        List Internal load balancers that have no backend pool virtual machines in a subscription.
        .PARAMETER SubscriptionID
        Azure subscription ID in the format, 00000000-0000-0000-0000-000000000000
        .OUTPUTS
        Microsoft.Azure.Commands.Network.Models.PSLoadBalancer
        .EXAMPLE
        Get-AzSMIlbNoBackendPoolVMs -SubscriptionID 00000000-0000-0000-0000-000000000000
        .NOTES
        * CAN be piped to Remove-AzLoadBalancer.
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
  
      
      $lbs=Get-AzLoadBalancer -WarningAction Ignore|Where-Object{$null -eq $_.BackendAddressPools.BackendIpConfigurations}
  
      Return $lbs
  }
  Export-ModuleMember -Function Get-AzSMIlbNoBackendPoolVMs