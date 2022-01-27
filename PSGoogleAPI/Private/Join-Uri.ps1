Function Join-Uri {
    <#
    .SYNOPSIS
        Function to combine url parts together.
    .DESCRIPTION
        This function combines two uri parts together taking care of trailing slashes.
    .EXAMPLE
        Join-Uri -UriBase https://foo.bar.com/api/v0 -Resource beer
        Return https://foo.bar.com/api/v0/beer
    .EXAMPLE
        Join-Uri -UriBase https://foobar.contoso.com -Resource bluefish/v1/System
        Returns an uri https://foobar.contoso.com/bluefish/v1/System
    #>
    [CmdletBinding()]
    Param (
        # Uri base to append resource path to
        [Parameter(Mandatory)]
        [AllowEmptyString()]
        [string]$UriBase,

        # API resource path
        [Parameter(Mandatory)]
        [string]$Resource,

        # Delimiter for uri parts
        [Parameter()]
        [string]$Delimiter = '/'
    )

    try {
        ($UriBase.trim($Delimiter), $Resource.trim($Delimiter)) -join $Delimiter
    } catch {
        throw "Failed to combine Uri parts '$UriBase' and '$Resource' with '$Delimiter' delimiter"
    }
}
