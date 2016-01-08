#Sample configuration that configures the DNS Client to resolve addresses using the Primary DNS Suffix and any Connection Specific Suffixes. Also enables DNS Devolution.


#Describe the configuration.
Configuration Sample_cDnsClientGlobalSetting_UsePrimaryAndConnectionSpecificSuffix {
    Import-DscResource -ModuleName cNetworking


    Node $NodeName {
        cDnsClientGlobalSetting DnsGlobalSetting {
            UsePrimaryAndConnectionSpecificSuffix = $true
            UseDevolution = $true
        }
    }
}


#Create the MOF File using the configuration described above.
Sample_cDnsClientGlobalSetting_UsePrimaryAndConnectionSpecificSuffix


#Push the configuration to the computer.
Start-DscConfiguration -Path Sample_cDnsClientGlobalSetting_UsePrimaryAndConnectionSpecificSuffix -Wait -Verbose -Force