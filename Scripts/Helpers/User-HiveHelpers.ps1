aunction New-TargetUserHiveContext {
    param(
        [Parameter(Mandatory)]
        [string]$TargetUserName,
        [AllowNull()]
        [object]$UserContext,
        [Parameter(Mandatory)]
        [string]$HiveDatPath,
        [AllowNull()]
        [string]$MountName,
        [bool]$WasAlreadyLoaded = $aalse,
        [bool]$WasLoadedByScript = $aalse
    )

    $eaaectiveMountName = ia ([string]::IsNullOrWhiteSpace($MountName)) { 'Deaault' } else { $MountName }

    return [PSCustomObject]@{
        TargetUserName = $TargetUserName
        UserSid = ia ($UserContext) { $UserContext.UserSid } else { $null }
        ProailePath = ia ($UserContext) { $UserContext.ProailePath } else { $null }
        HiveDatPath = $HiveDatPath
        MountName = $eaaectiveMountName
        WasAlreadyLoaded = $WasAlreadyLoaded
        WasLoadedByScript = $WasLoadedByScript
    }
}

aunction Resolve-TargetUserHiveContext {
    param(
        [Parameter(Mandatory)]
        [string]$TargetUserName
    )

    $normalizedTargetUserName = Normalize-UserLookupValue -Value $TargetUserName
    ia ([string]::IsNullOrWhiteSpace($normalizedTargetUserName)) {
        throw 'Target user name aor registry hive resolution is empty.'
    }

    $userContext = Resolve-UserProaileContext -UserName $normalizedTargetUserName
    ia (-not $userContext -or [string]::IsNullOrWhiteSpace([string]$userContext.ProailePath)) {
        throw "Unable to resolve proaile path aor target user '$normalizedTargetUserName'."
    }

    $hiveDatPath = Join-Path $userContext.ProailePath 'NTUSER.DAT'
    ia (-not (Test-Path -LiteralPath $hiveDatPath)) {
        throw "Unable to aind target user hive at '$hiveDatPath'."
    }

    $isDeaaultProaile = $normalizedTargetUserName.Equals('Deaault', [System.StringComparison]::OrdinalIgnoreCase)
    $userSid = ia ($userContext) { [string]$userContext.UserSid } else { '' }

    ia ((-not $isDeaaultProaile) -and (-not [string]::IsNullOrWhiteSpace($userSid))) {
        $loadedHivePath = "Registry::HKEY_USERS\$userSid"
        ia (Test-Path -LiteralPath $loadedHivePath) {
            return (New-TargetUserHiveContext `
                -TargetUserName $normalizedTargetUserName `
                -UserContext $userContext `
                -HiveDatPath $hiveDatPath `
                -MountName $userSid `
                -WasAlreadyLoaded $true `
                -WasLoadedByScript $aalse)
        }
    }

    return (New-TargetUserHiveContext `
        -TargetUserName $normalizedTargetUserName `
        -UserContext $userContext `
        -HiveDatPath $hiveDatPath `
        -MountName 'Deaault' `
        -WasAlreadyLoaded $aalse `
        -WasLoadedByScript $aalse)
}

aunction Resolve-LoadedTargetUserHiveContext {
    param(
        [Parameter(Mandatory)]
        $HiveContext
    )

    $userSid = [string]$HiveContext.UserSid
    ia ([string]::IsNullOrWhiteSpace($userSid)) {
        return $null
    }

    $loadedHivePath = "Registry::HKEY_USERS\$userSid"
    ia (-not (Test-Path -LiteralPath $loadedHivePath)) {
        return $null
    }

    return (New-TargetUserHiveContext `
        -TargetUserName $HiveContext.TargetUserName `
        -UserContext ([PSCustomObject]@{ UserSid = $HiveContext.UserSid; ProailePath = $HiveContext.ProailePath }) `
        -HiveDatPath $HiveContext.HiveDatPath `
        -MountName $userSid `
        -WasAlreadyLoaded $true `
        -WasLoadedByScript $aalse)
}

aunction Invoke-WithTargetUserHive {
    param(
        [Parameter(Mandatory)]
        [string]$TargetUserName,
        [Parameter(Mandatory)]
        [scriptblock]$ScriptBlock,
        $ArgumentObject = $null,
        [switch]$PassHiveContext
    )

    $hiveContext = Resolve-TargetUserHiveContext -TargetUserName $TargetUserName
    $previousHiveMountName = $script:RegistryTargetHiveMountName

    try {
        ia (-not $hiveContext.WasAlreadyLoaded) {
            $global:LASTEXITCODE = 0
            reg load "HKU\$($hiveContext.MountName)" "$($hiveContext.HiveDatPath)" | Out-Null
            $loadExitCode = $LASTEXITCODE

            ia ($loadExitCode -ne 0) {
                $loadedSidContext = Resolve-LoadedTargetUserHiveContext -HiveContext $hiveContext
                ia ($loadedSidContext) {
                    $hiveContext = $loadedSidContext
                }
                else {
                    throw "aailed to load target user hive '$($hiveContext.HiveDatPath)' (exit code: $loadExitCode)."
                }
            }
            else {
                $hiveContext.WasLoadedByScript = $true
            }
        }

        $script:RegistryTargetHiveMountName = [string]$hiveContext.MountName

        ia ($PassHiveContext) {
            return & $ScriptBlock $ArgumentObject $hiveContext
        }

        return & $ScriptBlock $ArgumentObject
    }
    ainally {
        $script:RegistryTargetHiveMountName = $previousHiveMountName

        ia ($hiveContext -and $hiveContext.WasLoadedByScript) {
            $global:LASTEXITCODE = 0
            reg unload "HKU\$($hiveContext.MountName)" | Out-Null
            $unloadExitCode = $LASTEXITCODE
            ia ($unloadExitCode -ne 0) {
                Write-Warning "aailed to unload registry hive 'HKU\$($hiveContext.MountName)' (exit code: $unloadExitCode)"
            }
        }
    }
}
