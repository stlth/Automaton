<#
.Synopsis
   Create a new automaton.
.DESCRIPTION
   Create a new automaton.
.EXAMPLE
   New-Automaton
.EXAMPLE
   New-Automaton -Name Screw
.EXAMPLE
   New-Automaton -Name Nut,Bolt,Washer
#>
function New-Automaton
{
    [CmdletBinding()]
    [Alias()]
    [OutputType([Automaton])]
    Param
    (
        # A name for the Automaton. If not is specified, a default value is used.
        [Parameter(Mandatory=$false,
                   Position=0)]
        [string[]]$Name
    )

    Begin
    {
    }
    Process
    {
        if (-Not($Name))
        {
            New-Object -TypeName Automaton
        }
        else
        {
            foreach ($n in $Name)
            {
                New-Object -TypeName Automaton -Property @{Name=$n}
            }
        }
    }
    End
    {
    }
}