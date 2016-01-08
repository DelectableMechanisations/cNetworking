#Sample configuration that configures the following DNS Client settings on all Network Adapters:
#   - Configures the 'Dns suffix for this connection's addresses in DNS' to 'mydomain.com'
#   - Ticks the 'Register this connection's addresses in DNS' checkbox.
#   - Unticks the 'Use this connection's DNS suffix in DNS registration' checkbox.


#Describe the configuration.
Configuration Sample_cDnsClient_ConfigureDnsClientSettingsForAllAdapters {
    Param (
        [AllowNull()]
        [System.String]$ConnectionSpecificSuffix,
        [System.Boolean]$RegisterThisConnectionsAddress,
        [System.Boolean]$UseSuffixWhenRegistering
    )
    Import-DscResource -ModuleName cNetworking


    Node $NodeName {
        cDnsClient PrimaryNetworkAdapterDnsClient {
            Action = 'ApplyToMatchingAdapters'
            FilterIPAddressPrefixes = '*'
            AddressFamily = 'IPv4'
            ConnectionSpecificSuffix = $ConnectionSpecificSuffix
            RegisterThisConnectionsAddress = $RegisterThisConnectionsAddress
            UseSuffixWhenRegistering = $UseSuffixWhenRegistering
        }
    }
}


#Create the MOF File using the configuration described above.
Sample_cDnsClient_ConfigureDnsClientSettingsForAllAdapters `
-ConnectionSpecificSuffix 'mydomain.com' `
-RegisterThisConnectionsAddress $true `
-UseSuffixWhenRegistering $false


#Push the configuration to the computer.
Start-DscConfiguration -Path Sample_cDnsClient_ConfigureDnsClientSettingsForAllAdapters -Wait -Verbose -Force