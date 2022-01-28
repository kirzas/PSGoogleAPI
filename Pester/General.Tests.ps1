Describe "PSGoogleAPI" {
    Context 'Test exported function'{
        BeforeAll {
            $privateFunctionsFilesPath = Join-Path -Path $PSScriptRoot -ChildPath ..\PSGoogleAPI\Private\*.ps1
            $privateFunctionsFiles = Get-ChildItem -Path $privateFunctionsFilesPath

            $publicFunctionsFilesPath = Join-Path -Path $PSScriptRoot -ChildPath ..\PSGoogleAPI\Public\*.ps1
            $publicFunctionsFiles = Get-ChildItem -Path $publicFunctionsFilesPath
            
            $moduleManifestPath = Join-Path -Path $PSScriptRoot -ChildPath ..\PSGoogleAPI\PSGoogleAPI.psd1
            $moduleManifest = Import-PowerShellDataFile -Path $moduleManifestPath
        }

        It "All functions from Public folder should be exported" {
            $publicFunctionsFiles.BaseName | Where-Object {$_ -notin $moduleManifest.FunctionsToExport} | Should -BeNullOrEmpty 
        }

        It "Should export only functions from Public folder" {
            $moduleManifest.FunctionsToExport | Where-Object {$_ -notin $publicFunctionsFiles.BaseName} | Should -BeNullOrEmpty 
        }
    }
}