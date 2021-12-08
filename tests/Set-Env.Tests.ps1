Describe 'Module Tests' {
    #$repoPath = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
    #$ModuleName = Split-Path $repoPath -Leaf
    #$ModuleScriptName = "$ModuleName.psm1"
    #$ModuleScriptPath = "$repoPath\src\$ModuleName\$ModuleScriptName"

    It 'imports successfully' {
        $repoPath = Split-Path $PSScriptRoot -Parent
        $ModuleName = Split-Path $repoPath -Leaf
        #$ModuleScriptPath = "$repoPath\src\$ModuleName\$ModuleName.psm1"
        $ModuleScriptPath = "$repoPath\$ModuleName\$ModuleName.psm1"

        Write-Verbose "Import-Module -Name $($ModuleScriptPath)"
        { Import-Module -Name $ModuleScriptPath -ErrorAction Stop } | Should -Not -Throw
    }

    It 'passes default PSScriptAnalyzer rules' {
        $repoPath = Split-Path $PSScriptRoot -Parent
        $ModuleName = Split-Path $repoPath -Leaf
        $ModuleScriptPath = "$repoPath\$ModuleName\$ModuleName.psm1"
        
        #fairly certain, this is newly required, used to already be in:
        #Install-Module PSScriptAnalyzer -Scope CurrentUser
        Invoke-ScriptAnalyzer -Path $ModuleScriptPath | Should -BeNullOrEmpty
    }
}

Describe 'Module Manifest Tests' {
    It 'passes Test-ModuleManifest' {
        $repoPath = Split-Path $PSScriptRoot -Parent
        $ModuleName = Split-Path $repoPath -Leaf
        $ModuleManifestName = "$ModuleName.psd1"
        $ModuleManifestPath = "$repoPath\$ModuleName\$ModuleManifestName"

        Write-Output $ModuleManifestPath
        Test-ModuleManifest -Path $ModuleManifestPath | Should -Not -BeNullOrEmpty
        $? | Should -Be $true
    }
}

Describe 'Smoke Tests' {
    It 'passes empty params' {
        $results = Set-Env -Verbose | Should -Not -BeNullOrEmpty
        Write-Verbose "results:$results"
    }
    It 'passes env set' {
        [System.Environment]::SetEnvironmentVariable("set-env-smoke-test-env-set","x")
        Set-Env -Verbose | Should -Not -BeNullOrEmpty
        $results = (Get-Item 'env:set-env-smoke-test-env-set').value
        $results | Should -Be 'test'
    }    
    It 'passes env-user set' {
        [System.Environment]::SetEnvironmentVariable("set-env-smoke-test-env-user-set","x")
        Set-Env -Verbose | Should -Not -BeNullOrEmpty
        $results = (Get-Item 'env:set-env-smoke-test-env-user-set').value
        $results | Should -Be 'test'
    }
}