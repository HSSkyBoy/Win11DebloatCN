# 显示 CLI 默认模式选项，或根据 RunDefaults/RunDefaultsLite 参数设置选择
function Show-CliDefaultModeOptions {
    if ($RunDefaults) {
        $RemoveAppsInput = '1'
    }
    elseif ($RunDefaultsLite) {
        $RemoveAppsInput = '0'
    }
    else {
        $RemoveAppsInput = Show-CliDefaultModeAppRemovalOptions

        if ($RemoveAppsInput -eq '2' -and ($script:SelectedApps.contains('Microsoft.XboxGameOverlay') -or $script:SelectedApps.contains('Microsoft.XboxGamingOverlay')) -and
          $( Read-Host -Prompt "是否禁用 Game Bar 集成和游戏/屏幕录制？这也会阻止 ms-gamingoverlay 和 ms-gamebar 弹窗 (y/n)" ) -eq 'y') {
            $DisableGameBarIntegrationInput = $true;
        }
    }

    Write-CliHeader '默认模式'

    try {
        # 根据用户输入选择应用移除选项
        switch ($RemoveAppsInput) {
            '1' {
                Add-Parameter 'RemoveApps'
                Add-Parameter 'Apps' 'Default'
            }
            '2' {
                Add-Parameter 'RemoveApps'
                Add-Parameter 'Apps' ($script:SelectedApps -join ',')

                if ($DisableGameBarIntegrationInput) {
                    Add-Parameter 'DisableDVR'
                    Add-Parameter 'DisableGameBarIntegration'
                }
            }
        }

        Import-Settings -filePath $script:DefaultSettingsFilePath -expectedVersion "1.0"
    }
    catch {
        Write-Error "无法加载 DefaultSettings.json 文件中的设置：$_"
        Wait-ForKeyPress
    }

    Save-Settings

    if ($Silent) {
        # 跳过更改摘要和确认提示
        return
    }

    Write-PendingChanges
    Write-CliHeader '默认模式'
}
