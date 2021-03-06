function ReadDnsSIGRecord {
  # .SYNOPSIS
  #   Reads properties for an SIG record from a byte stream.
  # .DESCRIPTION
  #   Internal use only.
  #
  #                                    1  1  1  1  1  1
  #      0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |                 TYPE COVERED                  |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |       ALGORITHM       |         LABELS        |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |                 ORIGINAL TTL                  |
  #    |                                               |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |             SIGNATURE EXPIRATION              |
  #    |                                               |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |              SIGNATURE INCEPTION              |
  #    |                                               |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |                    KEY TAG                    |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    /                 SIGNER'S NAME                 /
  #    /                                               /
  #    /                                               /
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    /                   SIGNATURE                   /
  #    /                                               /
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
  #   Indented.DnsResolverDns.Message.ResourceRecord.SIG
  # .LINK
  #   http://www.ietf.org/rfc/rfc2535.txt
  #   http://www.ietf.org/rfc/rfc2931.txt
  
  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [IO.BinaryReader]$BinaryReader,
    
    [Parameter(Mandatory = $true)]
    [ValidateScript( { $_.PsObject.TypeNames -contains 'Indented.DnsResolver.Message.ResourceRecord' } )]
    $ResourceRecord
  )

  $ResourceRecord.PsObject.TypeNames.Add("Indented.DnsResolver.Message.ResourceRecord.SIG")

  # Property: TypeCovered
  $TypeCovered = $BinaryReader.ReadBEUInt16()
  if ([Enum]::IsDefined([Indented.DnsResolver.RecordType], $TypeCovered)) {
    $TypeCovered = [Indented.DnsResolver.RecordType]$TypeCovered
  } else {
    $TypeCovered = "UNKNOWN ($TypeCovered)"
  }
  $ResourceRecord | Add-Member TypeCovered -MemberType NoteProperty -Value $TypeCovered
  # Property: Algorithm
  $ResourceRecord | Add-Member Algorithm -MemberType NoteProperty -Value ([Indented.DnsResolver.EncryptionAlgorithm]$BinaryReader.ReadByte())
  # Property: Labels
  $ResourceRecord | Add-Member Labels -MemberType NoteProperty -Value $BinaryReader.ReadByte()
  # Property: OriginalTTL
  $ResourceRecord | Add-Member OriginalTTL -MemberType NoteProperty -Value $BinaryReader.ReadBEUInt32()
  # Property: SignatureExpiration
  $ResourceRecord | Add-Member SignatureExpiration -MemberType NoteProperty -Value ((Get-Date "01/01/1970").AddSeconds($BinaryReader.ReadBEUInt32()))
  # Property: SignatureInception
  $ResourceRecord | Add-Member SignatureInception -MemberType NoteProperty -Value ((Get-Date "01/01/1970").AddSeconds($BinaryReader.ReadBEUInt32()))
  # Property: KeyTag
  $ResourceRecord | Add-Member KeyTag -MemberType NoteProperty -Value $BinaryReader.ReadBEUInt16()
  # Property: SignersName
  $ResourceRecord | Add-Member SignersName -MemberType NoteProperty -Value (ConvertToDnsDomainName $BinaryReader)
  # Property: Signature
  $Bytes = $BinaryReader.ReadBytes($ResourceRecord.RecordDataLength - $BinaryReader.BytesFromMarker)
  $Base64String = ConvertTo-String $Bytes -Base64
  $ResourceRecord | Add-Member Signature -MemberType NoteProperty -Value $Base64String

  # Property: RecordData
  $ResourceRecord | Add-Member RecordData -MemberType ScriptProperty -Force -Value {
    [String]::Format("{0} {1} {2} ( ; type-cov={0}, alg={1}, labels={2}`n" +
                     "    {3} ; Signature expiration`n" +
                     "    {4} ; Signature inception`n" +
                     "    {5} ; Key identifier`n" +
                     "    {6} ; Signer`n" +
                     "    {7} ; Signature`n" +
                     ")",
      $this.TypeCovered,
      (([Byte]$this.Algorithm).ToString()),
      ([Byte]$this.Labels.ToString()),
      $this.SignatureExpiration,
      $this.SignatureInception,
      $this.KeyTag,
      $this.SignersName,
      $this.Signature)
  }
  
  return $ResourceRecord
}




