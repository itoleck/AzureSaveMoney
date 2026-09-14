function global:Get-AzSMExpiringWebAppCertificates {

    <#
        .SYNOPSIS
        List App Service certificates that expire within 31 days or are already expired in a subscription.
        .DESCRIPTION
        List App Service certificates that expire within 31 days or are already expired in a subscription.
        A ResourceGroupName property is added to each certificate so the output has the values needed by Remove-AzWebAppCertificate.
        .PARAMETER SubscriptionID
        Azure subscription ID in the format, 00000000-0000-0000-0000-000000000000
        .PARAMETER ResourceGroupName
        A single Azure resource group name to scope query to
        .PARAMETER Days
          Set to the number of days ahead to check for expiring certificates.
          Default is 31 days.
        .OUTPUTS
        Microsoft.Azure.Commands.WebApps.Models.WebApp.PSCertificate
        .EXAMPLE
        Get-AzSMExpiringWebAppCertificates -SubscriptionID 00000000-0000-0000-0000-000000000000
        Get a list of App Service certificates that expire within 31 days or are already expired in a subscription.
        .EXAMPLE
        Get-AzSMExpiringWebAppCertificates -SubscriptionID 00000000-0000-0000-0000-000000000000|ForEach-Object {Remove-AzWebAppCertificate -ResourceGroupName $_.ResourceGroupName -ThumbPrint $_.Thumbprint}
        Remove App Service certificates that expire within 31 days or are already expired in a subscription without confirmation.
        .NOTES
        * CANNOT be piped directly to Remove-AzWebAppCertificate, its parameters do not accept pipeline input. Use ForEach-Object with the ResourceGroupName and Thumbprint properties.
        * Remove-AzWebAppCertificate does not prompt for confirmation.
        .LINK
    #>

    [CmdletBinding(
        DefaultParameterSetName='SubscriptionID',
        ConfirmImpact='Low'
    )]

    param(
      [Parameter(Mandatory=$true)][string] $SubscriptionID,
      [Parameter(Mandatory=$false)][string] $ResourceGroupName,
      [int] $Days = 31
    )

    $null = Set-AzContext -SubscriptionId $SubscriptionID
    Write-Debug ('Subscription ID: {0}' -f $SubscriptionID)

    if ($ResourceGroupName.Length -gt 0) {
      $certs=Get-AzWebAppCertificate -ResourceGroupName $ResourceGroupName
    } else {
      $certs=Get-AzWebAppCertificate
    }

    $expiringCerts=$certs|Where-Object{$null -ne $_.ExpirationDate -and $_.ExpirationDate -lt (Get-Date).AddDays($Days)}

    #Certificate objects do not include a resource group, add it from the resource Id for Remove-AzWebAppCertificate.
    $expiringCerts|ForEach-Object {
      $_|Add-Member -MemberType NoteProperty -Name ResourceGroupName -Value ($_.Id -split '/')[4] -Force
    }

    Return $expiringCerts
}
Export-ModuleMember -Function Get-AzSMExpiringWebAppCertificates
