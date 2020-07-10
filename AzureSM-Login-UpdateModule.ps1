#Azure login and module updating

Set-Location -Path $env:USERPROFILE\source\repos\AzureSaveMoney
ipmo .\AzureSaveMoney.psd1 -Verbose -Force -Global

Login-AzAccount



