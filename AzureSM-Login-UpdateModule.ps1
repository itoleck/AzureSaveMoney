#Azure login and module updating

Set-Location -Path $env:USERPROFILE\source\repos\AzureSaveMoney
Import-Module .\AzureSaveMoney.psm1 -Verbose -Force -Global

Login-AzAccount



