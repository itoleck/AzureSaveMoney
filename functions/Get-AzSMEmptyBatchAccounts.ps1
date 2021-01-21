function global:Get-AzSMEmptyBatchAccounts {

    <#
        .SYNOPSIS
        Lists batch accounts with no applications in a subscription.
        .DESCRIPTION
        Lists batch accounts with no applications in a subscription.
        .PARAMETER SubscriptionID
        Azure subscription ID in the format, 00000000-0000-0000-0000-000000000000
        .PARAMETER ResourceGroupName
        A single Azure resource group name to scope query to
        .OUTPUTS
        AzureSaveMoney.MyRGandName
        .EXAMPLE
        Get-AzSMEmptyBatchAccounts -Subscription 00000000-0000-0000-0000-000000000000
        Get a list of batch accounts with no applications in a subscription.
        .EXAMPLE
        .
        .NOTES
        * CANNOT pipe to Remove- command. Output is text based only.
        *
        .LINK
    #>
  
    [CmdletBinding(
        DefaultParameterSetName='SubscriptionID',
        ConfirmImpact='low'
    )]
  
    param(
      [Parameter(Mandatory=$true)][string] $SubscriptionID,
      [Parameter(Mandatory=$true)][string] $ResourceGroupName
    )
  
    $null = Set-AzContext -SubscriptionId $SubscriptionID
    Write-Debug ('Subscription: {0}' -f $SubscriptionID)
  
    $apps = New-Object System.Collections.ArrayList
    
    if ($ResourceGroupName.Length -gt 0) {
      $bas=Get-AzBatchAccount -ResourceGroupName $ResourceGroupName -WarningAction Ignore
    } else {
      $bas=Get-AzBatchAccount -WarningAction Ignore
      }

      foreach ($ba in $bas)
      {
        $a=Get-AzBatchApplication -ResourceGroupName $ba.ResourceGroupName -AccountName $ba.AccountName -WarningAction Ignore
          
          if ($a.Id.Length -lt 1) {
              $ap=New-Object MyRGandName
              $ap.RG=$ba.ResourceGroupName
              $ap.Name=$ba.AccountName
              $null = $apps.Add($ap)
          }
      }
    
    Return $apps|Select-Object @{n="ResourceGroupName";e="RG"}, @{n="AccountName";e="Name"}
 }
 Export-ModuleMember -Function Get-AzSMEmptyBatchAccounts