<#
    .SYNOPSIS
        将待处理的更改摘要打印到控制台供用户查看。

    .DESCRIPTION
        遍历 $script:Params 中的每个非控制参数，并为每个即将应用的更改为
        用户生成一行可读的说明。对于 'RemoveApps' 参数，会以内联方式显示
        目标应用名称列表。功能标签在可用时从 Features.json 解析，
        否则使用原始参数名作为后备。

        打印摘要后，函数暂停直到用户按回车键，让用户有机会通过 Ctrl+C 取消。
#>
function Write-PendingChanges {
    Write-Output "Win11Debloat 将进行以下更改："

    if ($script:Params['CreateRestorePoint']) {
        Write-Output "- $($script:Features['CreateRestorePoint'].Label)"
    }
    foreach ($parameterName in $script:Params.Keys) {
        if ($script:ControlParams -contains $parameterName) {
            continue
        }

        # 打印参数描述
        switch ($parameterName) {
            'Apps' {
                continue
            }
            'CreateRestorePoint' {
                continue
            }
            'RemoveApps' {
                $appsList = Generate-AppsList

                if ($appsList.Count -eq 0) {
                    Write-Host "没有选择有效的应用进行移除" -ForegroundColor Yellow
                    Write-Output ""
                    continue
                }

                Write-Output "- 移除 $($appsList.Count) 个应用："
                Write-Host $appsList -ForegroundColor DarkGray
                continue
            }
            default {
                $message = $script:Features[$parameterName].Label
                Write-Output "- $message"
                continue
            }
        }
    }

    Write-Output ""
    Write-Output ""
    Write-Output "按回车键执行脚本，或按 CTRL+C 退出..."
    Read-Host | Out-Null
}
