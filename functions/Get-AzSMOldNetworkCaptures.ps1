function global:Get-AzSMOldNetworkCaptures {

    <#
        .SYNOPSIS
        List old Network Watcher packet captures in a subscription.
        .DESCRIPTION
        List old Network Watcher packet captures in a subscription.
        .PARAMETER SubscriptionID
        Azure subscription ID in the format, 00000000-0000-0000-0000-000000000000
        .PARAMETER Days
          Set to the number of days to scan back for old captures.
          Default is 7 days old.
        .OUTPUTS
        Microsoft.Azure.Commands.Network.Models.PSGetPacketCaptureResult
        .EXAMPLE
        Get-AzSMOldNetworkCaptures -SubscriptionID 00000000-0000-0000-0000-000000000000 -Days 31
        Get Network Watcher packet captures ran more than 31 days ago.
        .NOTES
        *CANNOT be piped to Remove-AzNetworkWatcherPacketCapture.
        Does not return the .cap files that may be saved in storage.
        .LINK
    #>
  
    [CmdletBinding(
        DefaultParameterSetName='SubscriptionID',
        ConfirmImpact='Low'
    )]
  
    param(
      [Parameter(Mandatory=$true)][string] $SubscriptionID,
      [Parameter(Mandatory=$true)][string] $ResourceGroupName,
      [int] $Days = 7
    )
  
    $null = Set-AzContext -SubscriptionId $SubscriptionID
    Write-Debug ('Subscription ID: {0}' -f $SubscriptionID)
  
    if ($ResourceGroupName.Length -gt 0) {
      $oldcaptures=Get-AzNetworkWatcher -ResourceGroupName $ResourceGroupName|Get-AzNetworkWatcherPacketCapture|Where-Object{$_.PacketCaptureStatus -ne 'Running' -and $_.CaptureStartTime -lt (Get-Date).AddDays(-$Days) }
    } else {
      $oldcaptures=Get-AzNetworkWatcher|Get-AzNetworkWatcherPacketCapture|Where-Object{$_.PacketCaptureStatus -ne 'Running' -and $_.CaptureStartTime -lt (Get-Date).AddDays(-$Days) }
    }

    Return $oldcaptures
}
Export-ModuleMember -Function Get-AzSMOldNetworkCaptures