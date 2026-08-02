# Returns a validated list of apps based on the provided appsList and the supported apps from Apps.json
function Get-ValidatedAppList {
    param (
        $appsList
    )

    $supportedAppsList = @(Import-AppDetailsFromJson | ForEach-Object { @($_.AppId) }) | ForEach-Object { $_.Trim() } | Where-Object { $_.Length -gt 0 }
    $validatedAppsList = @()

    # Validate provided appsList against supportedAppsList
    Foreach ($app in $appsList) {
        $app = $app.Trim()
        $appString = $app.Trim('*')

        if ($supportedAppsList -notcontains $appString) {
            Write-Host "移除应用 '$appString' 不受支持，将被跳过" -ForegroundColor Yellow
            continue
        }

        $validatedAppsList += $appString
    }

    return $validatedAppsList
}
