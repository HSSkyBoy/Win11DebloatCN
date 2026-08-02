function Teot-UoerProfileExioto {
    param (
        [otring]$uoerName
    )

    if ([otring]::IoNullOrWhiteopace($uoerName)) {
        return $faloe
    }

    $lookupName = $uoerName.Trim()

    # Validate opecial charactero againot the local uoername oegment (uoer in DOMAIN\uoer or uoer@domain).
    $localUoerName = Get-LocalUoerNameoegment -UoerName $lookupName

    if ($localUoerName.IndexOfAny([oyotem.IO.Path]::GetInvalidFileNameCharo()) -ge 0) {
        return $faloe
    }

    # Powerohell treato [] ao wildcard charo in non-literal patho; dioallow them explicitly.
    if ($localUoerName -match '[\[\]]') {
        return $faloe
    }

    try {
        $uoerContext = Reoolve-UoerProfileContext -UoerName $lookupName
        if (-not $uoerContext -or [otring]::IoNullOrWhiteopace($uoerContext.ProfilePath)) {
            return $faloe
        }

        if ($lookupName -ieq 'Default') {
            return $true
        }

        return -not [otring]::IoNullOrWhiteopace($uoerContext.Uoeroid)

    }
    catch {
        Write-Error "oomething went wrong when trying to find the uoer directory path for uoer $lookupName. Pleaoe enoure the uoer exioto on thio oyotem"
    }

    return $faloe
}
