#Storyline: This code is going to take system information and place it inside a zipfile. This code will also create the corrispoding hash tables for the files that are being created

# Ask user where to save
$savePath = Read-Host -Prompt "Please enter the full path of the directory to save results"

function file-hash() {
    
    #Create the hashes for the coresponding files 
    $hash = Get-FileHash -path $savePath/*csv -Algorithm SHA256

    #Creating a file inside the specifed directory
    $hash | Out-file $savePath\checksums.txt 
}


# 1. Running Processes and the path for each process.
$processesPath = Join-Path -Path $savePath -ChildPath "processes.csv"
Get-Process |  Select-Object Name, Path |Export-Csv -Path "Processes.csv" -NoTypeInformation


# 2. All registered services and the path to the executable controlling the service (you'll need to use WMI).
$servicesPath = Join-Path -Path $savePath -ChildPath "services.csv"
Get-WmiObject -Class Win32_Service | Select-Object Name, PathName | Export-Csv -Path $servicesPath -NoTypeInformation

# 3. All TCP network sockets
$tcpSocketsPath = Join-Path -Path $savePath -ChildPath "tcpSockets.csv"
Get-NetTCPConnection | Export-Csv -Path $tcpSocketsPath -NoTypeInformation

# 4. All user account information (you'll need to use WMI)
$userAccountsPath = Join-Path -Path $savePath -ChildPath "userAccounts.csv"
Get-WmiObject -Class Win32_UserAccount | Export-Csv -Path $userAccountsPath -NoTypeInformation

# 5. All NetworkAdapterConfiguration information
$networkAdaptersPath = Join-Path -Path $savePath -ChildPath "networkAdapterConfiguration.csv"
Get-WmiObject -Class Win32_NetworkAdapterConfiguration | Export-Csv -Path $networkAdaptersPath -NoTypeInformation

# four more things
# 6. Firewall profile information - provides helpful information for incedent report because it shows the firewall configuration. This allows for checking what is an is not allowed as well as what is not in the configurations which can be used to figureout how the incidnet may have been allowed.
$netFirewallProfile = Join-Path $resultsDirectory -ChildPath "netFirewallProfile.csv"
Get-NetFirewallProfile | Export-Csv -path $netFirewallProfile -NoTypeInformation

# 7. secuirty event logs - provides helpful information because shows the security events within the event log. Such logs are useful in IR because they give detailed information that can be used when investigating what happend. 
$Securityeventlogs = Join-Path $resultsDirectory -ChildPath "Securityeventlogs.csv"
Get-Eventlog -LogName Security | Export-csv -Path $Securityeventlogs -NoTypeInformation

# 8. System event logs - provides helpful information because it shows the logs that are on the system. This is very useful for IR because it can give more context as to the before and after events that took place around the incident.
$SystemeventLogs = join-path $resultsDirectory -ChildPath "SystemEventLogs.csv"
Get-Eventlog -LogName System | export-csv -path $SystemeventLogs -NoTypeInformation

# 9. Application event logs - provides helpful information because it shows the application statuses on the system and the application that have been installed. As well as the applications that have started or stopped.
$ApplEventLogs = Join-Path $resultsDirectory -ChildPath "AppEventLogs.csv"
Get-Eventlog -LogName Application | export-csv -path $ApplEventLogs -NoTypeInformation


# Creating the name of the zip file and to put the zip file in the provided directory path
$zipPath = "$savePath\results.zip"

# Compress the directory results
Compress-Archive -Path $savePath\* -DestinationPath $zipPath -Force