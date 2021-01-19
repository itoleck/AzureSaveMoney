function global:Get-AzSMUnusedAlertActionGroups {

    <#
        .SYNOPSIS
        Lists unused Alert Action Groups in a subscription.
        .DESCRIPTION
        Lists unused Alert Action Groups in a subscription.
        .PARAMETER SubscriptionID
        Azure subscription ID in the format, 00000000-0000-0000-0000-000000000000
        .PARAMETER ResourceGroupName
        A single Azure resource group name to scope query to
        .OUTPUTS
        Microsoft.Azure.Commands.Insights.OutputClasses.PSActionGroupResource
        .EXAMPLE
        Get-AzSMUnusedAlertActionGroups -SubscriptionID 00000000-0000-0000-0000-000000000000
        Remove Action Groups with confirmation.
        .EXAMPLE
        Get-AzSMUnusedAlertActionGroups -SubscriptionID 00000000-0000-0000-0000-000000000000 | Remove-AzActionGroup -force
        Remove Action Groups without confirmation.
        .NOTES
        * CAN be piped to Remove-AzActionGroup.
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
      $rgs=Get-AzResourceGroup -Name $ResourceGroupName
    } else {
      $rgs=Get-AzResourceGroup
    }

    $actiongroups2 = New-Object System.Collections.ArrayList

    foreach ($rg in $rgs) {
      $ags=Get-AzResource -ResourceGroupName $rg.ResourceGroupName -ResourceType microsoft.insights/actionGroups
      foreach ($a in $ags) {
        $TempHoldActionGroup=New-Object MyRGandName
        $TempHoldActionGroup.RG=$rg.ResourceGroupName
        $TempHoldActionGroup.Name=$a.Name
        if ($a.Name.Length -gt 0) {
          $null = $actiongroups2.Add($TempHoldActionGroup)
        }
      }
    }
      
    $actiongroups = New-Object System.Collections.ArrayList
    foreach ($rg in $rgs) {
      $ala=Get-AzActivityLogAlert -ResourceGroupName $rg.ResourceGroupName -WarningAction SilentlyContinue -ErrorAction SilentlyContinue -ErrorVariable $alerr
      if ($ala -and $alerr.count -lt 1) {
        foreach ($a in $ala) {
          $as=$a.Actions.ActionGroups[0].ActionGroupId.Split('/') #TODO: 'You cannot call a method on a null-valued expression.'
      
          $TempHoldActionGroup=New-Object MyRGandName
          $TempHoldActionGroup.RG=$rg.ResourceGroupName
          $TempHoldActionGroup.Name=$as.GetValue($as.Count -1)
      
          $null = $actiongroups.add($TempHoldActionGroup)
        }
      }
    }

    $unusedactiongroups=$actiongroups2|Where-Object{$actiongroups.Name -notcontains $_.Name}
  
    foreach ($alertactiongroup in $unusedactiongroups) {
      Get-AzActionGroup -ResourceGroupName $alertactiongroup.RG -Name $alertactiongroup.Name -WarningAction SilentlyContinue
    }
 }
 Export-ModuleMember -Function Get-AzSMUnusedAlertActionGroups