# Array of websites containing threat intell
$drop_urls = @('https://rules.emergingthreats.net/blockrules/emerging-botcc.rules','https://rules.emergingthreats.net/blockrules/compromised-ips.txt')

# Loop through the URLs for the rules list
foreach ($u in $drop_urls) {

    # Extract the filename
    $temp = $u.split('/')
    
    # The last element in the array plucked off is the filename
    $file_name = $temp[-1]

    if (Test-Path $file_name) {

        continue

    } else {
     
        # Download the rules list
        Invoke-WebRequest -Uri $u -OutFile $file_name -UseBasicParsing

    } # Close if statement

} # Close the foreach loop

# Array containing the filename
$input_paths = @('.\emerging-botcc.rules','.\compromised-ips.txt')

# Extract the IP addresses
$regex_drop = '\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b'

# Append the IP addresses to the temporary IP list
Select-String -Path $input_paths -Pattern $regex_drop | `
ForEach-Object { $_.Matches.Value } | Sort-Object | Get-Unique | `
Out-File -FilePath 'ips-bad.tmp'


# Get the IP addresses discovered, loop through and replace the beginning of the line with the IPTables syntax and save 
(Get-Content -Path '.\ips-bad.tmp') | ForEach-Object `
{ Write-Output "iptables -A INPUT -s $_ -j DROP" } | `
Out-File -FilePath 'iptables.bash'



# Do the same as above but with netsh
(Get-Content -Path '.\ips-bad.tmp') | ForEach-Object `
{ Write-Output "netsh advfirewall firewall add rule name=`"BLOCK IP ADDRESS - $_`" dir=in action=block remoteip=$_" } | `
Out-File -FilePath 'netshrules.bat'