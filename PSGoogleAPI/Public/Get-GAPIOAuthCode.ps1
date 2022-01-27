Function Get-GAPIOAuthCode {
    <#
    .SYNOPSIS
        Function to get OAuth code for Google API.
    .DESCRIPTION
        Credentials must be precreated on https://console.cloud.google.com/apis/credentials page.
        ClientId is client_id field
        RedirectUri is redirect_uri field
        Scope of the toke, it must be allowed in the project.
    .EXAMPLE
        Get-GOAuthCode -Credential $cred
        Starts default browser on a page to authorize the application.
    #>
    [CmdletBinding()]
    Param (
        # Client Id of the API credential
        [Parameter(Mandatory)]
        [string]$ClientId,

        # Call back URI specified in the Project
        [Parameter()]
        [string]$RedirectUri = 'http://localhost',

        # Scope of the token that will be requested with the code
        [Parameter()]
        [uri]$Scope = 'https://www.googleapis.com/auth/calendar',

        # URI to get OAuth code
        [Parameter()]
        [uri]$UriBase = 'https://accounts.google.com/o/oauth2/auth'
    )
    
    $body = @{
        client_id = $ClientId
        scope = $Scope
        response_type = 'code'
        redirect_uri = $RedirectUri
        access_type = 'offline'
        approval_prompt = 'force'
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
    
    Start-Process -FilePath $fullUri
}