Function Save-GAPIAccessToken {
    <#
    .SYNOPSIS
        Function to save Google API access token and access token.
    .DESCRIPTION
        Function creates credential object with
            any username, as it is irrelevant, it will not be used
            access token as password
        And saves it as encrypted file using Export-Credential for the usage by the module.
    .EXAMPLE
        Save-GAPIAccessToken -AccessToken (New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList 'access_token', (ConvertTo-SecureString -String "real_access_token" -AsPlainText -Force))
        Saves access token using plain text input.
    .EXAMPLE
        Save-GAPIAccessToken
        Prompts for credential and saves access token.
    #>
    [CmdletBinding()]
    Param (
        # Credential should contain access token in password, username is not used
        [Parameter(Mandatory)]
        [pscredential]
        [System.Management.Automation.CredentialAttribute()]
        $AccessToken
    )
    
    Export-Credential -FileName access_token.cred -AllowClobber -Credential $AccessToken -ErrorAction Stop
}