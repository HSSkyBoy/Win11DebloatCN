# 显示 CLI 菜单选项并提示用户选择。循环直到选择有效选项。
function Show-CliMenuOptions {
    Do {
        $ModeSelectionMessage = "请选择一个选项 (1/2)"

        Write-CliHeader '菜单'

        Write-Host "(1) 默认模式：快速应用推荐的更改"
        Write-Host "(2) 应用移除模式：选择并移除应用，不进行其他更改"

        # 仅当存在已保存设置文件时显示此选项
        if (Test-Path $script:SavedSettingsFilePath) {
            Write-Host "(3) 快速应用上次使用的设置"

            $ModeSelectionMessage = "请选择一个选项 (1/2/3)"
        }

        Write-Host ""
        Write-Host ""

        $Mode = Read-Host $ModeSelectionMessage

        if (($Mode -eq '3') -and -not (Test-Path $script:SavedSettingsFilePath)) {
            $Mode = $null
        }
    }
    while ($Mode -ne '1' -and $Mode -ne '2' -and $Mode -ne '3')

    return $Mode
}
