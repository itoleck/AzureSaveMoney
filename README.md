# Introduction
PowerShell module with 25+ commands to report on, and opportunity to delete unused Azure resources and save money.

PowerShell Gallery URL; https://www.powershellgallery.com/packages/AzureSaveMoney

Project available here; https://github.com/itoleck/AzureSaveMoney

Report on the following resource types:

Unused Network Interfaces

Unused Network Security Groups

Unused Public IP addresses

Empty Resource Groups

Old Resource Group Deployments

Classic Alerts on resource no longer available

Log Alerts on resource no longer available

Unused Alert Action Groups

Virtual Networks without subnets

Unused Rout Tables

Unused Managed Disks

Empty AAD Groups

Disabled Logic Apps

Old snapshots

Load balancers with no backend pool

Load balancers with no backend pool virtual machines

Disabled Traffic Manager profiles

Traffic Manager profiles with no endpoints

Unconnected Virtual Network Gateways

Expired Webhooks

Virtual Machine performance information for manual scaling

App Service Plan performance information for manual scaling

Unused App Service Plans

Empty subnets

Disabled Service Bus Queues

Batch Accounts without applications

Virtual Machines not deleted after generalizing and imaging

Includes ability to report on all unused resources in a single command, Get-AzSMAllResources.


# Getting Started

Install dependencies.

PS> Install-Module Az.Accounts, Az.Automation, Az.Compute, Az.LogicApp, Az.Network, Az.Resources, Az.TrafficManager, AzureAD, Az.CostManagement, Az.Monitor, Az.Websites, Az.ServiceBus, Az.Batch, Az.Functions, Az.NotificationHubs

Install module form the PowerShell Gallery.

PS> Install-Module -Name AzureSaveMoney

Alternatively,

Download the .psm1 PowerShell module from the repository; https://github.com/itoleck/AzureSaveMoney and copy to your local computer.

Install-Module -Path <path to AzureSaveMoney.psm1>

Examples:

Get list of Azure Subscription and Tenants

    Get-AzSubscription

This will report all of the unused resource checks that are included in the module in a subscription and Tenant with old resource date checks back 31 days.

    Get-AzSMAllResources -Subscription 00000000-0000-0000-0000-000000000000 -TenantID 00000000-0000-0000-0000-000000000000 -Days 31

This will report only the unused Network Interfaces in a subscription.

    Get-AzSMUnusedNICs -Subscription 00000000-0000-0000-0000-000000000000

Most commands can be piped to remove the reported resources. Check get-help for notes on piping.
This will remove all unused Network Security Groups from a subscription with confirmation.

    Get-AzSMUnusedNSGs -Subscription 00000000-0000-0000-0000-000000000000|Remove-AzureRmNetworkSecurityGroups


There is support for PowerShell help.


    Get-Help get-azsmunusednics -full

NAME

    Get-AzSMUnusedNICs

SYNOPSIS

    Lists unused NICs in a subscription.

SYNTAX

    Get-AzSMUnusedNICs [-SubscriptionID] <String> [<CommonParameters>]

DESCRIPTION

    Lists unused NICs in a subscription.

PARAMETERS

    -SubscriptionID <String>
        Azure subscription ID in the format, 00000000-0000-0000-0000-000000000000

        Required?                    true
        Position?                    1
        Default value
        Accept pipeline input?       false
        Accept wildcard characters?  false

    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https:/go.microsoft.com/fwlink/?LinkID=113216).

INPUTS

OUTPUTS

    Microsoft.Azure.Commands.Network.Models.PSNetworkInterface


NOTES

        * CAN be piped to Remove-AzureRmNetworkInterface.

    -------------------------- EXAMPLE 1 --------------------------

    PS C:\>Get-AzSMUnusedNICs -Subscription 00000000-0000-0000-0000-000000000000

    Get a list of unused network interfaces in a subscription.

    -------------------------- EXAMPLE 2 --------------------------

    PS C:\>Get-AzSMUnusedNICs -Subscription 00000000-0000-0000-0000-000000000000 | Remove-AzureRmNetworkInterface

    Remove unused network interfaces in a subscription with confirmation.

        * All commands have a subscription or tenant parameter. If this is not specified and your PowerShell session is logged in the command will used your session's current subscription.

        * Using this module in Azure Automation requires a connection to the subscription.

        $Conn = Get-AutomationConnection -Name AzureRunAsConnection

        Connect-AzureRmAccount -ServicePrincipal -Tenant $Conn.TenantID -ApplicationId $Conn.ApplicationID -CertificateThumbprint $Conn.CertificateThumbprint

        * When piping the AzureSaveMoney command to the AzureRM PowerShell Remove- commands include the -force parameter or -confirm parameter if supported to supress prompts.

# Contribute

If you want to learn more about creating good readme files then refer the following [guidelines](https://www.visualstudio.com/en-us/docs/git/create-a-readme). You can also seek inspiration from the below readme files:
- [ASP.NET Core](https://github.com/aspnet/Home)
- [Visual Studio Code](https://github.com/Microsoft/vscode)
