#Requires -RunAsAdministrator

[CmdletBinding(SupportsShouldProcess)]
param (
    [switch]$Silent,
    [switch]$Sysprep,
    [string]$LogPath,
    [string]$User,
    [switch]$CreateRestorePoint,
    [switch]$RunAppsListGenerator, [switch]$RunAppConfigurator,
    [switch]$RunDefaults,
    [switch]$RunDefaultsLite,
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
    [switch]$DisableModernStandbyNetworking,
    [switch]$DisableBingSearches, [switch]$DisableBing,
    [switch]$DisableDesktopSpotlight,
    [switch]$DisableLockscrTips, [switch]$DisableLockscreenTips,
    [switch]$DisableWindowsSuggestions, [switch]$DisableSuggestions,
    [switch]$DisableEdgeAds,
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
    [switch]$DisableEdgeAI,
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
    Write-Host "错误: Win11Debloat 无法在您的系统上运行，powershell执行受到安全策略的限制" -ForegroundColor Red
    AwaitKeyToExit
}

# 将脚本输出记录到指定路径的 'Win11Debloat.log' 文件中
if ($LogPath -and (Test-Path $LogPath)) {
    Start-Transcript -Path "$LogPath/Win11Debloat.log" -Append -IncludeInvocationHeader -Force | Out-Null
}
else {
    Start-Transcript -Path "$PSScriptRoot/Win11Debloat.log" -Append -IncludeInvocationHeader -Force | Out-Null
}

# 显示应用程序选择表单，允许用户选择要移除或保留的应用
function ShowAppSelectionForm {
    [reflection.assembly]::loadwithpartialname("System.Windows.Forms") | Out-Null
    [reflection.assembly]::loadwithpartialname("System.Drawing") | Out-Null

    # 初始化表单对象
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

    # saveButton 事件处理程序
    $handler_saveButton_Click=
    {
        if ($selectionBox.CheckedItems -contains "Microsoft.WindowsStore" -and -not $Silent) {
            $warningSelection = [System.Windows.Forms.Messagebox]::Show('您确定要卸载Microsoft Store吗？此应用无法轻松重新安装。', '您确定吗？', 'YesNo', 'Warning')

            if ($warningSelection -eq 'No') {
                return
            }
        }

        $script:SelectedApps = $selectionBox.CheckedItems

        # 如果存储所选应用的文件不存在，则创建它
        if (-not (Test-Path "$PSScriptRoot/CustomAppsList")) {
            $null = New-Item "$PSScriptRoot/CustomAppsList"
        }

        Set-Content -Path "$PSScriptRoot/CustomAppsList" -Value $script:SelectedApps

        $form.DialogResult = [System.Windows.Forms.DialogResult]::OK
        $form.Close()
    }

    # cancelButton 事件处理程序
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
        # 修正表单的初始状态，以防止 .Net 窗口最大化问题
        $form.WindowState = $initialFormWindowState

        # 在再次加载应用列表之前将状态重置为默认值
        $script:selectionBoxIndex = -1
        $checkUncheckCheckBox.Checked = $False

        # 显示加载指示器
        $loadingLabel.Visible = $true
        $form.Refresh()

        # 在添加任何新项之前清空 selectionBox
        $selectionBox.Items.Clear()

        # 设置应用列表文件的路径
        $appsFile = "$PSScriptRoot/Appslist.txt"
        $listOfApps = ""

        if ($onlyInstalledCheckBox.Checked -and ($script:wingetInstalled -eq $true)) {
            # 尝试通过 winget 获取已安装应用的列表，10秒后超时
            $job = Start-Job { return winget list --accept-source-agreements --disable-interactivity }
            $jobDone = $job | Wait-Job -TimeOut 10

            if (-not $jobDone) {
                # 显示错误，表明脚本无法从 winget 获取应用列表
                [System.Windows.MessageBox]::Show('无法通过 winget 加载已安装应用的列表，某些应用可能不会显示在列表中。', '错误', 'Ok', 'Error')
            }
            else {
                # 将任务的输出（应用列表）添加到 $listOfApps
                $listOfApps = Receive-Job -Job $job
            }
        }

        # 遍历应用列表，逐个将项目添加到 selectionBox
        Foreach ($app in (Get-Content -Path $appsFile | Where-Object { $_ -notmatch '^\s*$' -and $_ -notmatch '^# .*' -and $_ -notmatch '^# -* #' } )) {
            $appChecked = $true

            # 如果应用名称以 # 开头，则移除它并将 appChecked 设置为 false
            if ($app.StartsWith('#')) {
                $app = $app.TrimStart("#")
                $appChecked = $false
            }

            # 从应用名称中移除所有注释
            if (-not ($app.IndexOf('#') -eq -1)) {
                $app = $app.Substring(0, $app.IndexOf('#'))
            }

            # 移除应用名称开头和结尾的空格以及 `*` 字符
            $app = $app.Trim()
            $appString = $app.Trim('*')

            # 确保 appString 不为空
            if ($appString.length -gt 0) {
                if ($onlyInstalledCheckBox.Checked) {
                    # 如果 onlyInstalledCheckBox 被选中，则在将应用添加到 selectionBox 之前检查它是否已安装
                    if (-not ($listOfApps -like ("*$appString*")) -and -not (Get-AppxPackage -Name $app)) {
                        # 应用未安装，继续处理下一个项目
                        continue
                    }
                    if (($appString -eq "Microsoft.Edge") -and -not ($listOfApps -like "* Microsoft.Edge *")) {
                        # 应用未安装，继续处理下一个项目
                        continue
                    }
                }

                # 将应用添加到 selectionBox 并设置其选中状态
                $selectionBox.Items.Add($appString, $appChecked) | Out-Null
            }
        }

        # 隐藏加载指示器
        $loadingLabel.Visible = $False

        # 按字母顺序对 selectionBox 进行排序
        $selectionBox.Sorted = $True
    }

    $form.Text = "Win11Debloat 应用程序选择"
    $form.Name = "appSelectionForm"
    $form.DataBindings.DefaultDataSourceUpdateMode = 0
    $form.ClientSize = New-Object System.Drawing.Size(400,502)
    $form.FormBorderStyle = 'FixedDialog'
    $form.MaximizeBox = $False

    $button1.TabIndex = 4
    $button1.Name = "saveButton"
    $button1.UseVisualStyleBackColor = $True
    $button1.Text = "确认"
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
    $label.Text = '勾选您希望移除的应用，取消勾选您希望保留的应用'

    $form.Controls.Add($label)

    $loadingLabel.Location = New-Object System.Drawing.Point(16,46)
    $loadingLabel.Size = New-Object System.Drawing.Size(300,418)
    $loadingLabel.Text = '正在加载应用...'
    $loadingLabel.BackColor = "White"
    $loadingLabel.Visible = $false

    $form.Controls.Add($loadingLabel)

    $onlyInstalledCheckBox.TabIndex = 6
    $onlyInstalledCheckBox.Location = New-Object System.Drawing.Point(230,474)
    $onlyInstalledCheckBox.Size = New-Object System.Drawing.Size(150,20)
    $onlyInstalledCheckBox.Text = '仅显示已安装的应用'
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

    # 保存表单的初始状态
    $initialFormWindowState = $form.WindowState

    # 将应用加载到 selectionBox 中
    $form.add_Load($load_Apps)

    # 表单打开时聚焦 selectionBox
    $form.Add_Shown({$form.Activate(); $selectionBox.Focus()})

    # 显示表单
    return $form.ShowDialog()
}


# 返回指定文件中的应用列表，它会修剪应用名称并移除所有注释
function ReadAppslistFromFile {
    param (
        $appsFilePath
    )

    $appsList = @()

    # 从提供的路径文件中获取应用列表，并逐一移除
    Foreach ($app in (Get-Content -Path $appsFilePath | Where-Object { $_ -notmatch '^#.*' -and $_ -notmatch '^\s*$' } )) {
        # 从应用名称中移除所有注释
        if (-not ($app.IndexOf('#') -eq -1)) {
            $app = $app.Substring(0, $app.IndexOf('#'))
        }

        # 移除应用名称之前和之后的任何空格
        $app = $app.Trim()

        $appString = $app.Trim('*')
        $appsList += $appString
    }

    return $appsList
}


# 移除函数调用期间指定的所有用户账户和操作系统镜像中的应用。
function RemoveApps {
    param (
        $appslist
    )

    Foreach ($app in $appsList) {
        Write-Output "正在尝试移除 $app..."

        if (($app -eq "Microsoft.OneDrive") -or ($app -eq "Microsoft.Edge")) {
            # 使用 winget 移除 OneDrive 和 Edge
            if ($script:wingetInstalled -eq $false) {
                Write-Host "错误: WinGet 未安装或已过时，无法移除 $app" -ForegroundColor Red
            }
            else {
                # 通过 winget 卸载应用
                Strip-Progress -ScriptBlock { winget uninstall --accept-source-agreements --disable-interactivity --id $app } | Tee-Object -Variable wingetOutput

                If (($app -eq "Microsoft.Edge") -and (Select-String -InputObject $wingetOutput -Pattern "Uninstall failed with exit code")) {
                    Write-Host "无法通过 Winget 卸载 Microsoft Edge" -ForegroundColor Red
                    Write-Output ""

                    if ($( Read-Host -Prompt "您想强制卸载 Edge 吗？不推荐！ (y/n)" ) -eq 'y') {
                        Write-Output ""
                        ForceRemoveEdge
                    }
                }
            }
        }
        else {
            # 使用 Remove-AppxPackage 移除所有其他应用
            $app = '*' + $app + '*'

            # 为所有现有用户移除已安装的应用
            if ($WinVersion -ge 22000) {
                # Windows 11 版本 22000 或更高
                try {
                    Get-AppxPackage -Name $app -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction Continue

                    if ($DebugPreference -ne "SilentlyContinue") {
                        Write-Host "已为所有用户移除 $app" -ForegroundColor DarkGray
                    }
                }
                catch {
                    if ($DebugPreference -ne "SilentlyContinue") {
                        Write-Host "无法为所有用户移除 $app" -ForegroundColor Yellow
                        Write-Host $psitem.Exception.StackTrace -ForegroundColor Gray
                    }
                }
            }
            else {
                # Windows 10
                try {
                    Get-AppxPackage -Name $app | Remove-AppxPackage -ErrorAction SilentlyContinue

                    if ($DebugPreference -ne "SilentlyContinue") {
                        Write-Host "已为当前用户移除 $app" -ForegroundColor DarkGray
                    }
                }
                catch {
                    if ($DebugPreference -ne "SilentlyContinue") {
                        Write-Host "无法为当前用户移除 $app" -ForegroundColor Yellow
                        Write-Host $psitem.Exception.StackTrace -ForegroundColor Gray
                    }
                }

                try {
                    Get-AppxPackage -Name $app -PackageTypeFilter Main, Bundle, Resource -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue

                    if ($DebugPreference -ne "SilentlyContinue") {
                        Write-Host "已为所有用户移除 $app" -ForegroundColor DarkGray
                    }
                }
                catch {
                    if ($DebugPreference -ne "SilentlyContinue") {
                        Write-Host "无法为所有用户移除 $app" -ForegroundColor Yellow
                        Write-Host $psitem.Exception.StackTrace -ForegroundColor Gray
                    }
                }
            }

            # 从操作系统镜像中移除已预配的应用，以便新用户不会安装该应用
            try {
                Get-AppxProvisionedPackage -Online | Where-Object { $_.PackageName -like $app } | ForEach-Object { Remove-ProvisionedAppxPackage -Online -AllUsers -PackageName $_.PackageName }
            }
            catch {
                Write-Host "无法从 windows 镜像中移除 $app" -ForegroundColor Yellow
                Write-Host $psitem.Exception.StackTrace -ForegroundColor Gray
            }
        }
        Write-Output ""
    }
}


# 使用 Edge 卸载程序强制移除 Microsoft Edge
function ForceRemoveEdge {
    # 基于 loadstring1 和 ave9858 的工作
    Write-Output "> 正在强制卸载 Microsoft Edge..."

    $regView = [Microsoft.Win32.RegistryView]::Registry32
    $hklm = [Microsoft.Win32.RegistryKey]::OpenBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine, $regView)
    $hklm.CreateSubKey('SOFTWARE\Microsoft\EdgeUpdateDev').SetValue('AllowUninstall', '')

    # 创建存根（创建此文件可以卸载 Edge）
    $edgeStub = "$env:SystemRoot\SystemApps\Microsoft.MicrosoftEdge_8wekyb3d8bbwe"
    New-Item $edgeStub -ItemType Directory | Out-Null
    New-Item "$edgeStub\MicrosoftEdge.exe" | Out-Null

    # 移除 Edge
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
                Write-Host "  已移除 $path" -ForegroundColor DarkGray
            }
        }

        Write-Output "正在清理注册表..."

        # 从自动启动中移除 MS Edge
        reg delete "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run" /v "MicrosoftEdgeAutoLaunch_A9F6DCE4ABADF4F51CF45CD7129E3C6C" /f *>$null
        reg delete "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run" /v "Microsoft Edge Update" /f *>$null
        reg delete "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run" /v "MicrosoftEdgeAutoLaunch_A9F6DCE4ABADF4F51CF45CD7129E3C6C" /f *>$null
        reg delete "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run" /v "Microsoft Edge Update" /f *>$null

        Write-Output "Microsoft Edge 已卸载"
    }
    else {
        Write-Output ""
        Write-Host "错误: 无法强制卸载 Microsoft Edge，找不到卸载程序" -ForegroundColor Red
    }

    Write-Output ""
}


# 执行提供的命令并从控制台输出中剥离进度旋转器/条
function Strip-Progress {
    param(
        [ScriptBlock]$ScriptBlock
    )

    # 匹配旋转字符和进度条模式的正则表达式
    $progressPattern = 'Γû[Æê]|^\s+[-\\|/]\s+$'

    # 用于大小格式的修正正则表达式，确保正确捕获组
    $sizePattern = '(\d+(\.\d{1,2})?)\s+(B|KB|MB|GB|TB|PB) /\s+(\d+(\.\d{1,2})?)\s+(B|KB|MB|GB|TB|PB)'

    & $ScriptBlock 2>&1 | ForEach-Object {
        if ($_ -is [System.Management.Automation.ErrorRecord]) {
            "错误: $($_.Exception.Message)"
        } else {
            $line = $_ -replace $progressPattern, '' -replace $sizePattern, ''
            if (-not ([string]::IsNullOrWhiteSpace($line)) -and -not ($line.StartsWith('  '))) {
                $line
            }
        }
    }
}


# 检查此机器是否支持 S0 现代待机电源状态。如果支持 S0 现代待机则返回 true，否则返回 false。
function CheckModernStandbySupport {
    $count = 0

    try {
        switch -Regex (powercfg /a) {
            ':' {
                $count += 1
            }

            '(.*S0.{1,}\))' {
                if ($count -eq 1) {
                    return $true
                }
            }
        }
    }
    catch {
        Write-Host "错误: 无法检查 S0 现代待机支持，powercfg 命令失败" -ForegroundColor Red
        Write-Host ""
        Write-Host "按任意键继续..."
        $null = [System.Console]::ReadKey()
        return $true
    }

    return $false
}


# 返回指定用户的目录路径，如果找不到用户路径则退出脚本
function GetUserDirectory {
    param (
        $userName,
        $fileName = "",
        $exitIfPathNotFound = $true
    )

    $userDirectoryExists = Test-Path "$env:SystemDrive\Users\$userName"
    $userPath = "$env:SystemDrive\Users\$userName\$fileName"

    if ((Test-Path $userPath) -or ($userDirectoryExists -and (-not $exitIfPathNotFound))) {
        return $userPath
    }

    $userDirectoryExists = Test-Path $env:USERPROFILE -Replace ('\\' + $env:USERNAME + '$'), "\$userName"
    $userPath = $env:USERPROFILE -Replace ('\\' + $env:USERNAME + '$'), "\$userName\$fileName"

    if ((Test-Path $userPath) -or ($userDirectoryExists -and (-not $exitIfPathNotFound))) {
        return $userPath
    }

    Write-Host "错误: 找不到用户 $userName 的用户目录路径" -ForegroundColor Red
    AwaitKeyToExit
}

# Import & execute regfile
function RegImport {
    param (
        $message,
        $path
    )

    Write-Output $message

    if ($script:Params.ContainsKey("Sysprep")) {
        $defaultUserPath = GetUserDirectory -userName "Default" -fileName "NTUSER.DAT"
        
        reg load "HKU\Default" $defaultUserPath | Out-Null
        reg import "$PSScriptRoot\Regfiles\Sysprep\$path"
        reg unload "HKU\Default" | Out-Null
    }
    elseif ($script:Params.ContainsKey("User")) {
        $userPath = GetUserDirectory -userName $script:Params.Item("User") -fileName "NTUSER.DAT"
        
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

    Write-Output "> 重新啟動 Windows 檔案總管以應用所有變更... (這可能會導致一些閃爍)"

    if ($script:Params.ContainsKey("DisableMouseAcceleration")) {
        Write-Host "警告: 增強指標精確度設定變更將在重新啟動後生效" -ForegroundColor Yellow
    }

    if ($script:Params.ContainsKey("DisableStickyKeys")) {
        Write-Host "警告: 黏滯鍵設定變更將在重新啟動後生效" -ForegroundColor Yellow
    }

    if ($script:Params.ContainsKey("DisableAnimations")) {
        Write-Host "警告: 動畫將在重新啟動後停用" -ForegroundColor Yellow
    }

    # Only restart if the powershell process matches the OS architecture.
    # Restarting explorer from a 32bit PowerShell window will fail on a 64bit OS
    if ([Environment]::Is64BitProcess -eq [Environment]::Is64BitOperatingSystem) {
        Stop-Process -processName: Explorer -Force
    }
    else {
        Write-Warning "無法重新啟動 Windows 檔案總管，請手動重新啟動電腦以應用所有變更。"
    }
}


# Replace the startmenu for all users, when using the default startmenuTemplate this clears all pinned apps
# Credit: https://lazyadmin.nl/win-11/customize-windows-11-start-menu-layout/
function ReplaceStartMenuForAllUsers {
    param (
        $startMenuTemplate = "$PSScriptRoot/Assets/Start/start2.bin"
    )

    Write-Output "> 從所有使用者的開始選單中移除所有固定的應用程式..."

    # Check if template bin file exists, return early if it doesn't
    if (-not (Test-Path $startMenuTemplate)) {
        Write-Host "錯誤: 無法清除開始選單，腳本資料夾中缺少 start2.bin 檔案" -ForegroundColor Red
        Write-Output ""
        return
    }

    # Get path to start menu file for all users
    $userPathString = GetUserDirectory -userName "*" -fileName "AppData\Local\Packages\Microsoft.Windows.StartMenuExperienceHost_cw5n1h2txyewy\LocalState"
    $usersStartMenuPaths = get-childitem -path $userPathString

    # Go through all users and replace the start menu file
    ForEach ($startMenuPath in $usersStartMenuPaths) {
        ReplaceStartMenu $startMenuTemplate "$($startMenuPath.Fullname)\start2.bin"
    }

    # Also replace the start menu file for the default user profile
    $defaultStartMenuPath = GetUserDirectory -userName "Default" -fileName "AppData\Local\Packages\Microsoft.Windows.StartMenuExperienceHost_cw5n1h2txyewy\LocalState" -exitIfPathNotFound $false

    # Create folder if it doesn't exist
    if (-not (Test-Path $defaultStartMenuPath)) {
        new-item $defaultStartMenuPath -ItemType Directory -Force | Out-Null
        Write-Output "已為預設使用者設定檔建立 LocalState 資料夾"
    }

    # Copy template to default profile
    Copy-Item -Path $startMenuTemplate -Destination $defaultStartMenuPath -Force
    Write-Output "已替換預設使用者設定檔的開始選單"
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
        $startMenuBinFile = GetUserDirectory -userName "$(GetUserName)" -fileName "AppData\Local\Packages\Microsoft.Windows.StartMenuExperienceHost_cw5n1h2txyewy\LocalState\start2.bin"
    }

    # Check if template bin file exists, return early if it doesn't
    if (-not (Test-Path $startMenuTemplate)) {
        Write-Host "錯誤: 無法替換開始選單，找不到範本檔案" -ForegroundColor Red
        return
    }

    if ([IO.Path]::GetExtension($startMenuTemplate) -ne ".bin" ) {
        Write-Host "錯誤: 無法替換開始選單，範本檔案不是有效的 .bin 檔案" -ForegroundColor Red
        return
    }

    $userName = [regex]::Match($startMenuBinFile, '(?:Users\\)([^\\]+)(?:\\AppData)').Groups[1].Value

    # Check if bin file exists, return early if it doesn't
    if (-not (Test-Path $startMenuBinFile)) {
        Write-Host "錯誤: 無法替換使用者 $userName 的開始選單，找不到原始的 start2.bin 檔案" -ForegroundColor Red
        return
    }

    $backupBinFile = $startMenuBinFile + ".bak"

    # Backup current start menu file
    Move-Item -Path $startMenuBinFile -Destination $backupBinFile -Force

    # Copy template file
    Copy-Item -Path $startMenuTemplate -Destination $startMenuBinFile -Force

    Write-Output "已替換使用者 $userName 的開始選單"
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

    $fullTitle = " Win11Debloat Script - $title"

    if ($script:Params.ContainsKey("Sysprep")) {
        $fullTitle = "$fullTitle (Sysprep 模式)"
    }
    else {
        $fullTitle = "$fullTitle (使用者: $(GetUserName))"
    }

    Clear-Host
    Write-Output "-------------------------------------------------------------------------------------------"
    Write-Output $fullTitle
    Write-Output "-------------------------------------------------------------------------------------------"
}


function PrintFromFile {
    param (
        $path,
        $title,
        $printHeader = $true
    )

    if ($printHeader) {
        Clear-Host

        PrintHeader $title
    }

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
    Write-Output "> 嘗試建立系統還原點..."
    
    $SysRestore = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SystemRestore" -Name "RPSessionInterval"

    if ($SysRestore.RPSessionInterval -eq 0) {
        if ($Silent -or $( Read-Host -Prompt "系統還原已停用，您想啟用它並建立一個還原點嗎? (y/n)") -eq 'y') {
            $enableSystemRestoreJob = Start-Job { 
                try {
                    Enable-ComputerRestore -Drive "$env:SystemDrive"
                } catch {
                    Write-Host "錯誤: 無法啟用系統還原: $_" -ForegroundColor Red
                    Write-Output ""
                    return
                }
            }
    
            $enableSystemRestoreJobDone = $enableSystemRestoreJob | Wait-Job -TimeOut 20

            if (-not $enableSystemRestoreJobDone) {
                Write-Host "錯誤: 無法啟用系統還原並建立還原點，操作逾時" -ForegroundColor Red
                Write-Output ""
                Write-Output "按任意鍵繼續..."
                $null = [System.Console]::ReadKey()
                return
            } else {
                Receive-Job $enableSystemRestoreJob
            }
        } else {
            Write-Output ""
            return
        }
    }

    $createRestorePointJob = Start-Job { 
        # Find existing restore points that are less than 24 hours old
        try {
            $recentRestorePoints = Get-ComputerRestorePoint | Where-Object { (Get-Date) - [System.Management.ManagementDateTimeConverter]::ToDateTime($_.CreationTime) -le (New-TimeSpan -Hours 24) }
        } catch {
            Write-Host "錯誤: 無法擷取現有的還原點: $_" -ForegroundColor Red
            Write-Output ""
            return
        }
    
        if ($recentRestorePoints.Count -eq 0) {
            try {
                Checkpoint-Computer -Description "由 Win11Debloat 建立的還原點" -RestorePointType "MODIFY_SETTINGS"
                Write-Output "系統還原點已成功建立"
            } catch {
                Write-Host "錯誤: 無法建立還原點: $_" -ForegroundColor Red
            }
        } else {
            Write-Host "最近已存在還原點，未建立新的還原點。" -ForegroundColor Yellow
        }
    }
    
    $createRestorePointJobDone = $createRestorePointJob | Wait-Job -TimeOut 20

    if (-not $createRestorePointJobDone) {
        Write-Host "錯誤: 無法建立系統還原點，操作逾時" -ForegroundColor Red
        Write-Output ""
        Write-Output "按任意鍵繼續..."
        $null = [System.Console]::ReadKey()
    } else {
        Receive-Job $createRestorePointJob
    }

    Write-Output ""
}


function DisplayCustomModeOptions {
    # Get current Windows build version to compare against features
    $WinVersion = Get-ItemPropertyValue 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' CurrentBuild
            
    PrintHeader '自訂模式'

    AddParameter 'CreateRestorePoint' '建立系統還原點'

    # Show options for removing apps, only continue on valid input
    Do {
        Write-Host "選項:" -ForegroundColor Yellow
        Write-Host " (n) 不移除任何應用程式" -ForegroundColor Yellow
        Write-Host " (1) 僅移除 'Appslist.txt' 中的預設臃腫軟體應用程式" -ForegroundColor Yellow
        Write-Host " (2) 移除預設臃腫軟體、郵件與日曆、開發者和遊戲應用程式"  -ForegroundColor Yellow
        Write-Host " (3) 手動選擇要移除的應用程式" -ForegroundColor Yellow
        $RemoveAppsInput = Read-Host "您想移除任何應用程式嗎? 應用程式將為所有使用者移除 (n/1/2/3)"

        # Show app selection form if user entered option 3
        if ($RemoveAppsInput -eq '3') {
            $result = ShowAppSelectionForm

            if ($result -ne [System.Windows.Forms.DialogResult]::OK) {
                # User cancelled or closed app selection, show error and change RemoveAppsInput so the menu will be shown again
                Write-Output ""
                Write-Host "已取消應用程式選擇，請重試" -ForegroundColor Red

                $RemoveAppsInput = 'c'
            }
            
            Write-Output ""
        }
    }
    while ($RemoveAppsInput -ne 'n' -and $RemoveAppsInput -ne '0' -and $RemoveAppsInput -ne '1' -and $RemoveAppsInput -ne '2' -and $RemoveAppsInput -ne '3') 

    # Select correct option based on user input
    switch ($RemoveAppsInput) {
        '1' {
            AddParameter 'RemoveApps' '移除預設的臃腫軟體應用程式'
        }
        '2' {
            AddParameter 'RemoveApps' '移除預設的臃腫軟體應用程式'
            AddParameter 'RemoveCommApps' '移除郵件、日曆和人脈應用程式'
            AddParameter 'RemoveW11Outlook' '移除新的 Windows Outlook 應用程式'
            AddParameter 'RemoveDevApps' '移除開發者相關的應用程式'
            AddParameter 'RemoveGamingApps' '移除 Xbox 應用程式和 Xbox Gamebar'
            AddParameter 'DisableDVR' '停用 Xbox 遊戲/螢幕錄製'
        }
        '3' {
            Write-Output "您已選擇移除 $($script:SelectedApps.Count) 個應用程式"

            AddParameter 'RemoveAppsCustom' "移除 $($script:SelectedApps.Count) 個應用程式:"

            Write-Output ""

            if ($( Read-Host -Prompt "停用 Xbox 遊戲/螢幕錄製嗎? 這也會停止遊戲覆蓋彈出視窗 (y/n)" ) -eq 'y') {
                AddParameter 'DisableDVR' '停用 Xbox 遊戲/螢幕錄製'
            }
        }
    }

    Write-Output ""

    if ($( Read-Host -Prompt "停用遙測、診斷資料、活動歷史記錄、應用程式啟動追蹤和定向廣告嗎? (y/n)" ) -eq 'y') {
        AddParameter 'DisableTelemetry' '停用遙測、診斷資料、活動歷史記錄、應用程式啟動追蹤和定向廣告'
    }

    Write-Output ""

    if ($( Read-Host -Prompt "停用開始選單、設定、通知、檔案總管、鎖定畫面和 Edge 中的提示、技巧、建議和廣告嗎? (y/n)" ) -eq 'y') {
        AddParameter 'DisableSuggestions' '停用開始選單、設定、通知和檔案總管中的提示、技巧、建議和廣告'
        AddParameter 'DisableEdgeAds' '停用 Microsoft Edge 中的廣告、建議和 MSN 新聞摘要'
        AddParameter 'DisableSettings365Ads' '停用設定首頁中的 Microsoft 365 廣告'
        AddParameter 'DisableLockscreenTips' '停用鎖定畫面上的提示和技巧'
    }

    Write-Output ""

    if ($( Read-Host -Prompt "停用並從 Windows 搜尋中移除 Bing 網路搜尋、Bing AI 和 Cortana 嗎? (y/n)" ) -eq 'y') {
        AddParameter 'DisableBing' '停用並從 Windows 搜尋中移除 Bing 網路搜尋、Bing AI 和 Cortana'
    }

    # Only show this option for Windows 11 users running build 22621 or later
    if ($WinVersion -ge 22621) {
        Write-Output ""

        # Show options for disabling/removing AI features, only continue on valid input
        Do {
            Write-Host "選項:" -ForegroundColor Yellow
            Write-Host " (n) 不停用任何 AI 功能" -ForegroundColor Yellow
            Write-Host " (1) 停用 Microsoft Copilot 和 Windows Recall 快照" -ForegroundColor Yellow
            Write-Host " (2) 停用 Microsoft Copilot、Windows Recall 快照以及 Microsoft Edge、小畫家和記事本中的 AI 功能"  -ForegroundColor Yellow
            $DisableAIInput = Read-Host "您想停用任何 AI 功能嗎? 這適用於所有使用者 (n/1/2)"
        }
        while ($DisableAIInput -ne 'n' -and $DisableAIInput -ne '0' -and $DisableAIInput -ne '1' -and $DisableAIInput -ne '2') 

        # Select correct option based on user input
        switch ($DisableAIInput) {
            '1' {
                AddParameter 'DisableCopilot' '停用並移除 Microsoft Copilot'
                AddParameter 'DisableRecall' '停用 Windows Recall 快照'
            }
            '2' {
                AddParameter 'DisableCopilot' '停用並移除 Microsoft Copilot'
                AddParameter 'DisableRecall' '停用 Windows Recall 快照'
                AddParameter 'DisableEdgeAI' '停用 Edge 中的 AI 功能'
                AddParameter 'DisablePaintAI' '停用小畫家中的 AI 功能'
                AddParameter 'DisableNotepadAI' '停用記事本中的 AI 功能'
            }
        }
    }

    Write-Output ""

    if ($( Read-Host -Prompt "停用桌面上的 Windows 焦點背景嗎? (y/n)" ) -eq 'y') {
        AddParameter 'DisableDesktopSpotlight' '停用 Windows 焦點桌面背景選項。'
    }

    Write-Output ""

    if ($( Read-Host -Prompt "為系統和應用程式啟用深色模式嗎? (y/n)" ) -eq 'y') {
        AddParameter 'EnableDarkMode' '為系統和應用程式啟用深色模式'
    }

    Write-Output ""

    if ($( Read-Host -Prompt "停用透明度、動畫和視覺效果嗎? (y/n)" ) -eq 'y') {
        AddParameter 'DisableTransparency' '停用透明度效果'
        AddParameter 'DisableAnimations' '停用動畫和視覺效果'
    }

    # Only show this option for Windows 11 users running build 22000 or later
    if ($WinVersion -ge 22000) {
        Write-Output ""

        if ($( Read-Host -Prompt "還原舊的 Windows 10 樣式右鍵選單嗎? (y/n)" ) -eq 'y') {
            AddParameter 'RevertContextMenu' '還原舊的 Windows 10 樣式右鍵選單'
        }
    }

    Write-Output ""

    if ($( Read-Host -Prompt "關閉「增強指標精確度」，也稱為滑鼠加速嗎? (y/n)" ) -eq 'y') {
        AddParameter 'DisableMouseAcceleration' '關閉增強指標精確度 (滑鼠加速)'
    }

    # Only show this option for Windows 11 users running build 26100 or later
    if ($WinVersion -ge 26100) {
        Write-Output ""

        if ($( Read-Host -Prompt "停用「黏滯鍵」鍵盤快捷鍵嗎? (y/n)" ) -eq 'y') {
            AddParameter 'DisableStickyKeys' '停用「黏滯鍵」鍵盤快捷鍵'
        }
    }

    Write-Output ""

    if ($( Read-Host -Prompt "停用快速啟動嗎? 這適用於所有使用者 (y/n)" ) -eq 'y') {
        AddParameter 'DisableFastStartup' '停用快速啟動'
    }

    # Only show this option for Windows 11 users running build 22000 or later, and if the machine has at least one battery
    if (($WinVersion -ge 22000) -and $script:ModernStandbySupported) {
        Write-Output ""

        if ($( Read-Host -Prompt "在現代待機期間停用網路連線嗎? 這適用於所有使用者 (y/n)" ) -eq 'y') {
            AddParameter 'DisableModernStandbyNetworking' '在現代待機期間停用網路連線'
        }
    }

    # Only show option for disabling context menu items for Windows 10 users or if the user opted to restore the Windows 10 context menu
    if ((get-ciminstance -query "select caption from win32_operatingsystem where caption like '%Windows 10%'") -or $script:Params.ContainsKey('RevertContextMenu')) {
        Write-Output ""

        if ($( Read-Host -Prompt "您想停用任何右鍵選單選項嗎? (y/n)" ) -eq 'y') {
            Write-Output ""

            if ($( Read-Host -Prompt "     隱藏右鍵選單中的「包含在媒體櫃中」選項嗎? (y/n)" ) -eq 'y') {
                AddParameter 'HideIncludeInLibrary' "隱藏右鍵選單中的「包含在媒體櫃中」選項"
            }

            Write-Output ""

            if ($( Read-Host -Prompt "     隱藏右鍵選單中的「授予存取權」選項嗎? (y/n)" ) -eq 'y') {
                AddParameter 'HideGiveAccessTo' "隱藏右鍵選單中的「授予存取權」選項"
            }

            Write-Output ""

            if ($( Read-Host -Prompt "     隱藏右鍵選單中的「共用」選項嗎? (y/n)" ) -eq 'y') {
                AddParameter 'HideShare' "隱藏右鍵選單中的「共用」選項"
            }
        }
    }

    # Only show this option for Windows 11 users running build 22621 or later
    if ($WinVersion -ge 22621) {
        Write-Output ""

        if ($( Read-Host -Prompt "您想對開始選單進行任何變更嗎? (y/n)" ) -eq 'y') {
            Write-Output ""

            if ($script:Params.ContainsKey("Sysprep")) {
                if ($( Read-Host -Prompt "從所有現有和新使用者的開始選單中移除所有固定的應用程式嗎? (y/n)" ) -eq 'y') {
                    AddParameter 'ClearStartAllUsers' '從現有和新使用者的開始選單中移除所有固定的應用程式'
                }
            }
            else {
                Do {
                    Write-Host "     選項:" -ForegroundColor Yellow
                    Write-Host "     (n) 不從開始選單中移除任何固定的應用程式" -ForegroundColor Yellow
                    Write-Host "     (1) 僅從此使用者 ($(GetUserName)) 的開始選單中移除所有固定的應用程式" -ForegroundColor Yellow
                    Write-Host "     (2) 從所有現有和新使用者的開始選單中移除所有固定的應用程式"  -ForegroundColor Yellow
                    $ClearStartInput = Read-Host "     移除開始選單中所有固定的應用程式嗎? (n/1/2)" 
                }
                while ($ClearStartInput -ne 'n' -and $ClearStartInput -ne '0' -and $ClearStartInput -ne '1' -and $ClearStartInput -ne '2') 

                # Select correct option based on user input
                switch ($ClearStartInput) {
                    '1' {
                        AddParameter 'ClearStart' "僅從此使用者的開始選單中移除所有固定的應用程式"
                    }
                    '2' {
                        AddParameter 'ClearStartAllUsers' "從所有現有和新使用者的開始選單中移除所有固定的應用程式"
                    }
                }
            }

            Write-Output ""

            if ($( Read-Host -Prompt "     停用開始選單中的建議區段嗎? 這適用於所有使用者 (y/n)" ) -eq 'y') {
                AddParameter 'DisableStartRecommended' '停用開始選單中的建議區段。'
            }

            Write-Output ""

            if ($( Read-Host -Prompt "     停用開始選單中的「電話連結」行動裝置整合嗎? (y/n)" ) -eq 'y') {
                AddParameter 'DisableStartPhoneLink' '停用開始選單中的「電話連結」行動裝置整合。'
            }
        }
    }

    Write-Output ""

    if ($( Read-Host -Prompt "您想對工作列和相關服務進行任何變更嗎? (y/n)" ) -eq 'y') {
        # Only show these specific options for Windows 11 users running build 22000 or later
        if ($WinVersion -ge 22000) {
            Write-Output ""

            if ($( Read-Host -Prompt "     將工作列按鈕靠左對齊嗎? (y/n)" ) -eq 'y') {
                AddParameter 'TaskbarAlignLeft' '將工作列圖示靠左對齊'
            }

            # Show options for search icon on taskbar, only continue on valid input
            Do {
                Write-Output ""
                Write-Host "     選項:" -ForegroundColor Yellow
                Write-Host "     (n) 無變更" -ForegroundColor Yellow
                Write-Host "     (1) 從工作列隱藏搜尋圖示" -ForegroundColor Yellow
                Write-Host "     (2) 在工作列上顯示搜尋圖示" -ForegroundColor Yellow
                Write-Host "     (3) 在工作列上顯示帶有標籤的搜尋圖示" -ForegroundColor Yellow
                Write-Host "     (4) 在工作列上顯示搜尋方塊" -ForegroundColor Yellow
                $TbSearchInput = Read-Host "     隱藏或變更工作列上的搜尋圖示嗎? (n/1/2/3/4)" 
            }
            while ($TbSearchInput -ne 'n' -and $TbSearchInput -ne '0' -and $TbSearchInput -ne '1' -and $TbSearchInput -ne '2' -and $TbSearchInput -ne '3' -and $TbSearchInput -ne '4') 

            # Select correct taskbar search option based on user input
            switch ($TbSearchInput) {
                '1' {
                    AddParameter 'HideSearchTb' '從工作列隱藏搜尋圖示'
                }
                '2' {
                    AddParameter 'ShowSearchIconTb' '在工作列上顯示搜尋圖示'
                }
                '3' {
                    AddParameter 'ShowSearchLabelTb' '在工作列上顯示帶有標籤的搜尋圖示'
                }
                '4' {
                    AddParameter 'ShowSearchBoxTb' '在工作列上顯示搜尋方塊'
                }
            }

            Write-Output ""

            if ($( Read-Host -Prompt "     從工作列隱藏「工作檢視」按鈕嗎? (y/n)" ) -eq 'y') {
                AddParameter 'HideTaskview' '從工作列隱藏「工作檢視」按鈕'
            }
        }

        Write-Output ""

        if ($( Read-Host -Prompt "     停用小工具服務以從工作列和鎖定畫面移除小工具嗎? (y/n)" ) -eq 'y') {
            AddParameter 'DisableWidgets' '從工作列和鎖定畫面停用小工具'
        }

        # Only show this options for Windows users running build 22621 or earlier
        if ($WinVersion -le 22621) {
            Write-Output ""

            if ($( Read-Host -Prompt "     從工作列隱藏「聊天 (立即開會)」圖示嗎? (y/n)" ) -eq 'y') {
                AddParameter 'HideChat' '從工作列隱藏「聊天 (立即開會)」圖示'
            }
        }
        
        # Only show this options for Windows users running build 22631 or later
        if ($WinVersion -ge 22631) {
            Write-Output ""

            if ($( Read-Host -Prompt "     在工作列右鍵選單中啟用「結束工作」選項嗎? (y/n)" ) -eq 'y') {
                AddParameter 'EnableEndTask' "在工作列右鍵選單中啟用「結束工作」選項"
            }
        }
        
        Write-Output ""
        if ($( Read-Host -Prompt "     在工作列應用程式區域中啟用「上次作用中點擊」行為嗎? (y/n)" ) -eq 'y') {
            AddParameter 'EnableLastActiveClick' "在工作列應用程式區域中啟用「上次作用中點擊」行為"
        }
    }

    Write-Output ""

    if ($( Read-Host -Prompt "您想對檔案總管進行任何變更嗎? (y/n)" ) -eq 'y') {
        # Show options for changing the File Explorer default location
        Do {
            Write-Output ""
            Write-Host "     選項:" -ForegroundColor Yellow
            Write-Host "     (n) 無變更" -ForegroundColor Yellow
            Write-Host "     (1) 將檔案總管開啟至「首頁」" -ForegroundColor Yellow
            Write-Host "     (2) 將檔案總管開啟至「本機」" -ForegroundColor Yellow
            Write-Host "     (3) 將檔案總管開啟至「下載」" -ForegroundColor Yellow
            Write-Host "     (4) 將檔案總管開啟至「OneDrive」" -ForegroundColor Yellow
            $ExplSearchInput = Read-Host "     變更檔案總管開啟時的預設位置嗎? (n/1/2/3/4)" 
        }
        while ($ExplSearchInput -ne 'n' -and $ExplSearchInput -ne '0' -and $ExplSearchInput -ne '1' -and $ExplSearchInput -ne '2' -and $ExplSearchInput -ne '3' -and $ExplSearchInput -ne '4') 

        # Select correct taskbar search option based on user input
        switch ($ExplSearchInput) {
            '1' {
                AddParameter 'ExplorerToHome' "將檔案總管開啟時的預設位置變更為「首頁」"
            }
            '2' {
                AddParameter 'ExplorerToThisPC' "將檔案總管開啟時的預設位置變更為「本機」"
            }
            '3' {
                AddParameter 'ExplorerToDownloads' "將檔案總管開啟時的預設位置變更為「下載」"
            }
            '4' {
                AddParameter 'ExplorerToOneDrive' "將檔案總管開啟時的預設位置變更為「OneDrive」"
            }
        }


Write-Output ""

# 如果用户选择“y”（是），则添加“ShowHiddenFolders”参数
if ($( Read-Host -Prompt "    显示隐藏的文件、文件夹和驱动器？ (y/n)" ) -eq 'y') {
    AddParameter 'ShowHiddenFolders' '显示隐藏的文件、文件夹和驱动器'
}

Write-Output ""

# 如果用户选择“y”，则添加“ShowKnownFileExt”参数
if ($( Read-Host -Prompt "    显示已知文件类型的文件扩展名？ (y/n)" ) -eq 'y') {
    AddParameter 'ShowKnownFileExt' '显示已知文件类型的文件扩展名'
}

# 仅对 Windows 11 版本 22000 或更高版本的用户显示此选项
if ($WinVersion -ge 22000) {
    Write-Output ""

    # 如果用户选择“y”，则添加“HideHome”参数
    if ($( Read-Host -Prompt "    从文件资源管理器侧边栏隐藏“主页”部分？ (y/n)" ) -eq 'y') {
        AddParameter 'HideHome' '从文件资源管理器侧边栏隐藏“主页”部分'
    }

    Write-Output ""

    # 如果用户选择“y”，则添加“HideGallery”参数
    if ($( Read-Host -Prompt "    从文件资源管理器侧边栏隐藏“图库”部分？ (y/n)" ) -eq 'y') {
        AddParameter 'HideGallery' '从文件资源管理器侧边栏隐藏“图库”部分'
    }
}

Write-Output ""

# 如果用户选择“y”，则添加“HideDupliDrive”参数
if ($( Read-Host -Prompt "    隐藏文件资源管理器侧边栏中重复的可移动驱动器条目，使其仅显示在“此电脑”下？ (y/n)" ) -eq 'y') {
    AddParameter 'HideDupliDrive' '隐藏文件资源管理器侧边栏中重复的可移动驱动器条目'
}

# 仅对 Windows 10 用户显示禁用这些特定文件夹的选项
if (get-ciminstance -query "select caption from win32_operatingsystem where caption like '%Windows 10%'") {
    Write-Output ""

    # 如果用户选择“y”，则询问是否要隐藏任何文件夹
    if ($( Read-Host -Prompt "您想从文件资源管理器侧边栏隐藏任何文件夹吗？ (y/n)" ) -eq 'y') {
        Write-Output ""

        # 如果用户选择“y”，则添加“HideOnedrive”参数
        if ($( Read-Host -Prompt "    从文件资源管理器侧边栏隐藏 OneDrive 文件夹？ (y/n)" ) -eq 'y') {
            AddParameter 'HideOnedrive' '在文件资源管理器侧边栏中隐藏 OneDrive 文件夹'
        }

        Write-Output ""

        # 如果用户选择“y”，则添加“Hide3dObjects”参数
        if ($( Read-Host -Prompt "    从文件资源管理器侧边栏隐藏“3D 对象”文件夹？ (y/n)" ) -eq 'y') {
            AddParameter 'Hide3dObjects' "在文件资源管理器“此电脑”下隐藏“3D 对象”文件夹"
        }

        Write-Output ""

        # 如果用户选择“y”，则添加“HideMusic”参数
        if ($( Read-Host -Prompt "    从文件资源管理器侧边栏隐藏“音乐”文件夹？ (y/n)" ) -eq 'y') {
            AddParameter 'HideMusic' "在文件资源管理器“此电脑”下隐藏“音乐”文件夹"
        }
    }
}

# 如果传递了“Silent”参数，则取消提示
if (-not $Silent) {
    Write-Output ""
    Write-Output ""
    Write-Output ""
    Write-Output "按 Enter 键确认您的选择并执行脚本，或按 CTRL+C 退出..."
    Read-Host | Out-Null
}

PrintHeader '自定义模式'
}

##################################################################################################################
#                                                                                                                #
#                                                  SCRIPT START                                                  #
#                                                                                                                #
##################################################################################################################



# 检查是否安装了 winget，如果安装了，检查版本是否至少为 v1.4
if ((Get-AppxPackage -Name "*Microsoft.DesktopAppInstaller*") -and ([int](((winget -v) -replace 'v','').split('.')[0..1] -join '') -gt 14)) {
    $script:wingetInstalled = $true
} else {
    $script:wingetInstalled = $false

    # 显示需要用户确认的警告，如果传递了“Silent”参数，则取消确认
    if (-not $Silent) {
        Write-Warning "Winget 未安装或已过时。这可能会阻止 Win11Debloat 删除某些应用程序。"
        Write-Output ""
        Write-Output "按任意键继续..."
        $null = [System.Console]::ReadKey()
    }
}

# 获取当前 Windows 内部版本号以与功能进行比较
$WinVersion = Get-ItemPropertyValue 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' CurrentBuild

# 检查计算机是否支持现代待机，这用于确定是否可以使用“DisableModernStandbyNetworking”选项
$script:ModernStandbySupported = CheckModernStandbySupport

$script:Params = $PSBoundParameters
$script:FirstSelection = $true
$SPParams = 'WhatIf', 'Confirm', 'Verbose', 'Silent', 'Sysprep', 'Debug', 'User', 'CreateRestorePoint', 'LogPath'
$SPParamCount = 0

# 计算 Params 中存在多少 SPParams
# 这稍后用于检查是否选择了任何选项
foreach ($Param in $SPParams) {
    if ($script:Params.ContainsKey($Param)) {
        $SPParamCount++
    }
}

# 隐藏应用程序移除的进度条，因为它们会阻塞 Win11Debloat 的输出
if (-not ($script:Params.ContainsKey("Verbose"))) {
    $ProgressPreference = 'SilentlyContinue'
} else {
    Write-Host "已启用详细模式"
    Write-Output ""
    Write-Output "按任意键继续..."
    $null = [System.Console]::ReadKey()

    $ProgressPreference = 'Continue'
}

if ($script:Params.ContainsKey("Sysprep")) {
    $defaultUserPath = GetUserDirectory -userName "Default"

    # 如果在 Windows 10 上以 Sysprep 模式运行，则退出脚本
    if ($WinVersion -lt 22000) {
        Write-Host "错误: Win11Debloat Sysprep 模式不支持 Windows 10" -ForegroundColor Red
        AwaitKeyToExit
    }
}

# 如果指定了“User”，则确保满足用户模式的所有要求
if ($script:Params.ContainsKey("User")) {
    $userPath = GetUserDirectory -userName $script:Params.Item("User")
}

# 如果“SavedSettings”文件存在且为空，则将其删除
if ((Test-Path "$PSScriptRoot/SavedSettings") -and ([String]::IsNullOrWhiteSpace((Get-content "$PSScriptRoot/SavedSettings")))) {
    Remove-Item -Path "$PSScriptRoot/SavedSettings" -recurse
}

# 仅在将“RunAppConfigurator”参数或“RunAppsListGenerator”参数传递给脚本时才运行应用程序选择表单
if ($RunAppConfigurator -or $RunAppsListGenerator) {
    PrintHeader "自定义应用程序列表生成器"

    $result = ShowAppSelectionForm

    # 根据应用程序选择是保存还是取消来显示不同的消息
    if ($result -ne [System.Windows.Forms.DialogResult]::OK) {
        Write-Host "应用程序选择窗口已关闭且未保存。" -ForegroundColor Red
    } else {
        Write-Output "您的应用程序选择已保存到 'CustomAppsList' 文件中，位于："
        Write-Host "$PSScriptRoot" -ForegroundColor Yellow
    }

    AwaitKeyToExit
}

# 根据提供的参数或用户输入更改脚本执行
if ((-not $script:Params.Count) -or $RunDefaults -or $RunDefaultsLite -or $RunSavedSettings -or ($SPParamCount -eq $script:Params.Count)) {
    if ($RunDefaults -or $RunDefaultsLite) {
        $Mode = '1'
    } elseif ($RunSavedSettings) {
        if (-not (Test-Path "$PSScriptRoot/SavedSettings")) {
            PrintHeader '自定义模式'
            Write-Host "错误: 未找到已保存的设置，未进行任何更改" -ForegroundColor Red
            AwaitKeyToExit
        }

        $Mode = '4'
    }
    else {
        # Show menu and wait for user input, loops until valid input is provided
        Do { 
            $ModeSelectionMessage = "Please select an option (1/2/3/0)" 

            PrintHeader '菜单'

            Write-Output "(1) 默认模式：快速应用推荐的更改"
            Write-Output "(2) 自定义模式：手动选择要进行的更改"
            Write-Output "(3) 应用程序移除模式：选择并移除应用程序，而不进行其他更改"

            # 仅在“SavedSettings”文件存在时显示此选项
            if (Test-Path "$PSScriptRoot/SavedSettings") {
                Write-Output "(4) 应用上次保存的自定义设置"

                $ModeSelectionMessage = "请选择一个选项 (1/2/3/4/0)"
            }

            Write-Output ""
            Write-Output "(0) 显示更多信息"
            Write-Output ""
            Write-Output ""

            $Mode = Read-Host $ModeSelectionMessage

            if ($Mode -eq '0') {
                # 从文件中打印信息屏幕
                PrintFromFile "$PSScriptRoot/Assets/Menus/Info" "信息"

                Write-Output "按任意键返回..."
                $null = [System.Console]::ReadKey()
            } elseif (($Mode -eq '4') -and -not (Test-Path "$PSScriptRoot/SavedSettings")) {
                $Mode = $null
            }
        }
        while ($Mode -ne '1' -and $Mode -ne '2' -and $Mode -ne '3' -and $Mode -ne '4')
    }

    # 根据模式添加执行参数
    switch ($Mode) {
        # 默认模式，确认后加载默认设置
        '1' {
            if (-not $script:Params.ContainsKey('CreateRestorePoint')) {
                $script:Params.Add('CreateRestorePoint', $true)
            }

            # 显示默认设置并进行确认，除非传递了“Silent”参数
            if (-not $Silent) {
                # 显示应用程序移除的选项
                if ((-not $RunDefaults) -and (-not $RunDefaultsLite)) {
                    PrintHeader '默认模式'

                    Do {
                        Write-Host "选项:" -ForegroundColor Yellow
                        Write-Host " (n) 不移除任何应用程序" -ForegroundColor Yellow
                        Write-Host " (1) 只移除默认选择的臃肿软件" -ForegroundColor Yellow
                        Write-Host " (2) 手动选择要移除的应用程序" -ForegroundColor Yellow
                        $RemoveAppsInput = Read-Host "您想移除任何应用程序吗？应用程序将为所有用户移除 (n/1/2)"

                        # 如果用户输入了选项 2，则显示应用程序选择表单
                        if ($RemoveAppsInput -eq '2') {
                            $result = ShowAppSelectionForm

                            if ($result -ne [System.Windows.Forms.DialogResult]::OK) {
                                # 用户取消或关闭了应用程序选择，显示错误并更改 RemoveAppsInput，以便再次显示菜单
                                Write-Output ""
                                Write-Host "已取消应用程序选择，请重试" -ForegroundColor Red

                                $RemoveAppsInput = 'c'
                            }

                            Write-Output ""
                        }
                    }
                    while ($RemoveAppsInput -ne 'n' -and $RemoveAppsInput -ne '0' -and $RemoveAppsInput -ne '1' -and $RemoveAppsInput -ne '2')
                } elseif ($RunDefaultsLite) {
                    $RemoveAppsInput = '0'
                } else {
                    $RemoveAppsInput = '1'
                }

                PrintHeader '默认模式'

                Write-Output "Win11Debloat 将进行以下更改："

                # 根据用户输入选择正确的选项
                switch ($RemoveAppsInput) {
                    '1' {
                        if (-not $script:Params.ContainsKey('RemoveApps')) {
                            $script:Params.Add('RemoveApps', $true)
                        }

                        Write-Output "- 移除默认选择的应用程序。"
                    }
                    '2' {
                        if (-not $script:Params.ContainsKey('RemoveAppsCustom')) {
                            $script:Params.Add('RemoveAppsCustom', $true)
                        }

                        Write-Output "- 移除您自定义选择的 $($script:SelectedApps.Count) 个应用程序。"
                    }
                }

                PrintFromFile "$PSScriptRoot/Assets/Menus/DefaultSettings" "默认模式" $false

                Write-Output "按 Enter 键执行脚本，或按 CTRL+C 退出..."
                Read-Host | Out-Null
            }

            $DefaultParameterNames = 'DisableTelemetry','DisableBing','DisableLockscreenTips','DisableSuggestions','DisableEdgeAds','ShowKnownFileExt','DisableWidgets','HideChat','DisableFastStartup','DisableCopilot'

            PrintHeader '默认模式'

            # 添加默认参数，如果它们尚不存在
            foreach ($ParameterName in $DefaultParameterNames) {
                if (-not $script:Params.ContainsKey($ParameterName)) {
                    $script:Params.Add($ParameterName, $true)
                }
            }

            # 仅对 Windows 10 用户添加此选项，如果它尚不存在
            if ((get-ciminstance -query "select caption from win32_operatingsystem where caption like '%Windows 10%'") -and (-not $script:Params.ContainsKey('Hide3dObjects'))) {
                $script:Params.Add('Hide3dObjects', $Hide3dObjects)
            }

            # 仅对 Windows 11 用户（版本 22000+）添加这些选项，如果它们尚不存在
            if ($WinVersion -ge 22000) {
                if (-not $script:Params.ContainsKey('DisableRecall')) {
                    $script:Params.Add('DisableRecall', $true)
                }

                if ($script:ModernStandbySupported -and (-not $script:Params.ContainsKey('DisableModernStandbyNetworking'))) {
                    $script:Params.Add('DisableModernStandbyNetworking', $true)
                }
            }
        }

        # 自定义模式，根据用户输入显示和添加选项
        '2' {
            DisplayCustomModeOptions
        }

        # 应用程序移除，根据用户选择移除应用程序
        '3' {
            PrintHeader "应用程序移除"

            $result = ShowAppSelectionForm

            if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
                Write-Output "您已选择移除 $($script:SelectedApps.Count) 个应用程序"
                AddParameter 'RemoveAppsCustom' "移除 $($script:SelectedApps.Count) 个应用程序："

                # 如果传递了“Silent”参数，则取消提示
                if (-not $Silent) {
                    Write-Output ""
                    Write-Output ""
                    Write-Output "按 Enter 键移除选定的应用程序，或按 CTRL+C 退出..."
                    Read-Host | Out-Null
                    PrintHeader "应用程序移除"
                }
            } else {
                Write-Host "选择已取消，未移除任何应用程序" -ForegroundColor Red
                Write-Output ""
            }
        }

        # 从“SavedSettings”文件加载自定义选项
        '4' {
            PrintHeader '自定义模式'
            Write-Output "Win11Debloat 将进行以下更改："

            # 从文件中打印已保存的设置信息
            Foreach ($line in (Get-Content -Path "$PSScriptRoot/SavedSettings" )) {
                # 移除行前后的所有空格
                $line = $line.Trim()

                # 检查行是否包含注释
                if (-not ($line.IndexOf('#') -eq -1)) {
                    $parameterName = $line.Substring(0, $line.IndexOf('#'))

                    # 打印参数描述并添加参数到 Params 列表
                    if ($parameterName -eq "RemoveAppsCustom") {
                        if (-not (Test-Path "$PSScriptRoot/CustomAppsList")) {
                            # 应用程序文件不存在，跳过
                            continue
                        }

                        $appsList = ReadAppslistFromFile "$PSScriptRoot/CustomAppsList"
                        Write-Output "- 移除 $($appsList.Count) 个应用程序："
                        Write-Host $appsList -ForegroundColor DarkGray
                    } else {
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
                Write-Output "按 Enter 键执行脚本，或按 CTRL+C 退出..."
                Read-Host | Out-Null
            }

            PrintHeader '自定义模式'
        }
    }
} else {
    PrintHeader '自定义模式'
}

# 如果 SPParams 中的键数等于 Params 中的键数，则表示没有选择或添加任何修改/更改，脚本可以退出而不进行任何更改。
if ($SPParamCount -eq $script:Params.Keys.Count) {
    Write-Output "脚本已完成，未进行任何更改。"

    AwaitKeyToExit
}

# 执行所有选定/提供的参数
switch ($script:Params.Keys) {
    'CreateRestorePoint' {
        CreateSystemRestorePoint
        continue
    }
    'RemoveApps' {
        $appsList = ReadAppslistFromFile "$PSScriptRoot/Appslist.txt"
        Write-Output "> 正在移除默认选择的 $($appsList.Count) 个应用程序..."
        RemoveApps $appsList
        continue
    }
    'RemoveAppsCustom' {
        if (-not (Test-Path "$PSScriptRoot/CustomAppsList")) {
            Write-Host "> 错误: 无法从文件加载自定义应用程序列表，未移除任何应用程序" -ForegroundColor Red
            Write-Output ""
            continue
        }

        $appsList = ReadAppslistFromFile "$PSScriptRoot/CustomAppsList"
        Write-Output "> 正在移除 $($appsList.Count) 个应用程序..."
        RemoveApps $appsList
        continue
    }
    'RemoveCommApps' {
        $appsList = 'Microsoft.windowscommunicationsapps', 'Microsoft.People'
        Write-Output "> 正在移除邮件、日历和人脉应用程序..."
        RemoveApps $appsList
        continue
    }
    'RemoveW11Outlook' {
        $appsList = 'Microsoft.OutlookForWindows'
        Write-Output "> 正在移除新的 Windows 版 Outlook 应用程序..."
        RemoveApps $appsList
        continue
    }
    'RemoveDevApps' {
        $appsList = 'Microsoft.PowerAutomateDesktop', 'Microsoft.RemoteDesktop', 'Windows.DevHome'
        Write-Output "> 正在移除与开发人员相关的应用程序..."
        RemoveApps $appsList
        continue
    }
    'RemoveGamingApps' {
        $appsList = 'Microsoft.GamingApp', 'Microsoft.XboxGameOverlay', 'Microsoft.XboxGamingOverlay'
        Write-Output "> 正在移除与游戏相关的应用程序..."
        RemoveApps $appsList
        continue
    }
    'RemoveHPApps' {
        $appsList = 'AD2F1837.HPAIExperienceCenter', 'AD2F1837.HPJumpStarts', 'AD2F1837.HPPCHardwareDiagnosticsWindows', 'AD2F1837.HPPowerManager', 'AD2F1837.HPPrivacySettings', 'AD2F1837.HPSupportAssistant', 'AD2F1837.HPSureShieldAI', 'AD2F1837.HPSystemInformation', 'AD2F1837.HPQuickDrop', 'AD2F1837.HPWorkWell', 'AD2F1837.myHP', 'AD2F1837.HPDesktopSupportUtilities', 'AD2F1837.HPQuickTouch', 'AD2F1837.HPEasyClean', 'AD2F1837.HPConnectedMusic', 'AD2F1837.HPFileViewer', 'AD2F1837.HPRegistration', 'AD2F1837.HPWelcome', 'AD2F1837.HPConnectedPhotopoweredbySnapfish', 'AD2F1837.HPPrinterControl'
        Write-Output "> 正在移除 HP 应用程序..."
        RemoveApps $appsList
        continue
    }
    "ForceRemoveEdge" {
        ForceRemoveEdge
        continue
    }
    'DisableDVR' {
        RegImport "> 正在禁用 Xbox 游戏/屏幕录制..." "Disable_DVR.reg"
        continue
    }
    'DisableTelemetry' {
        RegImport "> 正在禁用遥测、诊断数据、活动历史记录、应用程序启动跟踪和定向广告..." "Disable_Telemetry.reg"
        continue
    }
    {$_ -in "DisableSuggestions", "DisableWindowsSuggestions"} {
        RegImport "> 正在禁用 Windows 中的提示、技巧、建议和广告..." "Disable_Windows_Suggestions.reg"
        continue
    }
    'DisableEdgeAds' {
        RegImport "> 正在禁用 Microsoft Edge 中的广告、建议和 MSN 新闻源..." "Disable_Edge_Ads_And_Suggestions.reg"
        continue
    }
    {$_ -in "DisableLockscrTips", "DisableLockscreenTips"} {
        RegImport "> 正在禁用锁屏上的提示和技巧..." "Disable_Lockscreen_Tips.reg"
        continue
    }
    'DisableDesktopSpotlight' {
        RegImport "> 正在禁用“Windows 聚焦”桌面背景选项..." "Disable_Desktop_Spotlight.reg"
        continue
    }
    'DisableSettings365Ads' {
        RegImport "> 正在禁用“设置主页”中的 Microsoft 365 广告..." "Disable_Settings_365_Ads.reg"
        continue
    }
    'DisableSettingsHome' {
        RegImport "> 正在禁用“设置主页”页面..." "Disable_Settings_Home.reg"
        continue
    }
    {$_ -in "DisableBingSearches", "DisableBing"} {
        RegImport "> 正在禁用 Windows 搜索中的必应网页搜索、必应 AI 和 Cortana..." "Disable_Bing_Cortana_In_Search.reg"

        # 同时移除必应搜索的应用程序包
        $appsList = 'Microsoft.BingSearch'
        RemoveApps $appsList
        continue
    }
    'DisableCopilot' {
        RegImport "> 正在禁用 Microsoft Copilot..." "Disable_Copilot.reg"

        # 同时移除 Copilot 的应用程序包
        $appsList = 'Microsoft.Copilot'
        RemoveApps $appsList
        continue
    }
    'DisableRecall' {
        RegImport "> 正在禁用 Windows Recall 快照..." "Disable_AI_Recall.reg"
        continue
    }
    'DisableEdgeAI' {
        RegImport "> 正在禁用 Microsoft Edge 中的 AI 功能..." "Disable_Edge_AI_Features.reg"
        continue
    }
    'DisablePaintAI' {
        RegImport "> 正在禁用画图中的 AI 功能..." "Disable_Paint_AI_Features.reg"
        continue
    }
    'DisableNotepadAI' {
        RegImport "> 正在禁用记事本中的 AI 功能..." "Disable_Notepad_AI_Features.reg"
        continue
    }
    'RevertContextMenu' {
        RegImport "> 正在恢复旧的 Windows 10 样式上下文菜单..." "Disable_Show_More_Options_Context_Menu.reg"
        continue
    }
    'DisableMouseAcceleration' {
        RegImport "> 正在关闭“增强指针精确度”..." "Disable_Enhance_Pointer_Precision.reg"
        continue
    }
    'DisableStickyKeys' {
        RegImport "> 正在禁用“粘滞键”键盘快捷方式..." "Disable_Sticky_Keys_Shortcut.reg"
        continue
    }
    'DisableFastStartup' {
        RegImport "> 正在禁用快速启动..." "Disable_Fast_Startup.reg"
        continue
    }
    'DisableModernStandbyNetworking' {
        RegImport "> 正在禁用现代待机期间的网络连接..." "Disable_Modern_Standby_Networking.reg"
        continue
    }
    'ClearStart' {
        Write-Output "> 正在为用户 $(GetUserName) 移除开始菜单中所有固定的应用程序..."
        ReplaceStartMenu
        Write-Output ""
        continue
    }
    'ReplaceStart' {
        Write-Output "> 正在为用户 $(GetUserName) 替换开始菜单..."
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
        RegImport "> 正在禁用开始菜单推荐部分..." "Disable_Start_Recommended.reg"
        continue
    }
    'DisableStartPhoneLink' {
        RegImport "> 正在禁用开始菜单中的手机链接移动设备集成..." "Disable_Phone_Link_In_Start.reg"
        continue
    }
    'EnableDarkMode' {
        RegImport "> 正在为系统和应用程序启用深色模式..." "Enable_Dark_Mode.reg"
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
        RegImport "> 正在从任务栏隐藏搜索图标..." "Hide_Search_Taskbar.reg"
        continue
    }
    'ShowSearchIconTb' {
        RegImport "> 正在将任务栏搜索更改为仅图标..." "Show_Search_Icon.reg"
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
        RegImport "> 正在从任务栏隐藏任务视图按钮..." "Hide_Taskview_Taskbar.reg"
        continue
    }
    {$_ -in "HideWidgets", "DisableWidgets"} {
        RegImport "> 正在禁用任务栏和锁屏上的小组件..." "Disable_Widgets_Service.reg"

        # 同时移除小组件的应用程序包
        $appsList = 'Microsoft.StartExperiencesApp'
        RemoveApps $appsList
        continue
    }
    {$_ -in "HideChat", "DisableChat"} {
        RegImport "> 正在从任务栏隐藏聊天图标..." "Disable_Chat_Taskbar.reg"
        continue
    }
    'EnableEndTask' {
        RegImport "> 正在启用任务栏右键菜单中的“结束任务”选项..." "Enable_End_Task.reg"
        continue
    }
    'EnableLastActiveClick' {
        RegImport "> 正在启用任务栏应用程序区域中的“上次活动点击”行为..." "Enable_Last_Active_Click.reg"
        continue
    }
    'ExplorerToHome' {
        RegImport "> 正在将文件资源管理器默认打开位置更改为“主页”..." "Launch_File_Explorer_To_Home.reg"
        continue
    }
    'ExplorerToThisPC' {
        RegImport "> 正在将文件资源管理器默认打开位置更改为“此电脑”..." "Launch_File_Explorer_To_This_PC.reg"
        continue
    }
    'ExplorerToDownloads' {
        RegImport "> 正在将文件资源管理器默认打开位置更改为“下载”..." "Launch_File_Explorer_To_Downloads.reg"
        continue
    }
    'ExplorerToOneDrive' {
        RegImport "> 正在将文件资源管理器默认打开位置更改为“OneDrive”..." "Launch_File_Explorer_To_OneDrive.reg"
        continue
    }
    'ShowHiddenFolders' {
        RegImport "> 正在取消隐藏文件、文件夹和驱动器..." "Show_Hidden_Folders.reg"
        continue
    }
    'ShowKnownFileExt' {
        RegImport "> 正在为已知文件类型启用文件扩展名..." "Show_Extensions_For_Known_File_Types.reg"
        continue
    }
    'HideHome' {
        RegImport "> 正在从文件资源管理器导航窗格隐藏“主页”部分..." "Hide_Home_from_Explorer.reg"
        continue
    }
    'HideGallery' {
        RegImport "> 正在从文件资源管理器导航窗格隐藏“图库”部分..." "Hide_Gallery_from_Explorer.reg"
        continue
    }
    'HideDupliDrive' {
        RegImport "> 正在从文件资源管理器导航窗格隐藏重复的可移动驱动器条目..." "Hide_duplicate_removable_drives_from_navigation_pane_of_File_Explorer.reg"
        continue
    }
    {$_ -in "HideOnedrive", "DisableOnedrive"} {
        RegImport "> 正在从文件资源管理器导航窗格隐藏 OneDrive 文件夹..." "Hide_Onedrive_Folder.reg"
        continue
    }
    {$_ -in "Hide3dObjects", "Disable3dObjects"} {
        RegImport "> 正在从文件资源管理器导航窗格隐藏“3D 对象”文件夹..." "Hide_3D_Objects_Folder.reg"
        continue
    }
    {$_ -in "HideMusic", "DisableMusic"} {
        RegImport "> 正在从文件资源管理器导航窗格隐藏“音乐”文件夹..." "Hide_Music_folder.reg"
        continue
    }
    {$_ -in "HideIncludeInLibrary", "DisableIncludeInLibrary"} {
        RegImport "> 正在隐藏上下文菜单中的“包含到库中”..." "Disable_Include_in_library_from_context_menu.reg"
        continue
    }
    {$_ -in "HideGiveAccessTo", "DisableGiveAccessTo"} {
        RegImport "> 正在隐藏上下文菜单中的“授予访问权限”..." "Disable_Give_access_to_context_menu.reg"
        continue
    }
    {$_ -in "HideShare", "DisableShare"} {
        RegImport "> 正在隐藏上下文菜单中的“共享”..." "Disable_Share_from_context_menu.reg"
        continue
    }
}

RestartExplorer

Write-Output ""
Write-Output ""
Write-Output ""
Write-Output "脚本已完成！请检查上方是否有任何错误。"

AwaitKeyToExit