#
# If you have the resources, setting up your own PowerShellGet repository would be best.
# It's what is in use in Windows 10. Try out: Get-Module -Name PowerShellGet
# Read a bit more here: https://blogs.msdn.microsoft.com/powershell/2014/05/20/setting-up-an-internal-powershellget-repository/
#
# An additional WARNING: This code example is a prime reason to have your code signed!
# If something malicious were to happen on the repository it could be used in a way to download to the particular device and perform it's own actions.
#
# This script assumes you have placed a copy of the module into: "$env:HOMEDRIVE\$env:HOMEPATH\Documents\WindowsPowerShell\Modules\<Module>"
#

$ModulePath = $(Get-Variable -Name MyInvocation).Value.PSScriptRoot
$Module = $ModulePath | Split-Path -Leaf

# The location to check for newer releases
$ModuleURI = "\\servername.forest.fully-qualified-domain-name.tld\ShareNameHere\$Module\"
# Test if the location is available and if not it will not trigger an update process
Write-Debug -Message "Testing for repository availability for path: $ModuleURI"
if(Test-Path -Path $ModuleURI)
{
    Write-Output -InputObject 'Checking for Module Updates...'
    Write-Output -InputObject "Module Name: $Module"
    $LocalVersion = $(Get-Module -ListAvailable | Where-Object {$PSItem.Name -eq $Module}).Version.ToString()
    Write-Output -InputObject "Current Version: $LocalVersion"
    # Get a copy of the core *.psd1 file which contains the current version number
    try
    {
        Invoke-WebRequest -Uri "$ModuleURI\$Module.psd1" -OutFile "$ModulePath\tempfile.psd1" -ErrorAction 'Stop'
    }
    catch
    {
        # Do stuff.
		Write-Error -Message "Failed to acquire file: $PSItem"
    }
    # Check the newly obtained *.psd1 file for the module version, splitting the path to obtain just the version number. Example: ModuleVersion = '1.0'
    $RepositoryVersion = $(Select-String -Path "$ModulePath\tempfile.psd1" -Pattern 'ModuleVersion').Line.Split("'")[1]
    Write-Output -InputObject "Repository Version: $RepositoryVersion"
    # Check if the tempfile contains a newer version
    if([version]$RepositoryVersion -gt [version]$LocalVersion)
    {
        Write-Output -InputObject 'New version found. Performing update.'
        # Actions from here will vary depending on how your module is structured and/or the number of items to process...
        # As an example, you could...
        # ...Create an older versions directory if it does not already exist...
        if(-Not(Test-Path -Path "$ModulePath\PreviousRelease" -PathType Container))
        {
            New-Item -Path "$ModulePath\PreviousRelease" -ItemType Directory -Force -ErrorAction 'SilentlyContinue' | Out-Null
        }
        # ...And move the older files into the previous versions directory appending the previous version release number...
        Move-Item -Path "$ModulePath\$Module.psd1" -Destination "$ModulePath\PreviousRelease\$Module.$LocalVersion.psd1"
        Rename-Item -Path "$ModulePath\tempfile.psd1" -NewName "$ModulePath\$Module.psd1"
        # ...Maybe update the *.psm1 file...
        #Invoke-WebRequest -Uri "$ModuleURI\$Module.psm1" -OutFile "$ModulePath\tempfile.psm1" -ErrorAction 'Stop'
        #Move-Item -Path "$ModulePath\$Module.psm1" -Destination "$ModulePath\PreviousRelease\$Module.$LocalVersion.psm1"
        #Rename-Item -Path "$ModulePath\tempfile.psm1" -NewName "$ModulePath\$Module.psm1"
        # ...Et cetera...
        # ...Until you want to reload the new content.
        Write-Output -InputObject 'Obtained new module content successfully. Reloading...'
        # Reload the newly acquired contents, where as long as this script is still set it will re-check again on reload.
        Get-Module -ListAvailable | Where-Object -FilterScript {$PSItem.Name -eq $Module} | Remove-Module -Force
        Import-Module -Name $Module
    }
}