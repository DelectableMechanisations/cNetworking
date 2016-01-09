# cNetworking
DSC Module containing resources used to configure Networking and the DNS Client on a Windows Computer

This module is designed to complement Microsoft's xNetworking module and contains the following resources:

cDnsClient - This DSC resource is used to configure the DNS Client settings of a network adapter that matches a specified filter.
		
cDnsClientGlobalSetting - This DSC resource is used to configure the DNS Client Global Settings (resolve computer names by appending the Primary and Connection Specific Suffix or by using a pre-defined
list of DNS Suffixes).

cNetOffloadGlobalSetting - This DSC resource is used to configure the Network Offload Global Settings on a computer. 
If the 'Ensure' parameter is set to 'Present' then the Network Offload Global Settings are configured as per the specified parameters.
If the 'Ensure' parameter is set to 'Absent' then the Network Offload Global Settings are configured as using their default values and the specified parameters are ignored.
