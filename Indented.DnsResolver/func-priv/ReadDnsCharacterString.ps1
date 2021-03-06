function ReadDnsCharacterString {
  # .SYNOPSIS
  #   Reads a character-string from a DNS message.
  # .DESCRIPTION
  #   Internal use only.
  # .PARAMETER BinaryReader
  #   A binary reader created by using New-BinaryReader containing a byte array representing a DNS resource record.
  # .INPUTS
  #   System.IO.BinaryReader
  #
  #   The BinaryReader object must be created using New-BinaryReader
  # .OUTPUTS
  #   System.String
  # .LINK
  #   http://www.ietf.org/rfc/rfc1035.txt

  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [IO.BinaryReader]$BinaryReader
  )
  
  $Length = $BinaryReader.ReadByte()
  $CharacterString = New-Object String (,$BinaryReader.ReadChars($Length))
  
  return $CharacterString
}




