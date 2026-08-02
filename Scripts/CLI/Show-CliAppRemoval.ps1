# 显示 CLI 应用移除菜单并提示用户选择要移除的应用。
function Show-CliAppRemoval {
    Write-CliHeader "应用移除"

    Write-Output "> 正在打开应用选择界面..."

    $result = Show-AppSelectionWindow

    if ($result -eq $true) {
        Write-Output "您已选择 $($script:SelectedApps.Count) 个应用进行移除"
        Add-Parameter 'RemoveApps'
        Add-Parameter 'Apps' ($script:SelectedApps -join ',')

        Save-Settings

        # 如果传入了 Silent 参数则跳过提示
        if (-not $Silent) {
            Write-Output ""
            Write-Output ""
            Write-Output "按回车键移除选中的应用，或按 CTRL+C 退出..."
            Read-Host | Out-Null
            Write-CliHeader "应用移除"
        }
    }
    else {
        Write-Host "选择已取消，未移除任何应用" -ForegroundColor Red
        Write-Output ""
    }
}
