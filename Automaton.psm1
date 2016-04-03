####################################################################################################
# Name: Automaton                                                                                  #
# Author: Cory Calahan                                                                             #
# Date: 2016-04-02                                                                                 #
####################################################################################################

#region Internationalization (Localization)
$moduleRoot = Split-Path -Path $MyInvocation.MyCommand.Path -Parent
# https://technet.microsoft.com/en-us/library/hh847854.aspx
# A locale must be supplied, setting default as 'en-US':
$Culture = 'en-US'
# If a user's specific locale is available, use that instead:
if (Test-Path -Path (Join-Path -Path $moduleRoot -ChildPath $PSUICulture))
{
	$Culture = $PSUICulture
}
# Import the localized information:
Import-LocalizedData -BindingVariable LocalizedData -FileName Automaton.LocalizedData.psd1 -BaseDirectory $moduleRoot -UICulture $Culture -Verbose
#endregion

# Get functions to load:
$Public = @(Get-ChildItem -Path "$PSScriptRoot\Public\*.ps1" -ErrorAction 'SilentlyContinue')
$Private = @(Get-ChildItem -Path "$PSScriptRoot\Private\*.ps1" -ErrorAction 'SilentlyContinue')

foreach ($import in @($Public + $Private))
{
	try
	{
        # Dot-source the files:
		. $import.FullName
	}
	catch
	{
		Write-Error -Message -Message ([string]::Format($LocalizedData.ErrorModuleFailedToImportFunction,$import.FullName,$PSItem))
	}
}
# Export functions:
Export-ModuleMember -Function $Public.BaseName