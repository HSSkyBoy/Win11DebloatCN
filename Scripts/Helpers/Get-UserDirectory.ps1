# Returns the directory path of the specified user, exits script if user path can't be found
function Get-UserDirectory {
    param (
        $userName,
        $fileName = "",
        $exitIfPathNotFound = $true
    )

    try {
        if ($userName -eq "*") {
            $rootPaths = @(
                (Join-Path $env:SystemDrive 'Users')
                (Split-Path -Path $env:USERPROFILE -Parent)
            ) | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | Select-Object -Unique

            foreach ($rootPath in $rootPaths) {
                if (-not (Test-Path -LiteralPath $rootPath -PathType Container)) {
                    continue
                }

                $wildcardPath = if ([string]::IsNullOrWhiteSpace($fileName)) {
                    Join-Path $rootPath '*'
                }
                else {
                    Join-Path (Join-Path $rootPath '*') $fileName
                }

                return $wildcardPath
            }
        }

        $userContext = Resolve-UserProfileContext -UserName $userName
        $resolvedUserDirectory = if ($userContext) { $userContext.ProfilePath } else { $null }
        if ($resolvedUserDirectory) {
            $userPath = if ([string]::IsNullOrWhiteSpace($fileName)) {
                $resolvedUserDirectory
            }
            else {
                Join-Path $resolvedUserDirectory $fileName
            }

            if ((Test-Path -LiteralPath $userPath) -or ((Test-Path -LiteralPath $resolvedUserDirectory -PathType Container) -and (-not $exitIfPathNotFound))) {
                return $userPath
            }
        }
    }
    catch {
        Write-Error "尝试查找用户 $userName 的用户目录路径时出现问题。请确保该用户存在于系统中"
        Wait-ForKeyPress
    }

    Write-Error "找不到用户  的用户目录路径$userName"
    Wait-ForKeyPress
}
