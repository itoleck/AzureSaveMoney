function global:Get-AzSMSavingPlans {

    <#
        .SYNOPSIS
        Reports the savings plans in a subscription.
        .DESCRIPTION
        Reports the savings plans in a subscription.
        .PARAMETER SubscriptionID
        Azure subscription ID in the format, 00000000-0000-0000-0000-000000000000
        .OUTPUTS
        
        .EXAMPLE
        Get-AzSMSavingPlans -Subscription 00000000-0000-0000-0000-000000000000
        Reports the savings plans in a subscription.
        .NOTES
        * CANNOT pipe to Remove- command. Output is text based only.
        .LINK
    #>
  
    [CmdletBinding(
        DefaultParameterSetName='SubscriptionID',
        ConfirmImpact='low'
    )]

    param(
        [Parameter(Mandatory=$true)][string] $SubscriptionID,
        [Parameter(Mandatory=$true)][string] $ResourceGroupName,
        [Parameter(Mandatory=$true)][string] $ReservationGroupName
      )
    
    $null = Set-AzContext -SubscriptionId $SubscriptionID
    Write-Debug ('Subscription: {0}' -f $SubscriptionID)

    $savingplans = "Currently not available"

    return $savingplans
}