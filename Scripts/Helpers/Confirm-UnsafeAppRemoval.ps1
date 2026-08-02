<#
    .SYNOPSIS
        Confirms removal of applications that require an extra safety warning.
#>
function Confirm-UnsafeAppRemoval {
    param (
        [string[]]$SelectedApps,
        $Owner = $null
    )

    # Skip all warnings in Silent mode
    if ($Silent) {
        return $true
    }

    # Microsoft Store warning
    if ($SelectedApps -contains "Microsoft.WindowsStore") {
        $result = Show-MessageBox -Message '您确定要卸载 Microsoft Store 吗？此应用无法轻松重新安装。' -Title '您确定吗？' -Button 'YesNo' -Icon 'Warning' -Owner $Owner

        if ($result -ne 'Yes') {
            return $false
        }
    }

    # Windows Terminal warning
    if ($SelectedApps -contains "Microsoft.WindowsTerminal") {
        $result = Show-MessageBox -Message '您确定要移除 Windows Terminal 吗？Windows Terminal 是 Windows 的默认命令行应用。在继续之前，请确保您不是通过 Windows Terminal 运行 Win11Debloat，以避免过程中途失败。' -Title '您确定吗？' -Button 'YesNo' -Icon 'Warning' -Owner $Owner

        if ($result -ne 'Yes') {
            return $false
        }
    }

    return $true
}
