Function Get-GAPICalendarEvent {
    <#
    .SYNOPSIS
        Function to get Google Calendar events.
    .DESCRIPTION
        
    .EXAMPLE
        Get-GAPICalendarEvent -CalendarId 12123435 -EventId asdsfdsf
        returns specific event record.
    .EXAMPLE
        Get-GAPICalendarEvent -CalendarId 12123435
        returns list of events for the calendar.
    #>
    [CmdletBinding()]
    Param (
        # ID of the calendar
        [Parameter(Mandatory)]
        [string]$CalendarId,

        # ID of the event, if not specified, all are returned
        [Parameter()]
        [string]$EventId,

        # Credential should contain code in password, username is not used
        [Parameter()]
        [pscredential]
        [System.Management.Automation.CredentialAttribute()]
        $AccessToken = (Import-Credential -FileName access_token.cred),

        # URI Google Calendar API
        [Parameter()]
        [uri]$UriBase = 'https://www.googleapis.com/calendar/v3/calendars'
    )
    
    
    $calendarUri = Join-Uri -UriBase $UriBase -Resource $CalendarId -ErrorAction Stop
    $fullUri = Join-Uri -UriBase $calendarUri -Resource "events/$EventId" -ErrorAction Stop

    Invoke-GAPIRestMethod -Uri $fullUri -Method Get -AccessToken $AccessToken -ErrorAction Stop
}