####################################################################################################
# Name: Automaton                                                                                  #
# Author: Cory Calahan                                                                             #
# Date: 2016-02-27                                                                                 #
####################################################################################################

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
		Write-Error -Message "Failed to import function: $($import.FullName): $PSItem"
	}
}
# Export functions:
Export-ModuleMember -Function $Public.BaseName