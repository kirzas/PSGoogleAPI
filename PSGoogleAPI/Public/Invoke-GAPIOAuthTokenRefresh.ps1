Function Invoke-GAPIOAuthTokenRefresh {
    <#
    .SYNOPSIS
        Function to refresh OAuth tokens for Google API.
    .DESCRIPTION
        The fundtion starts the default browser on a page to authorize the application.
        After the authorization is complete, it will open URI with callback set in your project.
        URI contains the authorization code. Copy it before closing the browser.
    .EXAMPLE
        Invoke-GAPIOAuthTokenRefresh -Credential $cred
        Starts default browser on a page to authorize the application.
    #>
    [CmdletBinding()]
    Param (
        # Credential should contain client_id in username and client secred in password
        [Parameter()]
        [pscredential]
        [System.Management.Automation.CredentialAttribute()]
        $ClientCredential = (Import-Credential -FileName client.cred),

        # Credential should contain refresh token in password, username is not used
        [Parameter()]
        [pscredential]
        [System.Management.Automation.CredentialAttribute()]
        $RefreshToken = (Import-Credential -FileName refresh_token.cred),

        # URI to get code
        [Parameter()]
        [uri]$UriBase = 'https://www.googleapis.com/oauth2/v4/token'
    )
    try {
        $body = @{
            client_id = $ClientCredential.UserName
            client_secret = $ClientCredential.GetNetworkCredential().Password
            refresh_token = $RefreshToken.GetNetworkCredential().Password
            grant_type = 'refresh_token'
        }

        $uriResource = ''
        foreach ($key in $body.Keys) {
            $uriResource = Join-Uri -UriBase $uriResource -Resource "$($key)=$($body[$key])" -Delimiter '&'
        }

        $fullUri = Join-Uri -UriBase $UriBase -Resource $uriResource -Delimiter '?'
    } catch {
        $errorDetailsTemplate = if ($_.ErrorDetails) {
            '{0}; PreviousDetails: $($_.ErrorDetails)'
        } else {
            '{0}'
        }
        $_.ErrorDetails = $errorDetailsTemplate -f "Failed to build URI. The error was: $($_.Exception.Message)"
        $PSCmdlet.ThrowTerminatingError($_)
    }
    
    Invoke-KZRestMethod -Uri $fullUri -Method Post -ErrorAction Stop
}