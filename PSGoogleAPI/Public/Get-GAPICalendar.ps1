Function Get-GAPICalendar {
    <#
    .SYNOPSIS
        Function to get Google Calendar records.
    .DESCRIPTION
        
    .EXAMPLE
        Get-GAPICalendar -Credential $cred
        Starts default browser on a page to authorize the application.
    #>
    [CmdletBinding()]
    Param (
        # ID of the calendar
        [Parameter(Mandatory)]
        [string]$CalendarId,

        # Credential should contain code in password, username is not used
        [Parameter()]
        [pscredential]
        [System.Management.Automation.CredentialAttribute()]
        $AccessToken = (Import-Credential -FileName access_token.cred),

        # URI Google Calendar API
        [Parameter()]
        [uri]$UriBase = 'https://www.googleapis.com/calendar/v3/calendars'
    )
    $fullUri = Join-Uri -UriBase $UriBase -Resource $CalendarId -ErrorAction Stop

    Invoke-GAPIRestMethod -Uri $fullUri -Method Get -AccessToken $AccessToken -ErrorAction Stop
}