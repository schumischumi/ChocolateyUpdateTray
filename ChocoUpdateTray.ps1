# Based on this tutorial http://www.systanddeploy.com/2018/12/create-your-own-powershell.html
# Thanks Damien Van Robaeys
$oldprocess = $(Get-CimInstance Win32_Process -Filter "Name='powershell.exe' AND CommandLine LIKE '%ChocoUpdateTray.ps1%' AND NOT Handle LIKE $pid")
if($oldprocess.Handle){
     Stop-process -Id $oldprocess.Handle
}
$noReturn = $true
$stdout_choco_raw = $(choco outdated)
foreach($line in $stdout_choco_raw){
    if($line -like "Chocolatey has determined*"){
        $stdout_choco = $line
        $noReturn = $False
    }
}
if($noReturn){
    # popup
    [System.Windows.MessageBox]::Show('Cant find string in Choco outdated')
    exit
}
$start = $stdout_choco.indexof('Chocolatey has determined') + 26
if($stdout_choco -like "*Chocolatey has determined 0 package(s) are outdated.*"){
    exit
}
$start = $stdout_choco.indexof('Chocolatey has determined') + 26
$end = $stdout_choco.indexof('package(s) are outdated')
$end = $stdout_choco.indexof('are outdated')
$update_count = $stdout_choco.Substring($start,$end-$start).trim()

#$Current_Folder = split-path $MyInvocation.MyCommand.Path

# Add assemblies for WPF and Mahapps
[System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')    | out-null
[System.Reflection.Assembly]::LoadWithPartialName('presentationframework')   | out-null
[System.Reflection.Assembly]::LoadWithPartialName('System.Drawing')    | out-null
[System.Reflection.Assembly]::LoadWithPartialName('WindowsFormsIntegration') | out-null
#[System.Reflection.Assembly]::LoadFrom("Current_Folder\assembly\MahApps.Metro.dll")           | out-null

# Choose an icon to display in the systray
$icon = [System.Drawing.Icon]::ExtractAssociatedIcon("C:\ProgramData\chocolatey\bin\chocolatey.exe")

# Add icon the systray
$Main_Tool_Icon = New-Object System.Windows.Forms.NotifyIcon
$Main_Tool_Icon.Text = "chocolatey: $update_count Updates available"
$Main_Tool_Icon.Icon = $icon
$Main_Tool_Icon.Visible = $true

# Add menu Chocolatey Info
$Menu_INFO = New-Object System.Windows.Forms.MenuItem
$Menu_INFO.Text = "$update_count Updates available"

# Add menu Chocolatey GUI
$Menu_GUI = New-Object System.Windows.Forms.MenuItem
$Menu_GUI.Text = "Run: Chocolatey GUI"

# Add menu Powershell execution
$Menu_CMD = New-Object System.Windows.Forms.MenuItem
$Menu_CMD.Text = "Run: chocolatey upgrade all"


# Add menu exit
$Menu_Exit = New-Object System.Windows.Forms.MenuItem
$Menu_Exit.Text = "Exit"

# Add all menus as context menus
$contextmenu = New-Object System.Windows.Forms.ContextMenu
$Main_Tool_Icon.ContextMenu = $contextmenu

$Main_Tool_Icon.contextMenu.MenuItems.AddRange($Menu_INFO)
$Main_Tool_Icon.ContextMenu.MenuItems.Add("-");


$GUIpath="C:\Program Files (x86)\Chocolatey GUI\ChocolateyGui.exe"
if(Test-Path $GUIpath){
       # Action after clicking on the Users context menu
    $Menu_GUI.Add_Click({
        Start-Process -FilePath $GUIpath
        $Main_Tool_Icon.Visible = $false
        $window.Close()
        Stop-Process $pid
    })
    $Main_Tool_Icon.contextMenu.MenuItems.AddRange($Menu_GUI)

}
# Action after clicking on the Computers context menu
$Menu_CMD.Add_Click({
     start-process powershell.exe -Verb RunAs -ArgumentList "chocolatey update all"
     $Main_Tool_Icon.Visible = $false
     $window.Close()
     Stop-Process $pid
})

$Main_Tool_Icon.contextMenu.MenuItems.AddRange($Menu_CMD)
$Main_Tool_Icon.contextMenu.MenuItems.AddRange($Menu_Exit)


# Action after clicking on the Exit context menu
$Menu_Exit.add_Click({
     $Main_Tool_Icon.Visible = $false
     $window.Close()
     Stop-Process $pid
})



# Make PowerShell Disappear - Thanks Chrissy
$windowcode = '[DllImport("user32.dll")] public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);'
$asyncwindow = Add-Type -MemberDefinition $windowcode -name Win32ShowWindowAsync -namespace Win32Functions -PassThru
$null = $asyncwindow::ShowWindowAsync((Get-Process -PID $pid).MainWindowHandle, 0)

# Use a Garbage colection to reduce Memory RAM
# https://dmitrysotnikov.wordpress.com/2012/02/24/freeing-up-memory-in-powershell-using-garbage-collector/
# https://docs.microsoft.com/fr-fr/dotnet/api/system.gc.collect?view=netframework-4.7.2
[System.GC]::Collect()

# Create an application context for it to all run within - Thanks Chrissy
# This helps with responsiveness, especially when clicking Exit - Thanks Chrissy
$appContext = New-Object System.Windows.Forms.ApplicationContext

[void][System.Windows.Forms.Application]::Run($appContext)