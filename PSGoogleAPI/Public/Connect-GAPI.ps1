Function Connect-GAPI {
    <#
    .SYNOPSIS
        Function to get OAuth tokens for Google API.
    .DESCRIPTION
        
    .EXAMPLE
        Get-GOAuthToken -Credential $cred
        Starts default browser on a page to authorize the application.
    #>
    [CmdletBinding()]
    Param (
        # Credential should contain client_id in username and client secred in password
        [Parameter(Mandatory)]
        [pscredential]
        [System.Management.Automation.CredentialAttribute()]
        $ClientCredential = (Import-Credential -FileName client.cred),

        # Credential should contain code in password, username is not used
        [Parameter(Mandatory)]
        [pscredential]
        [System.Management.Automation.CredentialAttribute()]
        $CodeCredential,

        # Call back URI specified in the Project
        [Parameter()]
        [string]$RedirectUri = 'http://localhost',

        # Scope of the token that will be requested with the code
        [Parameter()]
        [uri]$Scope = 'https://www.googleapis.com/auth/calendar',

        # URI to get code
        [Parameter()]
        [uri]$UriBase = 'https://www.googleapis.com/oauth2/v4/token'
    )

    $body = @{
        code = $CodeCredential.GetNetworkCredential().Password
        client_id = $ClientCredential.UserName
        client_secret = $ClientCredential.GetNetworkCredential().Password
        redirect_uri = $RedirectUri
        grant_type = 'authorization_code'
    }
    
    try {
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