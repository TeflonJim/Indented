function NewDnsMessage {
  # .SYNOPSIS
  #   Reads a DNS message from a byte stream.
  # .DESCRIPTION
  #   Internal use only.
  #
  #   Authority is added when attempting an incremental zone transfer.
  #
  #                                    1  1  1  1  1  1
  #      0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    /                                               /
  #    /                    HEADER                     /
  #    /                                               /
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    /                                               /
  #    /                   QUESTION                    /
  #    /                                               /
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    /                                               /
  #    /                   AUTHORITY                   /
  #    /                                               /
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+

  param(
    [String]$Name = "",

    [Indented.DnsResolver.RecordType]$RecordType = [Indented.DnsResolver.RecordType]::ANY,

    [Indented.DnsResolver.RecordClass]$RecordClass = [Indented.DnsResolver.RecordClass]::IN,

    [UInt32]$SerialNumber
  )

  $DnsMessage = New-Object PsObject -Property ([Ordered]@{
    Header             = NewDnsMessageHeader;
    Question           = (NewDnsMessageQuestion -Name $Name -RecordType $RecordType -RecordClass $RecordClass);
    Answer             = @();
    Authority          = @();
    Additional         = @();
    Server             = "";
    Size               = 0;
    TimeTaken          = 0;
  })
  $DnsMessage.PsObject.TypeNames.Add("Indented.DnsResolver.Message")
  
  if ($SerialNumber -and $RecordType -eq [Indented.DnsResolver.RecordType]::IXFR) {
    $DnsMessage.Header.NSCount = [UInt16]1
    $DnsMessage.Authority = NewDnsSOARecord -Name $Name -SerialNumber $SerialNumber
  }

  # Property: QuestionToString
  $DnsMessage | Add-Member QuestionToString -MemberType ScriptProperty -Value {
    return [String]::Join("`n", $this.Question)
  }
  # Property: AnswerToString
  $DnsMessage | Add-Member AnswerToString -MemberType ScriptProperty -Value {
    return [String]::Join("`n", $this.Answer)
  }
  # Property: AuthorityToString
  $DnsMessage | Add-Member AuthorityToString -MemberType ScriptProperty -Value {
    return [String]::Join("`n", $this.Authority)
  }
  # Property: AdditionalToString
  $DnsMessage | Add-Member AdditionalToString -MemberType ScriptProperty -Value {
    return [String]::Join("`n", $this.Additional)
  }
  
  # Method: SetEDnsBufferSize
  $DnsMessage | Add-Member SetEDnsBufferSize -MemberType ScriptMethod -Value {
    param(
      [UInt16]$EDnsBufferSize = 4096
    )
    
    $this.Header.ARCount = [UInt16]1
    $this.Additional += NewDnsOPTRecord
    $this.Additional[0].MaximumPayloadSize = $EDnsBufferSize
  }
  # Method: SetAcceptDnsSec
  $DnsMessage | Add-Member SetAcceptDnsSec -MemberType ScriptMethod -Value {
    $this.Header.Flags = [Indented.DnsResolver.Flags]([UInt16]$this.Header.Flags -bxor [UInt16][Indented.DnsResolver.Flags]::AD)
  }
  
  # Method: ToByte
  $DnsMessage | Add-Member ToByte -MemberType ScriptMethod -Value {
    param(
      [Net.Sockets.ProtocolType]$ProtocolType = [Net.Sockets.ProtocolType]::Udp
    )
  
    $Bytes = [Byte[]]@()

    $Bytes += $this.Header.ToByte()
    $Bytes += $this.Question.ToByte()

    if ($this.Header.NSCount -gt 0) {
      $Bytes += $this.Authority | ForEach-Object {
         $_.ToByte()
      }
    }
    if ($this.Header.ARCount -gt 0) {
      $Bytes += $this.Additional | ForEach-Object {
        $_.ToByte()
      }
    }
    
    if ($ProtocolType -eq [Net.Sockets.ProtocolType]::Tcp) {
      # A value must be added to denote payload length when using a stream-based protocol.
      $LengthBytes = [BitConverter]::GetBytes([UInt16]$Bytes.Length)
      [Array]::Reverse($LengthBytes)
      $Bytes = $LengthBytes + $Bytes
    }
   
    return [Byte[]]$Bytes
  }

  return $DnsMessage
}




