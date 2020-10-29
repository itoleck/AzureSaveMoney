function global:Get-AzSMVMsNotDeletedAfterImage {

    <#
        .SYNOPSIS
        List virtual machines that were not deleted after a generalized image in a subscription.
        .DESCRIPTION
        List virtual machines that were not deleted after a generalized image in a subscription.
        .PARAMETER SubscriptionID
        Azure subscription ID in the format, 00000000-0000-0000-0000-000000000000
        .OUTPUTS
        AzureSaveMoney.MyRGandName
        .EXAMPLE
        Get-AzSMVMsNotDeletedAfterImage -SubscriptionID 00000000-0000-0000-0000-000000000000
        .NOTES
        * CANNOT pipe to Remove- command. Output is text based only.
        .LINK
    #>
  
    [CmdletBinding(
        DefaultParameterSetName='SubscriptionID',
        ConfirmImpact='Low'
    )]
  
    param(
      [Parameter(Mandatory=$true)][string] $SubscriptionID
    )
  
      $null = Set-AzContext -SubscriptionId $SubscriptionID
    Write-Debug ('Subscription ID: {0}' -f $SubscriptionID)
  
    $vms = New-Object System.Collections.ArrayList
  $images=Get-Azimage -WarningAction Ignore
  
  foreach ($image in $images)
    {
      $svm=Get-AzResource -ResourceId $image.SourceVirtualMachine.Id -ErrorAction Ignore -WarningAction Ignore
      if ($svm){
                $vm=New-Object MyRGandName
                $vm.RG=$svm.ResourceGroupName
                $vm.Name=$svm.Name
                $vms.Add($vm)
      }
    }
    Return $vms|Select-Object @{n="ResourceGroupName";e="RG"}, @{n="VMName";e="Name"}
 }
 Export-ModuleMember -Function Get-AzSMVMsNotDeletedAfterImage