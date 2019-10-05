Copy-Item $PSScriptRoot/readme.md $PSScriptRoot/set-env/about_set-env.help.txt
Publish-Module -Path $PSScriptRoot/set-env -NuGetApiKey $env:PSNugetKey -Verbose