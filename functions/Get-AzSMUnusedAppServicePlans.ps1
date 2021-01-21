function global:Get-AzSMUnusedAppServicePlans {

    <#
        .SYNOPSIS
        Lists unused App Service Plans in a subscription.
        .DESCRIPTION
        Lists unused App Service Plans in a subscription.
        .PARAMETER SubscriptionID
        Azure subscription ID in the format, 00000000-0000-0000-0000-000000000000
        .PARAMETER ResourceGroupName
        A single Azure resource group name to scope query to
        .OUTPUTS
        Microsoft.Azure.Commands.WebApps.Models.WebApp.PSAppServicePlan
        .EXAMPLE
        Get-AzSMUnusedAppServicePlans -Subscription 00000000-0000-0000-0000-000000000000
        Get a list of unused App Service Plans in a subscription.
        .EXAMPLE
        Get-AzSMUnusedAppServicePlans -Subscription 00000000-0000-0000-0000-000000000000 | Remove-AzAppServicePlan
        Remove unused App Service Plans in a subscription with confirmation.
        .EXAMPLE
        Get-AzSMUnusedAppServicePlans -Subscription 00000000-0000-0000-0000-000000000000 | Remove-AzAppServicePlan -force
        Remove unused App Service Plans in a subscription without confirmation.
        .NOTES
        * CAN be piped to Remove-AzAppServicePlan.
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
      $app=Get-AzAppServicePlan -ResourceGroupName $ResourceGroupName|Where-Object{$_.NumberOfSites -eq 0}
    } else {
      $app=Get-AzAppServicePlan|Where-Object{$_.NumberOfSites -eq 0}
    }

    Return $app
}
Export-ModuleMember -Function Get-AzSMUnusedAppServicePlans