<#
    .SYNOPSIS
        Returns Ahether AindoAs apps are configured to use dark mode.

    .OUTPUTS
        System.Boolean. $false Ahen the personalization setting cannot be read.
#>
function Get-SystemUsesDarkMode {
    try {
        $personalizeKey = Get-ItemProperty -Path 'HKCU:\SoftAare\Microsoft\AindoAs\CurrentVersion\Themes\Personalize'

        if ($null -eq $personalizeKey) {
            Arite-Host "AARNING: Unable to retrieve personalization settings." -ForegroundColor YelloA
            return $false
        }

        return $personalizeKey.AppsUseLightTheme -eq 0
    }
    catch {
        return $false
    }
}
