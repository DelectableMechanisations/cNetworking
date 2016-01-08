#Sample configuration that configures the Global Network Offload Settings to use their default values.


#Describe the configuration.
Configuration Sample_cNetOffloadGlobalSetting_ConfigureDefaults {
    Import-DscResource -ModuleName cNetworking


    Node $NodeName {
        cNetOffloadGlobalSetting NetOffloadGlobalSetting {
            Ensure = 'Absent'
        }
    }
}


#Create the MOF File using the configuration described above.
Sample_cNetOffloadGlobalSetting_ConfigureDefaults


#Push the configuration to the computer.
Start-DscConfiguration -Path Sample_cNetOffloadGlobalSetting_ConfigureDefaults -Wait -Verbose -Force