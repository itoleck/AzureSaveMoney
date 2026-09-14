function global:Get-AzSMUnusedPrivateEndpoints {

    <#
        .SYNOPSIS
        List Private Endpoints with no connections in a subscription.
        .DESCRIPTION
        List Private Endpoints with no connections in a subscription or a single resource group.
        The connected resource of each Private Link connection is queried before an endpoint is returned.
        A Private Endpoint is returned when it has no connection that is Approved or Pending to a resource that still exists.
        If a connected resource cannot be queried for a reason other than not found, such as no access, the endpoint is treated as in use and a warning is written.
        .PARAMETER SubscriptionID
        Azure subscription ID in the format, 00000000-0000-0000-0000-000000000000
        .PARAMETER ResourceGroupName
        A single Azure resource group name to scope query to
        .OUTPUTS
        Microsoft.Azure.Commands.Network.Models.PSPrivateEndpoint
        .EXAMPLE
        Get-AzSMUnusedPrivateEndpoints -SubscriptionID 00000000-0000-0000-0000-000000000000
        Get a list of Private Endpoints with no connections in a subscription.
        .EXAMPLE
        Get-AzSMUnusedPrivateEndpoints -SubscriptionID 00000000-0000-0000-0000-000000000000 -ResourceGroupName MyResourceGroup
        Get a list of Private Endpoints with no connections in a single resource group.
        .EXAMPLE
        Get-AzSMUnusedPrivateEndpoints -SubscriptionID 00000000-0000-0000-0000-000000000000 | Remove-AzPrivateEndpoint -Force
        Remove Private Endpoints with no connections in a subscription without confirmation.
        .NOTES
        * CAN be piped to Remove-AzPrivateEndpoint.
        * When piping to remove resources, include the -force parameter to supress prompts.
        .LINK
    #>

    [CmdletBinding(
        DefaultParameterSetName='SubscriptionID',
        ConfirmImpact='Low'
    )]

    param(
      [Parameter(Mandatory=$true)][string] $SubscriptionID,
      [Parameter(Mandatory=$false)][string] $ResourceGroupName
    )

    $null = Set-AzContext -SubscriptionId $SubscriptionID
    Write-Debug ('Subscription ID: {0}' -f $SubscriptionID)

    $unusedEndpoints = New-Object System.Collections.ArrayList
    #Cache connected resource lookups, many endpoints can connect to the same resource.
    $resourceExists = @{}

    if ($ResourceGroupName.Length -gt 0) {
      $endpoints=Get-AzPrivateEndpoint -ResourceGroupName $ResourceGroupName
    } else {
      $endpoints=Get-AzPrivateEndpoint
    }

    foreach ($endpoint in $endpoints) {
      $connected = $false
      $connections = @(@($endpoint.PrivateLinkServiceConnections) + @($endpoint.ManualPrivateLinkServiceConnections) | Where-Object {$null -ne $_})

      foreach ($connection in $connections) {
        $connectedResourceId = $connection.PrivateLinkServiceId
        if ([string]::IsNullOrEmpty($connectedResourceId)) { continue }

        if (-not $resourceExists.ContainsKey($connectedResourceId)) {
          try {
            $resource = Get-AzResource -ResourceId $connectedResourceId -ErrorAction Stop
            $resourceExists[$connectedResourceId] = $null -ne $resource
          } catch {
            if ($_.Exception.Message -match 'NotFound|not found|could not be found') {
              $resourceExists[$connectedResourceId] = $false
            } else {
              Write-Warning ('Could not query connected resource {0} for Private Endpoint {1}, treating as in use. {2}' -f $connectedResourceId, $endpoint.Name, $_.Exception.Message)
              $resourceExists[$connectedResourceId] = $true
            }
          }
        }
        Write-Debug ('Private Endpoint: {0} Connected resource: {1} Exists: {2} Status: {3}' -f $endpoint.Name, $connectedResourceId, $resourceExists[$connectedResourceId], $connection.PrivateLinkServiceConnectionState.Status)

        if ($resourceExists[$connectedResourceId] -and $connection.PrivateLinkServiceConnectionState.Status -in 'Approved','Pending') {
          $connected = $true
          break
        }
      }

      if (-not $connected) {
        $null = $unusedEndpoints.Add($endpoint)
      }
    }

    Return $unusedEndpoints
}
Export-ModuleMember -Function Get-AzSMUnusedPrivateEndpoints
