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
}