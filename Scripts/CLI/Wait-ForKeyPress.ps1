function Wait-ForKeyPress {
    # 如果传入了 Silent 参数则跳过提示
    if (-not $Silent) {
        Write-Output ""
        Write-Output "按任意键退出..."
        $null = [System.Console]::ReadKey()
    }

    Stop-Transcript
    Exit
}
