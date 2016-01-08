#Sample configuration that configures the following DNS Client settings on all Network Adapters that are assigned IP addresses that match '192.168.*' or '172.16.*':
#   - Configures the 'Dns suffix for this connection's addresses in DNS' to 'mydomain.com'
#   - Ticks the 'Register this connection's addresses in DNS' checkbox.
#   - Ticks the 'Use this connection's DNS suffix in DNS registration' checkbox.


#Describe the configuration.
Configuration Sample_cDnsClient_ConfigureSettingsForMatchingAdapters {
    Param (
        [System.String[]]$FilterIPAddressPrefixes,

        [AllowNull()]
        [System.String]$ConnectionSpecificSuffix,
        [System.Boolean]$RegisterThisConnectionsAddress,
        [System.Boolean]$UseSuffixWhenRegistering
    )
    Import-DscResource -ModuleName cNetworking


    Node $NodeName {
        cDnsClient PrimaryNetworkAdapterDnsClient {
            Action = 'ApplyToMatchingAdapters'
            FilterIPAddressPrefixes = $FilterIPAddressPrefixes
            AddressFamily = 'IPv4'
            ConnectionSpecificSuffix = $ConnectionSpecificSuffix
            RegisterThisConnectionsAddress = $RegisterThisConnectionsAddress
            UseSuffixWhenRegistering = $UseSuffixWhenRegistering
        }
    }
}


#Create the MOF File using the configuration described above.
Sample_cDnsClient_ConfigureSettingsForMatchingAdapters `
-FilterIPAddressPrefixes '192.168.*','172.16.*' `
-ConnectionSpecificSuffix 'mydomain.com' `
-RegisterThisConnectionsAddress $true `
-UseSuffixWhenRegistering $true


#Push the configuration to the computer.
Start-DscConfiguration -Path Sample_cDnsClient_ConfigureSettingsForMatchingAdapters -Wait -Verbose -Force