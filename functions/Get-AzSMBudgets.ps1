function global:Get-AzSMBudgets {

    <#
        .SYNOPSIS
        Reports the cost budgets in a subscription.
        .DESCRIPTION
        Reports the cost budgets in a subscription.
        .PARAMETER SubscriptionID
        Azure subscription ID in the format, 00000000-0000-0000-0000-000000000000
        .OUTPUTS
        
        .EXAMPLE
        Get-AzSMBudgets -Subscription 00000000-0000-0000-0000-000000000000
        Reports the cost budgets in a subscription.
        .NOTES
        * CANNOT pipe to Remove- command. Output is text based only.
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

    return $budgets
}