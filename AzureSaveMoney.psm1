#requires -Version 5.0 -Modules Az.Accounts, Az.Automation, Az.Compute, Az.LogicApp, Az.Network, Az.Resources, Az.TrafficManager, AzureAD
#!/usr/bin/env powershell
# Contributors:
# Chad Schultz (MSFT)
#
# PowerShell module to List on and delete unused Azure resources and save money.
#
# This Sample Code is provided for the purpose of illustration only and is not intended to be used in a production environment.  THIS SAMPLE CODE AND ANY RELATED INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.  We grant You a nonexclusive, royalty-free right to use and modify the Sample Code and to reproduce and distribute the object code form of the Sample Code, provided that You agree: (i) to not use Our name, logo, or trademarks to market Your software product in which the Sample Code is embedded; (ii) to include a valid copyright notice on Your software product in which the Sample Code is embedded; and (iii) to indemnify, hold harmless, and defend Us and Our suppliers from and against any claims or lawsuits, including attorneys fees, that arise or result from the use or distribution of the Sample Code.

#Install all of the functions using dot-sourcing in the current PS session when this module loads.
Write-Output "Installing module from $PSScriptRoot"
foreach($file in (Get-ChildItem "$PSScriptRoot\functions" -Filter *.ps1 -Recurse)) { . $file.FullName } # Future function split out to files

# Class to hold alert resource groups and names as script has to get RGs from different comdlet than alert.
Class MyRGandName
{
  [String]$RG
  [String]$Name
}
