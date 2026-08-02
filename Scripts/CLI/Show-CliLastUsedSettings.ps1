# 显示 CLI 上次使用的设置，展示待处理的更改并提示用户应用。
function Show-CliLastUsedSettings {
    Write-CliHeader '自定义模式'

    try {
        Import-Settings -filePath $script:SavedSettingsFilePath -expectedVersion "1.0"
    }
    catch {
        Write-Error "无法加载 LastUsedSettings.json 文件中的设置：$_"
        Wait-ForKeyPress
    }

    if ($Silent) {
        # 跳过更改摘要和确认提示
        return
    }

    Write-PendingChanges
    Write-CliHeader '自定义模式'
}
