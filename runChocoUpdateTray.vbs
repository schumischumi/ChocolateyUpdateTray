Dim WinScriptHost
Set WinScriptHost = CreateObject("WScript.Shell")
WinScriptHost.Run "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -windowstyle hidden  -ExecutionPolicy Bypass -File C:\Users\user\Documents\WindowsPowerShell\Scripts\ChocoUpdateTray.ps1", 0,0
Set WinScriptHost = Nothing