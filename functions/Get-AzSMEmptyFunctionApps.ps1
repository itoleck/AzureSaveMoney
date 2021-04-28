function global:Get-AzSMEmptyFunctionApps {

    <#
        .SYNOPSIS
        Lists FunctionApps with no function in a subscription.
        .DESCRIPTION
        Lists FunctionApps with no function in a subscription.
        .PARAMETER SubscriptionID
        Azure subscription ID in the format, 00000000-0000-0000-0000-000000000000
        .OUTPUTS
        AzureSaveMoney.MyRGandName
        .EXAMPLE
        Get-AzSMEmptyFunctionApps -Subscription 00000000-0000-0000-0000-000000000000
        Get a list of FunctionApps with no function in a subscription.
        .EXAMPLE
        .
        .NOTES
        Will only find empty FunctionApps that are running - We can't see functions in stopped FunctionApps.
        .LINK
    #>

    [CmdletBinding(
        DefaultParameterSetName = 'SubscriptionID',
        ConfirmImpact = 'low'
    )]

    param(
        [Parameter(Mandatory = $true)][string] $SubscriptionID
    )

    $null = Set-AzContext -SubscriptionId $SubscriptionID
    Write-Debug ('Subscription: {0}' -f $SubscriptionID)

    foreach ($FunctionApp in Get-AzFunctionApp) {
        if ($FunctionApp.State -ne 'Stopped') { # We can't see functions in stopped apps, so we ignore them
            $GetAzResourceParameters = @{
                ResourceType      = 'Microsoft.Web/sites/functions'
                ResourceGroupName = $FunctionApp.ResourceGroup
                ResourceName      = $FunctionApp.Name
                ApiVersion        = '2020-06-01'
                ErrorAction       = 'SilentlyContinue'
            }
            $Functions = Get-AzResource @GetAzResourceParameters
            if (!$Functions) {
                $FunctionApp
            }
        }
    }
}

Export-ModuleMember -Function Get-AzSMEmptyFunctionApps
