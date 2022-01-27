Function Save-GAPIRefreshToken {
    <#
    .SYNOPSIS
        Function to save Google API refresh token and access token.
    .DESCRIPTION
        Function creates credential object with
            any username, as it is irrelevant, it will not be used
            refresh token as password
        And saves it as encrypted file using Export-Credential for the usage by the module.
    .EXAMPLE
        Save-GAPIRefreshToken -RefreshToken (New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList 'refresh_token', (ConvertTo-SecureString -String "real_refresh_token" -AsPlainText -Force))
        Saves refresh token using plain text input.
    .EXAMPLE
        Save-GAPIRefreshToken
        Prompts for credential and saves refresh token.
    #>
    [CmdletBinding()]
    Param (
        # Credential should contain refresh token in password, username is not used
        [Parameter(Mandatory)]
        [pscredential]
        [System.Management.Automation.CredentialAttribute()]
        $RefreshToken
    )
    
    Export-Credential -FileName refresh_token.cred -AllowClobber -Credential $RefreshToken -ErrorAction Stop
}