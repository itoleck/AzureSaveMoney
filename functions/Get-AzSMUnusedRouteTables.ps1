function global:Get-AzSMUnusedRouteTables {

    <#
        .SYNOPSIS
        List unused route tables in a subscription.
        .DESCRIPTION
        List unused route tables in a subscription.
        .PARAMETER SubscriptionID
        Azure subscription ID in the format, 00000000-0000-0000-0000-000000000000
        .PARAMETER ResourceGroupName
        A single Azure resource group name to scope query to
        .OUTPUTS
        Microsoft.Azure.Commands.Network.Models.PSRouteTable
        .EXAMPLE
        Get-AzSMUnusedRouteTables -SubscriptionID 00000000-0000-0000-0000-000000000000
        .NOTES
        * CAN be piped to Remove-AzRouteTable.
        .LINK
    #>
  
    [CmdletBinding(
        DefaultParameterSetName='SubscriptionID',
        ConfirmImpact='Low'
    )]
  
    param(
      [Parameter(Mandatory=$true)][string] $SubscriptionID,
      [Parameter(Mandatory=$true)][string] $ResourceGroupName
    )
  
    $null = Set-AzContext -SubscriptionId $SubscriptionID
    Write-Debug ('Subscription: {0}' -f $SubscriptionID)
  
    if ($ResourceGroupName.Length -gt 0) {
      $routes=Get-AzRouteTable -ResourceGroupName $ResourceGroupName
    } else {
      $routes=Get-AzRouteTable
    }

    $routelist = New-Object System.Collections.ArrayList
    
    foreach ($route in $routes)
      {
        if ($route.Subnets.Count -eq 0) {
          $null = $routelist.add($route)
        }
      }
  
      Return $routelist
}
Export-ModuleMember -Function Get-AzSMUnusedRouteTables