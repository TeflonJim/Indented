function ReadDnsSINKRecord {
  # .SYNOPSIS
  #   Reads properties for an SINK record from a byte stream.
  # .DESCRIPTION
  #   Internal use only.
  #
  #                                    1  1  1  1  1  1
  #      0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |        CODING         |       SUBCODING       |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    /                     DATA                      /
  #    /                                               /
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #
  # .PARAMETER BinaryReader
  #   A binary reader created by using New-BinaryReader containing a byte array representing a DNS resource record.
  # .PARAMETER ResourceRecord
  #   An Indented.DnsResolver.Message.ResourceRecord object created by ReadDnsResourceRecord.
  # .INPUTS
  #   System.IO.BinaryReader
  #
  #   The BinaryReader object must be created using New-BinaryReader 
  # .OUTPUTS
  #   Indented.DnsResolver.Message.ResourceRecord.DNAME
  # .LINK
  #   http://tools.ietf.org/id/draft-eastlake-kitchen-sink-02.txt
  
  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [IO.BinaryReader]$BinaryReader,
    
    [Parameter(Mandatory = $true)]
    [ValidateScript( { $_.PsObject.TypeNames -contains 'Indented.DnsResolver.Message.ResourceRecord' } )]
    $ResourceRecord
  )

  $ResourceRecord.PsObject.TypeNames.Add("Indented.DnsResolver.Message.ResourceRecord.SINK")

  # Property: Coding
  $ResourceRecord | Add-Member Coding -MemberType NoteProperty -Value $BinaryReader.ReadByte()
  # Property: Subcoding
  $ResourceRecord | Add-Member Subcoding -MemberType NoteProperty -Value $BinaryReader.ReadByte()
  # Property: Data
  $Length = $ResourceRecord.RecordDataLength - 2
  $ResourceRecord | Add-Member Data -MemberType NoteProperty -Value $BinaryReader.ReadBytes($Length)
  
  return $ResourceRecord
}




