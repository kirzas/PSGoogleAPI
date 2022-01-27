# PSGoogleAPI
Powershell module for Google API

# Initial setup
## How it works
Google allows API access to it's products. This project is to leverage OAuth protocol to access Google API.

For API calls you need a valid access token in the header. It is valid for a short period of time.
To get a new access token you will need refresh token. It is valid for a long period of time.

To get refresh token you have to create OAuth credentials and obtain authorization code.
Authorization code is obtained via giving manual consent for the application to access your account.

## Create Google API project
You have to create Google API project
https://console.cloud.google.com/apis

Then create Credentials (OAuth client ID):
Name
Client ID
Client secret

## This project
All credential objects will be saved locally using DPAPI encryption by default.
Obtaining of the code requires to specify call back URI.
Currently this module does not support this and requires to supply authorization code to hte module manually using browser.

## Save OAuth credentials on the machine
Save Client ID and Client secret as a credential object. Provide Client ID as User and Client secret as password.
```
Save-GAPIClientCredential
```

## Request authorization code
Run Get-GAPIOAuthCode to request the code.
The function will start the default browser and you will have to give consent for the app to access your Google account.
Don't close the browser.
```
Get-GAPIOAuthCode
```
After consent is granted, it will open an unreachable callback URI. Authorization code will be in the URI. Copy it from there to get the token.

## Request and save tokens
Execute following command to request and save refresh token and access token

```
$tokens = Get-GOAuthToken -Code -Code 'real_authorization_code'
Save-GAPIRefreshToken -RefreshToken (New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList 'refresh_token', (ConvertTo-SecureString -String $tokens.refresh_token -AsPlainText -Force))
Save-GAPIAccessToken -AccessToken (New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList 'access_token', (ConvertTo-SecureString -String $tokens.access_token -AsPlainText -Force))
```
## You can start using Google API
You can call any PAI endpoint using generic Invoke-GAPIRestMethod
```
Invoke-GAPIRestMethod -Uri 'https://www.googleapis.com/calendar/v3/calendars' -Method Get
```
Or you can use other functions in the module, like Get-GAPICalendar.

## Refresh access token
Since access token expires quickly, you will have to refresh it regularly.
```
$newAccessToken = Invoke-GOAuthTokenRefresh
Save-GAPIAccessToken -AccessToken (New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList 'access_token', (ConvertTo-SecureString -String $newAccessToken -AsPlainText -Force))
```
## Revoke access
If you want to revoke access from the machine o your account, you can always go to your Google API project and revoke credentials.
All tokens will not be valid anymore.