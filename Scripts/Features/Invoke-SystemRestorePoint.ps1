function Invoke-SystemRestorePoint {
    $SysRestore = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SystemRestore" -Name "RPSessionInterval"
    $failed = $false

    if ($SysRestore.RPSessionInterval -eq 0) {
        # In GUI mode, skip the prompt and just try to enable it
        if ($script:GuiWindow -or $Silent -or $( Read-Host -Prompt "系统还原已禁用，是否要启用它并创建还原点？(y/n)") -eq 'y') {
            try {
                $enableResult = Invoke-NonBlocking -TimeoutSeconds 90 -ScriptBlock {
                    try {
                        Enable-ComputerRestore -Drive "$env:SystemDrive"
                        return $null
                    }
                    catch {
                        return "错误：启用系统还原失败：$_"
                    }
                }
            }
            catch {
                $enableResult = "错误：启用系统还原失败：$_"
            }

            if ($enableResult) {
                Write-Host $enableResult -ForegroundColor Red
                $failed = $true
            }
        }
        else {
            Write-Host ""
            $failed = $true
        }
    }

    if (-not $failed) {
        try {
            $result = Invoke-NonBlocking -TimeoutSeconds 90 -ScriptBlock {
                try {
                    $recentRestorePoints = Get-ComputerRestorePoint | Where-Object { (Get-Date) - [System.Management.ManagementDateTimeConverter]::ToDateTime($_.CreationTime) -le (New-TimeSpan -Hours 24) }
                }
                catch {
                    return [PSCustomObject]@{ Success = $false; Message = "错误：无法检索现有还原点：$_" }
                }

                if ($recentRestorePoints.Count -eq 0) {
                    try {
                        Checkpoint-Computer -Description "由 Win11Debloat 创建的还原点" -RestorePointType "MODIFY_SETTINGS"
                        return [PSCustomObject]@{ Success = $true; Message = "系统还原点创建成功" }
                    }
                    catch {
                        return [PSCustomObject]@{ Success = $false; Message = "错误：无法创建还原点：$_" }
                    }
                }
                else {
                    return [PSCustomObject]@{ Success = $true; Message = "已存在最近的还原点，未创建新的还原点" }
                }
            }
        }
        catch {
            $result = [PSCustomObject]@{ Success = $false; Message = "错误：创建系统还原点失败：$_" }
        }

        if ($result -and $result.Success) {
            Write-Host $result.Message
        }
        elseif ($result) {
            Write-Host $result.Message -ForegroundColor Red
            $failed = $true
        }
        else {
            Write-Host "错误：创建系统还原点失败" -ForegroundColor Red
            $failed = $true
        }
    }

    # Ensure that the user is aware if creating a restore point failed, and give them the option to continue without a restore point or cancel the script
    if ($failed) {
        if ($script:GuiWindow) {
            $result = Show-MessageBox "创建系统还原点失败。是否要在没有还原点的情况下继续？" "创建还原点失败" "YesNo" "Warning"

            if ($result -ne "Yes") {
                $script:CancelRequested = $true
                return
            }
        }
        elseif (-not $Silent) {
            Write-Host "创建系统还原点失败。是否要在没有还原点的情况下继续？(y/n)" -ForegroundColor Yellow
            if ($( Read-Host ) -ne 'y') {
                $script:CancelRequested = $true
                return
            }
        }

        Write-Host "警告：在没有还原点的情况下继续" -ForegroundColor Yellow
    }
}
