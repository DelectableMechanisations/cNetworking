#Sample configuration that does the following:
#   - Enables Receive Side Scaling
#   - Enables Receive Segment Coalescing
#   - Disables the TCP Chimney
#   - Disables Task Offloading
#   - Enables Network Direct
#   - Blocks Network Direct Across IP Subnets
#   - Disables the Packet Coalescing Filter


#Describe the configuration.
Configuration Sample_cNetOffloadGlobalSetting_CustomOffloadSettings {
    Param (
        [Parameter(Mandatory = $true)]
        [ValidateSet('Present','Absent')]
        [System.String]$Ensure,

        [ValidateSet('Disabled','Enabled')]
        [System.String]$ReceiveSideScaling,

        [ValidateSet('Disabled','Enabled')]
        [System.String]$ReceiveSegmentCoalescing,

        [ValidateSet('Automatic','Disabled','Enabled')]
        [System.String]$Chimney,

        [ValidateSet('Disabled','Enabled')]
        [System.String]$TaskOffload,

        [ValidateSet('Disabled','Enabled')]
        [System.String]$NetworkDirect,

        [ValidateSet('Allowed','Blocked')]
        [System.String]$NetworkDirectAcrossIPSubnets,

        [ValidateSet('Disabled','Enabled')]
        [System.String]$PacketCoalescingFilter
    )
    Import-DscResource -ModuleName cNetworking


    Node $NodeName {
        #Configures the Global Network Offload Settings that applies to all Network Adapters.
        cNetOffloadGlobalSetting NetOffloadGlobalSetting {
            Ensure = 'Present'
            ReceiveSideScaling = $ReceiveSideScaling
            ReceiveSegmentCoalescing = $ReceiveSegmentCoalescing
            Chimney = $Chimney
            TaskOffload = $TaskOffload
            NetworkDirect = $NetworkDirect
            NetworkDirectAcrossIPSubnets = $NetworkDirectAcrossIPSubnets
            PacketCoalescingFilter = $PacketCoalescingFilter
        }
    }
}


#Create the MOF File using the configuration described above.
Sample_cNetOffloadGlobalSetting_CustomOffloadSettings `
-ReceiveSideScaling 'Enabled' `
-ReceiveSegmentCoalescing 'Enabled' `
-Chimney 'Disabled' `
-TaskOffload 'Disabled' `
-NetworkDirect 'Enabled' `
-NetworkDirectAcrossIPSubnets 'Blocked' `
-PacketCoalescingFilter 'Disabled' 


#Push the configuration to the computer.
Start-DscConfiguration -Path Sample_cNetOffloadGlobalSetting_CustomOffloadSettings -Wait -Verbose -Force