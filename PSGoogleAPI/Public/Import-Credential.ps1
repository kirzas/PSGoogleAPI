Function Import-Credential {
    <#
    .SYNOPSIS
        Function used to read credentials encrypted and saved to a file by Export-Credential function.
    .DESCRIPTION
        Function used to read credentials saved to a file using Export-Credential. Default encryption is DPAPI, so only account that saved credential will be able to read it.
    .EXAMPLE
        Import-Credential -FileName foobar.cred
        Returns credential object from foobar.cred file in user profile folder (Documents\WindowsPowerShell\Credential).
    .EXAMPLE
        Import-Credential -FileName foobar.cred -Path c:\temp
        Returns credential object from foobar.cred file in c:\temp folder.
    #>

    [CmdletBinding()]
    [OutputType([PSCredential])]
    Param (
        # Path to file to save credential
        [string]$Path = "$($env:USERPROFILE)\Documents\WindowsPowerShell\Credential",

        # File name with stored credentials, it is named after credential location, which is usually a hostname
        [Parameter(
                Mandatory
        )]
        [string]$FileName
    )

    $fileFullPath = "$Path\$fileName"

    if (-not (Test-Path  -Path $fileFullPath)){
        throw "Credential file $fileName was not found in $Path"
    }

    Import-Clixml -Path $fileFullPath
}
