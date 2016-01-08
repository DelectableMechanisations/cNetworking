<#===============================================================================================================================================================================

DM_cDnsClientGlobalSetting.psm1

AUTHOR:         David Baumbach
Version:        1.0.0
Creation Date:  23/11/2015
Last Modified:  08/01/2016


This DSC module is used to configure the DNS Client Global Settings (resolve computer names by appending the Primary and Connection Specific Suffix or by using a pre-defined
list of DNS Suffixes).


Change Log:
    0.0.1   23/11/2015  Initial Creation
    1.0.0   08/01/2016  First Published


The code used to build the module.
    Import-Module xDSCResourceDesigner

    $UsePrimaryAndConnectionSpecificSuffix = New-xDscResourceProperty -Name UsePrimaryAndConnectionSpecificSuffix -Type Boolean -Attribute Key
    $SuffixSearchList = New-xDscResourceProperty -Name SuffixSearchList -Type 'String[]' -Attribute Write
    $UseDevolution = New-xDscResourceProperty -Name UseDevolution -Type Boolean -Attribute Write

    New-xDscResource -Name DM_cDnsClientGlobalSetting -FriendlyName cDnsClientGlobalSetting -Property $UsePrimaryAndConnectionSpecificSuffix,$SuffixSearchList,$UseDevolution -Path ([System.Environment]::GetFolderPath('Desktop')) -ModuleName cNetworking

===============================================================================================================================================================================#>


#The Get-TargetResource function wrapper.
Function Get-TargetResource {
	[CmdletBinding()]
	[OutputType([System.Collections.Hashtable])]
    Param (
        [Parameter(Mandatory = $true)]
        [System.Boolean]$UsePrimaryAndConnectionSpecificSuffix,

        [Parameter(Mandatory = $false)]
        [System.String[]]$SuffixSearchList,

        [Parameter(Mandatory = $false)]
        [System.Boolean]$UseDevolution
	)
    
    ValidateProperties @PSBoundParameters -Mode Get
}




#The Set-TargetResource function wrapper.
Function Set-TargetResource {
	[CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true)]
        [System.Boolean]$UsePrimaryAndConnectionSpecificSuffix,

        [Parameter(Mandatory = $false)]
        [System.String[]]$SuffixSearchList,

        [Parameter(Mandatory = $false)]
        [System.Boolean]$UseDevolution
	)

    ValidateProperties @PSBoundParameters -Mode Set
}




#The Test-TargetResource function wrapper.
Function Test-TargetResource {
	[CmdletBinding()]
	[OutputType([System.Boolean])]
	Param (
        [Parameter(Mandatory = $true)]
        [System.Boolean]$UsePrimaryAndConnectionSpecificSuffix,

        [Parameter(Mandatory = $false)]
        [System.String[]]$SuffixSearchList,

        [Parameter(Mandatory = $false)]
        [System.Boolean]$UseDevolution
	)

    ValidateProperties @PSBoundParameters -Mode Test
}




#This function has all the smarts in it and is used to do all of the configuring.
Function ValidateProperties {

    [CmdletBinding()]
	Param (
        [Parameter(Mandatory = $true)]
        [System.Boolean]$UsePrimaryAndConnectionSpecificSuffix,

        [Parameter(Mandatory = $false)]
        [System.String[]]$SuffixSearchList,

        [Parameter(Mandatory = $false)]
        [System.Boolean]$UseDevolution,

        [Parameter(Mandatory = $true)]
		[ValidateSet('Get','Set','Test')]
		[System.String]$Mode = 'Get'
	)


    #If Debug mode is on, don't prompt the user for permission to continue.
    if ($PSBoundParameters['Debug'] -eq $true) {
        $DebugPreference = 'Continue'
    }


    #$SuffixSearchList should be empty if $UsePrimaryAndConnectionSpecificSuffix is set to $true.
    if ($UsePrimaryAndConnectionSpecificSuffix -eq $true) {
        $SuffixSearchList = @()

    #$SuffixSearchList should have more than 1 string value in it if $UsePrimaryAndConnectionSpecificSuffix is set to $false.
    } else {
        if ($SuffixSearchList.Count -lt 1) {
            $ErrorRecord = New-Object System.Management.Automation.ErrorRecord(`
                (New-Object System.InvalidOperationException("The parameter 'SuffixSearchList' cannot be empty if 'UsePrimaryAndConnectionSpecificSuffix' is set to $false. Please set 'UsePrimaryAndConnectionSpecificSuffix' to $true or configure the 'SuffixSearchList' parameter (e.g. SuffixSearchList = 'mydomain.com')")), 
                'InvalidParameter', 
                ([System.Management.Automation.ErrorCategory]::InvalidOperation),
                $null
            )

            $PSCmdlet.ThrowTerminatingError($ErrorRecord)
        }
    }


    #Obtain the current DNS Client Global Settings.
    $DnsClientGlobalSetting = Get-DnsClientGlobalSetting
    $Current_UseDevolution = $DnsClientGlobalSetting.UseDevolution
    $DnsClient = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters"

    switch ($DnsClient.SearchList.Length -eq 0) {
        $true  {
            $Current_UsePrimaryAndConnectionSpecificSuffix = $true
            $Current_SuffixSearchList = @()
        }

        $false {
            $Current_UsePrimaryAndConnectionSpecificSuffix = $false
            $Current_SuffixSearchList = $DnsClientGlobalSetting.SuffixSearchList
        }
    }

    #Perform checks to see if the current DNS Client Global Settings are compliant.
    [System.Boolean]$Check_UsePrimaryAndConnectionSpecificSuffix = $Current_UsePrimaryAndConnectionSpecificSuffix -eq $UsePrimaryAndConnectionSpecificSuffix
    [System.Boolean]$Check_SuffixSearchList = (Compare-Object -ReferenceObject $Current_SuffixSearchList -DifferenceObject $SuffixSearchList -PassThru) -eq $null
    [System.Boolean]$Check_UseDevolution = $Current_UseDevolution = $UseDevolution








<#...............................................................................................................................................................................

Get, Set or Test the Dns Client Global Settings as per the checks performed in the previous section.

...............................................................................................................................................................................#>
    

    #Generate the data to return if 'Get' mode is used.
    $ReturnData = @{
        UsePrimaryAndConnectionSpecificSuffix = $Current_UsePrimaryAndConnectionSpecificSuffix
        SuffixSearchList = [System.String[]]$Current_SuffixSearchList
        UseDevolution = $Current_UseDevolution
    }




    #If all DNS Client Global Settings are compliant then no further action is require.
    #----------------------------------------------------------------------------------
    if ($Check_UsePrimaryAndConnectionSpecificSuffix -eq $true -and $Check_SuffixSearchList -eq $true -and $Check_UseDevolution -eq $true) {
        Write-Verbose -Message "All DNS Client Global Settings are compliant. No further action is required."
                
        switch ($Mode) {
            'Get'  {Return $ReturnData}
            'Set'  {Return}
            'Test' {Return $true}
        }




    #If one or more DNS Client Global Settings are not compliant then ptoceed as per the $Mode (Get, Set Test).
    #----------------------------------------------------------------------------------------------------------
    } else {
        Write-Verbose -Message "One or more DNS Client Global Settings are not compliant."

    


        #Configure the DNS Suffix Resolver settings if they are not compliant.
        #---------------------------------------------------------------------
        if ($Check_UsePrimaryAndConnectionSpecificSuffix -eq $false) {


            #If Debug mode is enabled then return more detailed information on which network adapters are not compliant.
            if ($PSBoundParameters['Debug'] -eq $true) {
                switch ($Current_UsePrimaryAndConnectionSpecificSuffix) {
                    $true  {Write-Debug -Message "The DNS Client on $($env:COMPUTERNAME) does not have compliant DNS Suffix Resolver settings.`nCurrent setting is to use the Primary and Connection Specific Suffix`nCompliant setting is to append the following DNS Suffixes: $(([String]$SuffixSearchList).Replace(' ',','))"}
                    $false {Write-Debug -Message "The DNS Client on $($env:COMPUTERNAME) does not have compliant DNS Suffix Resolver settings.`nCurrent setting is to append the following DNS Suffixes: $(([String]$Current_SuffixSearchList).Replace(' ',','))`nCompliant setting is to use the Primary and Connection Specific Suffix"}
                }
            }


            #If using 'Set' mode then bring matching non-compliant Netwok Adapters back into compliance.
            if ($Mode -eq 'Set') {
                Write-Verbose -Message "Configuring the DNS Client on $($env:COMPUTERNAME): SuffixSearchList = '$(([String]$SuffixSearchList).Replace(' ',"','"))'"
                try { 
                    Set-DnsClientGlobalSetting -SuffixSearchList $SuffixSearchList

                } catch {
                    $ErrorRecord = New-Object System.Management.Automation.ErrorRecord(`
                        (New-Object System.InvalidOperationException("Configuring the DNS Client on $($env:COMPUTERNAME): SuffixSearchList = '$(([String]$SuffixSearchList).Replace(' ',"','"))'")), 
                        'SetDnsClientGlobalSetting', 
                        ([System.Management.Automation.ErrorCategory]::InvalidOperation),
                        $null
                    )

                    $PSCmdlet.ThrowTerminatingError($ErrorRecord)
                }
            }
        }




        #Configure the DNS Devolution settings if they are not compliant.
        #----------------------------------------------------------------
        if ($Check_UseDevolution -eq $false) {


            #If Debug mode is enabled then return more detailed information on which network adapters are not compliant.
            if ($PSBoundParameters['Debug'] -eq $true) {
                switch ($Current_UseDevolution) {
                    $true  {Write-Debug -Message "The DNS Client on $($env:COMPUTERNAME) does not have compliant DNS Devolution settings.`nCurrent setting is to use DNS Devolution`nCompliant setting is to not use DNS Devolution"}
                    $false {Write-Debug -Message "The DNS Client on $($env:COMPUTERNAME) does not have compliant DNS Devolution settings.`nCurrent setting is to use not DNS Devolution`nCompliant setting is to not DNS Devolution"}
                }
            }


            #If using 'Set' mode then bring matching non-compliant Netwok Adapters back into compliance.
            if ($Mode -eq 'Set') {
                Write-Verbose -Message "Configuring the DNS Client on $($env:COMPUTERNAME): UseDevolution = $UseDevolution"
                try {
                    Set-DnsClientGlobalSetting -SuffixSearchList $SuffixSearchList

                } catch {
                    $ErrorRecord = New-Object System.Management.Automation.ErrorRecord(`
                        (New-Object System.InvalidOperationException("Configuring the DNS Client on $($env:COMPUTERNAME): UseDevolution = $UseDevolution")), 
                        'SetDnsClientGlobalSetting', 
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
            'Set'  {Write-Verbose -Message "Execution is complete and all DNS Client Global settings should now be in a compliant state.";  Return}
            'Test' {Return $false}
        }
    }
}


Export-ModuleMember -Function *-TargetResource