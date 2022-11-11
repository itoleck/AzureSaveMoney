function global:Get-AzSMReservations {

    <#
        .SYNOPSIS
        Reports the reserations in a subscription.
        .DESCRIPTION
        Reports the reserations in a subscription.
        .PARAMETER SubscriptionID
        Azure subscription ID in the format, 00000000-0000-0000-0000-000000000000
        .OUTPUTS
        
        .EXAMPLE
        Get-AzSMReserations -Subscription 00000000-0000-0000-0000-000000000000
        Reports the reserations in a subscription.
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

    $reserations = Get-AzCapacityReservation -ResourceGroupName $ResourceGroupName -ReservationGroupName $ReservationGroupName

    return $reserations
}