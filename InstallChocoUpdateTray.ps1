# Install Script

New-Item -Path "C:\Users\user\Documents\WindowsPowerShell\Scripts\" -Type Directory -force
Copy-Item ".\runChocoUpdateTray.vbs" "C:\Users\user\Documents\WindowsPowerShell\Scripts\"
Copy-Item ".\runChocoUpdateTray.ps1" "C:\Users\user\Documents\WindowsPowerShell\Scripts\"

$taskName = 'ChocoUpdateTray'
$taskDescription = "Check for chocolatey pdates and create tray icon"
$oneHtimespan = New-TimeSpan -Hours 1
$A = New-ScheduledTaskAction -Execute "C:\Users\user\Documents\WindowsPowerShell\Scripts\runChocoUpdateTray.vbs"
$T = New-ScheduledTaskTrigger -Once -At (Get-Date) -RepetitionInterval $oneHtimespan
$P = New-ScheduledTaskPrincipal $env:USERDOMAIN\$env:USERNAME -LogonType Interactive
$S = New-ScheduledTaskSettingsSet -Hidden -MultipleInstances IgnoreNew -ExecutionTimeLimit $oneHtimespan
$D = New-ScheduledTask -Action $A -Principal $P -Trigger $T -Settings $S -Description $taskDescription
Register-ScheduledTask $taskName -InputObject $D

Start-ScheduledTask -TaskName $taskName
