Function Remove-GAPICalendarEvent {
    <#
    .SYNOPSIS
        Function to delete Google Calendar event.
    .DESCRIPTION
        Function to delete an event using id.
    .EXAMPLE
        Remove-GAPICalendarEvent -CalendarId 2gj741jcpc26lpfh2773gbh3ns -EventId r1gblmuim5b11hkbgd7dgq2kf4
        Delete an event with r1gblmuim5b11hkbgd7dgq2kf4 id from calendar with 2gj741jcpc26lpfh2773gbh3ns id
    .EXAMPLE
        Remove-GAPICalendarEvent -CalendarId 2gj741jcpc26lpfh2773gbh3ns -EventId r1gblmuim5b11hkbgd7dgq2kf4
        Delete an event with r1gblmuim5b11hkbgd7dgq2kf4 id from calendar with 2gj741jcpc26lpfh2773gbh3ns id
    .EXAMPLE
        Get-GAPICalendarEvent -CalendarId 2gj741jcpc26lpfh2773gbh3ns | Remove-GAPICalendarEvent -CalendarId 2gj741jcpc26lpfh2773gbh3ns
        Remove all events from the calendar
    #>
    [CmdletBinding(
        DefaultParameterSetName = 'Duration'
    )]
    Param (
        # ID of the calendar
        [Parameter(Mandatory)]
        [string]$CalendarId,

        # ID of the event
        [Alias('EventId')]
        [Parameter(
            Mandatory,
            ValueFromPipelineByPropertyName
        )]
        [string]$Id,
        
        # Credential should contain code in password, username is not used
        [Parameter()]
        [pscredential]
        [System.Management.Automation.CredentialAttribute()]
        $AccessToken = (Import-Credential -FileName access_token.cred),

        # URI Google Calendar API
        [Parameter()]
        [uri]$UriBase = 'https://www.googleapis.com/calendar/v3/calendars'
    )
    Begin {
        $calendarUri = Join-Uri -UriBase $UriBase -Resource $CalendarId -ErrorAction Stop
    }
    Process {
        $fullUri = Join-Uri -UriBase $calendarUri -Resource "events/$Id" -ErrorAction Stop

        $splat = @{
            Uri = $fullUri
            Method = 'Delete'
            AccessToken = $AccessToken
            ErrorAction = 'Stop'
        }

        Invoke-GAPIRestMethod @splat
    }  
}