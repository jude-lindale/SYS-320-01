#Storyline: view service logs and check if the user specifed if the service is running, stopped, or both and print the results.
function getservicelogs(){
# Define the log options for the user prompt
    $logptions = @('A', 'S', 'R', 'Q')
#ask for user input
    
    #user input is all
    if($userInput -eq 'A') {

        Get-Service
        
    }

    #User input is running
    elseif($userInput -eq 'R') {

        Get-Service | Where-Object {$_.Status -eq 'Running'}
        
    }

    #user input is stopped 
    elseif ($userInput -eq 'S') {

        Get-Service | Where-Object {$_.Status -eq 'Stopped'}
  
    }

}
while ($true){

    $userInput = Read-Host "A for all, S for stopped, R for running, or q to quit"

    #user wants to quit
    if ($userInput -eq 'Q') {

        break
    }

    #invalid option
    elseif ($useIinput -notin $logOptions) {
        Write-Host "Enter which services to view."
        write-host "Ivalid option. Please type Running, Stopped, All, or quit into the prompt"
        continue
    }

    else{
        getservicelogs $userInput
    }

}