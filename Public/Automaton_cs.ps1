class Automaton
{
   [ValidatePattern("^[\d\w\s:-]*$")]
   [string]$Name = "Automaton: $((Get-Date).ToUniversalTime().GetDateTimeFormats('u'))"
   [guid]$GUID = [guid]::NewGuid()

   # Constructors
   Automaton()
   {
   }
   Automaton ([string] $s)
   {
       $this.Name = $s       
   }
}
#Examples:
# New-Object -TypeName Automaton
# New-Object -TypeName Automaton -Property @{Name='Gadget'}