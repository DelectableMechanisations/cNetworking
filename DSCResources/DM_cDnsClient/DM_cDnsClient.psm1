<#===============================================================================================================================================================================

DM_cDnsClient.psm1

AUTHOR:         David Baumbach
Version:        1.0.1
Creation Date:  21/11/2015
Last Modified:  09/01/2016


This DSC resource is used to configure the DNS Client settings of a network adapter that matches a specified filter.


Change Log:
    0.0.1   21/11/2015  Initial Creation
    1.0.0   08/01/2016  First Published
    1.0.1   09/01/2016  Cleaned up function parameters and added '[CmdletBinding()]' attribute.


The code used to build the module.
    Import-Module xDSCResourceDesigner

    $Action = New-xDscResourceProperty -Name Action -Type String -Attribute Key -ValidateSet @('ApplyToMatchingAdapters', 'ApplytoNonMatchingAdapters')
    $FilterIPAddressPrefixes = New-xDscResourceProperty -Name FilterIPAddressPrefixes -Type 'String[]' -Attribute Write
    $AddressFamily = New-xDscResourceProperty -Name AddressFamily -Type String -Attribute Write -ValidateSet @('IPv4', 'IPv6')
    $ConnectionSpecificSuffix = New-xDscResourceProperty -Name ConnectionSpecificSuffix -Type String -Attribute Write
    $RegisterThisConnectionsAddress = New-xDscResourceProperty -Name RegisterThisConnectionsAddress -Type Boolean -Attribute Write
    $UseSuffixWhenRegistering = New-xDscResourceProperty -Name UseSuffixWhenRegistering -Type Boolean -Attribute Write
    $MatchedIPAddresses = New-xDscResourceProperty -Name MatchedIPAddresses -Type 'String[]' -Attribute Read
    

    New-xDscResource -Name DM_cDnsClient -FriendlyName cDnsClient -Property $FilterIPAddressPrefixes, $Action, $AddressFamily, $ConnectionSpecificSuffix, $RegisterThisConnectionsAddress, $UseSuffixWhenRegistering, $MatchedIPAddresses `
    -Path ([System.Environment]::GetFolderPath('Desktop')) -ModuleName cNetworking

===============================================================================================================================================================================#>


#The Get-TargetResource function wrapper.
Function Get-TargetResource {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    Param (
        [Parameter(Mandatory = $true)]
        [ValidateSet('ApplyToMatchingAdapters', 'ApplytoNonMatchingAdapters')]
        [System.String]
        $Action,

        [Parameter(Mandatory = $false)]
        [System.String[]]
        $FilterIPAddressPrefixes = '*',

        [Parameter(Mandatory = $false)]
        [ValidateSet('IPv4', 'IPv6')]
        [System.String]
        $AddressFamily = 'IPv4',

        [Parameter(Mandatory = $false)]
        [AllowNull()]
        [System.String]
        $ConnectionSpecificSuffix,

        [Parameter(Mandatory = $false)]
        [System.Boolean]
        $RegisterThisConnectionsAddress,

        [Parameter(Mandatory = $false)]
        [System.Boolean]
        $UseSuffixWhenRegistering
    )

    ValidateProperties @PSBoundParameters -Mode Set
}




#The Set-TargetResource function wrapper.
Function Set-TargetResource {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true)]
        [ValidateSet('ApplyToMatchingAdapters', 'ApplytoNonMatchingAdapters')]
        [System.String]
        $Action,

        [Parameter(Mandatory = $false)]
        [System.String[]]
        $FilterIPAddressPrefixes = '*',

        [Parameter(Mandatory = $false)]
        [ValidateSet('IPv4', 'IPv6')]
        [System.String]
        $AddressFamily = 'IPv4',

        [Parameter(Mandatory = $false)]
        [AllowNull()]
        [System.String]
        $ConnectionSpecificSuffix,

        [Parameter(Mandatory = $false)]
        [System.Boolean]
        $RegisterThisConnectionsAddress,

        [Parameter(Mandatory = $false)]
        [System.Boolean]
        $UseSuffixWhenRegistering
    )

    ValidateProperties @PSBoundParameters -Mode Set
}




#The Test-TargetResource function wrapper.
Function Test-TargetResource {
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    Param (
        [Parameter(Mandatory = $true)]
        [ValidateSet('ApplyToMatchingAdapters', 'ApplytoNonMatchingAdapters')]
        [System.String]
        $Action,

        [Parameter(Mandatory = $false)]
        [System.String[]]
        $FilterIPAddressPrefixes = '*',

        [Parameter(Mandatory = $false)]
        [ValidateSet('IPv4', 'IPv6')]
        [System.String]
        $AddressFamily = 'IPv4',

        [Parameter(Mandatory = $false)]
        [AllowNull()]
        [System.String]
        $ConnectionSpecificSuffix,

        [Parameter(Mandatory = $false)]
        [System.Boolean]
        $RegisterThisConnectionsAddress,

        [Parameter(Mandatory = $false)]
        [System.Boolean]
        $UseSuffixWhenRegistering
    )

    ValidateProperties @PSBoundParameters -Mode Test
}




#This function has all the smarts in it and is used to do all of the configuring.
Function ValidateProperties {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true)]
        [ValidateSet('ApplyToMatchingAdapters', 'ApplytoNonMatchingAdapters')]
        [System.String]
        $Action,

        [Parameter(Mandatory = $false)]
        [System.String[]]
        $FilterIPAddressPrefixes = '*',

        [Parameter(Mandatory = $false)]
        [ValidateSet('IPv4', 'IPv6')]
        [System.String]
        $AddressFamily = 'IPv4',

        [Parameter(Mandatory = $false)]
        [AllowNull()]
        [System.String]
        $ConnectionSpecificSuffix,

        [Parameter(Mandatory = $false)]
        [System.Boolean]
        $RegisterThisConnectionsAddress = $true,

        [Parameter(Mandatory = $false)]
        [System.Boolean]
        $UseSuffixWhenRegistering = $false,

        [Parameter(Mandatory = $true)]
        [ValidateSet('Get','Set','Test')]
        [System.String]$Mode = 'Get'
    )
    

    #If Debug mode is on, don't prompt the user for permission to continue.
    if ($PSBoundParameters['Debug'] -eq $true) {
        $DebugPreference = 'Continue'
    }








<#...............................................................................................................................................................................

Find all Network Adapters on the system that match the search criteria specified in $FilterIPAddressPrefixes and $Action

...............................................................................................................................................................................#>


    #Build an array of all network adapters that have the same Address Family as specified in the $AddressFamily parameter.
    [Array]$List_NetworkAdapters = Get-NetAdapter | Get-NetIPAddress -AddressFamily $AddressFamily
    $List_AnalysedNetworkAdapters = New-Object -TypeName System.Collections.ArrayList

    foreach ($NetworkAdapter in $List_NetworkAdapters) {
        Write-Debug -Message "Analysing the Network Adapter '$($NetworkAdapter.InterfaceAlias)' (Interface Index $($NetworkAdapter.InterfaceIndex)) which uses the IP Address '$($NetworkAdapter.IPAddress)'."

        $AdapterMatchesPrefix = $false

        #Check to see if the IP Address of the Network Adapter matches one of the prefixes in the $FilterIPAddressPrefixes variable.
        foreach ($FilterIPAddressPrefix in $FilterIPAddressPrefixes) {
            if ($NetworkAdapter.IPAddress -like $FilterIPAddressPrefix) {
                Write-Debug -Message "The Network Adapter with the IP Address '$($NetworkAdapter.IPAddress)' matches the filter prefix '$FilterIPAddressPrefix'."
                $AdapterMatchesPrefix = $true

            } else {
                Write-Debug -Message "The Network Adapter with the IP Address '$($NetworkAdapter.IPAddress)' does not match the filter prefix '$FilterIPAddressPrefix'."
            }
           
        }

        #Profile the network adapter regardless of whether or not it matches the filter prefix.
        [VOID]$List_AnalysedNetworkAdapters.Add((New-Object -TypeName psobject -Property @{
            InterfaceIndex = $NetworkAdapter.InterfaceIndex
            InterfaceAlias = $NetworkAdapter.InterfaceAlias
            IPAddress = $NetworkAdapter.IPAddress
            AddressFamily = $NetworkAdapter.AddressFamily
            AdapterMatchesPrefix = $AdapterMatchesPrefix
        }))
    }




    #Apply the filter to the profiled Network Adapters.
    #--------------------------------------------------
    switch ($Action) {
        'ApplyToMatchingAdapters'    {
            [Array]$List_NetworkAdaptersToCheckForCompliance = $List_AnalysedNetworkAdapters | Where-Object {$_.AdapterMatchesPrefix -eq $true}  | Sort-Object -Property InterfaceIndex
            Write-Verbose -Message "$($List_NetworkAdaptersToCheckForCompliance.Count) out of $($List_AnalysedNetworkAdapters.Count) network adapters on $($env:COMPUTERNAME) match one of the IP Address prefixes specified in the 'FilterIPAddressPrefixes' parameter and will be checked for compliance."
            Break
        }

        'ApplytoNonMatchingAdapters' {
            [Array]$List_NetworkAdaptersToCheckForCompliance = $List_AnalysedNetworkAdapters | Where-Object {$_.AdapterMatchesPrefix -eq $false} | Sort-Object -Property InterfaceIndex
            Write-Verbose -Message "$($List_NetworkAdaptersToCheckForCompliance.Count) out of $($List_AnalysedNetworkAdapters.Count) network adapters on $($env:COMPUTERNAME) don't match one of the IP Address prefixes specified in the 'FilterIPAddressPrefixes' parameter and will be checked for compliance."
            Break
        }
    }




    #Add the Dns Client configuration to each profiled network adapter.
    foreach ($NetworkAdapterToCheck in $List_NetworkAdaptersToCheckForCompliance) {
        $DnsClientSettings = Get-DnsClient -InterfaceIndex $NetworkAdapterToCheck.InterfaceIndex
        $NetworkAdapterToCheck | Add-Member -MemberType NoteProperty -Name 'ConnectionSpecificSuffix' -Value $DnsClientSettings.ConnectionSpecificSuffix
        $NetworkAdapterToCheck | Add-Member -MemberType NoteProperty -Name 'RegisterThisConnectionsAddress' -Value $DnsClientSettings.RegisterThisConnectionsAddress
        $NetworkAdapterToCheck | Add-Member -MemberType NoteProperty -Name 'UseSuffixWhenRegistering' -Value $DnsClientSettings.UseSuffixWhenRegistering
    }
    



    #Determine whether or not the Network Adapters are all collectively in a compliant state.
    #----------------------------------------------------------------------------------------
    switch ([String]::IsNullOrEmpty($ConnectionSpecificSuffix)) {
        $true  {$CheckAll_ConnectionSpecificSuffix = ([Array]($List_NetworkAdaptersToCheckForCompliance | Where-Object {[String]::IsNullOrEmpty($_.ConnectionSpecificSuffix) -eq $true})).Count -eq $List_NetworkAdaptersToCheckForCompliance.Count}
        $false {$CheckAll_ConnectionSpecificSuffix = ([Array]($List_NetworkAdaptersToCheckForCompliance | Where-Object {$_.ConnectionSpecificSuffix -eq $ConnectionSpecificSuffix})).Count -eq $List_NetworkAdaptersToCheckForCompliance.Count}
    }
    $CheckAll_RegisterThisConnectionsAddress = ([Array]($List_NetworkAdaptersToCheckForCompliance | Where-Object {$_.RegisterThisConnectionsAddress -eq $RegisterThisConnectionsAddress})).Count -eq $List_NetworkAdaptersToCheckForCompliance.Count
    $CheckAll_UseSuffixWhenRegistering = ([Array]($List_NetworkAdaptersToCheckForCompliance | Where-Object {$_.UseSuffixWhenRegistering -eq $UseSuffixWhenRegistering})).Count -eq $List_NetworkAdaptersToCheckForCompliance.Count








<#...............................................................................................................................................................................

Get, Set or Test the Dns Client settings of the Network Adapters retrieved in the previous section.

...............................................................................................................................................................................#>
    

    #If all matching network adapters have compliant DNS Client Settings then no further action is require.
    #------------------------------------------------------------------------------------------------------
    if ($CheckAll_ConnectionSpecificSuffix -eq $true -and $CheckAll_RegisterThisConnectionsAddress -eq $true -and $CheckAll_UseSuffixWhenRegistering -eq $true) {
        Write-Verbose -Message "All matching network adapters have compliant DNS Client settings. No further action is required."
                
        switch ($Mode) {
            'Get'  {
            
                $ReturnData = @{
                    MatchedIPAddresses = [System.String[]]($List_MatchedIPAddressesToCheckForCompliance | Select-Object -ExpandProperty IPAddress)
                    FilterIPAddressPrefixes = $FilterIPAddressPrefixes
                    Action = $Action
                    AddressFamily = $AddressFamily
                    ConnectionSpecificSuffix = $ConnectionSpecificSuffix
                    RegisterThisConnectionsAddress = $RegisterThisConnectionsAddress
                    UseSuffixWhenRegistering = $UseSuffixWhenRegistering
                }

                Return $ReturnData
            }

            'Set'  {Return}
            'Test' {Return $true}
        }




    #If 1 or more matching network adapters do not have compliant DNS Client Settings then proceed as per the $Mode (Get, Set Test).
    #-------------------------------------------------------------------------------------------------------------------------------
    } else {
        Write-Verbose -Message "1 or more matching network adapters do not have compliant DNS Client settings."

    


        #Configure the 'ConnectionSpecificSuffix' DNS Client settings of any matching Network Adapters that are not compliant.
        #---------------------------------------------------------------------------------------------------------------------
        if ($CheckAll_ConnectionSpecificSuffix -eq $false) {
            $Get_ConnectionSpecificSuffix = 'NON COMPLIANT VALUE'


            #If Debug mode is enabled then return more detailed information on which network adapters are not compliant.
            if ($PSBoundParameters['Debug'] -eq $true) {
                $List_NetworkAdaptersToCheckForCompliance | Where-Object {$_.ConnectionSpecificSuffix -ne $ConnectionSpecificSuffix} | ForEach-Object {
                    Write-Debug -Message "The Network Adapter with Interface Index $($_.InterfaceIndex) and IP Address '$($_.IPAddress)' does not have a compliant Connection Specific Suffix.`nCurrent setting is ConnectionSpecificSuffix = '$($_.ConnectionSpecificSuffix)'`nCompliant setting is ConnectionSpecificSuffix = '$ConnectionSpecificSuffix'"
                }
            }


            #If using 'Set' mode then bring matching non-compliant Network Adapters back into compliance.
            if ($Mode -eq 'Set') {
                $List_NetworkAdaptersToCheckForCompliance | Where-Object {$_.ConnectionSpecificSuffix -ne $ConnectionSpecificSuffix} | ForEach-Object {
                
                    Write-Verbose -Message "Configuring Network Adapter with Interface Index $($_.InterfaceIndex) and IP Address '$($_.IPAddress)': ConnectionSpecificSuffix = '$ConnectionSpecificSuffix'"
                    try {
                        Set-DnsClient -InterfaceIndex $_.InterfaceIndex -ConnectionSpecificSuffix $ConnectionSpecificSuffix

                    } catch {
                        $ErrorRecord = New-Object System.Management.Automation.ErrorRecord(`
                            (New-Object System.InvalidOperationException("Configuring Network Adapter with Interface Index $($_.InterfaceIndex) and IP Address '$($_.IPAddress)': ConnectionSpecificSuffix = '$ConnectionSpecificSuffix'")), 
                            'SetDnsClient', 
                            ([System.Management.Automation.ErrorCategory]::InvalidOperation),
                            $null
                        )

                        $PSCmdlet.ThrowTerminatingError($ErrorRecord)
                    }
                }
            }
        }




        #Configure the 'RegisterThisConnectionsAddress' DNS Client settings of any matching Network Adapters that are not compliant.
        #---------------------------------------------------------------------------------------------------------------------------
        if ($CheckAll_RegisterThisConnectionsAddress -eq $false) {
            $Get_RegisterThisConnectionsAddress = -not $RegisterThisConnectionsAddress


            #If Debug mode is enabled then return more detailed information on which network adapters are not compliant.
            if ($PSBoundParameters['Debug'] -eq $true) {
                $List_NetworkAdaptersToCheckForCompliance | Where-Object {$_.RegisterThisConnectionsAddress -ne $RegisterThisConnectionsAddress} | ForEach-Object {
                    Write-Debug -Message "The Network Adapter with Interface Index $($_.InterfaceIndex) and IP Address '$($_.IPAddress)' does not have compliant Connection DNS Registration settings.`nCurrent setting is RegisterThisConnectionsAddress = $($_.RegisterThisConnectionsAddress)`nCompliant setting is RegisterThisConnectionsAddress = $RegisterThisConnectionsAddress"
                }
            }


            #If using 'Set' mode then bring matching non-compliant Network Adapters back into compliance.
            if ($Mode -eq 'Set') {
                $List_NetworkAdaptersToCheckForCompliance | Where-Object {$_.RegisterThisConnectionsAddress -ne $RegisterThisConnectionsAddress} | ForEach-Object {
                
                    Write-Verbose -Message "Configuring Network Adapter with Interface Index $($_.InterfaceIndex) and IP Address '$($_.IPAddress)': RegisterThisConnectionsAddress = '$RegisterThisConnectionsAddress'"
                    try {
                        Set-DnsClient -InterfaceIndex $_.InterfaceIndex -RegisterThisConnectionsAddress $RegisterThisConnectionsAddress

                    } catch {
                        $ErrorRecord = New-Object System.Management.Automation.ErrorRecord(`
                            (New-Object System.InvalidOperationException("Configuring Network Adapter with Interface Index $($_.InterfaceIndex) and IP Address '$($_.IPAddress)': RegisterThisConnectionsAddress = '$RegisterThisConnectionsAddress'")), 
                            'SetDnsClient', 
                            ([System.Management.Automation.ErrorCategory]::InvalidOperation),
                            $null
                        )

                        $PSCmdlet.ThrowTerminatingError($ErrorRecord)
                    }
                }
            }
        }




        #Configure the 'UseSuffixWhenRegistering' DNS Client settings of any matching Network Adapters that are not compliant.
        #---------------------------------------------------------------------------------------------------------------------
        if ($CheckAll_UseSuffixWhenRegistering -eq $false) {
            $Get_UseSuffixWhenRegistering = -not $UseSuffixWhenRegistering


            #If Debug mode is enabled then return more detailed information on which network adapters are not compliant.
            if ($PSBoundParameters['Debug'] -eq $true) {
                $List_NetworkAdaptersToCheckForCompliance | Where-Object {$_.UseSuffixWhenRegistering -ne $UseSuffixWhenRegistering} | ForEach-Object {
                    Write-Debug -Message "The Network Adapter with Interface Index $($_.InterfaceIndex) and IP Address '$($_.IPAddress)' does not have compliant DNS Suffix Registration settings.`nCurrent setting is UseSuffixWhenRegistering = $($_.UseSuffixWhenRegistering)`nCompliant setting is UseSuffixWhenRegistering = $UseSuffixWhenRegistering"
                }
            }


            #If using 'Set' mode then bring matching non-compliant Network Adapters back into compliance.
            if ($Mode -eq 'Set') {
                $List_NetworkAdaptersToCheckForCompliance | Where-Object {$_.UseSuffixWhenRegistering -ne $UseSuffixWhenRegistering} | ForEach-Object {
                
                    Write-Verbose -Message "Configuring Network Adapter with Interface Index $($_.InterfaceIndex) and IP Address '$($_.IPAddress)': UseSuffixWhenRegistering = '$UseSuffixWhenRegistering'"
                    try {
                        Set-DnsClient -InterfaceIndex $_.InterfaceIndex -UseSuffixWhenRegistering $UseSuffixWhenRegistering

                    } catch {
                        $ErrorRecord = New-Object System.Management.Automation.ErrorRecord(`
                            (New-Object System.InvalidOperationException(Write-Verbose -Message "Configuring Network Adapter with Interface Index $($_.InterfaceIndex) and IP Address '$($_.IPAddress)': UseSuffixWhenRegistering = '$UseSuffixWhenRegistering'")), 
                            'SetDnsClient', 
                            ([System.Management.Automation.ErrorCategory]::InvalidOperation),
                            $null
                        )

                        $PSCmdlet.ThrowTerminatingError($ErrorRecord)
                    }
                }
            }
        }




        #Return the appropriate response based on the $Mode (Get, Set Test).
        #-------------------------------------------------------------------
        switch ($Mode) {
            'Get'  {
            
                $ReturnData = @{
                    MatchedIPAddresses = [System.String[]]($List_MatchedIPAddressesToCheckForCompliance | Select-Object -ExpandProperty IPAddress)
                    FilterIPAddressPrefixes = $FilterIPAddressPrefixes
                    Action = $Action
                    AddressFamily = $AddressFamily
                    ConnectionSpecificSuffix = $Get_ConnectionSpecificSuffix
                    RegisterThisConnectionsAddress = $Get_RegisterThisConnectionsAddress
                    UseSuffixWhenRegistering = $Get_UseSuffixWhenRegistering
                }

                Return $ReturnData
            }

            'Set'  {Write-Verbose -Message "Execution is compliant and all DNS Client settings on matching network adapters should now be in a compliant state.";  Return}
            'Test' {Return $false}
        }
    }
}

Export-ModuleMember -Function *-TargetResource