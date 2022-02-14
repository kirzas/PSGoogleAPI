Function New-GAPICalendarEvent {
    <#
    .SYNOPSIS
        Function to create Google Calendar events.
    .DESCRIPTION
        Function to create an event. There are 3 ways to define time:
            - AllDay - event for full day with duration of specified number of days
            - Start time and Duration as timespan
            - Start and End times
    .EXAMPLE
        New-GAPICalendarEvent -CalendarId $tabithaCalendarId -Summary 'TestSummary' -Description 'TestDescription' -AllDay -Start '2022.02.14' -NumberOfDays 1 -Verbose
        Create an event for all day with duration of 1 day
    .EXAMPLE
        New-GAPICalendarEvent -CalendarId $tabithaCalendarId -Summary 'TestSummary15min' -Description 'TestDescription15min' -Start '2022.02.15 14:30' -Duration '00:00:15:00' -Verbose
        Create an event starting at 2022.02.15 14:30 with duration of 15 minutes
    .EXAMPLE
        New-GAPICalendarEvent -CalendarId $tabithaCalendarId -Summary 'TestSummary' -Description 'TestDescription' -Start '2022.02.14 16:30' -End '2022.02.14 18:30' -Verbose
        Create an event starting at 2022.02.14 16:30 and ends at 2022.02.14 18:30
    #>
    [CmdletBinding(
        DefaultParameterSetName = 'Duration'
    )]
    Param (
        # ID of the calendar
        [Parameter(Mandatory)]
        [string]$CalendarId,

        # Start time of the event
        [Parameter(Mandatory)]
        [datetime]$Start,

        # Switch to indicate that the event is full day event
        [Parameter(
            ParameterSetName = 'AllDay',
            Mandatory
        )]
        [switch]$AllDay,

        # Switch to indicate that the event is full day event
        [Parameter(
            ParameterSetName = 'AllDay'
        )]
        [ValidateRange(1,999)]
        [int]$NumberOfDays = 1,

        # Duration of the event
        [Parameter(
            ParameterSetName = 'Duration',
            Mandatory
        )]
        [timespan]$Duration,

        # End time of the event
        [Parameter(
            ParameterSetName = 'End',
            Mandatory
        )]
        [datetime]$End,

        # Description of the event
        [Parameter(Mandatory)]
        [string]$Description,
        
        # Title of the event
        [Parameter(Mandatory)]
        [string]$Summary,
        
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
    $fullUri = Join-Uri -UriBase $calendarUri -Resource "events" -ErrorAction Stop

    $startUtc = $Start.ToUniversalTime()
    switch ($PSCmdlet.ParameterSetName) {
        'AllDay' {
            $startInBody = @{
                date = $startUtc.ToString('yyyy-MM-dd')
            }
            $endInBody = @{
                date = $startUtc.AddDays($NumberOfDays - 1).ToString('yyyy-MM-dd')
            }
        }
        'Duration' {
            $startInBody = @{
                dateTime = [Xml.XmlConvert]::ToString($startUtc,[Xml.XmlDateTimeSerializationMode]::Utc)
            }
            $endInBody = @{
                dateTime = [Xml.XmlConvert]::ToString($startUtc + $Duration,[Xml.XmlDateTimeSerializationMode]::Utc)
            }
        }
        'End' {
            $startInBody = @{
                dateTime = [Xml.XmlConvert]::ToString($startUtc,[Xml.XmlDateTimeSerializationMode]::Utc)
            }
            $endUtc = $End.ToUniversalTime()
            $endInBody = @{
                dateTime = [Xml.XmlConvert]::ToString($endUtc,[Xml.XmlDateTimeSerializationMode]::Utc)
            }
        }
    }

    $body = $bodyHash = @{
        start = $startInBody
        end = $endInBody
        description = $Description
        summary = $Summary
    } | ConvertTo-Json -Depth 5 -Compress

    $splat = @{
        Uri = $fullUri
        Method = 'Post'
        AccessToken = $AccessToken
        ErrorAction = 'Stop'
        Body = $body
    }

    Invoke-GAPIRestMethod @splat
}