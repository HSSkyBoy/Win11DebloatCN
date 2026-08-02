# 显示 CLI 默认模式应用移除选项。循环直到选择有效选项。
function Show-CliDefaultModeAppRemovalOptions {
    Write-CliHeader '默认模式'

    Write-Host "请注意：默认选择的应用包括 Microsoft Teams、Spotify、Sticky Notes 等。选择选项 2 可查看和更改脚本将移除的应用" -ForegroundColor DarkGray
    Write-Host ""

    Do {
        Write-Host "选项：" -ForegroundColor Yellow
        Write-Host " (n) 不移除任何应用" -ForegroundColor Yellow
        Write-Host " (1) 仅移除默认选择的应用" -ForegroundColor Yellow
        Write-Host " (2) 手动选择要移除的应用" -ForegroundColor Yellow
        $RemoveAppsInput = Read-Host "是否要移除应用？应用将从所有用户中移除 (n/1/2)"

        # 如果用户输入选项 2，则显示应用选择界面
        if ($RemoveAppsInput -eq '2') {
            $result = Show-AppSelectionWindow

            if ($result -ne $true) {
                # 用户取消或关闭了应用选择，更改 RemoveAppsInput 以便重新显示菜单
                Write-Host ""
                Write-Host "应用选择已取消，请重试" -ForegroundColor Red

                $RemoveAppsInput = 'c'
            }

            Write-Host ""
        }
    }
    while ($RemoveAppsInput -ne 'n' -and $RemoveAppsInput -ne '0' -and $RemoveAppsInput -ne '1' -and $RemoveAppsInput -ne '2')

    return $RemoveAppsInput
}
