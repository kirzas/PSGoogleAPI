Function Invoke-GAPIRestMethod {
    <#
    .SYNOPSIS
        Wrapper around Invoke-RestMethod for Google API calls.
    .DESCRIPTION
        Function adds header with token specificly for Google API.
        There is additional error output.
    .EXAMPLE
        Invoke-GAPIRestMethod

    #>
    [CmdletBinding()]
    Param (
        # Uri
        [Parameter(Mandatory)]
        [uri]$Uri,

        # Rest method to call
        [Parameter()]
        [Microsoft.PowerShell.Commands.WebRequestMethod]
        $Method = 'Get',

        # Body for the request
        [Parameter()]
        [string]$Body,

        # Credential should contain access token in password, username is not used, it is expected to be saved
        [Parameter()]
        [pscredential]
        [System.Management.Automation.CredentialAttribute()]
        $AccessToken = (Import-Credential -FileName access_token.cred)
    )
    $headers = @{
        Authorization = "Bearer $($AccessToken.GetNetworkCredential().Password)"
    }
 
    $irmSplat = @{
        Uri = $Uri
        Method = $Method
        Headers = $headers
        ContentType = 'application/json'
        ErrorAction = 'Stop'
    }

    if ($PSBoundParameters.Keys.Contains('Body')) {
        $irmSplat['Body'] = $Body
    }

    try {
        $restCallOutput = Invoke-KZRestMethod @irmSplat
        if ($ValueOnly) {
            $restCallOutput.Value
        } else {
            $restCallOutput
        }
    } catch {
        $errorDetailsTemplate = if ($_.ErrorDetails) {
            "{0}; PreviousDetails: $($_.ErrorDetails)"
        } else {
            '{0}'
        }
        $_.ErrorDetails = $errorDetailsTemplate -f "$Method call to $Uri failed. The error was: $($_.Exception.Message)"
        $PSCmdlet.ThrowTerminatingError($_)
    }
}
