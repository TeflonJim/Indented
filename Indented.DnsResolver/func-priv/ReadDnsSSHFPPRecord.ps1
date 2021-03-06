function ReadDnsSSHFPRecord {
  # .SYNOPSIS
  #   Reads properties for an SSHFP record from a byte stream.
  # .DESCRIPTION
  #   Internal use only.
  #
  #                                    1  1  1  1  1  1
  #      0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |       ALGORITHM       |        FPTYPE         |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    /                  FINGERPRINT                  /
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
  #   Indented.DnsResolver.Message.ResourceRecord.SSHFP
  # .LINK
  #   http://www.ietf.org/rfc/rfc4255.txt
  
  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [IO.BinaryReader]$BinaryReader,
    
    [Parameter(Mandatory = $true)]
    [ValidateScript( { $_.PsObject.TypeNames -contains 'Indented.DnsResolver.Message.ResourceRecord' } )]
    $ResourceRecord
  )

  $ResourceRecord.PsObject.TypeNames.Add("Indented.DnsResolver.Message.ResourceRecord.SSHFP")

  # Property: Algorithm
  $ResourceRecord | Add-Member Algorithm -MemberType NoteProperty -Value ([Indented.DnsResolver.SSHAlgorithm]$BinaryReader.ReadByte())
  # Property: FPType
  $ResourceRecord | Add-Member FPType -MemberType NoteProperty -Value ([Indented.DnsResolver.SSHFPType]$BinaryReader.ReadByte())
  # Property: Fingerprint
  $Bytes = $BinaryReader.ReadBytes($ResourceRecord.RecordDataLength - 2)
  $HexString = ConvertTo-String $Bytes -Hexadecimal
  $ResourceRecord | Add-Member Fingerprint -MemberType NoteProperty -Value $HexString

  # Property: RecordData
  $ResourceRecord | Add-Member RecordData -MemberType ScriptProperty -Force -Value {
    [String]::Format("{0} {1} {2}",
      ([Byte]$this.Algorithm).ToString(),
      ([Byte]$this.FPType).ToString(),
      $this.Fingerprint)
  }
  
  return $ResourceRecord
}




