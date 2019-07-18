# Contributors:
# Chad Schultz
#
# PowerShell module to List on and delete unused Azure resources and save money.
#
# This Sample Code is provided for the purpose of illustration only and is not intended to be used in a production environment.  THIS SAMPLE CODE AND ANY RELATED INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.  We grant You a nonexclusive, royalty-free right to use and modify the Sample Code and to reproduce and distribute the object code form of the Sample Code, provided that You agree: (i) to not use Our name, logo, or trademarks to market Your software product in which the Sample Code is embedded; (ii) to include a valid copyright notice on Your software product in which the Sample Code is embedded; and (iii) to indemnify, hold harmless, and defend Us and Our suppliers from and against any claims or lawsuits, including attorneys’ fees, that arise or result from the use or distribution of the Sample Code.


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
		DefaultParameterSetName="SubscriptionID",
		SupportsShouldProcess=$false,
		ConfirmImpact='Low'
	)]

	param(
		[Parameter(Mandatory=$true)][string] $SubscriptionID
	)

    Select-AzSubscription -SubscriptionId $SubscriptionID|Out-Null
	Write-Debug "Subscription: $SubscriptionID"

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
		DefaultParameterSetName="SubscriptionID",
		SupportsShouldProcess=$false,
		ConfirmImpact='low'
	)]

	param(
		[Parameter(Mandatory=$true)][string] $SubscriptionID
	)

    Select-AzSubscription -SubscriptionId $SubscriptionID|Out-Null
	Write-Debug "Subscription: $SubscriptionID"

	$nsg=Get-AzNetworkSecurityGroup|Where-Object{!$_.NetworkInterfaces -and !$_.Subnets}
	
	Return $nsg
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
		DefaultParameterSetName="SubscriptionID",
		SupportsShouldProcess=$false,
		ConfirmImpact='low'
	)]

	param(
		[Parameter(Mandatory=$true)][string] $SubscriptionID
	)

    Select-AzSubscription -SubscriptionId $SubscriptionID|Out-Null
	Write-Debug "Subscription: $SubscriptionID"

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
		DefaultParameterSetName="SubscriptionID",
		SupportsShouldProcess=$false,
		ConfirmImpact='low'
	)]

	param(
		[Parameter(Mandatory=$true)][string] $SubscriptionID
	)

    Select-AzSubscription -SubscriptionId $SubscriptionID|Out-Null
	Write-Debug "Subscription: $SubscriptionID"

	$alerts = New-Object System.Collections.ArrayList
	$rgs=Get-AzResourceGroup
	foreach ($r in $rgs)
	{
		$a=Get-AzAlertRule -ResourceGroupName $r.ResourceGroupName -WarningAction Ignore|Where-Object{$_.IsEnabled -eq $false}
    
		if ($a.IsEnabled -eq $false) {
			$al=New-Object MyRGandName
			$al.RG=$r.ResourceGroupName
			$al.Name=$a.Name
			$alerts.Add($al)|Out-Null
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
		DefaultParameterSetName="SubscriptionID",
		SupportsShouldProcess=$false,
		ConfirmImpact='Low'
	)]

	param(
		[Parameter(Mandatory=$true)][string] $SubscriptionID
	)

    Select-AzSubscription -SubscriptionId $SubscriptionID|Out-Null
	Write-Debug "Subscription: $SubscriptionID"

	$logalerts = New-Object System.Collections.ArrayList
	$rg=Get-AzResourceGroup
	foreach ($r in $rg)
	{
		$a=Get-AzActivityLogAlert -ResourceGroupName $r.ResourceGroupName -WarningAction Ignore -ErrorAction Ignore|Where-Object{$_.Enabled -eq $false}

		if ($a.Enabled -eq $false){
			$al=New-Object MyRGandName
			$al.RG=$r.ResourceGroupName
			$al.Name=$a.Name
			$logalerts.Add($al)|Out-Null
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
		DefaultParameterSetName="SubscriptionID",
		SupportsShouldProcess=$false,
		ConfirmImpact='Low'
	)]

	param(
		[Parameter(Mandatory=$true)][string] $SubscriptionID
	)

    Select-AzSubscription -SubscriptionId $SubscriptionID|Out-Null
	Write-Debug "Subscription: $SubscriptionID"

	$emptyrgs = New-Object System.Collections.ArrayList
	$rgs=Get-AzResourceGroup

	$rgs|ForEach-Object {
		$rgd=Get-AzResource -ResourceGroupName $_.ResourceGroupName -WarningAction SilentlyContinue -ErrorAction SilentlyContinue -ErrorVariable $rgerr
		if (!$rgd -and $rgerr -eq $null) {
			$emptyrgs.add($_)|Out-Null
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
		DefaultParameterSetName="SubscriptionID",
		SupportsShouldProcess=$false,
		ConfirmImpact='Low'
	)]

	param(
		[Parameter(Mandatory=$true)][string] $SubscriptionID
	)

    Select-AzSubscription -SubscriptionId $SubscriptionID|Out-Null
	Write-Debug "Subscription: $SubscriptionID"

	$actiongroups2 = New-Object System.Collections.ArrayList
	$rgs=Get-AzResourceGroup
	foreach ($rg in $rgs) {
		$ags=Get-AzResource -ResourceGroupName $rg.ResourceGroupName -ResourceType microsoft.insights/actionGroups
		foreach ($a in $ags) {
			$TempHoldActionGroup=New-Object MyRGandName
			$TempHoldActionGroup.RG=$rg.ResourceGroupName
			$TempHoldActionGroup.Name=$a.Name
			if ($a.Name.Length -gt 0) {
				$actiongroups2.Add($TempHoldActionGroup)|Out-Null
			}
		}
	}
	
	$actiongroups = New-Object System.Collections.ArrayList
	foreach ($rg in $rgs) {
		$ala=Get-AzActivityLogAlert -ResourceGroupName $rg.ResourceGroupName -WarningAction SilentlyContinue -ErrorAction SilentlyContinue -ErrorVariable $alerr
		if ($ala -and $alerr.count -lt 1) {
			foreach ($a in $ala) {
				$as=$a.Actions.ActionGroups[0].ActionGroupId.Split("/")
	
				$TempHoldActionGroup=New-Object MyRGandName
				$TempHoldActionGroup.RG=$rg.ResourceGroupName
				$TempHoldActionGroup.Name=$as.GetValue($as.Count -1)
	
				$actiongroups.add($TempHoldActionGroup)|Out-Null
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
		DefaultParameterSetName="SubscriptionID",
		SupportsShouldProcess=$false,
		ConfirmImpact='Low'
	)]

	param(
		[Parameter(Mandatory=$true)][string] $SubscriptionID
	)

    Select-AzSubscription -SubscriptionId $SubscriptionID|Out-Null
	Write-Debug "Subscription: $SubscriptionID"

	$routelist = New-Object System.Collections.ArrayList
	$routes=Get-AzRouteTable
	$routes|ForEach-Object {
		if ($route.Subnets.Count -eq 0) {
            $routelist.add($_)|Out-Null
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
		DefaultParameterSetName="SubscriptionID",
		SupportsShouldProcess=$false,
		ConfirmImpact='Low'
	)]

	param(
		[Parameter(Mandatory=$true)][string] $SubscriptionID
	)

    Select-AzSubscription -SubscriptionId $SubscriptionID|Out-Null
	Write-Debug "Subscription: $SubscriptionID"

	$emptysubnets=New-Object System.Collections.ArrayList
	$vnets=Get-AzVirtualNetwork
	foreach ($vnet in $vnets) {
		if ($vnet.Subnets.Count -eq 0) {
			$emptysubnets.add($vnet)|Out-Null
			#Write-Host "VNet without subnets defined found: " + $vnet.Name
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
		DefaultParameterSetName="SubscriptionID",
		SupportsShouldProcess=$false,
		ConfirmImpact='Low'
	)]

	param(
		[Parameter(Mandatory=$true)][string] $SubscriptionID,
        [Parameter(Mandatory=$false)][int] $Days = 365
	)

	Select-AzSubscription -SubscriptionId $SubscriptionID|Out-Null
    Write-Debug "Subscription: $SubscriptionID"

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
		DefaultParameterSetName="SubscriptionID",
		SupportsShouldProcess=$false,
		ConfirmImpact='Low'
	)]

	param(
		[Parameter(Mandatory=$true)][string] $SubscriptionID
	)

    Select-AzSubscription -SubscriptionId $SubscriptionID|Out-Null
	Write-Debug "Subscription: $SubscriptionID"

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
		DefaultParameterSetName="TenantID",
		SupportsShouldProcess=$false,
		ConfirmImpact='Low'
	)]

	param(
		[Parameter(Mandatory=$true)][string] $TenantID
	)

    Connect-AzureAD -TenantId $TenantID
	Write-Debug "Tenant ID: $TenantID"

    $emptygroups=New-Object System.Collections.ArrayList
    Get-AzureADGroup|ForEach-Object {
        $aadgmem=Get-AzureADGroupMember -ObjectId $_.ObjectId
        if($aadgmem.Count -lt 1) {
            $emptygroups.add($_)|Out-Null
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
		DefaultParameterSetName="SubscriptionID",
		SupportsShouldProcess=$false,
		ConfirmImpact='Low'
	)]

	param(
		[Parameter(Mandatory=$true)][string] $SubscriptionID
	)

    Select-AzSubscription -SubscriptionId $SubscriptionID|Out-Null
	Write-Debug "Subscription ID: $SubscriptionID"

	$disabledlapps = New-Object System.Collections.ArrayList
	Get-AzResourceGroup|ForEach-Object {
		$lapps=Get-AzResource -ResourceGroupName $_.ResourceGroupName -ResourceType "Microsoft.Logic/workflows"
		$lapps|ForEach-Object {
			$lapp=Get-AzLogicApp -ResourceGroupName $_.ResourceGroupName -Name $_.Name|Where-Object{$_.State -eq "Disabled"}
			$disabledlapps.add($lapp)|Out-Null
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
		DefaultParameterSetName="SubscriptionID",
		SupportsShouldProcess=$false,
		ConfirmImpact='Low'
	)]

	param(
		[Parameter(Mandatory=$true)][string] $SubscriptionID,
        [Parameter(Mandatory=$false)][int] $Days = 365
	)

	Select-AzSubscription -SubscriptionId $SubscriptionID|Out-Null
    Write-Debug "Subscription ID: $SubscriptionID"

    $snap=Get-AzSnapshot|Where-Object{$_.TimeCreated -lt (Get-Date).AddDays(-$Days)}
    
    Return $snap
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
		DefaultParameterSetName="SubscriptionID",
		SupportsShouldProcess=$false,
		ConfirmImpact='Low'
	)]

	param(
		[Parameter(Mandatory=$true)][string] $SubscriptionID
	)

    Select-AzSubscription -SubscriptionId $SubscriptionID|Out-Null
	Write-Debug "Subscription ID: $SubscriptionID"

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
		DefaultParameterSetName="SubscriptionID",
		SupportsShouldProcess=$false,
		ConfirmImpact='Low'
	)]

	param(
		[Parameter(Mandatory=$true)][string] $SubscriptionID
	)

    Select-AzSubscription -SubscriptionId $SubscriptionID|Out-Null
	Write-Debug "Subscription ID: $SubscriptionID"

    $dtmpro=Get-AzTrafficManagerProfile|Where-Object{$_.ProfileStatus -eq "Disabled"}

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
		DefaultParameterSetName="SubscriptionID",
		SupportsShouldProcess=$false,
		ConfirmImpact='Low'
	)]

	param(
		[Parameter(Mandatory=$true)][string] $SubscriptionID
	)

    Select-AzSubscription -SubscriptionId $SubscriptionID|Out-Null
	Write-Debug "Subscription ID: $SubscriptionID"

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
		DefaultParameterSetName="SubscriptionID",
		SupportsShouldProcess=$false,
		ConfirmImpact='Low'
	)]

	param(
		[Parameter(Mandatory=$true)][string] $SubscriptionID,
        [Parameter(Mandatory=$false)][int] $Days = 7
	)

    Select-AzSubscription -SubscriptionId $SubscriptionID|Out-Null
	Write-Debug "Subscription ID: $SubscriptionID"

	$oldcaptures=Get-AzNetworkWatcher|Get-AzNetworkWatcherPacketCapture|Where-Object{$_.PacketCaptureStatus -ne "Running" -and $_.CaptureStartTime -lt (Get-Date).AddDays(-$Days) }

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
		DefaultParameterSetName="SubscriptionID",
		SupportsShouldProcess=$false,
		ConfirmImpact='Low'
	)]

	param(
		[Parameter(Mandatory=$true)][string] $SubscriptionID
	)

    Select-AzSubscription -SubscriptionId $SubscriptionID|Out-Null
	Write-Debug "Subscription ID: $SubscriptionID"

	$vngwconns = New-Object System.Collections.ArrayList
	Get-AzResourceGroup|ForEach-Object {

		$rg=$_.ResourceGroupName
		$vngwconn=Get-AzVirtualNetworkGatewayConnection -ResourceGroupName $rg

		if ($vngwconn.name.Length -gt 0) {
			#$vngwconnname=$vngwconn.name

			$vngwconn|ForEach-Object {
				$vngwconn2=Get-AzVirtualNetworkGatewayConnection -ResourceGroupName $rg -Name $_.Name|Where-Object {$_.ConnectionStatus -ne "Connected"}
				$vngwconns.Add($vngwconn2)|Out-Null

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
		DefaultParameterSetName="SubscriptionID",
		SupportsShouldProcess=$false,
		ConfirmImpact='Low'
	)]

	param(
		[Parameter(Mandatory=$true)][string] $SubscriptionID
	)

	Select-AzSubscription -SubscriptionId $SubscriptionID|Out-Null
	Write-Debug "Subscription ID: $SubscriptionID"

	$expiredWebhks = New-Object System.Collections.ArrayList
	Get-AzAutomationAccount|ForEach-Object {
		$webhks=Get-AzAutomationWebhook -ResourceGroupName $_.ResourceGroupName -AutomationAccountName $_.AutomationAccountName|Where-Object {$_.ExpiryTime -lt (Get-Date)}
		$webhks|ForEach-Object {
			$expiredWebhks.Add($_)|Out-Null
		}
	}

	Return $expiredWebhks

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
		DefaultParameterSetName="SubscriptionID",
		SupportsShouldProcess=$false,
		ConfirmImpact='Low'
	)]

	param(
		[Parameter(Mandatory=$true)][string] $SubscriptionID,
        [Parameter(Mandatory=$true)][string] $TenantID,
        [Parameter(Mandatory=$false)][int] $Days = 365
	)

    Connect-AzureAD -TenantId $TenantID|Out-Null
    Select-AzSubscription -SubscriptionId $SubscriptionID|Out-Null

	Write-Debug "Tenant ID: $TenantID"
    Write-Debug "Subscription ID: $SubscriptionID"
    Write-Debug "Days: $Days"
    
    Write-Host "Ununsed NICs:" -ForegroundColor Cyan
    Get-AzSMUnusedNICs -Subscription $SubscriptionID
    
    Write-Host "Ununsed NSGs:" -ForegroundColor Cyan
    Get-AzSMUnusedNSGs -Subscription $SubscriptionID
    
    Write-Host "Ununsed PIPs:" -ForegroundColor Cyan
    Get-AzSMUnusedPIPs -Subscription $SubscriptionID
    
    Write-Host "Disabled Alerts(Classic):" -ForegroundColor Cyan
    Get-AzSMDisabledAlerts -Subscription $SubscriptionID
    
    Write-Host "Disabled Log Alerts:" -ForegroundColor Cyan
    Get-AzSMDisabledLogAlerts -Subscription $SubscriptionID
    
    Write-Host "Empty Resource Groups:" -ForegroundColor Cyan
    Get-AzSMEmptyResourceGroups -Subscription $SubscriptionID
    
    Write-Host "Ununsed Alert Groups:" -ForegroundColor Cyan
    Get-AzSMUnusedAlertActionGroups -Subscription $SubscriptionID
    
    Write-Host "Ununsed Route Tables:" -ForegroundColor Cyan
    Get-AzSMUnusedRouteTables -Subscription $SubscriptionID
    
    Write-Host "VNets without Subnets:" -ForegroundColor Cyan
    Get-AzSMVNetsWithoutSubnets -Subscription $SubscriptionID
    
    Write-Host "Old Deployments older than $Days days:" -ForegroundColor Cyan
    Get-AzSMOldDeployments -Subscription $SubscriptionID
    
    Write-Host "Ununsed Disks:" -ForegroundColor Cyan
    Get-AzSMUnusedDisks -Subscription $SubscriptionID
    
    Write-Host "Empty AAD Groups:" -ForegroundColor Cyan
    Get-AzSMEmptyAADGroups -Subscription -TenantId $TenantID
    
    Write-Host "Disabled Logic Apps:" -ForegroundColor Cyan
    Get-AzSMDisabledLogicApps -Subscription $SubscriptionID
    
    Write-Host "Old Snapshots older than $Days days:" -ForegroundColor Cyan
    Get-AzSMOldSnapshots -Subscription $SubscriptionID
    
    Write-Host "ILBs with no backend pools:" -ForegroundColor Cyan
    Get-AzSMIlbNoBackendPool -Subscription $SubscriptionID

    Write-Host "Disabled TrafficManager Profiles:" -ForegroundColor Cyan
    Get-AzSMDisabledTrafficManagerProfiles -Subscription $SubscriptionID
    
    Write-Host "TrafficManager Profiles With No Endpoints:" -ForegroundColor Cyan
    Get-AzSMTrafficManagerProfilesWithNoEndpoints -Subscription $SubscriptionID

	Write-Host "Old Network Watcher packet captures" -ForegroundColor Cyan
	Get-AzSMOldNetworkCaptures -SubscriptionID $SubscriptionID

	Write-Host "Unconnected Virtual Network Gateway Connections" -ForegroundColor Cyan
	Get-AzSMUnconnectedVirtualNetworkGateways -SubscriptionID $SubscriptionID

	Write-Host "Expired Webhooks" -ForegroundColor Cyan
	Get-AzSMExpiredWebhooks -SubscriptionID $SubscriptionID
}
