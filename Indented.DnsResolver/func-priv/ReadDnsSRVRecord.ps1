function ReadDnsSRVRecord {
  # .SYNOPSIS
  #   Reads properties for an SRV record from a byte stream.
  # .DESCRIPTION
  #   Internal use only.
  #
  #                                    1  1  1  1  1  1
  #      0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |                   PRIORITY                    |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |                    WEIGHT                     |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |                     PORT                      |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    /                    TARGET                     /
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
  #   Indented.DnsResolver.Message.ResourceRecord.SRV
  # .LINK
  #   http://www.ietf.org/rfc/rfc2782.txt
  
  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [IO.BinaryReader]$BinaryReader,
    
    [Parameter(Mandatory = $true)]
    [ValidateScript( { $_.PsObject.TypeNames -contains 'Indented.DnsResolver.Message.ResourceRecord' } )]
    $ResourceRecord
  )

  $ResourceRecord.PsObject.TypeNames.Add("Indented.DnsResolver.Message.ResourceRecord.SRV")
  
  # Property: Priority
  $ResourceRecord | Add-Member Priority -MemberType NoteProperty -Value $BinaryReader.ReadBEUInt16()
  # Property: Weight
  $ResourceRecord | Add-Member Weight -MemberType NoteProperty -Value $BinaryReader.ReadBEUInt16()
  # Property: Port
  $ResourceRecord | Add-Member Port -MemberType NoteProperty -Value $BinaryReader.ReadBEUInt16()
  # Property: Hostname
  $ResourceRecord | Add-Member Hostname -MemberType NoteProperty -Value (ConvertToDnsDomainName $BinaryReader)

  # Property: RecordData
  $ResourceRecord | Add-Member RecordData -MemberType ScriptProperty -Force -Value {
    [String]::Format("{0} {1} {2} {3}",
      $this.Priority,
      $this.Weight,
      $this.Port,
      $this.Hostname)
  }
  
  return $ResourceRecord
}




