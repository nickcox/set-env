<#
.SYNOPSIS
Registers a CommandNotFoundAction to enable unix like inline variable setting.

.EXAMPLE
PS> Register-AutoSetEnv
PS> BAT_THEME="TwoDark" bat .\readme.md

.EXAMPLE
PS> Register-AutoSetEnv
PS> foo=bar baz=qux {node -e "['foo', 'baz'].forEach(x => console.log(process.env[x]))"}
bar
qux
PS>

.LINK
Set-Env
#>

function Register-AutoSetEnv {
  $existingAction = $ExecutionContext.SessionState.InvokeCommand.CommandNotFoundAction

  $ExecutionContext.SessionState.InvokeCommand.CommandNotFoundAction = {
    param($CommandName, $CommandLookupEventArgs)

    if ($existingAction) {
      $existingAction.Invoke($CommandName, $CommandLookupEventArgs)
    }

    if ($CommandName -notlike "*=*") {
      return
    }

    $scriptBlock = {

      $fullCommand = $CommandName + ' ' + ($args -join ' ')

      $matches = [regex]::Matches($fullCommand, '\w+=\w+\s+')
      if (!$Matches) {
        return
      }

      $target = $fullCommand.Split(($Matches | Select -Last 1)) | Select -Last 1

      $command = if ($target -is [scriptblock]) {
        $target
      }
      else {
        [scriptblock]::Create($target)
      }

      Set-Env -Set $Matches.Value -Command $command
    }.GetNewClosure()

    $CommandLookupEventArgs.CommandScriptBlock = $scriptBlock
    $CommandLookupEventArgs.StopSearch = $true
  }.GetNewClosure()
}