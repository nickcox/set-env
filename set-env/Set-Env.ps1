<#
.SYNOPSIS
Set or unset environment variables in the context of a single command.

.PARAMETER Set
Array of variables to set in the form `name=value`.

.PARAMETER Command
Command to execute.

.PARAMETER Unset
Array of variable names to unset.

.PARAMETER IgnoreEnvironment
Unset everything.

.EXAMPLE
PS> Set-Env foo=bar { echo $env:foo }
bar
PS> echo $env:foo
PS>

.EXAMPLE
PS> Set-Env # (without a command it returns a list of current environment variables.)
Name                           Value
----                           -----
__COMPAT_LAYER                 Installer RunAsAdmin
ALLUSERSPROFILE                C:\ProgramData
...

.LINK
Register-AutoSetEnv
#>

function Set-Env {

  [CmdletBinding()]
  param(
    [string[]] $Set,
    [scriptblock] $Command = { ls env: },
    [string[]] $Unset,
    [switch] $IgnoreEnvironment
  )

  if ($IgnoreEnvironment) {
    $Unset = (ls env:).Name
  }

  $varsToSet = if ($Set) {
    $Set | % {
      $var, $val = $_.trim().Split('=')
      $original = Get-Item "env:$var" -ea Ignore | select -expand Value

      @{ var = $var; val = $val -join '='; original = $original }
    }
  }

  $varsToUnset = if ($Unset) {
    $Unset | % {
      $var = $_.trim()
      $original = Get-Item "env:$var" -ea Ignore | select -expand Value

      @{ var = $var; val = $null; original = $original }
    }
  }

  $combined = @($varsToSet) + @($varsToUnset)

  try {

    $currLocation = "$(Get-Location)"
    @((Split-Path $profile -Parent),$PSScriptRoot,($currLocation -ne $PSScriptRoot ? $currLocation : ''),$Set).foreach({
      try {
        $p = $_
        if ($p) {
          #Write-Verbose "checking:$p\*.env*"
          if (Test-Path $p\*.env*) {
            Get-ChildItem –Path $p\*.env* | Foreach-Object {
              try {
                $f = $_
                Write-Verbose "checking:$($f.FullName)"							
                $content = (Get-Content $f.FullName)
                $content | ForEach-Object {
                  if (-not ($_ -like '#*') -and  ($_ -like '*=*')) {
                    $sp = $_.Split('=')
                    Write-Verbose "Set-Env $($sp[0])=$($sp[1])"
                    [System.Environment]::SetEnvironmentVariable($sp[0], $sp[1])
                  }
                }
              }
              catch {
                Write-Error "ERROR Set-Env $p-$f" -InformationVariable results
              }
            }
          } else { 
            #Write-Verbose "skipped:$p no *.env* files found"
          }
        }
      }
      catch {
        Write-Error "ERROR Set-Env $p" -InformationVariable results
      }
    })
    
    $combined | % {
      Set-Item "env:$($_.var)" $_.val
    }

    &$Command
  }
  finally {
    $combined | % {
      Set-Item "env:$($_.var)" $_.original
    }
  }

  Write-Verbose "Set-Env:end"
}