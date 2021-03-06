function Initialize-InternalDnsCache {
  # .SYNOPSIS
  #   Initializes a basic DNS cache for use by Get-Dns.
  # .DESCRIPTION
  #   Get-Dns maintains a limited DNS cache, capturing A and AAAA records, to assist name server resolution (for values passed using the Server parameter).
  #
  #   The cache may be manipulated using *-InternalDnsCacheRecord CmdLets.
  # .EXAMPLE
  #   Initialize-InternalDnsCache
  # .NOTES
  #   Author: Chris Dent
  #
  #   Change log:
  #     08/01/2014 - Chris Dent - Released.
  
  [CmdLetBinding()]
  param( )
  
  # These two variables are consumed by all other -InternalDnsCacheRecord CmdLets.
  
  # The primary cache variable stores a stub resource record
  if (Get-Variable DnsCache -Scope Script -ErrorAction SilentlyContinue) {
    Remove-Variable DnsCache -Scope Script
  }
  New-Variable DnsCache -Scope Script -Value @{}

  # Allows quick, if limited, reverse lookups against the cache.
  if (Get-Variable DnsCacheReverse -Scope Script -ErrorAction SilentlyContinue) {
    Remove-Variable DnsCache -Scope Script
  }
  New-Variable DnsCacheReverse -Scope Script -Value @{}
  
  if (Test-Path $psscriptroot\..\var\named.root) {
    Get-Content $psscriptroot\..\var\named.root | 
      Where-Object { $_ -match '(?<Name>\S+)\s+(?<TTL>\d+)\s+(IN\s+)?(?<RecordType>A\s+|AAAA\s+)(?<IPAddress>\S+)' } |
      ForEach-Object {
        $CacheRecord = New-Object PsObject -Property ([Ordered]@{
          Name       = $matches.Name;
          TTL        = [UInt32]$matches.TTL;
          RecordType = [Indented.DnsResolver.RecordType]$matches.RecordType;
          IPAddress  = [IPAddress]$matches.IPAddress;
        })
        $CacheRecord.PsObject.TypeNames.Add('Indented.DnsResolver.Message.CacheRecord')
        $CacheRecord
      } |
      Add-InternalDnsCacheRecord -Permanent -ResourceType Hint
  }
}

