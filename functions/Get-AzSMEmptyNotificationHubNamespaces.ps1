function global:Get-AzSMEmptyNotificationHubNamespaces {

    <#
        .SYNOPSIS
        Lists NotificationHubsNamespaces with no NotificationHub in a subscription.
        .DESCRIPTION
        Lists NotificationHubsNamespaces with no NotificationHub in a subscription.
        .PARAMETER SubscriptionID
        Azure subscription ID in the format, 00000000-0000-0000-0000-000000000000
        .OUTPUTS
        AzureSaveMoney.MyRGandName
        .EXAMPLE
        Get-AzSMEmptyNotificationHubNamespaces -Subscription 00000000-0000-0000-0000-000000000000
        Get a list of NotificationHubsNamespaces with no NotificationHub in a subscription.
        .EXAMPLE
        .
        .NOTES
        .
        .LINK
    #>

    [CmdletBinding(
        DefaultParameterSetName = 'SubscriptionID',
        ConfirmImpact = 'low'
    )]

    param(
        [Parameter(Mandatory = $true)][string] $SubscriptionID
    )

    $null = Set-AzContext -SubscriptionId $SubscriptionID
    Write-Debug ('Subscription: {0}' -f $SubscriptionID)

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

Export-ModuleMember -Function Get-AzSMEmptyNotificationHubNamespaces
