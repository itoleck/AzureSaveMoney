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
        Get-AzSMAllResources -Subscription 00000000-0000-0000-0000-000000000000 -Tenant 00000000-0000-0000-0000-000000000000 -Days 31 > c:\temp\AzureSaveMoney.txt
        Gets a list of all supported unused and old resources in a tenant/subscription combination.
        .NOTES
        * CANNOT be piped to any Remove- Azure command.
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

    If (-not [string]::IsNullOrEmpty($Applicationid) -AND -not [string]::IsNullOrEmpty($CertificateThumbprint)) {
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

      Write-Output 'FunctionApps without Functions:'
      Get-AzSmEmptyFunctionApps -SubscriptionID $SubscriptionID

      Write-Output 'Empty NotificationHubNamespaces:'
      Get-AzSMEmptyNotificationHubNamespaces -SubscriptionID $SubscriptionID
  }

  #Export-ModuleMember -Function Get-AzSMAllResources
