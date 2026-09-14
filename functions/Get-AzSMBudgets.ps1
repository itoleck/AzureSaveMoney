function global:Get-AzSMBudgets {

    <#
        .SYNOPSIS
        Reports the cost budgets in a subscription.
        .DESCRIPTION
        Reports the cost budgets in a subscription and writes a warning when the subscription has no budgets set.
        .PARAMETER SubscriptionID
        Azure subscription ID in the format, 00000000-0000-0000-0000-000000000000
        .OUTPUTS
        Microsoft.Azure.Commands.Consumption.Models.PSBudget
        .EXAMPLE
        Get-AzSMBudgets -SubscriptionID 00000000-0000-0000-0000-000000000000
        Reports the cost budgets in a subscription.
        .EXAMPLE
        if (-not (Get-AzSMBudgets -SubscriptionID 00000000-0000-0000-0000-000000000000 -WarningAction SilentlyContinue)) {'No budgets set'}
        Check if a subscription has no budgets set.
        .NOTES
        * CANNOT pipe to Remove- command. Budgets are not unused resources.
        * Returns nothing and writes a warning when the subscription has no budgets set.
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

    $budgets = Get-AzConsumptionBudget

    if (-not $budgets) {
      Write-Warning ('No budgets are set in subscription {0}.' -f $SubscriptionID)
    }

    return $budgets
}
Export-ModuleMember -Function Get-AzSMBudgets
