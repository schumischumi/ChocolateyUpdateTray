Dim WinScriptHost
Set WinScriptHost = CreateObject("WScript.Shell")
userProfile = WinScriptHost.ExpandEnvironmentStrings( "%userprofile%" )
WinScriptHost.Run "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -windowstyle hidden -ExecutionPolicy Bypass -File " & userProfile & "\Documents\WindowsPowerShell\Scripts\ChocoUpdateTray.ps1", 0,0
Set WinScriptHost = Nothing