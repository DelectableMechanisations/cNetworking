#Sample configuration that configures the following DNS Client settings on all Network Adapters that are assigned IP addresses that match '192.168.*' or '172.16.*':
#   - Configures the 'Dns suffix for this connection's addresses in DNS' to 'mydomain.com'
#   - Ticks the 'Register this connection's addresses in DNS' checkbox.
#   - Ticks the 'Use this connection's DNS suffix in DNS registration' checkbox.
#
#Some servers have a network adapter dedicated to monitoring the heartbeat in a cluster or similar setup. These network adapters should NOT register themselves in DNS as it is usually impossible
#to route to these addresses.
#The second portion of this configuration is designed to configure the following DNS Client settings on all Network Adapters that are assigned IP addresses that DO NOT match '192.168.*' or '172.16.*'
#   - Configures the 'Dns suffix for this connection's addresses in DNS' to '' (i.e. empty).
#   - Unticks the 'Register this connection's addresses in DNS' checkbox.
#   - Unticks the 'Use this connection's DNS suffix in DNS registration' checkbox.


#Describe the configuration.
Configuration Sample_cDnsClient_ConfigureSettingsForMatchingAndNonMatchingAdapters {
    Param (
        [System.String[]]$FilterIPAddressPrefixes,

        [AllowNull()]
        [System.String]$ConnectionSpecificSuffix
    )
    Import-DscResource -ModuleName cNetworking


    Node $NodeName {
        cDnsClient PrimaryNetworkAdapterDnsClient {
            Action = 'ApplyToMatchingAdapters'
            FilterIPAddressPrefixes = $FilterIPAddressPrefixes
            AddressFamily = 'IPv4'
            ConnectionSpecificSuffix = $ConnectionSpecificSuffix
            RegisterThisConnectionsAddress = $true
            UseSuffixWhenRegistering = $true
        }

        cDnsClient HeartbeatNetworkAdapterDnsClient {
            Action = 'ApplytoNonMatchingAdapters'
            FilterIPAddressPrefixes = $FilterIPAddressPrefixes
            AddressFamily = 'IPv4'
            ConnectionSpecificSuffix = ''
            RegisterThisConnectionsAddress = $false
            UseSuffixWhenRegistering = $false
        }
    }
}


#Create the MOF File using the configuration described above.
Sample_cDnsClient_ConfigureSettingsForMatchingAndNonMatchingAdapters `
-FilterIPAddressPrefixes '192.168.*','172.16.*' `
-ConnectionSpecificSuffix 'mydomain.com'


#Push the configuration to the computer.
Start-DscConfiguration -Path Sample_cDnsClient_ConfigureSettingsForMatchingAndNonMatchingAdapters -Wait -Verbose -Force