<#===============================================================================================================================================================================

DM_cNetOffloadGlobalSetting.psm1

AUTHOR:         David Baumbach
Version:        1.0.0
Creation Date:  30/11/2015
Last Modified:  08/01/2016


This DSC module is used to configure the Network Offload Global Settings on a computer. 
If the 'Ensure' parameter is set to 'Present' then the Network Offload Global Settings are configured as per the specified parameters.
If the 'Ensure' parameter is set to 'Absent' then the Network Offload Global Settings are configured as using their default values and the specified parameters are ignored.


Change Log:
    0.0.1   30/11/2015  Initial Creation
    1.0.0   08/01/2016  First Published


The code used to build the module.
    Import-Module xDSCResourceDesigner

    $Ensure  = New-xDscResourceProperty -Name Ensure -Type String -Attribute Key -ValidateSet @('Present','Absent')
    $ReceiveSideScaling = New-xDscResourceProperty -Name ReceiveSideScaling -Type String -Attribute Write -ValidateSet @('Disabled','Enabled')
    $ReceiveSegmentCoalescing = New-xDscResourceProperty -Name ReceiveSegmentCoalescing -Type String -Attribute Write -ValidateSet @('Disabled','Enabled')
    $Chimney = New-xDscResourceProperty -Name Chimney -Type String -Attribute Write -ValidateSet @('Automatic','Disabled','Enabled')
    $TaskOffload = New-xDscResourceProperty -Name TaskOffload -Type String -Attribute Write -ValidateSet @('Disabled','Enabled')
    $NetworkDirect = New-xDscResourceProperty -Name NetworkDirect -Type String -Attribute Write -ValidateSet @('Disabled','Enabled')
    $NetworkDirectAcrossIPSubnets = New-xDscResourceProperty -Name NetworkDirectAcrossIPSubnets -Type String -Attribute Write -ValidateSet @('Allowed','Blocked')
    $PacketCoalescingFilter = New-xDscResourceProperty -Name PacketCoalescingFilter -Type String -Attribute Write -ValidateSet @('Disabled','Enabled')

    New-xDscResource -Name DM_cNetOffloadGlobalSetting -FriendlyName cNetOffloadGlobalSetting -Property `
    $Ensure,$ReceiveSideScaling,$ReceiveSegmentCoalescing,$Chimney,$TaskOffload,$NetworkDirect,$NetworkDirectAcrossIPSubnets,$PacketCoalescingFilter `
    -Path ([System.Environment]::GetFolderPath('Desktop')) -ModuleName cNetworking

===============================================================================================================================================================================#>


#Localized messages 
data LocalizedData { 
    #culture="en-US" 
    ConvertFrom-StringData @' 
        EnsureSetToAbsent            = The 'Ensure' parameter has been set to 'Absent'. Therefore the current Network Offload options will be compared against their default values.
        ConfigurationIsCompliant     = All Network Offload Global Settings are compliant. No further action is required.
        ConfigurationIsNotCompliant  = One or more DNS Client Global Settings are not compliant.
        SettingNotcompliant          = The Network Offload Global Setting '{0}' is not compliant.`nCurrent state is: '{1}'`nCompliant state is: '{2}'
        ConfiguringSetting           = Configuring the Network Offload Global Setting on {0}: {1} = '{2}'
        FailedConfiguringSetting     = Failed to configure the Network Offload Global Setting on {0}: '{1}' to '{2}'
        ConfiguringComplete          = Execution is complete and all DNS Client Global settings should now be in a compliant state.
'@
} 


#The Get-TargetResource function wrapper.
Function Get-TargetResource {
	[CmdletBinding()]
	[OutputType([System.Collections.Hashtable])]
    Param (
        [Parameter(Mandatory = $true)]
        [ValidateSet('Present','Absent')]
        [System.String]
        $Ensure,

        [Parameter(Mandatory = $false)]
        [ValidateSet('Disabled','Enabled')]
        [System.String]
        $ReceiveSideScaling,

        [Parameter(Mandatory = $false)]
        [ValidateSet('Disabled','Enabled')]
        [System.String]
        $ReceiveSegmentCoalescing,

        [Parameter(Mandatory = $false)]
        [ValidateSet('Automatic','Disabled','Enabled')]
        [System.String]
        $Chimney,

        [Parameter(Mandatory = $false)]
        [ValidateSet('Disabled','Enabled')]
        [System.String]
        $TaskOffload,

        [Parameter(Mandatory = $false)]
        [ValidateSet('Disabled','Enabled')]
        [System.String]
        $NetworkDirect,

        [Parameter(Mandatory = $false)]
        [ValidateSet('Allowed','Blocked')]
        [System.String]
        $NetworkDirectAcrossIPSubnets,

        [Parameter(Mandatory = $false)]
        [ValidateSet('Disabled','Enabled')]
        [System.String]
        $PacketCoalescingFilter
	)
    
    ValidateProperties @PSBoundParameters -Mode Get
}




#The Set-TargetResource function wrapper.
Function Set-TargetResource {
	[CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true)]
        [ValidateSet('Present','Absent')]
        [System.String]
        $Ensure,

        [Parameter(Mandatory = $false)]
        [ValidateSet('Disabled','Enabled')]
        [System.String]
        $ReceiveSideScaling,

        [Parameter(Mandatory = $false)]
        [ValidateSet('Disabled','Enabled')]
        [System.String]
        $ReceiveSegmentCoalescing,

        [Parameter(Mandatory = $false)]
        [ValidateSet('Automatic','Disabled','Enabled')]
        [System.String]
        $Chimney,

        [Parameter(Mandatory = $false)]
        [ValidateSet('Disabled','Enabled')]
        [System.String]
        $TaskOffload,

        [Parameter(Mandatory = $false)]
        [ValidateSet('Disabled','Enabled')]
        [System.String]
        $NetworkDirect,

        [Parameter(Mandatory = $false)]
        [ValidateSet('Allowed','Blocked')]
        [System.String]
        $NetworkDirectAcrossIPSubnets,

        [Parameter(Mandatory = $false)]
        [ValidateSet('Disabled','Enabled')]
        [System.String]
        $PacketCoalescingFilter
	)

    ValidateProperties @PSBoundParameters -Mode Set
}




#The Test-TargetResource function wrapper.
Function Test-TargetResource {
	[CmdletBinding()]
	[OutputType([System.Boolean])]
	Param (
        [Parameter(Mandatory = $true)]
        [ValidateSet('Present','Absent')]
        [System.String]
        $Ensure,

        [Parameter(Mandatory = $false)]
        [ValidateSet('Disabled','Enabled')]
        [System.String]
        $ReceiveSideScaling,

        [Parameter(Mandatory = $false)]
        [ValidateSet('Disabled','Enabled')]
        [System.String]
        $ReceiveSegmentCoalescing,

        [Parameter(Mandatory = $false)]
        [ValidateSet('Automatic','Disabled','Enabled')]
        [System.String]
        $Chimney,

        [Parameter(Mandatory = $false)]
        [ValidateSet('Disabled','Enabled')]
        [System.String]
        $TaskOffload,

        [Parameter(Mandatory = $false)]
        [ValidateSet('Disabled','Enabled')]
        [System.String]
        $NetworkDirect,

        [Parameter(Mandatory = $false)]
        [ValidateSet('Allowed','Blocked')]
        [System.String]
        $NetworkDirectAcrossIPSubnets,

        [Parameter(Mandatory = $false)]
        [ValidateSet('Disabled','Enabled')]
        [System.String]
        $PacketCoalescingFilter
	)

    ValidateProperties @PSBoundParameters -Mode Test
}




#This function has all the smarts in it and is used to do all of the configuring.
Function ValidateProperties {

    [CmdletBinding()]
	Param (
        [Parameter(Mandatory = $true)]
        [ValidateSet('Present','Absent')]
        [System.String]
        $Ensure,

        [Parameter(Mandatory = $false)]
        [ValidateSet('Disabled','Enabled')]
        [System.String]
        $ReceiveSideScaling,

        [Parameter(Mandatory = $false)]
        [ValidateSet('Disabled','Enabled')]
        [System.String]
        $ReceiveSegmentCoalescing,

        [Parameter(Mandatory = $false)]
        [ValidateSet('Automatic','Disabled','Enabled')]
        [System.String]
        $Chimney,

        [Parameter(Mandatory = $false)]
        [ValidateSet('Disabled','Enabled')]
        [System.String]
        $TaskOffload,

        [Parameter(Mandatory = $false)]
        [ValidateSet('Disabled','Enabled')]
        [System.String]
        $NetworkDirect,

        [Parameter(Mandatory = $false)]
        [ValidateSet('Allowed','Blocked')]
        [System.String]
        $NetworkDirectAcrossIPSubnets,

        [Parameter(Mandatory = $false)]
        [ValidateSet('Disabled','Enabled')]
        [System.String]
        $PacketCoalescingFilter,

        [Parameter(Mandatory = $true)]
		[ValidateSet('Get','Set','Test')]
		[System.String]
        $Mode = 'Get'
	)


    #If Debug mode is on, don't prompt the user for permission to continue.
    if ($PSBoundParameters['Debug'] -eq $true) {
        $DebugPreference = 'Continue'
    }


    #If $Ensure is 'Absent' then Test that the offload options are using their default values.
    if ($Ensure -eq 'Absent') {
        Write-Debug -Message $LocalizedData.EnsureSetToAbsent
        $ReceiveSideScaling = 'Enabled'
        $ReceiveSegmentCoalescing = 'Enabled'
        $Chimney = 'Disabled'
        $TaskOffload = 'Enabled'
        $NetworkDirect = 'Enabled'
        $NetworkDirectAcrossIPSubnets = 'Blocked'
        $PacketCoalescingFilter = 'Disabled'
    
    } else {

    }


    #Obtain the current Network Offload Global Settings.
    $Current_NetOffloadGlobalSetting = Get-NetOffloadGlobalSetting




    #Perform checks to see if the current Network Offload Global Settings are compliant, but ignore any that have not had any values specified.
    #------------------------------------------------------------------------------------------------------------------------------------------
    #Check that the 'ReceiveSideScaling' setting is compliant (if the paramter has been specified).
    if (-not [String]::IsNullOrEmpty($ReceiveSideScaling)) {
        [System.Boolean]$Check_ReceiveSideScaling = $Current_NetOffloadGlobalSetting.ReceiveSideScaling -eq $ReceiveSideScaling
    }

    #Check that the 'ReceiveSegmentCoalescing' setting is compliant (if the paramter has been specified).
    if (-not [String]::IsNullOrEmpty($ReceiveSegmentCoalescing)) {
        [System.Boolean]$Check_ReceiveSegmentCoalescing = $Current_NetOffloadGlobalSetting.ReceiveSegmentCoalescing -eq $ReceiveSegmentCoalescing
    }

    #Check that the 'Chimney' setting is compliant (if the paramter has been specified).
    if (-not [String]::IsNullOrEmpty($Chimney)) {
        [System.Boolean]$Check_Chimney = $Current_NetOffloadGlobalSetting.Chimney -eq $Chimney
    }

    #Check that the 'TaskOffload' setting is compliant (if the paramter has been specified).
    if (-not [String]::IsNullOrEmpty($TaskOffload)) {
        [System.Boolean]$Check_TaskOffload = $Current_NetOffloadGlobalSetting.TaskOffload -eq $TaskOffload
    }

    #Check that the 'NetworkDirect' setting is compliant (if the paramter has been specified).
    if (-not [String]::IsNullOrEmpty($NetworkDirect)) {
        [System.Boolean]$Check_NetworkDirect = $Current_NetOffloadGlobalSetting.NetworkDirect -eq $NetworkDirect
    }

    #Check that the 'NetworkDirectAcrossIPSubnets' setting is compliant (if the paramter has been specified).
    if (-not [String]::IsNullOrEmpty($NetworkDirectAcrossIPSubnets)) {
        [System.Boolean]$Check_NetworkDirectAcrossIPSubnets = $Current_NetOffloadGlobalSetting.NetworkDirectAcrossIPSubnets -eq $NetworkDirectAcrossIPSubnets
    }

    #Check that the 'PacketCoalescingFilter' setting is compliant (if the paramter has been specified).
    if (-not [String]::IsNullOrEmpty($PacketCoalescingFilter)) {
        [System.Boolean]$Check_PacketCoalescingFilter = $Current_NetOffloadGlobalSetting.PacketCoalescingFilter -eq $PacketCoalescingFilter
    }

    






<#...............................................................................................................................................................................

Get, Set or Test the Network Offload Global Settings as per the checks performed in the previous section.

...............................................................................................................................................................................#>
    

    #Generate the data to return if 'Get' mode is used.
    $ReturnData = @{
        Ensure = $Ensure
        ReceiveSideScaling = $Current_NetOffloadGlobalSetting.ReceiveSideScaling
        ReceiveSegmentCoalescing = $Current_NetOffloadGlobalSetting.ReceiveSegmentCoalescing
        Chimney = $Current_NetOffloadGlobalSetting.Chimney
        TaskOffload = $Current_NetOffloadGlobalSetting.TaskOffload
        NetworkDirect = $Current_NetOffloadGlobalSetting.NetworkDirect
        NetworkDirectAcrossIPSubnets = $Current_NetOffloadGlobalSetting.NetworkDirectAcrossIPSubnets
        PacketCoalescingFilter = $Current_NetOffloadGlobalSetting.PacketCoalescingFilter
    }

    #See if any of the checks failed.
    [Array]$NonCompliantSettings = Get-Variable Check_* | Where-Object {$_.Value -eq $false}




    #If all Network Offload Global Settings are compliant then no further action is require.
    #---------------------------------------------------------------------------------------
    if ($NonCompliantSettings.Count -eq 0) {
        Write-Verbose -Message $LocalizedData.ConfigurationIsCompliant
                
        switch ($Mode) {
            'Get'  {Return $ReturnData}
            'Set'  {Return}
            'Test' {Return $true}
        }




    #If one or more Network Offload Global Settings are not compliant then proceed as per the $Mode (Get, Set Test).
    #---------------------------------------------------------------------------------------------------------------
    } else {
        Write-Verbose -Message $LocalizedData.ConfigurationIsNotCompliant

        #Indicate that the system requires a reboot.
	    $global:DSCMachineStatus = 1

    


        #Configure each non-compliant Network Offload Setting.
        #-----------------------------------------------------
        foreach ($NonCompliantSetting in $NonCompliantSettings) {
            $Setting_Name = $NonCompliantSetting.Name.Replace('Check_','')
            $Setting_CurrentState = (Get-Variable -Name $Setting_Name).Value
            $Setting_CompliantState = $Current_NetOffloadGlobalSetting.$Setting_Name

            #If Debug mode is enabled then return more detailed information on what settings are not compliant.
            if ($PSBoundParameters['Debug'] -eq $true) {
                Write-Debug -Message ($LocalizedData.SettingNotcompliant -f $Setting_Name, $Setting_CurrentState, $Setting_CompliantState)
            }


            #If using 'Set' mode then bring the non-compliant setting back into compliance.
            if ($Mode -eq 'Set') {
                Write-Verbose -Message ($LocalizedData.ConfiguringSetting -f $env:COMPUTERNAME, $Setting_Name, $Setting_CompliantState)

                $ConfigureSetting = @{$Setting_Name = $Setting_CompliantState}
                try { 
                    Set-NetOffloadGlobalSetting @ConfigureSetting

                } catch {
                    $ErrorRecord = New-Object System.Management.Automation.ErrorRecord(`
                        (New-Object System.InvalidOperationException(($LocalizedData.FailedConfiguringSetting -f $env:COMPUTERNAME, $Setting_Name, $Setting_CompliantState))), 
                        'SetNetOffloadGlobalSetting', 
                        ([System.Management.Automation.ErrorCategory]::InvalidOperation),
                        $null
                    )

                    $PSCmdlet.ThrowTerminatingError($ErrorRecord)
                }
            }
        }




        #Return the appropriate response based on the $Mode (Get, Set Test).
        #-------------------------------------------------------------------
        switch ($Mode) {
            'Get'  {Return $ReturnData}
            'Set'  {Write-Verbose -Message $LocalizedData.ConfiguringComplete;  Return}
            'Test' {Return $false}
        }
    }
}


Export-ModuleMember -Function *-TargetResource