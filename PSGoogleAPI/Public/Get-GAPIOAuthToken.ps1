Function Get-GOAuthToken {
    <#
    .SYNOPSIS
        Function to get OAuth tokens for Google API.
    .DESCRIPTION
        Function requests the access token.
        Function uses client_id and client secret created in the Googe API console.
        Function requres autorization code obtained by Get-GOAuthCode.
        Function returns an object with access token, refresh token and some more details.
    .EXAMPLE
        Get-GOAuthToken -Credential $cred
        Starts default browser on a page to authorize the application.
    #>
    [CmdletBinding()]
    Param (
        # Authorization code obtained after running Get-GAPIOAuthCode (read help)
        [Parameter(Mandatory)]
        [string]
        $Code,

        # Credential should contain client_id in username and client secred in password
        [Parameter()]
        [pscredential]
        [System.Management.Automation.CredentialAttribute()]
        $ClientCredential = (Import-Credential -FileName client.cred),

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
        code = $Code
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