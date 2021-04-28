function global:Get-AzSMEmptyNotificationHubNamespaces {

    <#
        .SYNOPSIS
        Lists NotificationHubsNamespaces with no NotificationHub in a subscription.
        .DESCRIPTION
        Lists NotificationHubsNamespaces with no NotificationHub in a subscription.
        .PARAMETER SubscriptionID
        Azure subscription ID in the format, 00000000-0000-0000-0000-000000000000
        .OUTPUTS
        Microsoft.Azure.Commands.NotificationHubs.Models.NamespaceAttributes
        .EXAMPLE
        Get-AzSMEmptyNotificationHubNamespaces -Subscription 00000000-0000-0000-0000-000000000000
        Get a list of NotificationHubsNamespaces with no NotificationHub in a subscription.
        .EXAMPLE
        .
        .NOTES
        * CANNOT be piped to Remove-AzSMEmptyNotificationHubNamespaces as the cmdlet does not take pipeline input.
        .LINK
    #>

    [CmdletBinding(
        DefaultParameterSetName = 'SubscriptionID',
        ConfirmImpact = 'low'
    )]

    param(
        [Parameter(Mandatory = $true)][string] $SubscriptionID,
        [Parameter(Mandatory=$false)][string] $ResourceGroupName
    )

    $null = Set-AzContext -SubscriptionId $SubscriptionID
    Write-Debug ('Subscription: {0}' -f $SubscriptionID)

    if ($ResourceGroupName.Length -gt 0) {
        foreach ($NotificationHubNamespace in Get-AzNotificationHubsNamespace -ResourceGroup $ResourceGroupName) {
            $GetAzResourceParameters = @{
                ResourceType      = 'Microsoft.NotificationHubs/namespaces/notificationHubs'
                ResourceGroupName = $NotificationHubNamespace.ResourceGroupName
                ResourceName      = $NotificationHubNamespace.Name
                ApiVersion        = '2017-04-01'
                ErrorAction       = 'SilentlyContinue'
            }
            $NotificationHub = Get-AzResource @GetAzResourceParameters
            if (!$NotificationHub) {
                $NotificationHubNamespace
            }
        }
    } else {
        foreach ($NotificationHubNamespace in Get-AzNotificationHubsNamespace) {
            $GetAzResourceParameters = @{
                ResourceType      = 'Microsoft.NotificationHubs/namespaces/notificationHubs'
                ResourceGroupName = $NotificationHubNamespace.ResourceGroupName
                ResourceName      = $NotificationHubNamespace.Name
                ApiVersion        = '2017-04-01'
                ErrorAction       = 'SilentlyContinue'
            }
            $NotificationHub = Get-AzResource @GetAzResourceParameters
            if (!$NotificationHub) {
                $NotificationHubNamespace
            }
        }
    }

}

Export-ModuleMember -Function Get-AzSMEmptyNotificationHubNamespaces
