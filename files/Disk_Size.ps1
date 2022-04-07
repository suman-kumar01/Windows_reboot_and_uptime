#Name : Disk_Size.ps1
#Author : Disk Size
#Date : Version 1
#Usage powershell.exe -ExecutionPolicy ByPass -File .\Disk_size.ps1 if powershell script execution is disabled.
# This script shows the all drive disk space, Windows update service status and last reboot time of servers. 
 
# Get the start Time
$startDTM = (Get-Date)

#Get the working directory
$path = (Get-Location).path

# This file contains the list of servers you want to copy files/folders to

$computers = gc "$path\AllComputers.txt"

$OFile = "$path\Output.csv"

"Server name|OS Name|Last Boot Time|BITS|Update|DiskName TotalSize FreeSpace %FreeSpace" | add-content -Path $OFile
    
foreach ($computer in $computers)
{

		if (Test-Connection -Cn "$computer" -Count 1 -Quiet)
        {
			echo $computer
			
			#Server Name
			$OS = Get-WmiObject -Class Win32_OperatingSystem -ComputerName "$computer"
			$Server_Name = $OS.CSName
			[io.file]::AppendAllText("$OFile", $Server_Name)
			[io.file]::AppendAllText("$OFile", "|")
			
			#OS Version
			$OS_Name = Get-WmiObject -Class Win32_OperatingSystem -ComputerName "$computer" | Select name
			$split1 = $OS_Name -split "\|"
			$split2 = $split1[0] -split "="
			
			[io.file]::AppendAllText("$OFile",$split2[1])
			[io.file]::AppendAllText("$OFile", "|")

            #Last boot time
			$LastBootTime = $OS.ConvertToDateTime($OS.LastBootUpTime)
			[io.file]::AppendAllText("$OFile", $LastBootTime)
			[io.file]::AppendAllText("$OFile", "|")


			#Check Service for BITS Service
			$ClusterSRVStatus = "";

			try {
					$ClusterSRV = Get-Service -Name "BITS" -ComputerName "$computer" -ErrorAction Stop;
					$ClusterSRVStatus = $ClusterSRV.Status;
					
				}
			catch {
					$ClusterSRVStatus = "Not Available"
				  }
			
			[io.file]::AppendAllText("$OFile", $ClusterSRVStatus)
			[io.file]::AppendAllText("$OFile", "|")


			
			#Check Service for Windows Update Service
			$ClusterSRVStatus = "";

			try {
					$ClusterSRV = Get-Service -Name "wuauserv" -ComputerName "$computer" -ErrorAction Stop;
					$ClusterSRVStatus = $ClusterSRV.Status;
					
				}
			catch {
					$ClusterSRVStatus = "Not Available"
				  }
			
			[io.file]::AppendAllText("$OFile", $ClusterSRVStatus)
			[io.file]::AppendAllText("$OFile", "|")

			#Disk Usage
			$LogDisks = Get-WmiObject -Class win32_logicaldisk -Filter "DriveType=3" -ComputerName $computer
			
			foreach ($LogDisk in $LogDisks) 
			{
				[io.file]::AppendAllText("$OFile", $LogDisk.DeviceId)
				[io.file]::AppendAllText("$OFile", " ")
				$Size = ($LogDisk.Size / 1GB).ToString("##.#");
				[io.file]::AppendAllText("$OFile", $Size)
				[io.file]::AppendAllText("$OFile", " ")
				$FreeSpace = ($LogDisk.FreeSpace / 1GB).ToString("##.#");
				[io.file]::AppendAllText("$OFile", $FreeSpace)
                [io.file]::AppendAllText("$OFile", " ")
				$PerSpace = (($LogDisk.FreeSpace / $LogDisk.Size) * 100).ToString("##.#");
				[io.file]::AppendAllText("$OFile", $PerSpace);
				[io.file]::AppendAllText("$OFile", " ")
				[io.file]::AppendAllText("$OFile", ",")
            }

				"|" | add-content -Path $OFile
			
			
        
				
         }
         else
         {
            "$computer|Server is not reachable" | add-content -Path $OFile
         }        
 }
 
 
 # Get End Time
$endDTM = (Get-Date)

#Calculate the differnce time.
$run_time = ($endDTM-$startDTM).totalseconds


# Echo Time elapsed

if ($run_time -lt 60)
{
   echo  "Script run time: $run_time seconds"
}
else
{
    $hrs   = [int]($run_time / 3600)
    $mins = [int]($run_time / 60) - ($hrs * 60)
    $secs = $run_time - (($hrs * 3600) + ($mins * 60))
   
    if ($hrs -gt 1)
      {
        $timeStr =  "Run time: " + $hrs + " hours "
      }
      ElseIf ($hrs -gt 0)
      {
        $timeStr = "Run time: " + $hrs + " hour "
      }

      if ($mins -gt 1)
      {
        $timeStr = "Run time: " + $mins + " minutes "
      }
      ElseIf ($mins -gt 0)
      {
        $timeStr = "Run time: " + $mins + " minute "
      }

      if ($secs -gt 1)
      {
        $timeStr = "Run time: " + $secs + " seconds "
      }

      ElseIf($secs -gt 0)
      {
        $timeStr = "Run time: " + $secs + " second "
      }

      echo "Script $timeStr"
    
}