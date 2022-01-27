Function Save-GAPIClientCredential {
    <#
    .SYNOPSIS
        Function to save Google API client_id and client secret locally for the module to use.
    .DESCRIPTION
        Function creates credential object with
            client_id as username
            client secret as password
        And saves it as encrypted file using Export-Credential for the usage by the module.
    .EXAMPLE
        Save-GAPIClientCredential -ClientCredential (New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList '1234567asdggh.apps.googleusercontent.com', (ConvertTo-SecureString -String "notverysecretpassword" -AsPlainText -Force))
        Saves client_id and client secret using plain text input.
    .EXAMPLE
        Save-GAPIClientCredential
        Prompts for credential and saves client_id and client secret.
    #>
    [CmdletBinding()]
    Param (
        # Credential should contain client_id in username and client secred in password
        [Parameter(Mandatory)]
        [pscredential]
        [System.Management.Automation.CredentialAttribute()]
        $ClientCredential
    )
    
    Export-Credential -FileName client.cred -AllowClobber -Credential $ClientCredential -ErrorAction Stop
}