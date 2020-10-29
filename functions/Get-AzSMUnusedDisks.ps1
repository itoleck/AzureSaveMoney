function global:Get-AzSMUnusedDisks {

    <#
        .SYNOPSIS
        List unused managed disks in a subscription.
        .DESCRIPTION
        List unused managed disks in a subscription.
        .PARAMETER SubscriptionID
        Azure subscription ID in the format, 00000000-0000-0000-0000-000000000000
        .OUTPUTS
        Microsoft.Azure.Commands.Compute.Automation.Models.PSDiskList
        .EXAMPLE
        Get-AzSMUnusedDisks -SubscriptionID 00000000-0000-0000-0000-000000000000
        .NOTES
        * CAN be piped to Remove-AzDisk.
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
  
    $disks = Get-AzDisk|Where-Object{$_.ManagedBy.Length -lt 1}
  
      Return $disks
  }
  Export-ModuleMember -Function Get-AzSMUnusedDisks