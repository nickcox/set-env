What is it?
===========

(1) A command, `Set-Env`, similar to the unix `env` command which sets or unsets environment
variables, executes a given command, then restores them to their original state. For example, given the
alias, `env`:

```sh
> env foo=bar { echo $env:foo }
bar

> env -u bat_theme -c { bat .\readme.md }
# unsets existing bat_theme variable
...

> env -i -c { bat .\readme.md }
# unsets all existing environment variables
...
```
  

(2) A [`CommandNotFoundAction`](https://docs.microsoft.com/en-us/dotnet/api/system.management.automation.commandinvocationintrinsics.commandnotfoundaction?view=pscore-6.2.0),
`Register-AutoSetEnv`, which enables a unix-like syntax for `Set-Env`:

```sh
> BAT_THEME="TwoDark" bat .\readme.md
...

> foo=bar baz=qux {node -e "['foo', 'baz'].forEach(x => console.log(process.env[x]))"}
bar
qux
```

Install
===========

From the [gallery](https://www.powershellgallery.com/packages/set-env/)

```sh
Install-Module set-env
Import-Module set-env

# add to profile. e.g:

Add-Content $PROFILE `n, 'Import-Module set-env'
Add-Content $PROFILE 'Register-AutoSetEnv'
Add-Content $PROFILE 'New-Alias env set-env'
```

Usage
===========

Import the module and call `Register-AutoSetEnv` once if you want to use the
`VAR=something command` syntax.

Note that if your command contains Powershell expressions like quotes or variables,
you'll need to wrap it in a scriptblock (curly braces) to prevent Powershell from
evaluating it too early.

```sh
# do this
tmp=xxx { echo $env:tmp }

# not this
tmp=xxx echo $env:tmp
```

