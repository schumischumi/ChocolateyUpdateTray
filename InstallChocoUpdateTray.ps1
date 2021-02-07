# Install Script

$path = Join-Path -Path $env:USERPROFILE -ChildPath "Documents\WindowsPowerShell\Scripts\"
New-Item -Path $path -Type Directory -force
Copy-Item ".\runChocoUpdateTray.vbs" $path
Copy-Item ".\ChocoUpdateTray.ps1" $path

$taskName = 'ChocoUpdateTray'
$taskDescription = "Check for chocolatey pdates and create tray icon"
$oneHtimespan = New-TimeSpan -Hours 1
$executable = Join-Path -Path $path -ChildPath "runChocoUpdateTray.vbs"
$A = New-ScheduledTaskAction -Execute $executable
$T = New-ScheduledTaskTrigger -Once -At (Get-Date) -RepetitionInterval $oneHtimespan
$P = New-ScheduledTaskPrincipal $env:USERDOMAIN\$env:USERNAME -LogonType Interactive
$S = New-ScheduledTaskSettingsSet -Hidden -MultipleInstances IgnoreNew -ExecutionTimeLimit $oneHtimespan
$D = New-ScheduledTask -Action $A -Principal $P -Trigger $T -Settings $S -Description $taskDescription

$task = Get-ScheduledTask | Where-Object { $_.TaskName -eq $taskName } | Select-Object -First 1
if ($null -ne $task) {
	$task | Unregister-ScheduledTask -Confirm:$false
	Write-Host “Task $taskName was removed” -ForegroundColor Yellow
}

Register-ScheduledTask $taskName -InputObject $D
Write-Host “Task $taskName was added” -ForegroundColor Yellow

Start-ScheduledTask -TaskName $taskName
