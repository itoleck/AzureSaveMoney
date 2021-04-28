function global:Get-AzSMDisabledLogicApps {

    <#
        .SYNOPSIS
        List disabled Logic Apps in a subscription.
        .DESCRIPTION
        List disabled Logic Apps in a subscription.
        .PARAMETER SubscriptionID
        Azure subscription ID in the format, 00000000-0000-0000-0000-000000000000
        .PARAMETER ResourceGroupName
        A single Azure resource group name to scope query to
        .OUTPUTS
        Microsoft.Azure.Management.Logic.Models.Workflow
        .EXAMPLE
        Get-AzSMDisabledLogicApps -SubscriptionID 00000000-0000-0000-0000-000000000000
        .NOTES
        * CANNOT pipe to Remove- command. Output is text based only.
        .LINK
    #>
  
    [CmdletBinding(
        DefaultParameterSetName='SubscriptionID',
        ConfirmImpact='Low'
    )]
  
    param(
      [Parameter(Mandatory=$true)][string] $SubscriptionID,
      [Parameter(Mandatory=$false)][string] $ResourceGroupName
    )
  
    $null = Set-AzContext -SubscriptionId $SubscriptionID
    Write-Debug ('Subscription ID: {0}' -f $SubscriptionID)
  
    $disabledlapps = New-Object System.Collections.ArrayList

    if ($ResourceGroupName.Length -gt 0) {
      $rgs=Get-AzResourceGroup -Name $ResourceGroupName
    } else {
      $rgs=Get-AzResourceGroup
    }

    $rgs|ForEach-Object {
      $lapps=Get-AzResource -ResourceGroupName $_.ResourceGroupName -ResourceType 'Microsoft.Logic/workflows'
      $lapps|ForEach-Object {
        $lapp=Get-AzLogicApp -ResourceGroupName $_.ResourceGroupName -Name $_.Name|Where-Object{$_.State -eq 'Disabled'}
        $null = $disabledlapps.add($lapp)
      }
    }
      Return $disabledlapps
  }
  Export-ModuleMember -Function Get-AzSMDisabledLogicApps