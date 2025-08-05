#Requires -RunAsAdministrator

[CmdletBinding(SupportsShouldProcess)]
param (
    [switch]$Silent,
    [switch]$Sysprep,
    [string]$LogPath,
    [string]$User,
    [switch]$CreateRestorePoint,
    [switch]$RunAppsListGenerator, [switch]$RunAppConfigurator,
    [switch]$RunDefaults, [switch]$RunWin11Defaults,
    [switch]$RunSavedSettings,
    [switch]$RemoveApps, 
    [switch]$RemoveAppsCustom,
    [switch]$RemoveGamingApps,
    [switch]$RemoveCommApps,
    [switch]$RemoveDevApps,
    [switch]$RemoveHPApps,
    [switch]$RemoveW11Outlook,
    [switch]$ForceRemoveEdge,
    [switch]$DisableDVR,
    [switch]$DisableTelemetry,
    [switch]$DisableFastStartup,
    [switch]$DisableBingSearches, [switch]$DisableBing,
    [switch]$DisableDesktopSpotlight,
    [switch]$DisableLockscrTips, [switch]$DisableLockscreenTips,
    [switch]$DisableWindowsSuggestions, [switch]$DisableSuggestions,
    [switch]$DisableSettings365Ads,
    [switch]$DisableSettingsHome,
    [switch]$ShowHiddenFolders,
    [switch]$ShowKnownFileExt,
    [switch]$HideDupliDrive,
    [switch]$EnableDarkMode,
    [switch]$DisableTransparency,
    [switch]$DisableAnimations,
    [switch]$TaskbarAlignLeft,
    [switch]$HideSearchTb, [switch]$ShowSearchIconTb, [switch]$ShowSearchLabelTb, [switch]$ShowSearchBoxTb,
    [switch]$HideTaskview,
    [switch]$DisableStartRecommended,
    [switch]$DisableStartPhoneLink,
    [switch]$DisableCopilot,
    [switch]$DisableRecall,
    [switch]$DisablePaintAI,
    [switch]$DisableNotepadAI,
    [switch]$DisableWidgets, [switch]$HideWidgets,
    [switch]$DisableChat, [switch]$HideChat,
    [switch]$EnableEndTask,
    [switch]$EnableLastActiveClick,
    [switch]$ClearStart,
    [string]$ReplaceStart,
    [switch]$ClearStartAllUsers,
    [string]$ReplaceStartAllUsers,
    [switch]$RevertContextMenu,
    [switch]$DisableMouseAcceleration,
    [switch]$DisableStickyKeys,
    [switch]$HideHome,
    [switch]$HideGallery,
    [switch]$ExplorerToHome,
    [switch]$ExplorerToThisPC,
    [switch]$ExplorerToDownloads,
    [switch]$ExplorerToOneDrive,
    [switch]$DisableOnedrive, [switch]$HideOnedrive,
    [switch]$Disable3dObjects, [switch]$Hide3dObjects,
    [switch]$DisableMusic, [switch]$HideMusic,
    [switch]$DisableIncludeInLibrary, [switch]$HideIncludeInLibrary,
    [switch]$DisableGiveAccessTo, [switch]$HideGiveAccessTo,
    [switch]$DisableShare, [switch]$HideShare
)


# Show error if current powershell environment is limited by security policies
if ($ExecutionContext.SessionState.LanguageMode -ne "FullLanguage") {
    Write-Host "错误：Win11Debloat 无法在您的系统上运行，PowerShell 执行受到安全策略的限制。" -ForegroundColor Red
    AwaitKeyToExit
}

# Log script output to 'Win11Debloat.log' at the specified path
if ($LogPath -and (Test-Path $LogPath)) {
    Start-Transcript -Path "$LogPath/Win11Debloat.log" -Append -IncludeInvocationHeader -Force | Out-Null
}
else {
    Start-Transcript -Path "$PSScriptRoot/Win11Debloat.log" -Append -IncludeInvocationHeader -Force | Out-Null
}

# Shows application selection form that allows the user to select what apps they want to remove or keep
function ShowAppSelectionForm {
    [reflection.assembly]::loadwithpartialname("System.Windows.Forms") | Out-Null
    [reflection.assembly]::loadwithpartialname("System.Drawing") | Out-Null

    # Initialise form objects
    $form = New-Object System.Windows.Forms.Form
    $label = New-Object System.Windows.Forms.Label
    $button1 = New-Object System.Windows.Forms.Button
    $button2 = New-Object System.Windows.Forms.Button
    $selectionBox = New-Object System.Windows.Forms.CheckedListBox 
    $loadingLabel = New-Object System.Windows.Forms.Label
    $onlyInstalledCheckBox = New-Object System.Windows.Forms.CheckBox
    $checkUncheckCheckBox = New-Object System.Windows.Forms.CheckBox
    $initialFormWindowState = New-Object System.Windows.Forms.FormWindowState

    $script:selectionBoxIndex = -1

    # saveButton eventHandler
    $handler_saveButton_Click= 
    {
        if ($selectionBox.CheckedItems -contains "Microsoft.WindowsStore" -and -not $Silent) {
            $warningSelection = [System.Windows.Forms.Messagebox]::Show('您确定要卸载 Microsoft Store 吗？此应用不易重新安装', '你确定吗?', 'YesNo', 'Warning')
        
            if ($warningSelection -eq 'No') {
                return
            }
        }

        $script:SelectedApps = $selectionBox.CheckedItems

        # Create file that stores selected apps if it doesn't exist
        if (-not (Test-Path "$PSScriptRoot/CustomAppsList")) {
            $null = New-Item "$PSScriptRoot/CustomAppsList"
        } 

        Set-Content -Path "$PSScriptRoot/CustomAppsList" -Value $script:SelectedApps

        $form.DialogResult = [System.Windows.Forms.DialogResult]::OK
        $form.Close()
    }

    # cancelButton eventHandler
    $handler_cancelButton_Click= 
    {
        $form.Close()
    }

    $selectionBox_SelectedIndexChanged= 
    {
        $script:selectionBoxIndex = $selectionBox.SelectedIndex
    }

    $selectionBox_MouseDown=
    {
        if ($_.Button -eq [System.Windows.Forms.MouseButtons]::Left) {
            if ([System.Windows.Forms.Control]::ModifierKeys -eq [System.Windows.Forms.Keys]::Shift) {
                if ($script:selectionBoxIndex -ne -1) {
                    $topIndex = $script:selectionBoxIndex

                    if ($selectionBox.SelectedIndex -gt $topIndex) {
                        for (($i = ($topIndex)); $i -le $selectionBox.SelectedIndex; $i++) {
                            $selectionBox.SetItemChecked($i, $selectionBox.GetItemChecked($topIndex))
                        }
                    }
                    elseif ($topIndex -gt $selectionBox.SelectedIndex) {
                        for (($i = ($selectionBox.SelectedIndex)); $i -le $topIndex; $i++) {
                            $selectionBox.SetItemChecked($i, $selectionBox.GetItemChecked($topIndex))
                        }
                    }
                }
            }
            elseif ($script:selectionBoxIndex -ne $selectionBox.SelectedIndex) {
                $selectionBox.SetItemChecked($selectionBox.SelectedIndex, -not $selectionBox.GetItemChecked($selectionBox.SelectedIndex))
            }
        }
    }

    $check_All=
    {
        for (($i = 0); $i -lt $selectionBox.Items.Count; $i++) {
            $selectionBox.SetItemChecked($i, $checkUncheckCheckBox.Checked)
        }
    }

    $load_Apps=
    {
        # Correct the initial state of the form to prevent the .Net maximized form issue
        $form.WindowState = $initialFormWindowState

        # Reset state to default before loading appslist again
        $script:selectionBoxIndex = -1
        $checkUncheckCheckBox.Checked = $False

        # Show loading indicator
        $loadingLabel.Visible = $true
        $form.Refresh()

        # Clear selectionBox before adding any new items
        $selectionBox.Items.Clear()

        # Set filePath where Appslist can be found
        $appsFile = "$PSScriptRoot/Appslist.txt"
        $listOfApps = ""

        if ($onlyInstalledCheckBox.Checked -and ($script:wingetInstalled -eq $true)) {
            # Attempt to get a list of installed apps via winget, times out after 10 seconds
            $job = Start-Job { return winget list --accept-source-agreements --disable-interactivity }
            $jobDone = $job | Wait-Job -TimeOut 10

            if (-not $jobDone) {
                # Show error that the script was unable to get list of apps from winget
                [System.Windows.MessageBox]::Show('无法通过 winget 加载已安装应用程序列表，某些应用程序可能不会显示在列表中', 'Error', 'Ok', 'Error')
            }
            else {
                # Add output of job (list of apps) to $listOfApps
                $listOfApps = Receive-Job -Job $job
            }
        }

        # Go through appslist and add items one by one to the selectionBox
        Foreach ($app in (Get-Content -Path $appsFile | Where-Object { $_ -notmatch '^\s*$' -and $_ -notmatch '^#  .*' -and $_ -notmatch '^# -* #' } )) { 
            $appChecked = $true

            # Remove first # if it exists and set appChecked to false
            if ($app.StartsWith('#')) {
                $app = $app.TrimStart("#")
                $appChecked = $false
            }

            # Remove any comments from the Appname
            if (-not ($app.IndexOf('#') -eq -1)) {
                $app = $app.Substring(0, $app.IndexOf('#'))
            }
            
            # Remove leading and trailing spaces and `*` characters from Appname
            $app = $app.Trim()
            $appString = $app.Trim('*')

            # Make sure appString is not empty
            if ($appString.length -gt 0) {
                if ($onlyInstalledCheckBox.Checked) {
                    # onlyInstalledCheckBox is checked, check if app is installed before adding it to selectionBox
                    if (-not ($listOfApps -like ("*$appString*")) -and -not (Get-AppxPackage -Name $app)) {
                        # App is not installed, continue with next item
                        continue
                    }
                    if (($appString -eq "Microsoft.Edge") -and -not ($listOfApps -like "* Microsoft.Edge *")) {
                        # App is not installed, continue with next item
                        continue
                    }
                }

                # Add the app to the selectionBox and set it's checked status
                $selectionBox.Items.Add($appString, $appChecked) | Out-Null
            }
        }
        
        # Hide loading indicator
        $loadingLabel.Visible = $False

        # Sort selectionBox alphabetically
        $selectionBox.Sorted = $True
    }

    $form.Text = "Win11Debloat Application Selection"
    $form.Name = "appSelectionForm"
    $form.DataBindings.DefaultDataSourceUpdateMode = 0
    $form.ClientSize = New-Object System.Drawing.Size(400,502)
    $form.FormBorderStyle = 'FixedDialog'
    $form.MaximizeBox = $False

    $button1.TabIndex = 4
    $button1.Name = "saveButton"
    $button1.UseVisualStyleBackColor = $True
    $button1.Text = "确定"
    $button1.Location = New-Object System.Drawing.Point(27,472)
    $button1.Size = New-Object System.Drawing.Size(75,23)
    $button1.DataBindings.DefaultDataSourceUpdateMode = 0
    $button1.add_Click($handler_saveButton_Click)

    $form.Controls.Add($button1)

    $button2.TabIndex = 5
    $button2.Name = "cancelButton"
    $button2.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
    $button2.UseVisualStyleBackColor = $True
    $button2.Text = "取消"
    $button2.Location = New-Object System.Drawing.Point(129,472)
    $button2.Size = New-Object System.Drawing.Size(75,23)
    $button2.DataBindings.DefaultDataSourceUpdateMode = 0
    $button2.add_Click($handler_cancelButton_Click)

    $form.Controls.Add($button2)

    $label.Location = New-Object System.Drawing.Point(13,5)
    $label.Size = New-Object System.Drawing.Size(400,14)
    $Label.Font = 'Microsoft Sans Serif,8'
    $label.Text = '在下面选择你想要卸载的程序，要保留的程序不选择'

    $form.Controls.Add($label)

    $loadingLabel.Location = New-Object System.Drawing.Point(16,46)
    $loadingLabel.Size = New-Object System.Drawing.Size(300,418)
    $loadingLabel.Text = '加载程序中...'
    $loadingLabel.BackColor = "White"
    $loadingLabel.Visible = $false

    $form.Controls.Add($loadingLabel)

    $onlyInstalledCheckBox.TabIndex = 6
    $onlyInstalledCheckBox.Location = New-Object System.Drawing.Point(230,474)
    $onlyInstalledCheckBox.Size = New-Object System.Drawing.Size(150,20)
    $onlyInstalledCheckBox.Text = '只显示已安装了的应用'
    $onlyInstalledCheckBox.add_CheckedChanged($load_Apps)

    $form.Controls.Add($onlyInstalledCheckBox)

    $checkUncheckCheckBox.TabIndex = 7
    $checkUncheckCheckBox.Location = New-Object System.Drawing.Point(16,22)
    $checkUncheckCheckBox.Size = New-Object System.Drawing.Size(150,20)
    $checkUncheckCheckBox.Text = '全选/全不选'
    $checkUncheckCheckBox.add_CheckedChanged($check_All)

    $form.Controls.Add($checkUncheckCheckBox)

    $selectionBox.FormattingEnabled = $True
    $selectionBox.DataBindings.DefaultDataSourceUpdateMode = 0
    $selectionBox.Name = "selectionBox"
    $selectionBox.Location = New-Object System.Drawing.Point(13,43)
    $selectionBox.Size = New-Object System.Drawing.Size(374,424)
    $selectionBox.TabIndex = 3
    $selectionBox.add_SelectedIndexChanged($selectionBox_SelectedIndexChanged)
    $selectionBox.add_Click($selectionBox_MouseDown)

    $form.Controls.Add($selectionBox)

    # Save the initial state of the form
    $initialFormWindowState = $form.WindowState

    # Load apps into selectionBox
    $form.add_Load($load_Apps)

    # Focus selectionBox when form opens
    $form.Add_Shown({$form.Activate(); $selectionBox.Focus()})

    # Show the Form
    return $form.ShowDialog()
}


# Returns list of apps from the specified file, it trims the app names and removes any comments
function ReadAppslistFromFile {
    param (
        $appsFilePath
    )

    $appsList = @()

    # Get list of apps from file at the path provided, and remove them one by one
    Foreach ($app in (Get-Content -Path $appsFilePath | Where-Object { $_ -notmatch '^#.*' -and $_ -notmatch '^\s*$' } )) { 
        # Remove any comments from the Appname
        if (-not ($app.IndexOf('#') -eq -1)) {
            $app = $app.Substring(0, $app.IndexOf('#'))
        }

        # Remove any spaces before and after the Appname
        $app = $app.Trim()
        
        $appString = $app.Trim('*')
        $appsList += $appString
    }

    return $appsList
}


# Removes apps specified during function call from all user accounts and from the OS image.
function RemoveApps {
    param (
        $appslist
    )

    Foreach ($app in $appsList) { 
        Write-Output "正在尝试移除 $app..."

        if (($app -eq "Microsoft.OneDrive") -or ($app -eq "Microsoft.Edge")) {
            # Use winget to remove OneDrive and Edge
            if ($script:wingetInstalled -eq $false) {
                Write-Host "错误：WinGet 未安装或已过时，无法移除 $app" -ForegroundColor Red
            }
            else {
                # Uninstall app via winget
                Strip-Progress -ScriptBlock { winget uninstall --accept-source-agreements --disable-interactivity --id $app } | Tee-Object -Variable wingetOutput 

                If (($app -eq "Microsoft.Edge") -and (Select-String -InputObject $wingetOutput -Pattern "Uninstall failed with exit code")) {
                    Write-Host "无法通过 Winget 卸载 Microsoft Edge。" -ForegroundColor Red
                    Write-Output ""

                    if ($( Read-Host -Prompt "您想强制卸载 Edge 吗？强烈不推荐！(y/n)" ) -eq 'y') {
                        Write-Output ""
                        ForceRemoveEdge
                    }
                }
            }
        }
        else {
            # Use Remove-AppxPackage to remove all other apps
            $app = '*' + $app + '*'

            # Remove installed app for all existing users
            if ($WinVersion -ge 22000) {
                # Windows 11 build 22000 or later
                try {
                    Get-AppxPackage -Name $app -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction Continue

                    if ($DebugPreference -ne "SilentlyContinue") {
                        Write-Host "Removed $app for all users" -ForegroundColor DarkGray
                    }
                }
                catch {
                    if ($DebugPreference -ne "SilentlyContinue") {
                        Write-Host "Unable to remove $app for all users" -ForegroundColor Yellow
                        Write-Host $psitem.Exception.StackTrace -ForegroundColor Gray
                    }
                }
            }
            else {
                # Windows 10
                try {
                    Get-AppxPackage -Name $app | Remove-AppxPackage -ErrorAction SilentlyContinue
                    
                    if ($DebugPreference -ne "SilentlyContinue") {
                        Write-Host "Removed $app for current user" -ForegroundColor DarkGray
                    }
                }
                catch {
                    if ($DebugPreference -ne "SilentlyContinue") {
                        Write-Host "Unable to remove $app for current user" -ForegroundColor Yellow
                        Write-Host $psitem.Exception.StackTrace -ForegroundColor Gray
                    }
                }
                
                try {
                    Get-AppxPackage -Name $app -PackageTypeFilter Main, Bundle, Resource -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
                    
                    if ($DebugPreference -ne "SilentlyContinue") {
                        Write-Host "Removed $app for all users" -ForegroundColor DarkGray
                    }
                }
                catch {
                    if ($DebugPreference -ne "SilentlyContinue") {
                        Write-Host "Unable to remove $app for all users" -ForegroundColor Yellow
                        Write-Host $psitem.Exception.StackTrace -ForegroundColor Gray
                    }
                }
            }

            # Remove provisioned app from OS image, so the app won't be installed for any new users
            try {
                Get-AppxProvisionedPackage -Online | Where-Object { $_.PackageName -like $app } | ForEach-Object { Remove-ProvisionedAppxPackage -Online -AllUsers -PackageName $_.PackageName }
            }
            catch {
                Write-Host "Unable to remove $app from windows image" -ForegroundColor Yellow
                Write-Host $psitem.Exception.StackTrace -ForegroundColor Gray
            }
        }
    }
            
    Write-Output ""
}


# Forcefully removes Microsoft Edge using it's uninstaller
function ForceRemoveEdge {
    # Based on work from loadstring1 & ave9858
    Write-Output "> 正在强制卸载 Microsoft Edge..."

    $regView = [Microsoft.Win32.RegistryView]::Registry32
    $hklm = [Microsoft.Win32.RegistryKey]::OpenBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine, $regView)
    $hklm.CreateSubKey('SOFTWARE\Microsoft\EdgeUpdateDev').SetValue('AllowUninstall', '')

    # Create stub (Creating this somehow allows uninstalling edge)
    $edgeStub = "$env:SystemRoot\SystemApps\Microsoft.MicrosoftEdge_8wekyb3d8bbwe"
    New-Item $edgeStub -ItemType Directory | Out-Null
    New-Item "$edgeStub\MicrosoftEdge.exe" | Out-Null

    # Remove edge
    $uninstallRegKey = $hklm.OpenSubKey('SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Microsoft Edge')
    if ($null -ne $uninstallRegKey) {
        Write-Output "正在运行卸载程序..."
        $uninstallString = $uninstallRegKey.GetValue('UninstallString') + ' --force-uninstall'
        Start-Process cmd.exe "/c $uninstallString" -WindowStyle Hidden -Wait

        Write-Output "正在移除残留文件..."

        $edgePaths = @(
            "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Microsoft Edge.lnk",
            "$env:APPDATA\Microsoft\Internet Explorer\Quick Launch\Microsoft Edge.lnk",
            "$env:APPDATA\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar\Microsoft Edge.lnk",
            "$env:APPDATA\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar\Tombstones\Microsoft Edge.lnk",
            "$env:PUBLIC\Desktop\Microsoft Edge.lnk",
            "$env:USERPROFILE\Desktop\Microsoft Edge.lnk",
            "$edgeStub"
        )

        foreach ($path in $edgePaths) {
            if (Test-Path -Path $path) {
                Remove-Item -Path $path -Force -Recurse -ErrorAction SilentlyContinue
                Write-Host "  Removed $path" -ForegroundColor DarkGray
            }
        }

        Write-Output "正在清理注册表..."

        # Remove ms edge from autostart
        reg delete "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run" /v "MicrosoftEdgeAutoLaunch_A9F6DCE4ABADF4F51CF45CD7129E3C6C" /f *>$null
        reg delete "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run" /v "Microsoft Edge Update" /f *>$null
        reg delete "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run" /v "MicrosoftEdgeAutoLaunch_A9F6DCE4ABADF4F51CF45CD7129E3C6C" /f *>$null
        reg delete "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run" /v "Microsoft Edge Update" /f *>$null

        Write-Output "Microsoft Edge 已卸载"
    }
    else {
        Write-Output ""
        Write-Host "错误：无法强制卸载 Microsoft Edge，未找到卸载程序" -ForegroundColor Red
    }
    
    Write-Output ""
}


# Execute provided command and strips progress spinners/bars from console output
function Strip-Progress {
    param(
        [ScriptBlock]$ScriptBlock
    )

    # Regex pattern to match spinner characters and progress bar patterns
    $progressPattern = 'Γû[Æê]|^\s+[-\\|/]\s+$'

    # Corrected regex pattern for size formatting, ensuring proper capture groups are utilized
    $sizePattern = '(\d+(\.\d{1,2})?)\s+(B|KB|MB|GB|TB|PB) /\s+(\d+(\.\d{1,2})?)\s+(B|KB|MB|GB|TB|PB)'

    & $ScriptBlock 2>&1 | ForEach-Object {
        if ($_ -is [System.Management.Automation.ErrorRecord]) {
            "ERROR: $($_.Exception.Message)"
        } else {
            $line = $_ -replace $progressPattern, '' -replace $sizePattern, ''
            if (-not ([string]::IsNullOrWhiteSpace($line)) -and -not ($line.StartsWith('  '))) {
                $line
            }
        }
    }
}


# Import & execute regfile
function RegImport {
    param (
        $message,
        $path
    )

    Write-Output $message

    if ($script:Params.ContainsKey("Sysprep")) {
        $defaultUserPath = $env:USERPROFILE -Replace ('\\' + $env:USERNAME + '$'), '\Default\NTUSER.DAT'
        
        reg load "HKU\Default" $defaultUserPath | Out-Null
        reg import "$PSScriptRoot\Regfiles\Sysprep\$path"
        reg unload "HKU\Default" | Out-Null
    }
    elseif ($script:Params.ContainsKey("User")) {
        $userPath = $env:USERPROFILE -Replace ('\\' + $env:USERNAME + '$'), "\$($script:Params.Item("User"))\NTUSER.DAT"
        
        reg load "HKU\Default" $userPath | Out-Null
        reg import "$PSScriptRoot\Regfiles\Sysprep\$path"
        reg unload "HKU\Default" | Out-Null
        
    }
    else {
        reg import "$PSScriptRoot\Regfiles\$path"  
    }

    Write-Output ""
}


# Restart the Windows Explorer process
function RestartExplorer {
    if ($script:Params.ContainsKey("Sysprep") -or $script:Params.ContainsKey("User")) {
        return
    }

    Write-Output "> R正在重启 Windows 资源管理器进程以应用所有更改... (这可能会导致屏幕闪烁)"

    if ($script:Params.ContainsKey("DisableMouseAcceleration")) {
        Write-Host "更改 增强指针精度 设置后，需要重启电脑才能生效。" -ForegroundColor Yellow
    }

    if ($script:Params.ContainsKey("DisableStickyKeys")) {
        Write-Host "警告：粘滞键设置的更改只有在重启后才会生效。" -ForegroundColor Yellow
    }

    if ($script:Params.ContainsKey("DisableAnimations")) {
        Write-Host "警告：动画效果将在重启后才会禁用。" -ForegroundColor Yellow
    }

    # Only restart if the powershell process matches the OS architecture.
    # Restarting explorer from a 32bit PowerShell window will fail on a 64bit OS
    if ([Environment]::Is64BitProcess -eq [Environment]::Is64BitOperatingSystem) {
        Stop-Process -processName: Explorer -Force
    }
    else {
        Write-Warning "无法重启 Windows 资源管理器进程，请手动重启您的电脑以应用所有更改。"
    }
}


# Replace the startmenu for all users, when using the default startmenuTemplate this clears all pinned apps
# Credit: https://lazyadmin.nl/win-11/customize-windows-11-start-menu-layout/
function ReplaceStartMenuForAllUsers {
    param (
        $startMenuTemplate = "$PSScriptRoot/Assets/Start/start2.bin"
    )

    Write-Output "> 正在为所有用户移除开始菜单中所有已固定的应用程序..."

    # Check if template bin file exists, return early if it doesn't
    if (-not (Test-Path $startMenuTemplate)) {
        Write-Host "错误：无法清除开始菜单，脚本文件夹中缺少 start2.bin 文件。" -ForegroundColor Red
        Write-Output ""
        return
    }

    # Get path to start menu file for all users
    $userPathString = $env:USERPROFILE -Replace ('\\' + $env:USERNAME + '$'), "\*\AppData\Local\Packages\Microsoft.Windows.StartMenuExperienceHost_cw5n1h2txyewy\LocalState"
    $usersStartMenuPaths = get-childitem -path $userPathString

    # Go through all users and replace the start menu file
    ForEach ($startMenuPath in $usersStartMenuPaths) {
        ReplaceStartMenu $startMenuTemplate "$($startMenuPath.Fullname)\start2.bin"
    }

    # Also replace the start menu file for the default user profile
    $defaultStartMenuPath = $env:USERPROFILE -Replace ('\\' + $env:USERNAME + '$'), '\Default\AppData\Local\Packages\Microsoft.Windows.StartMenuExperienceHost_cw5n1h2txyewy\LocalState'

    # Create folder if it doesn't exist
    if (-not (Test-Path $defaultStartMenuPath)) {
        new-item $defaultStartMenuPath -ItemType Directory -Force | Out-Null
        Write-Output "已为默认用户配置文件创建 LocalState 文件夹"
    }

    # Copy template to default profile
    Copy-Item -Path $startMenuTemplate -Destination $defaultStartMenuPath -Force
    Write-Output "已替换默认用户配置文件的开始菜单"
    Write-Output ""
}


# Replace the startmenu for all users, when using the default startmenuTemplate this clears all pinned apps
# Credit: https://lazyadmin.nl/win-11/customize-windows-11-start-menu-layout/
function ReplaceStartMenu {
    param (
        $startMenuTemplate = "$PSScriptRoot/Assets/Start/start2.bin",
        $startMenuBinFile = "$env:LOCALAPPDATA\Packages\Microsoft.Windows.StartMenuExperienceHost_cw5n1h2txyewy\LocalState\start2.bin"
    )

    # Change path to correct user if a user was specified
    if ($script:Params.ContainsKey("User")) {
        $startMenuBinFile = $env:USERPROFILE -Replace ('\\' + $env:USERNAME + '$'), "\$(GetUserName)\AppData\Local\Packages\Microsoft.Windows.StartMenuExperienceHost_cw5n1h2txyewy\LocalState\start2.bin"
    }

    # Check if template bin file exists, return early if it doesn't
    if (-not (Test-Path $startMenuTemplate)) {
        Write-Host "错误：无法替换开始菜单，未找到模板文件" -ForegroundColor Red
        return
    }

    if ([IO.Path]::GetExtension($startMenuTemplate) -ne ".bin" ) {
        Write-Host "错误：无法替换开始菜单，模板文件不是一个有效的 .bin 文件" -ForegroundColor Red
        return
    }

    # Check if bin file exists, return early if it doesn't
    if (-not (Test-Path $startMenuBinFile)) {
        Write-Host "错误：无法为用户 $(GetUserName) 替换开始菜单，未找到原始的 start2.bin 文件" -ForegroundColor Red
        return
    }

    $backupBinFile = $startMenuBinFile + ".bak"

    # Backup current start menu file
    Move-Item -Path $startMenuBinFile -Destination $backupBinFile -Force

    # Copy template file
    Copy-Item -Path $startMenuTemplate -Destination $startMenuBinFile -Force

    Write-Output "已替换用户 $(GetUserName) 的开始菜单"
}


# Add parameter to script and write to file
function AddParameter {
    param (
        $parameterName,
        $message
    )

    # Add key if it doesn't already exist
    if (-not $script:Params.ContainsKey($parameterName)) {
        $script:Params.Add($parameterName, $true)
    }

    # Create or clear file that stores last used settings
    if (-not (Test-Path "$PSScriptRoot/SavedSettings")) {
        $null = New-Item "$PSScriptRoot/SavedSettings"
    } 
    elseif ($script:FirstSelection) {
        $null = Clear-Content "$PSScriptRoot/SavedSettings"
    }
    
    $script:FirstSelection = $false

    # Create entry and add it to the file
    $entry = "$parameterName#- $message"
    Add-Content -Path "$PSScriptRoot/SavedSettings" -Value $entry
}


function PrintHeader {
    param (
        $title
    )

    $fullTitle = " Win11Debloat脚本 - $title"

    if ($script:Params.ContainsKey("Sysprep")) {
        $fullTitle = "$fullTitle (Sysprep mode)"
    }
    else {
        $fullTitle = "$fullTitle (用户: $(GetUserName))"
    }

    Clear-Host
    Write-Output "-------------------------------------------------------------------------------------------"
    Write-Output $fullTitle
    Write-Output "-------------------------------------------------------------------------------------------"
}


function PrintFromFile {
    param (
        $path,
        $title
    )

    Clear-Host

    PrintHeader $title

    # Get & print script menu from file
    Foreach ($line in (Get-Content -Path $path )) {   
        Write-Output $line
    }
}


function AwaitKeyToExit {
    # Suppress prompt if Silent parameter was passed
    if (-not $Silent) {
        Write-Output ""
        Write-Output "Press any key to exit..."
        $null = [System.Console]::ReadKey()
    }

    Stop-Transcript
    Exit
}


function GetUserName {
    if ($script:Params.ContainsKey("User")) { 
        return $script:Params.Item("User") 
    }
    
    return $env:USERNAME
}


function CreateSystemRestorePoint {
    Write-Output "> 正在尝试创建系统还原点..."

    $SysRestore = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SystemRestore" -Name "RPSessionInterval"

    if ($SysRestore.RPSessionInterval -eq 0) {
        if ($Silent -or $( Read-Host -Prompt "系统还原已禁用，您想启用它并创建还原点吗？ (y/n)") -eq 'y') {
            try {
                Enable-ComputerRestore -Drive "$env:SystemDrive"
            } catch {
                Write-Host "错误：未能启用系统还原： $_" -ForegroundColor Red
                Write-Output ""
                return
            }
        } else {
            Write-Output ""
            return
        }
    }

    # Find existing restore points that are less than 24 hours old
    try {
        $recentRestorePoints = Get-ComputerRestorePoint | Where-Object { (Get-Date) - [System.Management.ManagementDateTimeConverter]::ToDateTime($_.CreationTime) -le (New-TimeSpan -Hours 24) }
    } catch {
        Write-Host "错误：无法检索现有还原点： $_" -ForegroundColor Red
        Write-Output ""
        return
    }

    if ($recentRestorePoints.Count -eq 0) {
        try {
            Checkpoint-Computer -Description "Restore point created by Win11Debloat" -RestorePointType "MODIFY_SETTINGS"
            Write-Output "System restore point created successfully"
        } catch {
            Write-Host "Error: Unable to create restore point: $_" -ForegroundColor Red
        }
    } else {
        Write-Host "A recent restore point already exists, no new restore point was created." -ForegroundColor Yellow
    }

    Write-Output ""
}


function DisplayCustomModeOptions {
    # Get current Windows build version to compare against features
    $WinVersion = Get-ItemPropertyValue 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' CurrentBuild
            
    PrintHeader '自定义模式'

    AddParameter 'CreateRestorePoint' '创建系统还原点'

    # Show options for removing apps, only continue on valid input
    Do {
        Write-Host "选项:" -ForegroundColor Yellow
        Write-Host " (n) 不移除任何应用" -ForegroundColor Yellow
        Write-Host " (1) 仅移除 Appslist.txt 中默认选择的臃肿应用（bloatware apps）" -ForegroundColor Yellow
        Write-Host " (2) 移除默认选择的臃肿应用，以及邮件和日历应用、开发者应用和游戏应用"  -ForegroundColor Yellow
        Write-Host " (3) 手动选择要移除的应用" -ForegroundColor Yellow
        $RemoveAppsInput = Read-Host "是否要移除应用？请根据上方选项输入对应编号进行选择，所选应用将会为所有用户移除（n/1/2/3）"

        # Show app selection form if user entered option 3
        if ($RemoveAppsInput -eq '3') {
            $result = ShowAppSelectionForm

            if ($result -ne [System.Windows.Forms.DialogResult]::OK) {
                # User cancelled or closed app selection, show error and change RemoveAppsInput so the menu will be shown again
                Write-Output ""
                Write-Host "C已取消应用选择，请重试" -ForegroundColor Red

                $RemoveAppsInput = 'c'
            }
            
            Write-Output ""
        }
    }
    while ($RemoveAppsInput -ne 'n' -and $RemoveAppsInput -ne '0' -and $RemoveAppsInput -ne '1' -and $RemoveAppsInput -ne '2' -and $RemoveAppsInput -ne '3') 

    # Select correct option based on user input
    switch ($RemoveAppsInput) {
        '1' {
            AddParameter 'RemoveApps' 'Remove default selection of bloatware apps'
        }
        '2' {
            AddParameter 'RemoveApps' 'Remove default selection of bloatware apps'
            AddParameter 'RemoveCommApps' 'Remove the Mail, Calendar, and People apps'
            AddParameter 'RemoveW11Outlook' 'Remove the new Outlook for Windows app'
            AddParameter 'RemoveDevApps' 'Remove developer-related apps'
            AddParameter 'RemoveGamingApps' 'Remove the Xbox App and Xbox Gamebar'
            AddParameter 'DisableDVR' 'Disable Xbox game/screen recording'
        }
        '3' {
            Write-Output "You have selected $($script:SelectedApps.Count) apps for removal"

            AddParameter 'RemoveAppsCustom' "Remove $($script:SelectedApps.Count) apps:"

            Write-Output ""

            if ($( Read-Host -Prompt "确定禁用 Xbox game/screen recording? 这也将停止游戏叠加弹出窗口 (y/n)" ) -eq 'y') {
                AddParameter 'DisableDVR' 'Disable Xbox game/screen recording'
            }
        }
    }

    Write-Output ""

    if ($( Read-Host -Prompt "禁用遥测（telemetry）、诊断数据（diagnostic data）、活动历史记录（activity history）、应用启动追踪（app-launch tracking）和定向广告（targeted ads）? (y/n)" ) -eq 'y') {
        AddParameter 'DisableTelemetry' 'Disable telemetry, diagnostic data, activity history, app-launch tracking & targeted ads'
    }

    Write-Output ""

    if ($( Read-Host -Prompt "是否在开始菜单、设置、通知、资源管理器和锁屏界面中禁用提示（tips）、技巧（tricks）、建议（suggestions）和广告（ads）? (y/n)" ) -eq 'y') {
        AddParameter 'DisableSuggestions' 'Disable tips, tricks, suggestions and ads in start, settings, notifications and File Explorer'
        AddParameter 'DisableSettings365Ads' 'Disable Microsoft 365 ads in Settings Home'
        AddParameter 'DisableLockscreenTips' 'Disable tips & tricks on the lockscreen'
    }

    Write-Output ""

    if ($( Read-Host -Prompt "是否禁用并移除 Windows 搜索中的必应网页搜索（Bing web search）、必应 AI（Bing AI）和 Cortana？? (y/n)" ) -eq 'y') {
        AddParameter 'DisableBing' 'Disable & remove Bing web search, Bing AI and Cortana from Windows search'
    }

    # Only show this option for Windows 11 users running build 22621 or later
    if ($WinVersion -ge 22621) {
        Write-Output ""

        # Show options for disabling/removing AI features, only continue on valid input
        Do {
            Write-Host "选项:" -ForegroundColor Yellow
            Write-Host " (n) 不禁用任何 AI 功能" -ForegroundColor Yellow
            Write-Host " (1) 禁用 Microsoft Copilot 和 Windows Recall 快照" -ForegroundColor Yellow
            Write-Host " (2) 禁用 Microsoft Copilot、Windows Recall 快照以及画图（Paint）和记事本（Notepad）中的 AI 功能"  -ForegroundColor Yellow
            $DisableAIInput = Read-Host "是否要禁用所选 AI 功能？请根据上方选项输入对应编号进行选择，此设置将会为所有用户移除。 (n/1/2)"
        }
        while ($DisableAIInput -ne 'n' -and $DisableAIInput -ne '0' -and $DisableAIInput -ne '1' -and $DisableAIInput -ne '2') 

        # Select correct option based on user input
        switch ($DisableAIInput) {
            '1' {
                AddParameter 'DisableCopilot' 'Disable & remove Microsoft Copilot'
                AddParameter 'DisableRecall' 'Disable Windows Recall snapshots'
            }
            '2' {
                AddParameter 'DisableCopilot' 'Disable & remove Microsoft Copilot'
                AddParameter 'DisableRecall' 'Disable Windows Recall snapshots'
                AddParameter 'DisablePaintAI' 'Disable AI features in Paint'
                AddParameter 'DisableNotepadAI' 'Disable AI features in Notepad'
            }
        }
    }

    Write-Output ""

    if ($( Read-Host -Prompt "禁用桌面上的 Windows 聚焦（Windows Spotlight）背景? (y/n)" ) -eq 'y') {
        AddParameter 'DisableDesktopSpotlight' 'Disable the Windows Spotlight desktop background option.'
    }

    Write-Output ""

    if ($( Read-Host -Prompt "启用系统与应用的深色模式（dark mode）? (y/n)" ) -eq 'y') {
        AddParameter 'EnableDarkMode' 'Enable dark mode for system and apps'
    }

    Write-Output ""

    if ($( Read-Host -Prompt "禁用透明效果（transparency）、动画（animations）和视觉效果（visual effects）? (y/n)" ) -eq 'y') {
        AddParameter 'DisableTransparency' 'Disable transparency effects'
        AddParameter 'DisableAnimations' 'Disable animations and visual effects'
    }

    # Only show this option for Windows 11 users running build 22000 or later
    if ($WinVersion -ge 22000) {
        Write-Output ""

        if ($( Read-Host -Prompt "恢复旧版 Windows 10 样式的右键菜单。（仅适用于 Windows 11）? (y/n)" ) -eq 'y') {
            AddParameter 'RevertContextMenu' 'Restore the old Windows 10 style context menu'
        }
    }

    Write-Output ""

    if ($( Read-Host -Prompt "关闭 增强指针精度 （Enhance Pointer Precision，又称鼠标加速）? (y/n)" ) -eq 'y') {
        AddParameter 'DisableMouseAcceleration' 'Turn off Enhance Pointer Precision (mouse acceleration)'
    }

    # Only show this option for Windows 11 users running build 26100 or later
    if ($WinVersion -ge 26100) {
        Write-Output ""

        if ($( Read-Host -Prompt "禁用粘滞键（Sticky Keys）快捷键。（仅适用于 Windows 11）? (y/n)" ) -eq 'y') {
            AddParameter 'DisableStickyKeys' 'Disable the Sticky Keys keyboard shortcut'
        }
    }

    Write-Output ""

    if ($( Read-Host -Prompt "是否禁用快速启动（Fast Start-up） (y/n)" ) -eq 'y') {
        AddParameter 'DisableFastStartup' 'Disable Fast Start-up'
    }

    # Only show option for disabling context menu items for Windows 10 users or if the user opted to restore the Windows 10 context menu
    if ((get-ciminstance -query "select caption from win32_operatingsystem where caption like '%Windows 10%'") -or $script:Params.ContainsKey('RevertContextMenu')) {
        Write-Output ""

        if ($( Read-Host -Prompt "是否要禁用一些右键菜单选项? (y/n)" ) -eq 'y') {
            Write-Output ""

            if ($( Read-Host -Prompt "   在右键菜单中隐藏'包含到库 Include in library '选项? (y/n)" ) -eq 'y') {
                AddParameter 'HideIncludeInLibrary' "Hide the 'Include in library' option in the context menu"
            }

            Write-Output ""

            if ($( Read-Host -Prompt "   在右键菜单中隐藏'授予访问权限'选项? (y/n)" ) -eq 'y') {
                AddParameter 'HideGiveAccessTo' "Hide the 'Give access to' option in the context menu"
            }

            Write-Output ""

            if ($( Read-Host -Prompt "   在右键菜单中隐藏'共享'选项? (y/n)" ) -eq 'y') {
                AddParameter 'HideShare' "Hide the 'Share' option in the context menu"
            }
        }
    }

    # Only show this option for Windows 11 users running build 22621 or later
    if ($WinVersion -ge 22621) {
        Write-Output ""

        if ($( Read-Host -Prompt "是否要对开始菜单进行一些更改? (y/n)" ) -eq 'y') {
            Write-Output ""

            if ($script:Params.ContainsKey("Sysprep")) {
                if ($( Read-Host -Prompt "要为所有现有和新用户移除开始菜单中固定的所有应用吗? (y/n)" ) -eq 'y') {
                    AddParameter 'ClearStartAllUsers' 'Remove all pinned apps from the start menu for existing and new users'
                }
            }
            else {
                Do {
                    Write-Host "   Options:" -ForegroundColor Yellow
                    Write-Host "    (n) 不要移除开始菜单中固定的任何应用" -ForegroundColor Yellow
                    Write-Host "    (1) 仅为当前用户 ($(GetUserName)) 移除开始菜单中固定的所有应用 " -ForegroundColor Yellow
                    Write-Host "    (2) 为所有现有用户和新用户移除开始菜单中固定的所有应用"  -ForegroundColor Yellow
                    $ClearStartInput = Read-Host "   移除开始菜单中固定的所有应用? (n/1/2)" 
                }
                while ($ClearStartInput -ne 'n' -and $ClearStartInput -ne '0' -and $ClearStartInput -ne '1' -and $ClearStartInput -ne '2') 

                # Select correct option based on user input
                switch ($ClearStartInput) {
                    '1' {
                        AddParameter 'ClearStart' "Remove all pinned apps from the start menu for this user only"
                    }
                    '2' {
                        AddParameter 'ClearStartAllUsers' "Remove all pinned apps from the start menu for all existing and new users"
                    }
                }
            }

            Write-Output ""

            if ($( Read-Host -Prompt "   是否禁用开始菜单中的推荐部分？此设置将应用于所有用户。 (y/n)" ) -eq 'y') {
                AddParameter 'DisableStartRecommended' 'Disable the recommended section in the start menu.'
            }

            Write-Output ""

            if ($( Read-Host -Prompt "   禁用开始菜单中的手机链接（Phone Link）移动设备集成功能? (y/n)" ) -eq 'y') {
                AddParameter 'DisableStartPhoneLink' 'Disable the Phone Link mobile devices integration in the start menu.'
            }
        }
    }

    Write-Output ""

    if ($( Read-Host -Prompt "是否要对任务栏及相关服务进行一些更改？ (y/n)" ) -eq 'y') {
        # Only show these specific options for Windows 11 users running build 22000 or later
        if ($WinVersion -ge 22000) {
            Write-Output ""

            if ($( Read-Host -Prompt "   将任务栏按钮靠左对齐? (y/n)" ) -eq 'y') {
                AddParameter 'TaskbarAlignLeft' 'Align taskbar icons to the left'
            }

            # Show options for search icon on taskbar, only continue on valid input
            Do {
                Write-Output ""
                Write-Host "   选项:" -ForegroundColor Yellow
                Write-Host "    (n) 不要改变" -ForegroundColor Yellow
                Write-Host "    (1) 隐藏任务栏上的搜索图标" -ForegroundColor Yellow
                Write-Host "    (2) 在任务栏上展示搜索图标" -ForegroundColor Yellow
                Write-Host "    (3) 在任务栏上显示带标签的搜索图标" -ForegroundColor Yellow
                Write-Host "    (4) 在任务栏上显示搜索框" -ForegroundColor Yellow
                $TbSearchInput = Read-Host "   Hide or change the search icon on the taskbar? (n/1/2/3/4)" 
            }
            while ($TbSearchInput -ne 'n' -and $TbSearchInput -ne '0' -and $TbSearchInput -ne '1' -and $TbSearchInput -ne '2' -and $TbSearchInput -ne '3' -and $TbSearchInput -ne '4') 

            # Select correct taskbar search option based on user input
            switch ($TbSearchInput) {
                '1' {
                    AddParameter 'HideSearchTb' 'Hide search icon from the taskbar'
                }
                '2' {
                    AddParameter 'ShowSearchIconTb' 'Show search icon on the taskbar'
                }
                '3' {
                    AddParameter 'ShowSearchLabelTb' 'Show search icon with label on the taskbar'
                }
                '4' {
                    AddParameter 'ShowSearchBoxTb' 'Show search box on the taskbar'
                }
            }

            Write-Output ""

            if ($( Read-Host -Prompt "   隐藏任务栏上的任务视图按钮? (y/n)" ) -eq 'y') {
                AddParameter 'HideTaskview' 'Hide the taskview button from the taskbar'
            }
        }

        Write-Output ""

        if ($( Read-Host -Prompt "   禁用小组件（widgets）服务并隐藏其任务栏图标? (y/n)" ) -eq 'y') {
            AddParameter 'DisableWidgets' 'Disable the widget service & hide the widget (news and interests) icon from the taskbar'
        }

        # Only show this options for Windows users running build 22621 or earlier
        if ($WinVersion -le 22621) {
            Write-Output ""

            if ($( Read-Host -Prompt "   隐藏任务栏上的聊天（Meet Now）图标? (y/n)" ) -eq 'y') {
                AddParameter 'HideChat' 'Hide the chat (meet now) icon from the taskbar'
            }
        }
        
        # Only show this options for Windows users running build 22631 or later
        if ($WinVersion -ge 22631) {
            Write-Output ""

            if ($( Read-Host -Prompt "   是否启用任务栏右键菜单中的‘结束任务’选项？ (y/n)" ) -eq 'y') {
                AddParameter 'EnableEndTask' "Enable the 'End Task' option in the taskbar right click menu"
            }
        }
        
        Write-Output ""
        if ($( Read-Host -Prompt "   启用任务栏应用区域的'最后活动点击'（Last Active Click）行为? (y/n)" ) -eq 'y') {
            AddParameter 'EnableLastActiveClick' "Enable the 'Last Active Click' behavior in the taskbar app area"
        }
    }

    Write-Output ""

    if ($( Read-Host -Prompt "你想要对资源管理器进行更改吗? (y/n)" ) -eq 'y') {
        # Show options for changing the File Explorer default location
        Do {
            Write-Output ""
            Write-Host "   选项:" -ForegroundColor Yellow
            Write-Host "    (n) 不要改变 " -ForegroundColor Yellow
            Write-Host "    (1) 将文件资源管理器默认打开位置设置为“主页”（Home）" -ForegroundColor Yellow
            Write-Host "    (2) 将文件资源管理器默认打开位置设置为“此电脑”（This PC）" -ForegroundColor Yellow
            Write-Host "    (3) 将文件资源管理器默认打开位置设置为“下载”（Downloads）" -ForegroundColor Yellow
            Write-Host "    (4) 将文件资源管理器默认打开位置设置为 OneDrive " -ForegroundColor Yellow
            $ExplSearchInput = Read-Host "   将文件资源管理器默认打开位置设置为? (n/1/2/3/4)" 
        }
        while ($ExplSearchInput -ne 'n' -and $ExplSearchInput -ne '0' -and $ExplSearchInput -ne '1' -and $ExplSearchInput -ne '2' -and $ExplSearchInput -ne '3' -and $ExplSearchInput -ne '4') 

        # Select correct taskbar search option based on user input
        switch ($ExplSearchInput) {
            '1' {
                AddParameter 'ExplorerToHome' "Change the default location that File Explorer opens to 'Home'"
            }
            '2' {
                AddParameter 'ExplorerToThisPC' "Change the default location that File Explorer opens to 'This PC'"
            }
            '3' {
                AddParameter 'ExplorerToDownloads' "Change the default location that File Explorer opens to 'Downloads'"
            }
            '4' {
                AddParameter 'ExplorerToOneDrive' "Change the default location that File Explorer opens to 'OneDrive'"
            }
        }

        Write-Output ""

        if ($( Read-Host -Prompt "   显示隐藏的文件、文件夹和驱动器? (y/n)" ) -eq 'y') {
            AddParameter 'ShowHiddenFolders' 'Show hidden files, folders and drives'
        }

        Write-Output ""

        if ($( Read-Host -Prompt "   显示已知文件类型的文件扩展名? (y/n)" ) -eq 'y') {
            AddParameter 'ShowKnownFileExt' 'Show file extensions for known file types'
        }

        # Only show this option for Windows 11 users running build 22000 or later
        if ($WinVersion -ge 22000) {
            Write-Output ""

            if ($( Read-Host -Prompt "   隐藏文件资源管理器侧边栏中的 主页 部分? (y/n)" ) -eq 'y') {
                AddParameter 'HideHome' 'Hide the Home section from the File Explorer sidepanel'
            }

            Write-Output ""

            if ($( Read-Host -Prompt "   隐藏文件资源管理器侧边栏中的 图库 部分？? (y/n)" ) -eq 'y') {
                AddParameter 'HideGallery' 'Hide the Gallery section from the File Explorer sidepanel'
            }
        }

        Write-Output ""

        if ($( Read-Host -Prompt "   隐藏文件资源管理器侧边栏中重复的可移动驱动器条目，使其仅在 此电脑 下显示？ (y/n)" ) -eq 'y') {
            AddParameter 'HideDupliDrive' 'Hide duplicate removable drive entries from the File Explorer sidepanel'
        }

        # Only show option for disabling these specific folders for Windows 10 users
        if (get-ciminstance -query "select caption from win32_operatingsystem where caption like '%Windows 10%'") {
            Write-Output ""

            if ($( Read-Host -Prompt "是否要隐藏文件资源管理器侧边栏中的某些文件夹? (y/n)" ) -eq 'y') {
                Write-Output ""

                if ($( Read-Host -Prompt "   隐藏文件资源管理器侧边栏中的 OneDrive 文件夹? (y/n)" ) -eq 'y') {
                    AddParameter 'HideOnedrive' 'Hide the OneDrive folder in the File Explorer sidepanel'
                }

                Write-Output ""
                
                if ($( Read-Host -Prompt "   隐藏文件资源管理器侧边栏中的 3D 对象文件夹? (y/n)" ) -eq 'y') {
                    AddParameter 'Hide3dObjects' "Hide the 3D objects folder under 'This pc' in File Explorer" 
                }
                
                Write-Output ""

                if ($( Read-Host -Prompt "   隐藏文件资源管理器侧边栏中的音乐文件夹? (y/n)" ) -eq 'y') {
                    AddParameter 'HideMusic' "Hide the music folder under 'This pc' in File Explorer"
                }
            }
        }
    }

    # Suppress prompt if Silent parameter was passed
    if (-not $Silent) {
        Write-Output ""
        Write-Output ""
        Write-Output ""
        Write-Output "按 Enter 键确认你的选择并执行脚本，或按 CTRL+C 退出…"
        Read-Host | Out-Null
    }

    PrintHeader '自定义模式'
}



##################################################################################################################
#                                                                                                                #
#                                                  SCRIPT START                                                  #
#                                                                                                                #
##################################################################################################################



# Check if winget is installed & if it is, check if the version is at least v1.4
if ((Get-AppxPackage -Name "*Microsoft.DesktopAppInstaller*") -and ([int](((winget -v) -replace 'v','').split('.')[0..1] -join '') -gt 14)) {
    $script:wingetInstalled = $true
}
else {
    $script:wingetInstalled = $false

    # Show warning that requires user confirmation, Suppress confirmation if Silent parameter was passed
    if (-not $Silent) {
        Write-Warning "Winget 未安装或版本过旧，可能导致 Win11Debloat 无法移除某些应用。"
        Write-Output ""
        Write-Output "按任意键继续..."
        $null = [System.Console]::ReadKey()
    }
}

# Get current Windows build version to compare against features
$WinVersion = Get-ItemPropertyValue 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' CurrentBuild

$script:Params = $PSBoundParameters
$script:FirstSelection = $true
$SPParams = 'WhatIf', 'Confirm', 'Verbose', 'Silent', 'Sysprep', 'Debug', 'User', 'CreateRestorePoint', 'LogPath'
$SPParamCount = 0

# Count how many SPParams exist within Params
# This is later used to check if any options were selected
foreach ($Param in $SPParams) {
    if ($script:Params.ContainsKey($Param)) {
        $SPParamCount++
    }
}

# Hide progress bars for app removal, as they block Win11Debloat's output
if (-not ($script:Params.ContainsKey("Verbose"))) {
    $ProgressPreference = 'SilentlyContinue'
}
else {
    Write-Host "详细模式已启用"
    Write-Output ""
    Write-Output "按任意键继续..."
    $null = [System.Console]::ReadKey()

    $ProgressPreference = 'Continue'
}

# Make sure all requirements for Sysprep are met, if Sysprep is enabled
if ($script:Params.ContainsKey("Sysprep")) {
    $defaultUserPath = $env:USERPROFILE -Replace ('\\' + $env:USERNAME + '$'), '\Default\NTUSER.DAT'

    # Exit script if default user directory or NTUSER.DAT file cannot be found
    if (-not (Test-Path "$defaultUserPath")) {
        Write-Host "错误：无法以 Sysprep 模式启动 Win11Debloat，未能找到默认用户文件夹，路径为 '$defaultUserPath'" -ForegroundColor Red
        AwaitKeyToExit
    }
    # Exit script if run in Sysprep mode on Windows 10
    if ($WinVersion -lt 22000) {
        Write-Host "错误：Win11Debloat 的 Sysprep 模式不支持 Windows 10。" -ForegroundColor Red
        AwaitKeyToExit
    }
}

# Make sure all requirements for User mode are met, if User is specified
if ($script:Params.ContainsKey("User")) {
    $userPath = $env:USERPROFILE -Replace ('\\' + $env:USERNAME + '$'), "\$($script:Params.Item("User"))\NTUSER.DAT"

    # Exit script if user directory or NTUSER.DAT file cannot be found
    if (-not (Test-Path "$userPath")) {
        Write-Host "错误：无法为用户 $($script:Params.Item("User")) 运行 Win11Debloat，未能找到用户数据，路径为 '$userPath'。" -ForegroundColor Red
        AwaitKeyToExit
    }
}

# Remove SavedSettings file if it exists and is empty
if ((Test-Path "$PSScriptRoot/SavedSettings") -and ([String]::IsNullOrWhiteSpace((Get-content "$PSScriptRoot/SavedSettings")))) {
    Remove-Item -Path "$PSScriptRoot/SavedSettings" -recurse
}

# Only run the app selection form if the 'RunAppsListGenerator' parameter was passed to the script
if ($RunAppConfigurator -or $RunAppsListGenerator) {
    PrintHeader "自定义应用程序生成器"

    $result = ShowAppSelectionForm

    # Show different message based on whether the app selection was saved or cancelled
    if ($result -ne [System.Windows.Forms.DialogResult]::OK) {
        Write-Host "应用选择窗口已关闭，未保存。" -ForegroundColor Red
    }
    else {
        Write-Output "你的应用选择已保存到“CustomAppsList”文件，位置为："
        Write-Host "$PSScriptRoot" -ForegroundColor Yellow
    }

    AwaitKeyToExit
}

# Change script execution based on provided parameters or user input
if ((-not $script:Params.Count) -or $RunDefaults -or $RunWin11Defaults -or $RunSavedSettings -or ($SPParamCount -eq $script:Params.Count)) {
    if ($RunDefaults -or $RunWin11Defaults) {
        $Mode = '1'
    }
    elseif ($RunSavedSettings) {
        if (-not (Test-Path "$PSScriptRoot/SavedSettings")) {
            PrintHeader '自定义模式'
            Write-Host "错误：未找到已保存的设置，未进行任何更改。" -ForegroundColor Red
            AwaitKeyToExit
        }

        $Mode = '4'
    }
    else {
        # Show menu and wait for user input, loops until valid input is provided
        Do { 
            $ModeSelectionMessage = "请选择一个选项，输入 (1/2/3/0)" 

            PrintHeader '菜单'

            Write-Output "(1) 默认模式：快速应用推荐的更改"
            Write-Output "(2) 自定义模式：手动选择要进行的更改"
            Write-Output "(3) 应用移除模式：选择并移除应用程序，而不进行其他更改"

            # Only show this option if SavedSettings file exists
            if (Test-Path "$PSScriptRoot/SavedSettings") {
                Write-Output "(4) 应用上次保存的自定义设置"
                
                $ModeSelectionMessage = "请选择一个选项，输入 (1/2/3/4/0)" 
            }

            Write-Output ""
            Write-Output "(0) 显示更多信息"
            Write-Output ""
            Write-Output ""

            $Mode = Read-Host $ModeSelectionMessage

            if ($Mode -eq '0') {
                # Print information screen from file
                PrintFromFile "$PSScriptRoot/Assets/Menus/Info" "Information"

                Write-Output "按任意键返回..."
                $null = [System.Console]::ReadKey()
            }
            elseif (($Mode -eq '4') -and -not (Test-Path "$PSScriptRoot/SavedSettings")) {
                $Mode = $null
            }
        }
        while ($Mode -ne '1' -and $Mode -ne '2' -and $Mode -ne '3' -and $Mode -ne '4') 
    }

    # Add execution parameters based on the mode
    switch ($Mode) {
        # Default mode, loads defaults after confirmation
        '1' { 
            # Show the default settings with confirmation, unless Silent parameter was passed
            if (-not $Silent) {
                PrintFromFile "$PSScriptRoot/Assets/Menus/DefaultSettings" "Default Mode"

                Write-Output "按 Enter 键执行，或按 CTRL+C 退出..."
                Read-Host | Out-Null
            }

            $DefaultParameterNames = 'CreateRestorePoint','RemoveApps','DisableTelemetry','DisableBing','DisableLockscreenTips','DisableSuggestions','ShowKnownFileExt','DisableWidgets','HideChat','DisableCopilot','DisableFastStartup'

            PrintHeader '默认模式'

            # Add default parameters, if they don't already exist
            foreach ($ParameterName in $DefaultParameterNames) {
                if (-not $script:Params.ContainsKey($ParameterName)) {
                    $script:Params.Add($ParameterName, $true)
                }
            }

            # Only add this option for Windows 10 users, if it doesn't already exist
            if ((get-ciminstance -query "select caption from win32_operatingsystem where caption like '%Windows 10%'") -and (-not $script:Params.ContainsKey('Hide3dObjects'))) {
                $script:Params.Add('Hide3dObjects', $Hide3dObjects)
            }
        }

        # Custom mode, show & add options based on user input
        '2' { 
            DisplayCustomModeOptions
        }

        # App removal, remove apps based on user selection
        '3' {
            PrintHeader "应用移除"

            $result = ShowAppSelectionForm

            if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
                Write-Output "你已选择移除 $($script:SelectedApps.Count) 个应用。"
                AddParameter 'RemoveAppsCustom' "Remove $($script:SelectedApps.Count) apps:"

                # Suppress prompt if Silent parameter was passed
                if (-not $Silent) {
                    Write-Output ""
                    Write-Output ""
                    Write-Output "按 Enter 键移除所选应用，或按 **CTRL+C** 退出…"
                    Read-Host | Out-Null
                    PrintHeader "应用移除"
                }
            }
            else {
                Write-Host "已取消选择，未移除任何应用。" -ForegroundColor Red
                Write-Output ""
            }
        }

        # Load custom options from the "SavedSettings" file
        '4' {
            PrintHeader '自定义模式'
            Write-Output "Win11Debloat 将会执行下列更改:"

            # Print the saved settings info from file
            Foreach ($line in (Get-Content -Path "$PSScriptRoot/SavedSettings" )) { 
                # Remove any spaces before and after the line
                $line = $line.Trim()
            
                # Check if the line contains a comment
                if (-not ($line.IndexOf('#') -eq -1)) {
                    $parameterName = $line.Substring(0, $line.IndexOf('#'))

                    # Print parameter description and add parameter to Params list
                    if ($parameterName -eq "RemoveAppsCustom") {
                        if (-not (Test-Path "$PSScriptRoot/CustomAppsList")) {
                            # Apps file does not exist, skip
                            continue
                        }
                        
                        $appsList = ReadAppslistFromFile "$PSScriptRoot/CustomAppsList"
                        Write-Output "- Remove $($appsList.Count) apps:"
                        Write-Host $appsList -ForegroundColor DarkGray
                    }
                    else {
                        Write-Output $line.Substring(($line.IndexOf('#') + 1), ($line.Length - $line.IndexOf('#') - 1))
                    }

                    if (-not $script:Params.ContainsKey($parameterName)) {
                        $script:Params.Add($parameterName, $true)
                    }
                }
            }

            if (-not $Silent) {
                Write-Output ""
                Write-Output ""
                Write-Output "按 Enter 键执行脚本，或按 CTRL+C 退出…"
                Read-Host | Out-Null
            }

            PrintHeader '自定义模式'
        }
    }
}
else {
    PrintHeader '自定义模式'
}

# If the number of keys in SPParams equals the number of keys in Params then no modifications/changes were selected
#  or added by the user, and the script can exit without making any changes.
if ($SPParamCount -eq $script:Params.Keys.Count) {
    Write-Output "脚本已完成执行，但未进行任何更改。"

    AwaitKeyToExit
}

# Execute all selected/provided parameters
switch ($script:Params.Keys) {
    'CreateRestorePoint' {
        CreateSystemRestorePoint
        continue
    }
    'RemoveApps' {
        $appsList = ReadAppslistFromFile "$PSScriptRoot/Appslist.txt" 
        Write-Output "> 正在移除默认选择的 $($appsList.Count) 个应用…"
        RemoveApps $appsList
        continue
    }
    'RemoveAppsCustom' {
        if (-not (Test-Path "$PSScriptRoot/CustomAppsList")) {
            Write-Host "> 错误：无法从文件加载自定义应用列表，未移除任何应用。" -ForegroundColor Red
            Write-Output ""
            continue
        }
        
        $appsList = ReadAppslistFromFile "$PSScriptRoot/CustomAppsList"
        Write-Output "> 正在移除 $($appsList.Count) 个应用..."
        RemoveApps $appsList
        continue
    }
    'RemoveCommApps' {
        $appsList = 'Microsoft.windowscommunicationsapps', 'Microsoft.People'
        Write-Output "> 正在移除邮件、日历和联系人应用..."
        RemoveApps $appsList
        continue
    }
    'RemoveW11Outlook' {
        $appsList = 'Microsoft.OutlookForWindows'
        Write-Output "> 正在移除新版 Windows Outlook 应用..."
        RemoveApps $appsList
        continue
    }
    'RemoveDevApps' {
        $appsList = 'Microsoft.PowerAutomateDesktop', 'Microsoft.RemoteDesktop', 'Windows.DevHome'
        Write-Output "> 正在移除开发者相关应用..."
        RemoveApps $appsList
        continue
    }
    'RemoveGamingApps' {
        $appsList = 'Microsoft.GamingApp', 'Microsoft.XboxGameOverlay', 'Microsoft.XboxGamingOverlay'
        Write-Output "> 正在移除与游戏相关的应用..."
        RemoveApps $appsList
        continue
    }
    'RemoveHPApps' {
        $appsList = 'AD2F1837.HPAIExperienceCenter', 'AD2F1837.HPJumpStarts', 'AD2F1837.HPPCHardwareDiagnosticsWindows', 'AD2F1837.HPPowerManager', 'AD2F1837.HPPrivacySettings', 'AD2F1837.HPSupportAssistant', 'AD2F1837.HPSureShieldAI', 'AD2F1837.HPSystemInformation', 'AD2F1837.HPQuickDrop', 'AD2F1837.HPWorkWell', 'AD2F1837.myHP', 'AD2F1837.HPDesktopSupportUtilities', 'AD2F1837.HPQuickTouch', 'AD2F1837.HPEasyClean', 'AD2F1837.HPConnectedMusic', 'AD2F1837.HPFileViewer', 'AD2F1837.HPRegistration', 'AD2F1837.HPWelcome', 'AD2F1837.HPConnectedPhotopoweredbySnapfish', 'AD2F1837.HPPrinterControl'
        Write-Output "> 正在移除惠普（HP）应用..."
        RemoveApps $appsList
        continue
    }
    "ForceRemoveEdge" {
        ForceRemoveEdge
        continue
    }
    'DisableDVR' {
        RegImport "> 正在禁用 Xbox 游戏/屏幕录制功能..." "Disable_DVR.reg"
        continue
    }
    'DisableTelemetry' {
        RegImport "> 正在禁用遥测（telemetry）、诊断数据（diagnostic data）、活动历史记录（activity history）、应用启动追踪（app-launch tracking）和定向广告（targeted ads）..." "Disable_Telemetry.reg"
        continue
    }
    {$_ -in "DisableSuggestions", "DisableWindowsSuggestions"} {
        RegImport "> 正在禁用 Windows 系统中的提示（tips）、技巧（tricks）、建议（suggestions）和广告（ads）..." "Disable_Windows_Suggestions.reg"
        continue
    }
    {$_ -in "DisableLockscrTips", "DisableLockscreenTips"} {
        RegImport "> 正在禁用锁屏界面的提示与技巧..." "Disable_Lockscreen_Tips.reg"
        continue
    }
    'DisableDesktopSpotlight' {
        RegImport "> 正在禁用“Windows 聚焦”（Windows Spotlight）桌面背景选项" "Disable_Desktop_Spotlight.reg"
        continue
    }
    'DisableSettings365Ads' {
        RegImport "> 正在禁用设置首页中的 Microsoft 365 广告..." "Disable_Settings_365_Ads.reg"
        continue
    }
    'DisableSettingsHome' {
        RegImport "> 正在禁用“设置”主页页面..." "Disable_Settings_Home.reg"
        continue
    }
    {$_ -in "DisableBingSearches", "DisableBing"} {
        RegImport "> 正在禁用 Windows 搜索中的必应网页搜索（Bing web search）、必应 AI（Bing AI）和 Cortana..." "Disable_Bing_Cortana_In_Search.reg"
        
        # Also remove the app package for Bing search
        $appsList = 'Microsoft.BingSearch'
        RemoveApps $appsList
        continue
    }
    'DisableCopilot' {
        RegImport "> 正在禁用 Microsoft Copilot..." "Disable_Copilot.reg"

        # Also remove the app package for Copilot
        $appsList = 'Microsoft.Copilot'
        RemoveApps $appsList
        continue
    }
    'DisableRecall' {
        RegImport "> 正在禁用 Windows Recall..." "Disable_AI_Recall.reg"
        continue
    }
    'DisablePaintAI' {
        RegImport "> 正在禁用画图（Paint）中的 AI 功能。..." "Disable_Paint_AI_Features.reg"
        continue
    }
    'DisableNotepadAI' {
        RegImport "> 正在禁用记事本（Notepad）中的 AI 功能..." "Disable_Notepad_AI_Features.reg"
        continue
    }
    'RevertContextMenu' {
        RegImport "> 正在恢复旧版 Windows 10 样式的右键菜单..." "Disable_Show_More_Options_Context_Menu.reg"
        continue
    }
    'DisableMouseAcceleration' {
        RegImport "> 正在关闭增强指针精度（Enhanced Pointer Precision）" "Disable_Enhance_Pointer_Precision.reg"
        continue
    }
    'DisableStickyKeys' {
        RegImport "> 正在禁用粘滞键（Sticky Keys）快捷键..." "Disable_Sticky_Keys_Shortcut.reg"
        continue
    }
    'DisableFastStartup' {
        RegImport "> 正在禁用快速启动（Fast Start-up）..." "Disable_Fast_Startup.reg"
        continue
    }
    'ClearStart' {
        Write-Output "> 正在为用户 $(GetUserName) 移除开始菜单中所有固定的应用。..."
        ReplaceStartMenu
        Write-Output ""
        continue
    }
    'ReplaceStart' {
        Write-Output "> 正在为用户 $(GetUserName) 替换开始菜单。..."
        ReplaceStartMenu $script:Params.Item("ReplaceStart")
        Write-Output ""
        continue
    }
    'ClearStartAllUsers' {
        ReplaceStartMenuForAllUsers
        continue
    }
    'ReplaceStartAllUsers' {
        ReplaceStartMenuForAllUsers $script:Params.Item("ReplaceStartAllUsers")
        continue
    }
    'DisableStartRecommended' {
        RegImport "> 正在禁用开始菜单中的推荐部分..." "Disable_Start_Recommended.reg"
        continue
    }
    'DisableStartPhoneLink' {
        RegImport "> 正在禁用开始菜单中的手机链接（Phone Link）移动设备集成功能..." "Disable_Phone_Link_In_Start.reg"
        continue
    }
    'EnableDarkMode' {
        RegImport "> 正在为系统和应用启用深色模式..." "Enable_Dark_Mode.reg"
        continue
    }
    'DisableTransparency' {
        RegImport "> 正在禁用透明效果..." "Disable_Transparency.reg"
        continue
    }
    'DisableAnimations' {
        RegImport "> 正在禁用动画和视觉效果..." "Disable_Animations.reg"
        continue
    }
    'TaskbarAlignLeft' {
        RegImport "> 正在将任务栏按钮左对齐..." "Align_Taskbar_Left.reg"
        continue
    }
    'HideSearchTb' {
        RegImport "> 正在隐藏任务栏上的搜索图标..." "Hide_Search_Taskbar.reg"
        continue
    }
    'ShowSearchIconTb' {
        RegImport "> 正在将任务栏搜索更改为仅显示图标..." "Show_Search_Icon.reg"
        continue
    }
    'ShowSearchLabelTb' {
        RegImport "> 正在将任务栏搜索更改为带标签的图标..." "Show_Search_Icon_And_Label.reg"
        continue
    }
    'ShowSearchBoxTb' {
        RegImport "> 正在将任务栏搜索更改为搜索框..." "Show_Search_Box.reg"
        continue
    }
    'HideTaskview' {
        RegImport "> 正在隐藏任务栏上的任务视图按钮..." "Hide_Taskview_Taskbar.reg"
        continue
    }
    {$_ -in "HideWidgets", "DisableWidgets"} {
        RegImport "> 正在禁用小组件（widget）服务并隐藏任务栏上的小组件图标..." "Disable_Widgets_Taskbar.reg"

        # Also remove the app package for Widgets
        $appsList = 'Microsoft.StartExperiencesApp'
        RemoveApps $appsList
        continue
    }
    {$_ -in "HideChat", "DisableChat"} {
        RegImport "> 正在隐藏任务栏上的 Chat 图标..." "Disable_Chat_Taskbar.reg"
        continue
    }
    'EnableEndTask' {
        RegImport "> 正在启用任务栏右键菜单中的 结束任务 选项..." "Enable_End_Task.reg"
        continue
    }
    'EnableLastActiveClick' {
        RegImport "> 正在启用任务栏应用区域的 最后活动点击 行为..." "Enable_Last_Active_Click.reg"
        continue
    }
    'ExplorerToHome' {
        RegImport "> 正在将文件资源管理器的默认打开位置更改为 主页 ..." "Launch_File_Explorer_To_Home.reg"
        continue
    }
    'ExplorerToThisPC' {
        RegImport "> 正在将文件资源管理器的默认打开位置更改为 此电脑 ..." "Launch_File_Explorer_To_This_PC.reg"
        continue
    }
    'ExplorerToDownloads' {
        RegImport "> 正在将文件资源管理器的默认打开位置更改为 下载 ..." "Launch_File_Explorer_To_Downloads.reg"
        continue
    }
    'ExplorerToOneDrive' {
        RegImport "> 正在将文件资源管理器的默认打开位置更改为 OneDrive ..." "Launch_File_Explorer_To_OneDrive.reg"
        continue
    }
    'ShowHiddenFolders' {
        RegImport "> 正在取消隐藏已隐藏的文件、文件夹和驱动器..." "Show_Hidden_Folders.reg"
        continue
    }
    'ShowKnownFileExt' {
        RegImport "> 正在启用已知文件类型的文件扩展名显示..." "Show_Extensions_For_Known_File_Types.reg"
        continue
    }
    'HideHome' {
        RegImport "> 正在从文件资源管理器导航窗格中隐藏主页部分..." "Hide_Home_from_Explorer.reg"
        continue
    }
    'HideGallery' {
        RegImport "> 正在从文件资源管理器导航窗格中隐藏图库部分..." "Hide_Gallery_from_Explorer.reg"
        continue
    }
    'HideDupliDrive' {
        RegImport "> 正在从文件资源管理器导航窗格中隐藏重复的可移动驱动器条目..." "Hide_duplicate_removable_drives_from_navigation_pane_of_File_Explorer.reg"
        continue
    }
    {$_ -in "HideOnedrive", "DisableOnedrive"} {
        RegImport "> 正在从文件资源管理器导航窗格中隐藏 OneDrive 文件夹..." "Hide_Onedrive_Folder.reg"
        continue
    }
    {$_ -in "Hide3dObjects", "Disable3dObjects"} {
        RegImport "> 正在从文件资源管理器导航窗格中隐藏 3D 对象文件夹..." "Hide_3D_Objects_Folder.reg"
        continue
    }
    {$_ -in "HideMusic", "DisableMusic"} {
        RegImport "> 在文件资源管理器导航窗格中隐藏音乐文件夹..." "Hide_Music_folder.reg"
        continue
    }
    {$_ -in "HideIncludeInLibrary", "DisableIncludeInLibrary"} {
        RegImport "> 正在隐藏右键菜单中的 包含到库 Include in library 选项..." "Disable_Include_in_library_from_context_menu.reg"
        continue
    }
    {$_ -in "HideGiveAccessTo", "DisableGiveAccessTo"} {
        RegImport "> 正在隐藏右键菜单中的“授予访问权限”选项..." "Disable_Give_access_to_context_menu.reg"
        continue
    }
    {$_ -in "HideShare", "DisableShare"} {
        RegImport "> 正在隐藏右键菜单中的“共享”选项..." "Disable_Share_from_context_menu.reg"
        continue
    }
}

RestartExplorer

Write-Output ""
Write-Output ""
Write-Output ""
Write-Output "脚本执行完毕！请检查以上是否有任何错误"

AwaitKeyToExit
