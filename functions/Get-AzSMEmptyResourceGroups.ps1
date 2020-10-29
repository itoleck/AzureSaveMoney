function global:Get-AzSMEmptyResourceGroups {

    <#
        .SYNOPSIS
        Lists empty resource groups in a subscription.
        .DESCRIPTION
        Lists empty resource groups in a subscription.
        .PARAMETER SubscriptionID
        Azure subscription ID in the format, 00000000-0000-0000-0000-000000000000
        .OUTPUTS
        Microsoft.Azure.Commands.ResourceManager.Cmdlets.SdkModels.PSResourceGroup
        .EXAMPLE
        Get-AzSMEmptyResourceGroups -SubscriptionID 00000000-0000-0000-0000-000000000000
        Get a list of empty Resource Groups in a subscription with confirmation.
        .EXAMPLE
        Get-AzSMEmptyResourceGroups -SubscriptionID 00000000-0000-0000-0000-000000000000 -force
        Get a list of empty Resource Groups in a subscription without confirmation.
        .NOTES
        * CAN be piped to Remove-AzResourceGroup.
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
  
    $emptyrgs = New-Object System.Collections.ArrayList
    $rgs=Get-AzResourceGroup
  
    $rgs|ForEach-Object {
      $rgd=Get-AzResource -ResourceGroupName $_.ResourceGroupName -WarningAction SilentlyContinue -ErrorAction SilentlyContinue -ErrorVariable $rgerr
      if (!$rgd -and $null -eq $rgerr) {
        $null = $emptyrgs.add($_)
      }
    }
      Return $emptyrgs
 }
 Export-ModuleMember -Function Get-AzSMEmptyResourceGroups