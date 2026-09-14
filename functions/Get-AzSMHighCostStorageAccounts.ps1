function global:Get-AzSMHighCostStorageAccounts {

    <#
        .SYNOPSIS
        List Storage Accounts with Hierarchical namespace or SFTP enabled in a subscription.
        .DESCRIPTION
        List Storage Accounts with Hierarchical namespace or SFTP enabled in a subscription or a single resource group.
        Storage Accounts with these features enabled cost more than regular Storage Accounts.
        .PARAMETER SubscriptionID
        Azure subscription ID in the format, 00000000-0000-0000-0000-000000000000
        .PARAMETER ResourceGroupName
        A single Azure resource group name to scope query to
        .OUTPUTS
        Microsoft.Azure.Commands.Management.Storage.Models.PSStorageAccount
        .EXAMPLE
        Get-AzSMHighCostStorageAccounts -SubscriptionID 00000000-0000-0000-0000-000000000000
        Get a list of Storage Accounts with Hierarchical namespace or SFTP enabled in a subscription.
        .EXAMPLE
        Get-AzSMHighCostStorageAccounts -SubscriptionID 00000000-0000-0000-0000-000000000000 -ResourceGroupName MyResourceGroup
        Get a list of Storage Accounts with Hierarchical namespace or SFTP enabled in a single resource group.
        .EXAMPLE
        Get-AzSMHighCostStorageAccounts -SubscriptionID 00000000-0000-0000-0000-000000000000 | Where-Object {$_.EnableSftp} | Set-AzStorageAccount -EnableSftp $false
        Disable SFTP on Storage Accounts in a subscription that have SFTP enabled.
        .NOTES
        * CAN be piped to Set-AzStorageAccount to disable SFTP.
        * Hierarchical namespace cannot be disabled after it is enabled, the data must be moved to a new Storage Account.
        * Storage Accounts are not unused, do not pipe to Remove-AzStorageAccount unless the data is no longer needed.
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

    if ($ResourceGroupName.Length -gt 0) {
      $storage=Get-AzStorageAccount -ResourceGroupName $ResourceGroupName|Where-Object{$_.EnableHierarchicalNamespace -eq $true -or $_.EnableSftp -eq $true}
    } else {
      $storage=Get-AzStorageAccount|Where-Object{$_.EnableHierarchicalNamespace -eq $true -or $_.EnableSftp -eq $true}
    }

    Return $storage
}
Export-ModuleMember -Function Get-AzSMHighCostStorageAccounts
