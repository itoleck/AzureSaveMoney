function global:Get-AzSMOldDeployments {

    <#
        .SYNOPSIS
        List deployments older than 365 days in a subscription.
        .DESCRIPTION
        List deployments older than 365 days in a subscription.
        .PARAMETER SubscriptionID
        Azure subscription ID in the format, 00000000-0000-0000-0000-000000000000
        .PARAMETER ResourceGroupName
        A single Azure resource group name to scope query to
        .PARAMETER Days
          Set to the number of days to scan back for old deployments.
          Default is 365 days old.
        .OUTPUTS
        Microsoft.Azure.Commands.ResourceManager.Cmdlets.SdkModels.PSResourceGroupDeployment
        .EXAMPLE
        Get-AzSMOldDeployments -SubscriptionID 00000000-0000-0000-0000-000000000000
        .NOTES
        * CAN be piped to Remove-AzResourceGroupDeployment.
        .LINK
    #>
  
    [CmdletBinding(
        DefaultParameterSetName='SubscriptionID',
        ConfirmImpact='Low'
    )]
  
    param(
      [Parameter(Mandatory=$true)][string] $SubscriptionID,
      [Parameter(Mandatory=$true)][string] $ResourceGroupName,
      [int] $Days = 365
    )
  
    $null = Set-AzContext -SubscriptionId $SubscriptionID
    Write-Debug ('Subscription: {0}' -f $SubscriptionID)

    if ($ResourceGroupName.Length -gt 0) {
      $rgs=Get-AzResourceGroup -Name $ResourceGroupName
    } else {
      $rgs=Get-AzResourceGroup
    }

    $rgd=$rgs|Get-AzResourceGroupDeployment|Where-Object{$_.Timestamp -lt (Get-Date).AddDays(-$Days)}
    
    Return $rgd
}
Export-ModuleMember -Function Get-AzSMOldDeployments