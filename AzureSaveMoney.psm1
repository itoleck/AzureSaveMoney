#requires -Version 5.0 -Modules Az.Accounts, Az.Automation, Az.Compute, Az.LogicApp, Az.Network, Az.Resources, Az.TrafficManager, AzureAD
#!/usr/bin/env powershell
# Contributors:
# Chad Schultz
#
# PowerShell module to List on and delete unused Azure resources and save money.
#
# This Sample Code is provided for the purpose of illustration only and is not intended to be used in a production environment.  THIS SAMPLE CODE AND ANY RELATED INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.  We grant You a nonexclusive, royalty-free right to use and modify the Sample Code and to reproduce and distribute the object code form of the Sample Code, provided that You agree: (i) to not use Our name, logo, or trademarks to market Your software product in which the Sample Code is embedded; (ii) to include a valid copyright notice on Your software product in which the Sample Code is embedded; and (iii) to indemnify, hold harmless, and defend Us and Our suppliers from and against any claims or lawsuits, including attorneys fees, that arise or result from the use or distribution of the Sample Code.


# Class to hold alert resource groups and names as script has to get RGs from different command let than alert.
Class MyRGandName
{
  [String]$RG
  [String]$Name
}
function global:Get-AzSMUnusedNICs {
  <#
      .SYNOPSIS
      Lists unused NICs in a subscription.
      .DESCRIPTION
      Lists unused NICs in a subscription.
      .PARAMETER SubscriptionID
      Azure subscription ID in the format, 00000000-0000-0000-0000-000000000000
      .OUTPUTS
      Microsoft.Azure.Commands.Network.Models.PSNetworkInterface
      .EXAMPLE
      Get-AzSMUnusedNICs -Subscription 00000000-0000-0000-0000-000000000000
      Get a list of unused network interfaces in a subscription.
      .EXAMPLE
      Get-AzSMUnusedNICs -Subscription 00000000-0000-0000-0000-000000000000 | Remove-AzNetworkInterface
      Remove unused network interfaces in a subscription with confirmation.
      .NOTES
      * CAN be piped to Remove-AzNetworkInterface.
      * When piping to remove resources, include the -force parameter to supress prompts.
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

  $nics=Get-AzNetworkInterface|Where-Object{!$_.VirtualMachine}
	
    Return $nics
}
function global:Get-AzSMUnusedNSGs {

  <#
      .SYNOPSIS
      Lists unused NSGs in a subscription.
      .DESCRIPTION
      Lists unused NSGs in a subscription.
      .PARAMETER SubscriptionID
      Azure subscription ID in the format, 00000000-0000-0000-0000-000000000000
      .OUTPUTS
      Microsoft.Azure.Commands.Network.Models.PSNetworkSecurityGroup
      .EXAMPLE
      Get-AzSMUnusedNSGs -Subscription 00000000-0000-0000-0000-000000000000
      Get a list of unused network security groups in a subscription.
      .EXAMPLE
      Get-AzSMUnusedNSGs -Subscription 00000000-0000-0000-0000-000000000000 | Remove-AzNetworkSecurityGroup
      Remove unused network security groups in a subscription.
      .NOTES
      * CAN be piped to Remove-AzNetworkSecurityGroup.
      * When piping to remove resources, include the -force parameter to supress prompts.
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

  $nsg=Get-AzNetworkSecurityGroup|Where-Object{!$_.NetworkInterfaces}
	
  Return $nsg
}

function global:Get-AzSMEmptyBatchAccounts {

  <#
      .SYNOPSIS
      Lists batch accounts with no applications in a subscription.
      .DESCRIPTION
      Lists batch accounts with no applications in a subscription.
      .PARAMETER SubscriptionID
      Azure subscription ID in the format, 00000000-0000-0000-0000-000000000000
      .OUTPUTS
      AzureSaveMoney.MyRGandName
      .EXAMPLE
      Get-AzSMEmptyBatchAccounts -Subscription 00000000-0000-0000-0000-000000000000
      Get a list of batch accounts with no applications in a subscription.
      .EXAMPLE
      .
      .NOTES
      *
      *
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

  $apps = New-Object System.Collections.ArrayList
  $bas=Get-AzBatchAccount -WarningAction Ignore
  foreach ($ba in $bas)
    {
      $a=Get-AzBatchApplication -ResourceGroupName $ba.ResourceGroupName -AccountName $ba.AccountName -WarningAction Ignore
        
        if ($a.Id.Length -lt 1) {
            $ap=New-Object MyRGandName
            $ap.RG=$ba.ResourceGroupName
            $ap.Name=$ba.AccountName
            $null = $apps.Add($ap)
        }
    }  
  
  Return $apps|Select-Object @{n="ResourceGroupName";e="RG"}, @{n="AccountName";e="Name"}
}

function global:Get-AzSMVMsNotDeletedAfterImage {

  <#
      .SYNOPSIS
      List virtual machines that were not deleted after a generalized image in a subscription.
      .DESCRIPTION
      List virtual machines that were not deleted after a generalized image in a subscription.
      .PARAMETER SubscriptionID
      Azure subscription ID in the format, 00000000-0000-0000-0000-000000000000
      .OUTPUTS
      AzureSaveMoney.MyRGandName
      .EXAMPLE
      Get-AzSMVMsNotDeletedAfterImage -SubscriptionID 00000000-0000-0000-0000-000000000000
      .NOTES
      *
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
  Write-Debug ('Subscription ID: {0}' -f $SubscriptionID)

  $vms = New-Object System.Collections.ArrayList
$images=Get-Azimage -WarningAction Ignore

foreach ($image in $images)
  {
    $svm=Get-AzResource -ResourceId $image.SourceVirtualMachine.Id -ErrorAction Ignore -WarningAction Ignore
    if ($svm){
              $vm=New-Object MyRGandName
              $vm.RG=$svm.ResourceGroupName
              $vm.Name=$svm.Name
              $vms.Add($vm)
    }
  }
  Return $vms|Select-Object @{n="ResourceGroupName";e="RG"}, @{n="VMName";e="Name"}
}

function global:Get-AzSMDisabledServiceBusQueues {

  <#
      .SYNOPSIS
      Lists disabled Service Bus Queues in a subscription.
      .DESCRIPTION
      Lists disabled Service Bus Queues in a subscription.
      .PARAMETER SubscriptionID
      Azure subscription ID in the format, 00000000-0000-0000-0000-000000000000
      .OUTPUTS
      Microsoft.Azure.Commands.ServiceBus.Models.PSQueueAttributes
      .EXAMPLE
      Get-AzSMDisabledServiceBusQueues -Subscription 00000000-0000-0000-0000-000000000000
      Get a list of disabled Service Bus Queues in a subscription.
      .EXAMPLE
      Get-AzSMDisabledServiceBusQueues -Subscription 00000000-0000-0000-0000-000000000000|Remove-AzServiceBusQueue -Confirm
      Removes all disabled Service Bus Queues in a subscription.
      .NOTES
      *
      *
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

  $q=Get-AzResourceGroup|Get-AzServiceBusNamespace|ForEach-Object {Get-AzServiceBusQueue -ResourceGroupName $_.ResourceGroupName -Namespace $_.Name|Where-Object{$_.Status -eq "Disabled"}}
  
  Return $q
}

function global:Get-AzSMEmptySubnets {

  <#
      .SYNOPSIS
      Lists empty subnets in a subscription.
      .DESCRIPTION
      Lists empty subnets in a subscription.
      .PARAMETER SubscriptionID
      Azure subscription ID in the format, 00000000-0000-0000-0000-000000000000
      .OUTPUTS
      Selected.Microsoft.Azure.Commands.Network.Models.PSVirtualNetwork
      .EXAMPLE
      Get-AzSMEmptySubnets -Subscription 00000000-0000-0000-0000-000000000000
      Get a list of unused subnets in a subscription.
      .EXAMPLE
      *
      .NOTES
      *
      *
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

  $vn=Get-AzVirtualNetwork
  $emptysubnets=$vn|?{$_.Subnets.IpConfigurations.count -eq 0}|select-object @{n="VNet";e="Name"},Subnets
  
  Return $emptysubnets
}

function global:Get-AzSMUnusedAppServicePlans {

  <#
      .SYNOPSIS
      Lists unused App Service Plans in a subscription.
      .DESCRIPTION
      Lists unused App Service Plans in a subscription.
      .PARAMETER SubscriptionID
      Azure subscription ID in the format, 00000000-0000-0000-0000-000000000000
      .OUTPUTS
      Microsoft.Azure.Commands.WebApps.Models.WebApp.PSAppServicePlan
      .EXAMPLE
      Get-AzSMUnusedAppServicePlans -Subscription 00000000-0000-0000-0000-000000000000
      Get a list of unused App Service Plans in a subscription.
      .EXAMPLE
      Get-AzSMUnusedAppServicePlans -Subscription 00000000-0000-0000-0000-000000000000 | Remove-AzAppServicePlan
      Remove unused App Service Plans in a subscription.
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
    [Parameter(Mandatory=$true)][string] $SubscriptionID
  )

    $null = Set-AzContext -SubscriptionId $SubscriptionID
  Write-Debug ('Subscription: {0}' -f $SubscriptionID)

  $app=Get-AzAppServicePlan|Where-Object{$_.NumberOfSites -eq 0}
	
  Return $app
}

function global:Get-AzSMUnusedPIPs {

  <#
      .SYNOPSIS
      Lists unused Public IPs in a subscription.
      .DESCRIPTION
      Lists unused Public IPs in a subscription.
      .PARAMETER SubscriptionID
      Azure subscription ID in the format, 00000000-0000-0000-0000-000000000000
      .OUTPUTS
      Microsoft.Azure.Commands.Network.Models.PSPublicIpAddress
      .EXAMPLE
      Get-AzSMUnusedPIPs -Subscription 00000000-0000-0000-0000-000000000000
      Gets a list of unused public IP addresses in a subscription.
      .EXAMPLE
      Get-AzSMUnusedPIPs -Subscription 00000000-0000-0000-0000-000000000000 | Remove-AzPublicIpAddress
      Remove unused public IP addresses in a subscription.
      .NOTES
      * CAN be piped to Remove-AzPublicIpAddress.
      * When piping to remove resources, include the -force parameter to supress prompts.
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

  $pip=Get-AzPublicIpAddress|Where-Object{!$_.IpConfiguration}
	
  Return $pip
}
function global:Get-AzSMDisabledAlerts {

  <#
      .SYNOPSIS
      Lists disabled "classic" alerts in a subscription.
      .DESCRIPTION
      Lists disabled "classic" alerts in a subscription.
      .PARAMETER SubscriptionID
      Azure subscription ID in the format, 00000000-0000-0000-0000-000000000000
      .OUTPUTS
      AzureSaveMoney.MyRGandName
      .EXAMPLE
      Get-AzSMDisabledAlerts -Subscription 00000000-0000-0000-0000-000000000000
      Get a list of disabled classic alerts in a subscription.
      .NOTES
      * CANNOT be piped to Remove-AzAlertRule.
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

  $alerts = New-Object System.Collections.ArrayList
  $rgs=Get-AzResourceGroup
  foreach ($r in $rgs)
  {
    $a=Get-AzAlertRule -ResourceGroupName $r.ResourceGroupName -WarningAction Ignore|Where-Object{$_.IsEnabled -eq $false}
    
    if ($a.IsEnabled -eq $false) {
      $al=New-Object MyRGandName
      $al.RG=$r.ResourceGroupName
      $al.Name=$a.Name
      $null = $alerts.Add($al)
    }
  }
  Return $alerts
}
function global:Get-AzSMDisabledLogAlerts{

  <#
      .SYNOPSIS
      List disabled Activity Log alerts in a subscription.
      .DESCRIPTION
      List disabled Activity Log alerts in a subscription.
      .PARAMETER SubscriptionID
      Azure subscription ID in the format, 00000000-0000-0000-0000-000000000000
      .OUTPUTS
      AzureSaveMoney.MyRGandName
      .EXAMPLE
      Get-AzSMDisabledLogAlerts -Subscription 00000000-0000-0000-0000-000000000000
      Get a list of disabled Activity Log alerts in a subscription.
      .NOTES
      *CANNOT be piped to Remove-AzActivityLogAlert.
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

  $logalerts = New-Object System.Collections.ArrayList
  $rg=Get-AzResourceGroup
  foreach ($r in $rg)
  {
    $a=Get-AzActivityLogAlert -ResourceGroupName $r.ResourceGroupName -WarningAction Ignore -ErrorAction Ignore|Where-Object{$_.Enabled -eq $false}

    if ($a.Enabled -eq $false){
      $al=New-Object MyRGandName
      $al.RG=$r.ResourceGroupName
      $al.Name=$a.Name
      $null = $logalerts.Add($al)
    }
  }
    
  Return $logalerts
}
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
      Get a list of empty Resource Groups in a subscription.
      .NOTES
      *CAN be piped to Remove-AzResourceGroup.
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
function global:Get-AzSMUnusedAlertActionGroups {

  <#
      .SYNOPSIS
      Lists unused Alert Action Groups in a subscription.
      .DESCRIPTION
      Lists unused Alert Action Groups in a subscription.
      .PARAMETER SubscriptionID
      Azure subscription ID in the format, 00000000-0000-0000-0000-000000000000
      .OUTPUTS
      Microsoft.Azure.Commands.Insights.OutputClasses.PSActionGroupResource
      .EXAMPLE
      Get-AzSMUnusedAlertActionGroups -SubscriptionID 00000000-0000-0000-0000-000000000000
      .EXAMPLE
      Get-AzSMUnusedAlertActionGroups -SubscriptionID 00000000-0000-0000-0000-000000000000 | Remove-AzActionGroup -Confirm
      .NOTES
      *CAN be piped to Remove-AzActionGroup.
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

  $actiongroups2 = New-Object System.Collections.ArrayList
  $rgs=Get-AzResourceGroup
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
        $as=$a.Actions.ActionGroups[0].ActionGroupId.Split('/')
	
        $TempHoldActionGroup=New-Object MyRGandName
        $TempHoldActionGroup.RG=$rg.ResourceGroupName
        $TempHoldActionGroup.Name=$as.GetValue($as.Count -1)
	
        $null = $actiongroups.add($TempHoldActionGroup)
      }
    }
  }
	
  $unusedactiongroups=$actiongroups2|Where-Object{$actiongroups.Name -notcontains $_.Name}

  foreach ($alertactiongroup in $unusedactiongroups) {
    Get-AzActionGroup -ResourceGroupName $alertactiongroup.RG -Name $alertactiongroup.Name
  }
}
function global:Get-AzSMUnusedRouteTables {

  <#
      .SYNOPSIS
      List unused route tables in a subscription.
      .DESCRIPTION
      List unused route tables in a subscription.
      .PARAMETER SubscriptionID
      Azure subscription ID in the format, 00000000-0000-0000-0000-000000000000
      .OUTPUTS
      Microsoft.Azure.Commands.Network.Models.PSRouteTable
      .EXAMPLE
      Get-AzSMUnusedRouteTables -SubscriptionID 00000000-0000-0000-0000-000000000000
      .NOTES
      *CAN be piped to Remove-AzRouteTable.
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

  $routelist = New-Object System.Collections.ArrayList
  $routes=Get-AzRouteTable
  $routes|ForEach-Object {
    if ($route.Subnets.Count -eq 0) {
            $null = $routelist.add($_)
        }
  }

    Return $routelist
}
function global:Get-AzSMVNetsWithoutSubnets {

  <#
      .SYNOPSIS
      List VNets without any subnets defined in a subscription.
      .DESCRIPTION
      List VNets without any subnets defined in a subscription.
      .PARAMETER SubscriptionID
      Azure subscription ID in the format, 00000000-0000-0000-0000-000000000000
      .OUTPUTS
      Microsoft.Azure.Commands.Network.Models.PSVirtualNetwork
      .EXAMPLE
      Get-AzSMVNetsWithoutSubnets -SubscriptionID 00000000-0000-0000-0000-000000000000
      .NOTES
      *CAN be piped to Remove-AzVirtualNetwork
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

  $emptysubnets=New-Object System.Collections.ArrayList
  $vnets=Get-AzVirtualNetwork
  foreach ($vnet in $vnets) {
    if ($vnet.Subnets.Count -eq 0) {
      $null = $emptysubnets.add($vnet)
      #Write-Output "VNet without subnets defined found: " + $vnet.Name
    }
  }

    Return $emptysubnets
}
function global:Get-AzSMOldDeployments{

  <#
      .SYNOPSIS
      List deployments older than 365 days in a subscription.
      .DESCRIPTION
      List deployments older than 365 days in a subscription.
      .PARAMETER SubscriptionID
      Azure subscription ID in the format, 00000000-0000-0000-0000-000000000000
      .PARAMETER Days
        Set to the number of days to scan back for old deployments.
        Default is 365 days old.
      .OUTPUTS
      Microsoft.Azure.Commands.ResourceManager.Cmdlets.SdkModels.PSResourceGroupDeployment
      .EXAMPLE
      Get-AzSMOldDeployments -SubscriptionID 00000000-0000-0000-0000-000000000000
      .NOTES
      *CAN be piped to Remove-AzResourceGroupDeployment.
      .LINK
  #>

  [CmdletBinding(
      DefaultParameterSetName='SubscriptionID',
      ConfirmImpact='Low'
  )]

  param(
    [Parameter(Mandatory=$true)][string] $SubscriptionID,
        [int] $Days = 365
  )

  $null = Set-AzContext -SubscriptionId $SubscriptionID
    Write-Debug ('Subscription: {0}' -f $SubscriptionID)

    $rgd=Get-AzResourceGroup|Get-AzResourceGroupDeployment|Where-Object{$_.Timestamp -lt (Get-Date).AddDays(-$Days)}
    
    Return $rgd
}
function global:Get-AzSMUnusedDisks {

  <#
      .SYNOPSIS
      List unused managed disks in a subscription.
      .DESCRIPTION
      List unused managed disks in a subscription.
      .PARAMETER SubscriptionID
      Azure subscription ID in the format, 00000000-0000-0000-0000-000000000000
      .OUTPUTS
      Microsoft.Azure.Commands.Compute.Automation.Models.PSDiskList
      .EXAMPLE
      Get-AzSMUnusedDisks -SubscriptionID 00000000-0000-0000-0000-000000000000
      .NOTES
      *CAN be piped to Remove-AzDisk.
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

  $disks = Get-AzDisk|Where-Object{$_.ManagedBy.Length -lt 1}

    Return $disks
}
function global:Get-AzSMEmptyAADGroups {

  <#
      .SYNOPSIS
      List empty AAD groups in a tenant.
      .DESCRIPTION
      List empty AAD groups in a tenant.
      .PARAMETER TenantID
      Azure tenant ID in the format, 00000000-0000-0000-0000-000000000000
      .OUTPUTS
      Microsoft.Open.AzureAD.Model.Group
      .EXAMPLE
      Get-AzSMEmptyAADGroups -TenantID 00000000-0000-0000-0000-000000000000
      .NOTES
      *It is not recommended to pipe command to remove AAD groups as there are built-in and synced groups that may have not members.
      .LINK
  #>

  [CmdletBinding(
      DefaultParameterSetName='TenantID',
      ConfirmImpact='Low'
  )]

  param(
    [Parameter(Mandatory=$true)][string] $TenantID,
    [Parameter(Mandatory=$false)][string] $Applicationid = $null,
    [Parameter(Mandatory=$false)][string] $CertificateThumbprint = $null
  )

  If ($Applicationid -ne $null -AND $CertificateThumbprint -ne $null) {
    $Applicationid
    $CertificateThumbprint
    $null = Connect-AzureAD -TenantId $TenantID -ApplicationId $Applicationid -CertificateThumbprint $CertificateThumbprint
  } Else {
    $null = Connect-AzureAD -TenantId $TenantID
  }
    
    
  Write-Debug ('Tenant ID: {0}' -f $TenantID)

    $emptygroups=New-Object System.Collections.ArrayList
    Get-AzureADGroup|ForEach-Object {
        $aadgmem=Get-AzureADGroupMember -ObjectId $_.ObjectId
        if($aadgmem.Count -lt 1) {
            $null = $emptygroups.add($_)
        }
    }
    Return $emptygroups
}
function global:Get-AzSMDisabledLogicApps {

  <#
      .SYNOPSIS
      List disabled Logic Apps in a subscription.
      .DESCRIPTION
      List disabled Logic Apps in a subscription.
      .PARAMETER SubscriptionID
      Azure subscription ID in the format, 00000000-0000-0000-0000-000000000000
      .OUTPUTS
      Microsoft.Azure.Management.Logic.Models.Workflow
      .EXAMPLE
      Get-AzSMDisabledLogicApps -SubscriptionID 00000000-0000-0000-0000-000000000000
      .NOTES
      *CANNOT be piped to Remove-AzLogicApp.
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
  Write-Debug ('Subscription ID: {0}' -f $SubscriptionID)

  $disabledlapps = New-Object System.Collections.ArrayList
  Get-AzResourceGroup|ForEach-Object {
    $lapps=Get-AzResource -ResourceGroupName $_.ResourceGroupName -ResourceType 'Microsoft.Logic/workflows'
    $lapps|ForEach-Object {
      $lapp=Get-AzLogicApp -ResourceGroupName $_.ResourceGroupName -Name $_.Name|Where-Object{$_.State -eq 'Disabled'}
      $null = $disabledlapps.add($lapp)
    }
  }
    Return $disabledlapps
}
function global:Get-AzSMOldSnapshots{

  <#
      .SYNOPSIS
      List snapshots older than 365 days in a subscription.
      .DESCRIPTION
      List snapshots older than 365 days in a subscription.
      .PARAMETER SubscriptionID
      Azure subscription ID in the format, 00000000-0000-0000-0000-000000000000
      .PARAMETER Days
        Set to the number of days to scan back for old deployments.
        Default is 365 days old.
      .OUTPUTS
      Microsoft.Azure.Commands.Compute.Automation.Models.PSSnapshotList
      .EXAMPLE
      Get-AzSMOldSnapshots -SubscriptionID 00000000-0000-0000-0000-000000000000
      .NOTES
      *CAN be piped to Remove-AzSnapshot.
      .LINK
  #>

  [CmdletBinding(
      DefaultParameterSetName='SubscriptionID',
      ConfirmImpact='Low'
  )]

  param(
    [Parameter(Mandatory=$true)][string] $SubscriptionID,
        [int] $Days = 365
  )

  $null = Set-AzContext -SubscriptionId $SubscriptionID
    Write-Debug ('Subscription ID: {0}' -f $SubscriptionID)

    $snap=Get-AzSnapshot|Where-Object{$_.TimeCreated -lt (Get-Date).AddDays(-$Days)}
    
    Return $snap
}

function global:Get-AzSMIlbNoBackendPoolVMs {

  <#
      .SYNOPSIS
      List Internal load balancers that have no backend pool virtual machines in a subscription.
      .DESCRIPTION
      List Internal load balancers that have no backend pool virtual machines in a subscription.
      .PARAMETER SubscriptionID
      Azure subscription ID in the format, 00000000-0000-0000-0000-000000000000
      .OUTPUTS
      Microsoft.Azure.Commands.Network.Models.PSLoadBalancer
      .EXAMPLE
      Get-AzSMIlbNoBackendPoolVMs -SubscriptionID 00000000-0000-0000-0000-000000000000
      .NOTES
      *CAN be piped to Remove-AzLoadBalancer.
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
  Write-Debug ('Subscription ID: {0}' -f $SubscriptionID)

    
    $lbs=Get-AzLoadBalancer -WarningAction Ignore|Where-Object{$_.BackendAddressPools.BackendIpConfigurations -eq $null}

    Return $lbs
}

function global:Get-AzSMIlbNoBackendPool {

  <#
      .SYNOPSIS
      List Internal load balancers that have no backend pool in a subscription.
      .DESCRIPTION
      List Internal load balancers that have no backend pool in a subscription.
      .PARAMETER SubscriptionID
      Azure subscription ID in the format, 00000000-0000-0000-0000-000000000000
      .OUTPUTS
      Microsoft.Azure.Commands.Network.Models.PSLoadBalancer
      .EXAMPLE
      Get-AzSMIlbNoBackendPool -SubscriptionID 00000000-0000-0000-0000-000000000000
      .NOTES
      *CAN be piped to Remove-AzLoadBalancer.
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
  Write-Debug ('Subscription ID: {0}' -f $SubscriptionID)

    $ilbsnopool=Get-AzLoadBalancer|Where-Object{$_.BackendAddressPools.Count -lt 1}

    Return $ilbsnopool
}
function global:Get-AzSMDisabledTrafficManagerProfiles {

  <#
      .SYNOPSIS
      List disabled TrafficManager Profiles in a subscription.
      .DESCRIPTION
      List disabled TrafficManager Profiles in a subscription.
      .PARAMETER SubscriptionID
      Azure subscription ID in the format, 00000000-0000-0000-0000-000000000000
      .OUTPUTS
      Microsoft.Azure.Commands.TrafficManager.Models.TrafficManagerProfile
      .EXAMPLE
      Get-AzSMDisabledTrafficManagerProfiles -SubscriptionID 00000000-0000-0000-0000-000000000000
      .NOTES
      *CAN be piped to Remove-AzTrafficManagerProfile.
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
  Write-Debug ('Subscription ID: {0}' -f $SubscriptionID)

    $dtmpro=Get-AzTrafficManagerProfile|Where-Object{$_.ProfileStatus -eq 'Disabled'}

    Return $dtmpro
}
function global:Get-AzSMTrafficManagerProfilesWithNoEndpoints {

  <#
      .SYNOPSIS
      List TrafficManager Profiles without endpoints in a subscription.
      .DESCRIPTION
      List TrafficManager Profiles without endpoints in a subscription.
      .PARAMETER SubscriptionID
      Azure subscription ID in the format, 00000000-0000-0000-0000-000000000000
      .OUTPUTS
      Microsoft.Azure.Commands.TrafficManager.Models.TrafficManagerProfile
      .EXAMPLE
      Get-AzSMTrafficManagerProfilesWithNoEndpoints -SubscriptionID 00000000-0000-0000-0000-000000000000
      .NOTES
      *CAN be piped to Remove-AzTrafficManagerProfile.
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
  Write-Debug ('Subscription ID: {0}' -f $SubscriptionID)

    $dtmpro=Get-AzTrafficManagerProfile|Where-Object{$_.Endpoints.Count -lt 1}

    Return $dtmpro
}

function global:Get-AzSMOldNetworkCaptures {

  <#
      .SYNOPSIS
      List old Network Watcher packet captures in a subscription.
      .DESCRIPTION
      List old Network Watcher packet captures in a subscription.
      .PARAMETER SubscriptionID
      Azure subscription ID in the format, 00000000-0000-0000-0000-000000000000
      .PARAMETER Days
        Set to the number of days to scan back for old captures.
        Default is 7 days old.
      .OUTPUTS
      Microsoft.Azure.Commands.Network.Models.PSGetPacketCaptureResult
      .EXAMPLE
      Get-AzSMOldNetworkCaptures -SubscriptionID 00000000-0000-0000-0000-000000000000 -Days 31
      Get Network Watcher packet captures ran more than 31 days ago.
      .NOTES
      *CANNOT be piped to Remove-AzNetworkWatcherPacketCapture.
      Does not return the .cap files that may be saved in storage.
      .LINK
  #>

  [CmdletBinding(
      DefaultParameterSetName='SubscriptionID',
      ConfirmImpact='Low'
  )]

  param(
    [Parameter(Mandatory=$true)][string] $SubscriptionID,
        [int] $Days = 7
  )

    $null = Set-AzContext -SubscriptionId $SubscriptionID
  Write-Debug ('Subscription ID: {0}' -f $SubscriptionID)

  $oldcaptures=Get-AzNetworkWatcher|Get-AzNetworkWatcherPacketCapture|Where-Object{$_.PacketCaptureStatus -ne 'Running' -and $_.CaptureStartTime -lt (Get-Date).AddDays(-$Days) }

  Return $oldcaptures
}

function global:Get-AzSMUnconnectedVirtualNetworkGateways {

  <#
      .SYNOPSIS
      List Virtual Network Gateway Connections in states other than 'Connected' in a subscription.
      .DESCRIPTION
      List Virtual Network Gateway Connections in states other than 'Connected' in a subscription.
      .PARAMETER SubscriptionID
      Azure subscription ID in the format, 00000000-0000-0000-0000-000000000000
      .OUTPUTS
      Microsoft.Azure.Commands.Network.Models.PSVirtualNetworkGatewayConnection
      .EXAMPLE
      Get-AzSMUnconnectedVirtualNetworkGateways -SubscriptionID 00000000-0000-0000-0000-000000000000
      .EXAMPLE
      Get-AzSMUnconnectedVirtualNetworkGateways -SubscriptionID 00000000-0000-0000-0000-000000000000|Remove-AzVirtualNetworkGatewayConnection
      .NOTES
      *CAN be piped to Remove-AzVirtualNetworkGatewayConnection.
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
  Write-Debug ('Subscription ID: {0}' -f $SubscriptionID)

  $vngwconns = New-Object System.Collections.ArrayList
  Get-AzResourceGroup|ForEach-Object {

    $rg=$_.ResourceGroupName
    $vngwconn=Get-AzVirtualNetworkGatewayConnection -ResourceGroupName $rg

    if ($vngwconn.name.Length -gt 0) {
      #$vngwconnname=$vngwconn.name

      $vngwconn|ForEach-Object {
        $vngwconn2=Get-AzVirtualNetworkGatewayConnection -ResourceGroupName $rg -Name $_.Name|Where-Object {$_.ConnectionStatus -ne 'Connected'}
        $null = $vngwconns.Add($vngwconn2)

      }
    }
  }

  Return $vngwconns
}

function global:Get-AzSMExpiredWebhooks {

  <#
      .SYNOPSIS
      List expired Webhooks in a subscription.
      .DESCRIPTION
      List expired Webhooks in a subscription.
      .PARAMETER SubscriptionID
      Azure subscription ID in the format, 00000000-0000-0000-0000-000000000000
      .OUTPUTS
      Microsoft.Azure.Commands.Automation.Model.Webhook
      .EXAMPLE
      Get-AzSMExpiredWebhooks -SubscriptionID 00000000-0000-0000-0000-000000000000
      .EXAMPLE
      Get-AzSMExpiredWebhooks -SubscriptionID 00000000-0000-0000-0000-000000000000|Remove-AzAutomationWebhook
      .NOTES
      *CAN be piped to Remove-AzAutomationWebhook.
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
  Write-Debug ('Subscription ID: {0}' -f $SubscriptionID)

  $expiredWebhks = New-Object System.Collections.ArrayList
  Get-AzAutomationAccount|ForEach-Object {
    $webhks=Get-AzAutomationWebhook -ResourceGroupName $_.ResourceGroupName -AutomationAccountName $_.AutomationAccountName|Where-Object {$_.ExpiryTime -lt (Get-Date)}
    $webhks|ForEach-Object {
      $null = $expiredWebhks.Add($_)
    }
  }

  Return $expiredWebhks

}

function global:Get-AzSMAppServicePlanScaleinfo {

  <#
      .SYNOPSIS
      List all App Service Plan scaling recommendations for a subscription.
      .DESCRIPTION
      List all App Service Plan scaling recommendations for a subscription.
      .PARAMETER SubscriptionID
      Azure subscription ID in the format, 00000000-0000-0000-0000-000000000000
      .OUTPUTS
      String recommendations.
      .EXAMPLE
      Get-AzSMAppServicePlanScaleinfo -Subscription 00000000-0000-0000-0000-000000000000
      APPPLANNAME - Low average CPU usage detected (8.00125)%. Scale down VM size.
      APPPLANNAME - Average CPU usage normal (64.4690909090909)%. Stay at current VM size.
      APPPLANNAME - High average CPU use detected (84.2233333333333)%. Scale up VM size.
      APPPLANNAME - No CPU data found. VM not running?
      .NOTES
      *CANNOT be piped to any Remove- Azure command.
      High CPU uasage is > 80%
      Low CPU usage is < 20%
      Normal CPU usage is 20% - 79%
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
  Write-Debug ('Subscription ID: {0}' -f $SubscriptionID)
  
  $rgs=Get-AzResourceGroup
  foreach ($r in $rgs)
  {
    $vms=Get-AzAppServicePlan -ResourceGroupName $r.ResourceGroupName
    
    foreach ($vm in $vms) {
    
      $met=Get-AzMetric -ResourceId $vm.Id -WarningAction SilentlyContinue
      $avg=$met.Data|Where-Object {$_.Average -gt 0}|Select-Object Average

      foreach ($a in $avg) {
        $t=$t+$a.Average
      }
      try {
        $cputimeavg=$t/$avg.Count
      } catch {}
      


      if ($avg.Count -lt 5) {
        $vmusage = 0
      } else {
        try{
          $vmusage=($avg.Average |Measure-Object -Average).Average
        }catch{}
        
      }


      if ($vmusage -eq $null -or $vmusage -eq 0){Write-Output ('{0} - Not enough CPU usage data. Is app not running or just started?' -f $vm.Name)} else {
        if ($vmusage -gt 79) {
          Write-Output ('{1} - High average CPU use detected ({0})%. Scale up App Service Plan size.' -f $vmusage,$vm.Name)
        } else {
          if ($vmusage -lt 20) {
            Write-Output ('{1} - Low average CPU usage detected ({0})%. Scale down App Service Plan size.' -f $vmusage,$vm.Name)
          } else {
            Write-Output ('{1} - Average CPU usage normal ({0})%. Stay at current App Service Plan size.' -f $vmusage,$vm.Name)
          }
        }
      }
    }
  }

}

function global:Get-AzSMVMScaleinfo {

  <#
      .SYNOPSIS
      List all Virtual Machine scaling recommendations for a subscription.
      .DESCRIPTION
      List all Virtual Machine scaling recommendations for a subscription.
      .PARAMETER SubscriptionID
      Azure subscription ID in the format, 00000000-0000-0000-0000-000000000000
      .OUTPUTS
      String recommendations.
      .EXAMPLE
      Get-AzSMVMScaleinfo -Subscription 00000000-0000-0000-0000-000000000000
      VMNAME - Low average CPU usage detected (8.00125)%. Scale down VM size.
      VMNAME - Average CPU usage normal (64.4690909090909)%. Stay at current VM size.
      VMNAME - High average CPU use detected (84.2233333333333)%. Scale up VM size.
      VMNAME - No CPU data found. VM not running?
      .NOTES
      *CANNOT be piped to any Remove- Azure command.
      High CPU uasage is > 80%
      Low CPU usage is < 20%
      Normal CPU usage is 20% - 79%
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
  Write-Debug ('Subscription ID: {0}' -f $SubscriptionID)
  
  $rgs=Get-AzResourceGroup
  foreach ($r in $rgs)
  {
    $vms=get-azvm -ResourceGroupName $r.ResourceGroupName
    
    foreach ($vm in $vms) {
    
      $met=Get-AzMetric -ResourceId $vm.Id -WarningAction SilentlyContinue
      $avg=$met.Data|Where-Object {$_.Average -gt 0}|Select-Object Average

      foreach ($a in $avg) {
        $t=$t+$a.Average
      }
      try {
        $cputimeavg=$t/$avg.Count
      } catch {}
      


      if ($avg.Count -lt 5) {
        $vmusage = 0
      } else {
        try{
          $vmusage=($avg.Average |Measure-Object -Average).Average
        }catch{}
        
      }


      if ($vmusage -eq $null -or $vmusage -eq 0){Write-Output ('{0} - Not enough CPU usage data. Is VM not running or just started?' -f $vm.Name)} else {
        if ($vmusage -gt 79) {
          Write-Output ('{1} - High average CPU use detected ({0})%. Scale up VM size.' -f $vmusage,$vm.Name)
        } else {
          if ($vmusage -lt 20) {
            Write-Output ('{1} - Low average CPU usage detected ({0})%. Scale down VM size.' -f $vmusage,$vm.Name)
          } else {
            Write-Output ('{1} - Average CPU usage normal ({0})%. Stay at current VM size.' -f $vmusage,$vm.Name)
          }
        }
      }
    }
  }

}

function global:Get-AzSMAllResources {

  <#
      .SYNOPSIS
      List all unused resources that this module implements in a tenant and subscription.
      .DESCRIPTION
      List all unused resources that this module implements in a tenant and subscription.
      .PARAMETER SubscriptionID
      Azure subscription ID in the format, 00000000-0000-0000-0000-000000000000
      .PARAMETER TenantID
      Azure tenant ID in the format, 00000000-0000-0000-0000-000000000000
      .PARAMETER Days
      Set to the number of days to scan back for old captures.
        Default is 365 days old.
      .OUTPUTS
      Various objects.
      .EXAMPLE
      Get-AzSMAllResources -Subscription 00000000-0000-0000-0000-000000000000 -Tenant 00000000-0000-0000-0000-000000000000
      Gets a list of all supported unused and old resources in a tenant/subscription combination.
      .NOTES
      *CANNOT be piped to any Remove- Azure command.
      .LINK
  #>

  [CmdletBinding(
    DefaultParameterSetName='SubscriptionID',
    ConfirmImpact='Low'
  )]

  param(
    [Parameter(Mandatory=$true)][string] $SubscriptionID,
        [Parameter(Mandatory=$true)][string] $TenantID,
        [Parameter(Mandatory=$false)][int] $Days = 365,
        [Parameter(Mandatory=$false)][string] $Applicationid = $null,
        [Parameter(Mandatory=$false)][string] $CertificateThumbprint = $null
  )

  If ($Applicationid -ne $null -AND $CertificateThumbprint -ne $null) {
    $null = Connect-AzureAD -TenantId $TenantID -ApplicationId $Applicationid -CertificateThumbprint $CertificateThumbprint
  } Else {
    $null = Connect-AzureAD -TenantId $TenantID
  } 
      
    $null = Set-AzContext -SubscriptionId $SubscriptionID

    Write-Output 'Querying all resources for savings using the following parameters:'
    Write-Output ('Tenant ID: {0}' -f $TenantID)
    Write-Output ('Subscription ID: {0}' -f $SubscriptionID)
    Write-Output ("Days: {0}`n" -f $Days)

    Write-Output 'Ununsed NICs:'
    Get-AzSMUnusedNICs -Subscription $SubscriptionID
	
    Write-Output 'Ununsed NSGs:'
    Get-AzSMUnusedNSGs -Subscription $SubscriptionID
    
    Write-Output 'Ununsed PIPs:'
    Get-AzSMUnusedPIPs -Subscription $SubscriptionID
    
    Write-Output 'Disabled Alerts(Classic):'
    Get-AzSMDisabledAlerts -Subscription $SubscriptionID
    
    Write-Output 'Disabled Log Alerts:'
    Get-AzSMDisabledLogAlerts -Subscription $SubscriptionID
    
    Write-Output 'Empty Resource Groups:'
    Get-AzSMEmptyResourceGroups -Subscription $SubscriptionID
    
    Write-Output 'Ununsed Alert Groups:'
    Get-AzSMUnusedAlertActionGroups -Subscription $SubscriptionID
    
    Write-Output 'Ununsed Route Tables:'
    Get-AzSMUnusedRouteTables -Subscription $SubscriptionID
    
    Write-Output 'VNets without Subnets:'
    Get-AzSMVNetsWithoutSubnets -Subscription $SubscriptionID
    
    Write-Output ('Old Deployments older than {0} days:' -f $Days)
    Get-AzSMOldDeployments -Subscription $SubscriptionID
    
    Write-Output 'Ununsed Disks:'
    Get-AzSMUnusedDisks -Subscription $SubscriptionID
    
    Write-Output 'Empty AAD Groups:'
    Get-AzSMEmptyAADGroups -TenantId $TenantID
    
    Write-Output 'Disabled Logic Apps:'
    Get-AzSMDisabledLogicApps -Subscription $SubscriptionID
    
    Write-Output ('Old Snapshots older than {0} days:' -f $Days)
    Get-AzSMOldSnapshots -Subscription $SubscriptionID
    
    Write-Output 'Load balancers with no backend pools:'
    Get-AzSMIlbNoBackendPool -Subscription $SubscriptionID

    Write-Output 'Disabled TrafficManager Profiles:'
    Get-AzSMDisabledTrafficManagerProfiles -Subscription $SubscriptionID
    
    Write-Output 'TrafficManager Profiles With No Endpoints:'
    Get-AzSMTrafficManagerProfilesWithNoEndpoints -Subscription $SubscriptionID

    Write-Output 'Old Network Watcher packet captures:'
    Get-AzSMOldNetworkCaptures -SubscriptionID $SubscriptionID

    Write-Output 'Unconnected Virtual Network Gateway Connections:'
    Get-AzSMUnconnectedVirtualNetworkGateways -SubscriptionID $SubscriptionID

    Write-Output 'Expired Webhooks:'
    Get-AzSMExpiredWebhooks -SubscriptionID $SubscriptionID
  
    Write-Output 'VM CPU scaling info:'
    Get-AzSMVMScaleinfo -SubscriptionID $SubscriptionID

    Write-Output 'Empty Subnets:'
    Get-AzSMEmptySubnets -SubscriptionID $SubscriptionID
  
    Write-Output 'Unused App Service Plans:'
    Get-AzSMUnusedAppServicePlans -SubscriptionID $SubscriptionID

    Write-Output 'Disabled Service Bus Queues:'
    Get-AzSMDisabledServiceBusQueues -SubscriptionID $SubscriptionID
  
    Write-Output 'Batch Accounts with no Applications:'
    Get-AzSMEmptyBatchAccounts -SubscriptionID $SubscriptionID

    Write-Output 'Virtual Machines that have images. * VMs should be deleted after generalizing and imaging.:'
    Get-AzSMVMsNotDeletedAfterImage -SubscriptionID $SubscriptionID

    Write-Output 'Load balancers with no backend pool VMs:'
    Get-AzSMIlbNoBackendPoolVMs -Subscription $SubscriptionID

    Write-Output 'App Service Plan CPU scaling info:'
    Get-AzSMAppServicePlanScaleinfo -SubscriptionID $SubscriptionID
}
