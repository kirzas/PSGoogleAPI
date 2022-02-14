Function Invoke-KZRestMethod {
    [CmdletBinding(HelpUri='https://go.microsoft.com/fwlink/?LinkID=217034')]
    Param (
        # Parameter to retry in case of timeout adding 10 seconds to timeout parameter
        [switch]
        $TimeoutRetry,

        # Parameter from Invoke-RestMethod
        [Microsoft.PowerShell.Commands.WebRequestMethod]
        ${Method},

        # Parameter from Invoke-RestMethod
        [switch]
        ${UseBasicParsing},

        # Parameter from Invoke-RestMethod
        [Parameter(Mandatory, Position=0)]
        [ValidateNotNullOrEmpty()]
        [uri]
        ${Uri},

        # Parameter from Invoke-RestMethod
        [Microsoft.PowerShell.Commands.WebRequestSession]
        ${WebSession},

        # Parameter from Invoke-RestMethod
        [Alias('SV')]
        [string]
        ${SessionVariable},

        # Parameter from Invoke-RestMethod
        [pscredential]
        [System.Management.Automation.CredentialAttribute()]
        ${Credential},

        # Parameter from Invoke-RestMethod
        [switch]
        ${UseDefaultCredentials},

        # Parameter from Invoke-RestMethod
        [ValidateNotNullOrEmpty()]
        [string]
        ${CertificateThumbprint},

        # Parameter from Invoke-RestMethod
        [ValidateNotNull()]
        [X509Certificate]
        ${Certificate},

        # Parameter from Invoke-RestMethod
        [string]
        ${UserAgent},

        # Parameter from Invoke-RestMethod
        [switch]
        ${DisableKeepAlive},

        # Parameter from Invoke-RestMethod
        [ValidateRange(0, 2147483647)]
        [int]
        ${TimeoutSec} = 10,

        # Parameter from Invoke-RestMethod
        [System.Collections.IDictionary]
        ${Headers} = @{
            Accept = 'application/json'
        },

        # Parameter from Invoke-RestMethod
        [ValidateRange(0, 2147483647)]
        [int]
        ${MaximumRedirection},

        # Parameter from Invoke-RestMethod
        [uri]
        ${Proxy},

        # Parameter from Invoke-RestMethod
        [pscredential]
        [System.Management.Automation.CredentialAttribute()]
        ${ProxyCredential},

        # Parameter from Invoke-RestMethod
        [switch]
        ${ProxyUseDefaultCredentials},

        # Parameter from Invoke-RestMethod
        [Parameter(ValueFromPipeline)]
        [System.Object]
        ${Body},

        # Parameter from Invoke-RestMethod
        [string]
        ${ContentType},

        # Parameter from Invoke-RestMethod
        [ValidateSet('chunked','compress','deflate','gzip','identity')]
        [string]
        ${TransferEncoding},

        # Parameter from Invoke-RestMethod
        [string]
        ${InFile},

        # Parameter from Invoke-RestMethod
        [string]
        ${OutFile},

        # Parameter from Invoke-RestMethod
        [switch]
        ${PassThru}
    )
    
    try {

        $irmBuiltinParameters = (Get-Command -Name Invoke-RestMethod).Parameters

        $clonedPsBoundParameters = @{} + $PsBoundParameters
        $clonedPsBoundParameters['ErrorAction'] = 'Stop'

        foreach ($boundParameter in $PsBoundParameters.Keys) {
            if ($boundParameter -notin $irmBuiltinParameters.Keys) {
                $clonedPsBoundParameters.Remove($boundParameter)
            }
        }

        foreach ($paramaterName in $irmBuiltinParameters.Keys) {
            if (
                $paramaterName -notin $PsBoundParameters.Keys -and
                ($paramaterValue = Get-Variable -Scope Local -Name $paramaterName -ValueOnly -ErrorAction SilentlyContinue)
            ) {
                $clonedPsBoundParameters[$paramaterName] = $paramaterValue
            }
        }

        try {
            $output = Invoke-RestMethod @clonedPsBoundParameters
        } catch {
            if (
                $TimeoutRetry -and
                $_.Exception.message -eq 'The operation has timed out.'
            ) {
                Write-Verbose "Operation timed out, TimeoutRetry switch is used - trying again - $uri"
                $clonedPsBoundParameters['TimeoutSec'] = $clonedPsBoundParameters['TimeoutSec'] + 10 

                $output = Invoke-RestMethod @clonedPsBoundParameters
            } else {
                throw $_
            }
        }

        $output
    } catch {
        if ($_.Exception.Response) {
            if ($PSVersionTable.PSVersion.Major -lt 7) {
                $errorInResponse = [IO.StreamReader]::new(
                    $_.Exception.Response.GetResponseStream()
                ).ReadToEnd()
            } else {
                $errorInResponse = $_.Exception.Response
            }
        }

        if ($errorInResponse) {
            # Merging messages and dropping original exception into the InnerException if needed.
            $finalMessage = 'Invoke REST Method failed. Original message: "{0}". Data from response: "{1}"' -f @(
                $_.Exception.Message
                $errorInResponse | Out-String
            )
            $updateException = [Net.WebException]::new(
                $finalMessage,
                $_.Exception
            )
            throw $updateException
        } else {
            throw $_
        }
    }
}
