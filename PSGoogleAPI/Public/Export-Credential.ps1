Function Export-Credential {
    <#
    .SYNOPSIS
        Function used to encrypt and save credentials to a file. Default encryption is DPAPI. 
    .DESCRIPTION
        Function used to encrypt and save credentials to a file. Default encryption is used, which is DPAPI, so only account that saved credential will be able to read it. Could be read by Import-Credential function.
        If User name for credential is provided in <hostname>\<username> format,then \ will be replaced by .
    .EXAMPLE
        Export-Credential -AllowClobber
        Will create or overwrite a .cred file in user profile folder (Documents\WindowsPowerShell\Credential) with credentials that are provided via prompt.
    .EXAMPLE
        Export-Credential -Credential $credential -Path c:\temp
        Will create a .cred file in c:\temp folder with credentials that are stored in $credential variable.
    #>

    [CmdletBinding()]
    Param (
        # Path to file to save credential
        [string]$Path = "$($env:USERPROFILE)\Documents\WindowsPowerShell\Credential",

        # Credential to be saved to a file
        [Parameter(Mandatory)]
        [PSCredential][System.Management.Automation.Credential()]$Credential,

        # File name with stored credentials, it is named after credential location, which is usually a hostname
        [string]$FileName,

        # Allow to overwrite previously saved credentials
        [switch]$AllowClobber
    )

    if (-not $FileName){
        $FileName = if ($Credential.UserName -like '*\*') {
            "$($Credential.UserName -replace '\\', '#').cred"
        } else {
            "$($Credential.UserName).cred"
        }
    }

    $fileFullPath = Join-Path -Path $Path -ChildPath $FileName

    if (-not (Test-Path -Path $Path)){
        try {
            New-Item -Type Directory -Path $Path -ErrorAction Stop
        } catch {
            throw "Directory $Path doesn't exist and failed to create it"
        }
    }

    $Credential | Export-Clixml -Path $fileFullPath -NoClobber:(-not $AllowClobber)
}
