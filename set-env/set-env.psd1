@{

  RootModule        = '.\set-env.psm1'
  ModuleVersion     = '0.1'
  Author            = 'Nick Cox'
  CompanyName       = 'n/a'
  Copyright         = '(c) 2019 Nick Cox. All rights reserved.'
  Description       = 'Set or unset environment variables in the context of a single command.'
  GUID              = 'e00763ca-efb3-4f88-a045-aae1be4150de'
  PowerShellVersion = '3.0'
  FunctionsToExport = @("*-*")


  PrivateData       = @{

    PSData = @{
      Tags       = @('env', 'productivity')
      LicenseUri = 'https://github.com/nickcox/set-env/blob/master/LICENSE'
      ProjectUri = 'https://github.com/nickcox/set-env'
    }
  }
}

