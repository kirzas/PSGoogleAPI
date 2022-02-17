Function Update-KZError {
    <#
    .SYNOPSIS
        Function to report errors.
    .DESCRIPTION
        It enriches ErrorDetails that is displayed on the screen by default or could be seen in the logs.
        And the original exception is not touched, so no data is lost.
    .EXAMPLE
        # to be called in catch block
        Update-KZError -Message "Failed to do things for Param1=Param1Value " -ErrorRecord $_

        see further examples for more details
        
    .EXAMPLE
        # to be called in catch block
        Update-KZError -ErrorRecord $_ -Action "Doing custom things" -CommandName $functionName -InputParameters $PSBoundParameters

        see further examples for more details

    .EXAMPLE
        Function Test-Error {
            [CmdletBinding()]
            Param (
                [string]$Param1
            )
            $functionName = $MyInvocation.MyCommand.Name
            try {
                Invoke-CustomFunction -Param1 $Param1 -ErrorAction Stop
            } catch {
                Update-KZError -Message "Failed to do things for Param1=Param1Value " -ErrorRecord $_
            }
        }
        Test-Error -Param1 Param1Value
        
        Will get you following ErrorDetails on the screen:

        Failed to do things for Param1=Param1Value
        ExceptionMessage:
        The term 'Invoke-CustomFunction' is not recognized as a name of a cmdlet, function, script file, or executable program.
        Check the spelling of the name, or if a path was included, verify that the path is correct and try again.

    .EXAMPLE
        Function Test-Error {
            [CmdletBinding()]
            Param (
                [string]$Param1
            )
            $functionName = $MyInvocation.MyCommand.Name
            try {
                Invoke-CustomFunction -Param1 $Param1 -ErrorAction Stop
            } catch {
                Update-KZError -ErrorRecord $_ -Action "Doing custom things" -CommandName $functionName -InputParameters $PSBoundParameters
            }
        }
        Test-Error -Param1 Param1Value
        
        Will get you following ErrorDetails on the screen:

        Doing custom things failed (Test-Error).
        Input:
        {
        "Param1": "Param1Value"
        }
        ExceptionMessage:
        The term 'Invoke-CustomFunction' is not recognized as a name of a cmdlet, function, script file, or executable program.
        Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
        
    #>
    [CmdletBinding(
        DefaultParameterSetName = 'StandardInput'
    )]
    Param (
        # Error record
        [Parameter(Mandatory)]
        [System.Management.Automation.ErrorRecord]$ErrorRecord,

        # Message to add to the error
        [Parameter(Mandatory, ParameterSetName='StandardInput')]
        [string]$Action,    

        # Message to add to the error
        [Parameter(Mandatory, ParameterSetName='StandardInput')]
        [string]$CommandName,

        [Parameter(Mandatory, ParameterSetName='StandardInput')]
        [hashtable]$InputParameters,

        # Message to add to the error
        [Parameter(Mandatory, ParameterSetName='CustomMessage')]
        [string]$Message,
        
        # Switch to make error non terminating
        [Parameter()]
        [switch]$NonTerminating
    )

    $newErrorDetailsMessage = [System.Text.StringBuilder]::new()

    if ($PSCmdlet.ParameterSetName -eq 'CustomMessage') {
        $null = $newErrorDetailsMessage.AppendLine($Message)
    } else {
        $null = $newErrorDetailsMessage.AppendLine("$Action failed ($CommandName).")
        if ($InputParameters.Keys.Count) {
            $null = $newErrorDetailsMessage.AppendLine('Input:')
            $parametersMessage = $InputParameters | ConvertTo-Json -Depth 3
            $null = $newErrorDetailsMessage.AppendLine($parametersMessage)
        }
    }

    $previousErrorDetailsMessage = $ErrorRecord.ErrorDetails.Message
    if ($previousErrorDetailsMessage) {
        $null = $newErrorDetailsMessage.AppendLine('ErrorDetails:')
    }
    $null = $newErrorDetailsMessage.AppendLine($previousErrorDetailsMessage)

    $exceptionMessage = $ErrorRecord.Exception.Message
    if (
        $exceptionMessage -and
        $previousErrorDetailsMessage -notlike "*$exceptionMessage*"
    ) {
        $null = $newErrorDetailsMessage.AppendLine('ExceptionMessage:')
        $null = $newErrorDetailsMessage.AppendLine($exceptionMessage)
    }

    $ErrorRecord.ErrorDetails = $newErrorDetailsMessage.ToString()

    if ($NonTerminating) {
        $PSCmdlet.WriteError($ErrorRecord)
    } else {
        $PSCmdlet.ThrowTerminatingError($ErrorRecord)        
    }
}

