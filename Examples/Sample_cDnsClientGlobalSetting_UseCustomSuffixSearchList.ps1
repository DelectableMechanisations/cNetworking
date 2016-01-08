#Sample configuration that configures the DNS Client to resolve addresses using a custom DNS Suffix Search list ('testdomain.com' and 'mydomain.co.uk').


#Describe the configuration.
Configuration Sample_cDnsClientGlobalSetting_UseCustomSuffixSearchList {
    Param (
        [Parameter(Mandatory = $true)]
        [System.Boolean]$UsePrimaryAndConnectionSpecificSuffix,

        [Parameter(Mandatory = $false)]
        [System.String[]]$SuffixSearchList
    )
    Import-DscResource -ModuleName cNetworking


    Node $NodeName {
        cDnsClientGlobalSetting DnsGlobalSetting {
            UsePrimaryAndConnectionSpecificSuffix = $UsePrimaryAndConnectionSpecificSuffix
            SuffixSearchList = $SuffixSearchList
            UseDevolution = $true
        }
    }
}


#Create the MOF File using the configuration described above.
Sample_cDnsClientGlobalSetting_UseCustomSuffixSearchList `
-UsePrimaryAndConnectionSpecificSuffix $false `
-SuffixSearchList 'testdomain.com','mydomain.co.uk'


#Push the configuration to the computer.
Start-DscConfiguration -Path Sample_cDnsClientGlobalSetting_UseCustomSuffixSearchList -Wait -Verbose -Force