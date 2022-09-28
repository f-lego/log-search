#USM Anywhere Cold Storage Search v2.1 by Felipe Legorreta
#Disclaimer: The purpose of the script is to search amongst raw log files from USM Anywhere. 
#In no way is this backed-up, promoted or authorized by ATT, use at your own discretion.
Write-Host "Starting..." -ForegroundColor Red
Sleep 7

#Global variables
$exit=0
$host.ui.RawUI.WindowTitle = “USM Anywhere Cold Storage Search v2.1”
if (Test-Path -Path "c:\usmacss_temp")
{Remove-Item "c:\usmacss_temp" -Force -Recurse
Sleep 5
}
New-Item -Path c:\usmacss_temp -ItemType directory
New-Item -Path c:\usmacss_temp\logs -ItemType directory
$path="c:\usmacss_temp\logs"
New-Item "c:\usmacss_temp\USMACSS_temp1.log" -ItemType file
New-Item "c:\usmacss_temp\USMACSS_temp2.log" -ItemType file
$DownloadsPath = "$($env:USERPROFILE)\Downloads\"

if ((Test-Path -Path "C:\Program Files\7-Zip\7z.exe")){
$7zipExecutable = "C:\Program Files\7-Zip\7z.exe"
Set-Alias 7zip $7zipExecutable
}
elseif ((Test-Path -Path "7-Zip\7z.exe")){
$7zipExecutable = "7-Zip\7z.exe"
Set-Alias 7zip $7zipExecutable
}
else {
Write-Host "ERROR: 7zip not found. Please install 7zip or make sure you run this script from its original folder to use 7zip portable." -ForegroundColor Red
Sleep 8
Exit
}


#Start the user interaction
#################################################################################
#clear the screen
Clear
Write-Host "USM Anywhere Cold Storage Search v2.1 by Felipe Legorreta" -ForegroundColor Blue -BackgroundColor White
Write-Host "By using this tool, you agree that it is delivered 'as-is', with no guarantee that it will suit all log search needs." -ForegroundColor Blue -BackgroundColor White
Write-Host "AT&T does not officially authorize, support, endorse or promote this script." -ForegroundColor Blue -BackgroundColor White
Write-Host "`n`nWARNING: This script utilizes 7zip. It is highly recommended to have 7zip installed, otherwise the script will utilize a portable version of 7zip (painfully slower)." -ForegroundColor Yellow
Write-Host "`nPress enter to continue..." -ForegroundColor Red -BackgroundColor Black
Read-Host ":"

#Ask to browse for the folder that contains the log files and unzip them
Add-Type -AssemblyName System.Windows.Forms
$browser = New-Object System.Windows.Forms.FolderBrowserDialog
$browser.Description = 'Where are your compressed log files located?'
$null = $browser.ShowDialog((New-Object System.Windows.Forms.Form -Property @{TopMost = $true }))
$logspath = $browser.SelectedPath

7zip x -o"c:\usmacss_temp\logs" $logspath -aoa -r
7zip x -o"c:\usmacss_temp\logs" "c:\usmacss_temp\logs\*.log.gz" -aoa -r

Remove-Item "c:\usmacss_temp\logs\*.log.gz" -Force -Recurse


#keyword to search for
Write-Host "`nWhat do you want to search for?" -ForegroundColor Red -BackgroundColor Black
$search = Read-Host -Prompt ":"
Write-Host "`nSearching..." -ForegroundColor Red -BackgroundColor Black
#proceed to search for the keyword in all files in the selected folder and subfolders
$Output = Get-ChildItem -Path $path -Recurse -Include "*.log" | Select-String -Pattern "$search"
#copy the results to a temp file to and count number of lines
$Output.line | out-file "c:\usmacss_temp\USMACSS_temp1.log"
$result_count = $Output.Matches.Length
#print results
Write-Host "`n" $result_count " log lines found that match your search.`n`n"

#Begin loop of actions
do {
Write-Host "`n`n1-Show results`n2-Search within results`n3-Save results`n4-Start over`n0-Exit and clear cache`n`nWhat do you want to do? (0-4)" -ForegroundColor Red -BackgroundColor Black
$option =  Read-Host ":"
switch ($option)
{
    #Exit
    0{  #Message host
        Write-Host "`nCleaning cache..." -ForegroundColor Red -BackgroundColor Black
        #Delete temp files
        Remove-Item "c:\usmacss_temp" -Force -Recurse
        #Message host
        Write-Host "`nDone!`nClosing in 5 seconds..." -ForegroundColor Red -BackgroundColor Black
        #Exit loop
        $exit=1
        #Timer so user can read prompts
        Sleep 5
    }
    #Show search results
    1{  #Display contents of temp file, which has the search results
        Write-Host "`nHere are the results`n`n" -ForegroundColor Red -BackgroundColor Black
        Get-Content "c:\usmacss_temp\USMACSS_temp1.log"
    }
    #Search within results
    2{  Clear-Content "c:\usmacss_temp\USMACSS_temp2.log"
        #Prompt for new search keyword
        Write-Host "`nWhat do you want to search for?" -ForegroundColor Red -BackgroundColor Black
        $search = Read-Host -Prompt ":"
        Write-Host "`nSearching..." -ForegroundColor Red -BackgroundColor Black
        #Search for the keyword in the temp results
        $Output = Get-ChildItem -Path "c:\usmacss_temp\USMACSS_temp1.log" | Select-String -Pattern "$search"
        #Copy new results to a second temp file
        $Output.line | out-file "c:\usmacss_temp\USMACSS_temp2.log"
        #Count results
        $result_count = $Output.Matches.Length
        #Output result count
        Write-Host $result_count " log lines found that match your search."
        $ask = Read-Host "`nDo you want to continue with the new search results? (y/n)"
        if ($ask -eq "y"){
        #Copy new results to temp file and clear second temp file
        Remove-Item "c:\usmacss_temp\USMACSS_temp1.log"
        Sleep 1
        Copy-Item "c:\usmacss_temp\USMACSS_temp2.log" -Destination "c:\usmacss_temp\USMACSS_temp1.log"
        Sleep 1
        Clear-Content "c:\usmacss_temp\USMACSS_temp2.log"
        }
              
    }
    #Save results
    3{  $saveas=""
        Write-Host "`nWhat do you want to save the results as?" -ForegroundColor Red -BackgroundColor Black
        $saveas = Read-Host ":"
        $saveas=$DownloadsPath+$saveas+".log"
        Copy-Item "c:\usmacss_temp\USMACSS_temp1.log" -Destination $saveas
        Write-Host "`nSaved to downloads" -ForegroundColor Red -BackgroundColor Black
    }
    #Start over
    4{  #keyword to search for
        Write-Host "`nWhat do you want to search for?" -ForegroundColor Red -BackgroundColor Black
        $search = Read-Host -Prompt ":"
        Write-Host "`nSearching..." -ForegroundColor Red -BackgroundColor Black
        #proceed to search for the keyword in all files in the selected folder and subfolders
        $Output = Get-ChildItem -Path $path -Recurse -Include "*.log" | Select-String -Pattern "$search"
        #copy the results to a temp file to and count number of lines
        $Output.line | out-file "c:\usmacss_temp\USMACSS_temp1.log"
        $result_count = $Output.Matches.Length
        #print results
        Write-Host "`n" $result_count " log lines found that match your search.`n`n" -ForegroundColor Red -BackgroundColor Black
    }

}

} while ($exit -eq 0)
