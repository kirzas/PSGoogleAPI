# PSGoogleAPI
Powershell module for Google API

# Initial setup
## How it works
Google allows API access to it's products. This project is to leverage OAuth protocol to access Google API.

For API calls you need a valid access token in the header. It is valid for a short period of time.
To get a new access token you will need refresh token. It is valid for a long period of time.

To get refresh token you have to create OAuth credentials and obtain authorization code.
Authorization code is obtained via manual consent for the application to access your account.

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
Save Client ID and Client secret as a credential object using
```
Save-GAPIClientCredential
```

## Request and save authorization code
Run Get-GAPIOAuthCode to request the code.
The function will start the default browser and you will have to give consent for the app to access your Google account.
Don't close the browser.
```
Get-GAPIOAuthCode
```
After consent is granted, it will open an unreachable callback URI. Authorization code will be in the URI. Copy it from there and save 
```
Save-GAPIAuthorizationCode
```


You will need to create OAuth credentials, which are client ID and client secret.
Using OAuth credentials you will have to request Authorization code, for which you will have to authorize with you Google account and OAuth credentials.
You can get access token and refresh token using OAuth credentials and Authorization code.
To get the refresh token you will have to give your consent for the application to access your account.
Application is identified by the project that you created OAuth credntials in.


Refresh token may become invalid in several scenarios, for example if you don't use it for a long time or if you revoke it.





All tokens are requested and created for a specific scope. Scope is an API endpoint that is allowed for the token.
Tokens will not work outside the scope.