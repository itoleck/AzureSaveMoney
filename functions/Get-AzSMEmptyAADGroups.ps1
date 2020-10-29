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
        * It is not recommended to pipe command to remove AAD groups as there are built-in and synced groups that may have not members.
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
Export-ModuleMember -Function Get-AzSMEmptyAADGroups