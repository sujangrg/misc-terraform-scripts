Write-Output "## Installing Cholocatey ###"
Set-ExecutionPolicy Bypass -Scope Process -Force; 
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; 
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

Write-Output "## Installing Notepad++ using chocolatey ##"
choco install -y notepadplusplus


Write-Output "## Installing IIS ##"
Install-WindowsFeature -name "Web-Server" -IncludeAllSubFeature -IncludeManagementTools

