# Storyline: Review Security Event Log

# Directory to save Files:
$myDir= "C:\Users\Jude\Desktop\"

# List all windows event logs
Get-EventLog -list

# Create a prompt to allow user to select the Log to view
$readLog = Read-host -Prompt "Select a log to review from the list above"

# Create a prompt to allow user to select the keyword to search for
$findMessage = Read-Host -Prompt "Enter a keyword or phrase to search for"

# File name
$fileName = Read-host -Prompt "Enter name for csv file."

# Print the results for the log
Get-EventLog -LogName $readLog -Newest 40 | where {$_.Message -ilike "*$findMessage*" } | export-csv -NoTypeInformation `
-Path "$myDir\$fileName.csv"