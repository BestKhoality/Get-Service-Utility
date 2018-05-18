
#https://stackoverflow.com/questions/7690994/powershell-running-a-command-as-administrator
#if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit }

#Displays the main menu to user with menu options
function DisplayMainMenu ()
{
    #Write-Host prints text to console
    #`n prints a newline
    Write-Host "`n1 - Check Running Services on Local Server..."
    Write-Host "2 - Check Stopped Services on Local Server..."
    Write-Host "3 - Check Running Services on Remote Server..."
    Write-Host "4 - Check Stopped Services on Remote Server..."
    Write-Host "5 - Check Services on Mutiple Remote Servers..."
    Write-Host "0 - Quit Utility...`n"
}

#Allows user to check Windows services running on their local server
#This is either localhost or if they are logged into the target server itself
function RunningServicesLocalServer ()
{
    #Get running services, format the columns to size on their own
    #Output to variable
    $RunningServicesOutput = Get-Service | Where {$_.Status -eq "Running"} | Format-Table -AutoSize
    #Get user input if they want to view the output in notepad or not
    $UserInputNotepad = Read-Host "Output into notepad? (Y/N?)"

    #Perform conditional processing based on user's input
    switch ($UserInputNotepad)
    {
        #Generate a random number for user with file naming convention
        #Output variable and send the results into a text file
        #Open the text file
        'Y' { $TxtFileTemp = Get-Random; Write-Output $RunningServicesOutput > RunningServices_$TxtFileTemp.txt; notepad RunningServices_$TxtFileTemp.txt }
        #Output variable content to console
        'N' { Write-Output $RunningServicesOutput }
        #If unrecognized output is received, call the function again
        DEFAULT { RunningServicesLocalServer }

    }
}

#Allows user to check Windows services that are stopped on their local server
#This is either localhost or if they are logged into the target server itself
function StoppedServicesLocalServer ()
{
    #Get stopped services, format the columns to size on their own
    #Output to variable
    $StoppedServicesOutput = Get-Service | Where {$_.Status -eq "Stopped"} | Format-Table -AutoSize
    #Get user input if they want to view the output in notepad or not
    $UserInputNotepad = Read-Host "Output into notepad? (Y/N?)"

    #Perform conditional processing based on user's input
    switch ($UserInputNotepad)
    {   
        #Generate a random number for user with file naming convention
        #Output variable and send the results into a text file
        #Open the text file
        'Y' { $TxtFileTemp = Get-Random; Write-Output $StoppedServicesOutput > StoppedServices_$TxtFileTemp.txt; notepad StoppedServices_$TxtFileTemp.txt }
        #Output variable content to console
        'N' { Write-Output $StoppedServicesOutput }
        #If unrecognized output is received, call the function again
        DEFAULT { StoppedServicesLocalServer }

    }
}

#Allows user to check Windows services running on a remote, target server
function RunningServicesRemoteServer ()
{
    #Prompt user for a server name and store it as a variable
    $Server = Read-Host "Enter a server name: "

    Write-Host "Attemping to ping server..."
    #Ping the server
    $PingOutput = ping -n 1 $Server

    #If the output of the server ping, contains "Reply"
    if ($PingOutput | sls "Reply")
    {
        #Get running services, format the columns to size on their own
        #Output to variable        
        $RunningServicesOutput = Get-Service -ComputerName $Server | Where {$_.Status -eq "Running"} | Format-Table -AutoSize
        #Get user input if they want to view the output in notepad or not
        $UserInputNotepad = Read-Host "Output into notepad? (Y/N?)"

        #Perform conditional processing based on user's input
        switch ($UserInputNotepad)
        {   
            #Generate a random number for user with file naming convention
            #Output variable and send the results into a text file
            #Open the text file
            'Y' { $TxtFileTemp = Get-Random; Write-Output $RunningServicesOutput > RunningServices_$TxtFileTemp.txt; notepad RunningServices_$TxtFileTemp.txt }
            #Output variable content to console
            'N' { Write-Output $RunningServicesOutput }
            #If unrecognized output is received, call the function again
            DEFAULT { RunningServicesRemoteServer }
    
        }
    }

    #Output to user that the server name is not pingable, so the script cannot query the services on it
    #Call the function again
    else
    {
        Write-Host "Server not pingable!`n" -ForegroundColor Red
        RunningServicesRemoteServer
    }

}

#Allows user to check Windows services that are stopped on a remote, target server
function StoppedServicesRemoteServer ()
{
    #Prompt user for a server name and store it as a variable
    $Server = Read-Host "Enter a server name: "

    Write-Host "Attemping to ping server..."

    #Ping the server
    $PingOutput = ping -n 1 $Server

    #If the output of the server ping, contains "Reply"
    if ($PingOutput | sls "Reply")
    {
        #Get stopped services, format the columns to size on their own
        #Output to variable
        $StoppedServicesOutput = Get-Service -ComputerName $Server | Where {$_.Status -eq "Stopped"} | Format-Table -AutoSize
        #Get user input if they want to view the output in notepad or not
        $UserInputNotepad = Read-Host "Output into notepad? (Y/N?)"

        #Perform conditional processing based on user's input
        switch ($UserInputNotepad)
        {
            #Generate a random number for user with file naming convention
            #Output variable and send the results into a text file
            #Open the text file
            'Y' { $TxtFileTemp = Get-Random; Write-Output $StoppedServicesOutput > StoppedServices_$TxtFileTemp.txt; notepad StoppedServices_$TxtFileTemp.txt }
            #Output variable content to console
            'N' { Write-Output $StoppedServicesOutput }
            #If unrecognized output is received, call the function again
            DEFAULT { StoppedServicesRemoteServer }
    
        }
    }
    
    #Output to user that the server name is not pingable, so the script cannot query the services on it
    #Call the function again
    else
    {
        Write-Host "Server not pingable!`n" -ForegroundColor Red
        StoppedServicesRemoteServer
    }

}

#https://stackoverflow.com/questions/24992681/powershell-check-if-a-file-is-locked
#A notepad file is utilized here to capture user input of server names.
#This function is checking if the notepad file is closed or not to determine if the user has completed entering servernames.
function Test-FileLock 
{
    #This is a required parameter of path to file to test for existence of lock
    param (
      [parameter(Mandatory=$true)][string]$Path
    )
  
    #Create a new object instance of I/O to provided path
    $oFile = New-Object System.IO.FileInfo $Path
  
    #Return false if provided path does not exist
    #We cannot test for a lock if the file does not exist...
    if ((Test-Path -Path $Path) -eq $false) 
    {
      return $false
    }
  
    #Attempt to open, read/write to the file
    try 
    {
      $oStream = $oFile.Open([System.IO.FileMode]::Open, [System.IO.FileAccess]::ReadWrite, [System.IO.FileShare]::None)
  
      #Close the file if successful
      if ($oStream) 
      {
        $oStream.Close()
      }
      $false
    } catch 
    {
      # file is locked by a process.
      return $true
    }
}

#This function actually queries the servers for their service statuses
#There is a required param of server name as a string
function CheckBulkServicesByServer ($ServerName)
{
        #Prompt user to choose service status and take it as an input
        $ServiceStatus = Read-Host "Which service status should be displayed for $ServerName (R - Running, S - Stopped, B - Both)"

        #Generate a random number
        $TxtFileTemp = Get-Random;

        #Use the server name, server status chosen, and random number generated to create a file name
        $FileName = $ServerName + "_" + $ServiceStatus + "_" + $TxtFileTemp + ".txt"
        
        #Conditional statements based on content of $ServiceStatus variable
        switch ($ServiceStatus)
        {
            #If R is received as input
            'R' 
                {
                    #Get running services on server
                    $RunningServicesOutput = Get-Service -ComputerName $ServerName | Where {$_.Status -eq "Running"} | Format-Table -AutoSize;

                    #Echo the output into a txt file
                    Write-Output $RunningServicesOutput > $FileName;

                    #Prompt the user if they want to view the output in notepad or not
                    #The window will be opened minimized
                    #This will cause the powershell terminal to lose user focus
                    $Output2Notepad = Read-Host "Output saved to $(pwd | Select -ExpandProperty Path)\$Filename - open file minimized? (Y/N?)"

                    #Conditional statement based on content of $Output2Notepad
                    switch ($Output2Notepad)
                    {
                        #Open the file minimized
                        'Y' {Start-Process notepad -WindowStyle Minimized -FilePath $FileName;}

                        #proceed with script execution
                        'N' { continue;}

                        #Condition to catch all other input
                        #CheckBulkServicesByServer function will be called again with current $ServerName
                        DEFAULT { Write-Host "No option chosen for $ServerName..."; CheckBulkServicesByServer $ServerName;}

                    }
                }

            #If S is received as input
            'S' 
                {
                    #Get stopped services on server
                    $StoppedServicesOutput = Get-Service -ComputerName $ServerName | Where {$_.Status -eq "Stopped"} | Format-Table -AutoSize;

                    #Echo the output into a txt file
                    Write-Output $StoppedServicesOutput > $FileName;

                    #Prompt the user if they want to view the output in notepad or not
                    #The window will be opened minimized
                    #This will cause the powershell terminal to lose user focus
                    $Output2Notepad = Read-Host "Output saved to $(pwd | Select -ExpandProperty Path)\$Filename - open file minimized? (Y/N?)"

                    #Conditional statement based on content of $Output2Notepad
                    switch ($Output2Notepad)
                    {
                        #Open the file minimized
                        'Y' {Start-Process notepad -WindowStyle Minimized -FilePath $FileName;}
                        #proceed with script execution
                        'N' { continue;}
                        #Condition to catch all other input
                        #CheckBulkServicesByServer function will be called again with current $ServerName
                        DEFAULT { Write-Host "No option chosen for $ServerName..."; CheckBulkServicesByServer $ServerName;}

                    }
                }

            #If B is received as input
            'B' 
                {
                    #Get Running services on server
                    $RunningServicesOutput = Get-Service -ComputerName $ServerName | Where {$_.Status -eq "Running"} | Format-Table -AutoSize;

                    #Get stopped services on server
                    $StoppedServicesOutput = Get-Service -ComputerName $ServerName | Where {$_.Status -eq "Stopped"} | Format-Table -AutoSize;

                    #Append the output into a new variable
                    $BothServicesOutput += $RunningServicesOutput;

                    #Append a new line into the variable
                    $BothServicesOutput += "`n";

                    #Append the output into another variable
                    $BothServicesOutput += $StoppedServicesOutput;

                    #Echo the output into a txt file
                    Write-Output $BothServicesOutput > $FileName;

                    #Prompt the user if they want to view the output in notepad or not
                    #The window will be opened minimized
                    #This will cause the powershell terminal to lose user focus
                    $Output2Notepad = Read-Host "Output saved to $(pwd | Select -ExpandProperty Path)\$Filename - open file minimized? (Y/N?)"
                    
                    #Conditional statement based on content of $Output2Notepad
                    switch ($Output2Notepad)
                    {
                        #Open the file minimized
                        'Y' {Start-Process notepad -WindowStyle Minimized -FilePath $FileName;}
                        #proceed with script execution
                        'N' { continue;}
                        #Condition to catch all other input
                        #CheckBulkServicesByServer function will be called again with current $ServerName
                        DEFAULT { Write-Host "No option chosen for $ServerName..."; CheckBulkServicesByServer $ServerName;}

                    }
                }
            
                #Condition to catch all other input
            #CheckBulkServicesByServer function will be called again with current $ServerName
            DEFAULT { Write-Host "No service status chosen for $ServerName..."; CheckBulkServicesByServer $ServerName;}
        }
}

#This function will attempt to ping each server and output if the ping was successful or not
#It has a required parameter of servername in string
function PingServer ($ServerName)
{
    #Attempt to ping the servername and only echo the request once
    #Send output to a variable
    $PingOutput = ping -n 1 $ServerName

    #Output to user what the script is doing next
    Write-Host "`nAttemping to ping servers..."

    #using a string search, if the variable contains "reply"
    if ($PingOutput | sls "Reply")
    {
        #Inform user that the server could be pinged
        Write-Host "$ServerName pinged successfully!" -ForegroundColor Green

        #Call this function to begin checking services on the server
        CheckBulkServicesByServer $ServerName
    }

    else
    {   #Inform user that the server could not be pinged and services could not be checked
        Write-Host "$ServerName could not be pinged!" -ForegroundColor Red
    }

}

#This function allows the user to check services on a bulk number of servers at a time
function CheckBulkServicesRemoteServer ()
{
    #Create a random number
    $TxtFileTemp = Get-Random

    #Output to user that a txt file is being created
    Write-Host "Creating ServerList.txt to store server details...`n"

    #Create a txt file using the random number generated earlier
    #Out-Null will hide output to console when creating a new file
    New-Item -Name ServersList_$TxtFileTemp.txt -ItemType File | Out-null

    #Add the string after -value into the newly created text file
    Set-Content -Path ServersList_$TxtFileTemp.txt -Value "Enter your server names/IP addresses below this line, then save and close the file:"

    #Open the txt file
    notepad ServersList_$TxtFileTemp.txt

    #This will prompt the user to press enter within the script shell
    pause 
    
    #Once enter is received, the script will continue and attempt to check if the notepad file containing the server names has been closed
    if (Test-FileLock ServersList_$TxtFileTemp.txt)
    {
        #If test-file lock is successful, read the contents of the file into a variable but skip the first line
        $Servers = cat ServersList_$TxtFileTemp.txt | Select -Skip 1
    }

    #Attempt to ping each server mentioned in the text file
    foreach ($Server in $Servers)
    {
        #Call PingServer function and pass the server details
        PingServer $Server

    }
}


#This do-until loop will execute and call DisplayMainMenu function; it will exit the loop when user enters zero as an input
do 
{
    #Calls DisplayMainMenu function
    DisplayMainMenu

    #Prompts user for input and saves it in a variable
    $UserInput = Read-Host "Please make a selection... "
    
    #Perform conditional processing based on user's input
    Switch ($UserInput)
    {
        #Call function RunningServicesLocalServer
        '1' { RunningServicesLocalServer }
        #Call function StoppedServicesLocalServer
        '2' { StoppedServicesLocalServer }
        #Call function RunningServicesRemoteServer
        '3' { RunningServicesRemoteServer }
        #Call function StoppedServicesRemoteServer
        '4' { StoppedServicesRemoteServer }
        #Call function CheckBulkServicesRemoteServer
        '5' { CheckBulkServicesRemoteServer }
        #This is the exit condition
        '0' { Write-Host "You chose option #0`n"}
        #If any other output is received, this condition will execute
        DEFAULT { Write-Host "Input not recognized!`n"; RunningServicesLocalServer}
    }
}
#Exit Condition for do-until loop
Until ($UserInput -eq "0")
