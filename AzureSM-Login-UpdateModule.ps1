#Azure login and module updating

#If AzureAD module is not installed
Install-Module AzureAD -Scope AllUsers -AllowClobber
Import-Module AzureAD

#For updating local module during testing
Set-Location -Path $env:USERPROFILE\source\repos\AzureSaveMoney
Import-Module .\AzureSaveMoney.psd1 -Verbose -Force -Scope Local -MinimumVersion 1.0.16
Get-Module AzureSaveMoney -Verbose

#Login before running Azure commands
Add-AzAccount
