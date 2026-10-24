param(
    [Parameter(Mandatory)][string]$ZipPath,
    [Parameter(Mandatory)][string]$SetupPath,
    [Parameter(Mandatory)][ValidateSet('amd64', 'arm64')][string]$Arch,
    [switch]$RequireSigned,
    [switch]$AllowInstall
)

$ErrorActionPreference = 'Stop'
$ZipPath = (Resolve-Path $ZipPath).Path
$SetupPath = (Resolve-Path $SetupPath).Path
$root = Join-Path ([IO.Path]::GetTempPath()) ('reclash-package-' + [guid]::NewGuid())
$installed = Join-Path $root 'installed'
$expanded = Join-Path $root 'zip'
$diagnostics = Join-Path $root 'logs'
$corePath = Join-Path $installed 'ReClashCore.exe'
$serviceRoot = Join-Path ([Environment]::GetFolderPath('ProgramFiles')) 'ReClash Service'
$process = $null
$uninstaller = $null
$coreProcess = $null
$appData = $null
$ownsAppData = $false
$launch = 0

function Start-InstalledApp {
    $script:launch++
    $output = Join-Path $diagnostics "gui-$launch.stdout.log"
    $errors = Join-Path $diagnostics "gui-$launch.stderr.log"
    $script:process = Start-Process -FilePath "$installed/ReClash.exe" -WorkingDirectory $installed `
        -RedirectStandardOutput $output -RedirectStandardError $errors -PassThru
    $null = $process.Handle
    $deadline = [DateTime]::UtcNow.AddSeconds(60)
    do {
        $process.Refresh()
        if ($process.HasExited) { throw "GUI exited during startup: $($process.ExitCode)" }
        $rpcReady = $null -ne (Select-String -Path $output, $errors -SimpleMatch 'init result: true' |
            Select-Object -First 1)
        if ($process.MainWindowHandle -ne 0 -and $rpcReady) { break }
        Start-Sleep -Milliseconds 250
    } while ([DateTime]::UtcNow -lt $deadline)
    if ($process.MainWindowHandle -eq 0 -or -not $rpcReady) {
        throw 'Installed GUI did not show a window and complete Core init RPC within 60 seconds'
    }
    $cores = @(Get-InstalledCores)
    if ($cores.Count -ne 1) { throw "Expected one installed Core after RPC init, found $($cores.Count)" }
    $script:coreProcess = $cores[0]
    if ($coreProcess.HasExited) { throw 'Core exited immediately after initialization' }
    Write-Host "Installed GUI and Core ($($coreProcess.Id)) completed authenticated IPC and init RPC."
}

function Confirm-OwnedExit {
    if ($null -ne $process -and -not $process.WaitForExit(20000)) {
        throw 'Installed GUI did not complete owned shutdown'
    }
    if ($null -ne $coreProcess -and -not $coreProcess.WaitForExit(15000)) {
        throw "Installed Core $($coreProcess.Id) outlived the GUI"
    }
}

function Assert-Signature([string]$Path) {
    $signature = Get-AuthenticodeSignature -LiteralPath $Path
    Write-Host ("Authenticode {0}: {1}" -f [IO.Path]::GetFileName($Path), $signature.Status)
    if ($RequireSigned -and $signature.Status -ne 'Valid') {
        throw "Authenticode verification failed: $Path ($($signature.Status))"
    }
    if ($signature.Status -notin @('Valid', 'NotSigned')) {
        throw "Invalid existing Authenticode signature: $Path ($($signature.Status))"
    }
}

function Get-InstalledCores {
    Get-CimInstance Win32_Process -Filter "Name = 'ReClashCore.exe'" |
        Where-Object { $_.ExecutablePath -eq $corePath } |
        ForEach-Object {
            $candidate = Get-Process -Id $_.ProcessId -ErrorAction SilentlyContinue
            if ($null -ne $candidate -and -not $candidate.HasExited -and $candidate.Path -eq $corePath) {
                $null = $candidate.Handle
                $candidate
            }
        }
}

function Assert-NoReClashService([string]$Context) {
    if (Get-Service -Name 'ReClashService' -ErrorAction SilentlyContinue) {
        throw "${Context}: ReClashService is still registered"
    }
    if (Test-Path -LiteralPath $serviceRoot) { throw "${Context}: $serviceRoot still exists" }
}

function Invoke-Setup([string]$Path, [string[]]$Arguments) {
    $setup = Start-Process -FilePath $Path -ArgumentList $Arguments -PassThru
    if (-not $setup.WaitForExit(180000)) {
        $setup.Kill($true)
        throw "Installer timed out: $Path"
    }
    if ($setup.ExitCode -notin @(0, 3010)) {
        throw "Installer failed: $($setup.ExitCode), see $root"
    }
}

try {
    New-Item -ItemType Directory -Path $diagnostics -Force | Out-Null
    if ($env:GITHUB_ENV) {
        Add-Content -LiteralPath $env:GITHUB_ENV -Value "WINDOWS_PACKAGE_LOGS=$diagnostics"
    }
    $validation = @('--arch', $Arch, '--zip', $ZipPath)
    if ($RequireSigned) { $validation += '--require-signed' }
    & dart run "$PSScriptRoot/windows_package.dart" @validation
    if ($LASTEXITCODE -ne 0) { throw 'ZIP validation failed' }
    Expand-Archive -LiteralPath $ZipPath -DestinationPath $expanded
    foreach ($file in @($SetupPath, "$expanded/ReClash.exe", "$expanded/ReClashCore.exe",
            "$expanded/ReClashService.exe", "$expanded/rust_api.dll")) {
        Assert-Signature $file
    }
    if (-not $AllowInstall) { return }
    if (Get-Process -Name 'ReClash', 'ReClashCore', 'ReClashService', 'ReClashHelperService' -ErrorAction SilentlyContinue) {
        throw 'Installation smoke requires a disposable Windows session with no running ReClash'
    }
    Assert-NoReClashService 'Installation smoke requires a disposable Windows session'
    $appIds = @('E642C6C1-B712-41C2-969E-3C2049CA883F_is1', '728B3532-C74B-4870-9068-BE70FE12A3E6_is1')
    foreach ($hive in @('HKLM:', 'HKCU:')) {
        foreach ($view in @('Software', 'Software\WOW6432Node')) {
            foreach ($appId in $appIds) {
                if (Test-Path "$hive\$view\Microsoft\Windows\CurrentVersion\Uninstall\$appId") {
                    throw 'Installation smoke must not overwrite an existing installation'
                }
            }
        }
    }
    $uninstaller = Join-Path $installed 'unins000.exe'
    Invoke-Setup $SetupPath @('/VERYSILENT', '/SUPPRESSMSGBOXES', '/SP-', '/NORESTART',
        "/DIR=`"$installed`"", "/LOG=`"$diagnostics/setup.log`"")
    & dart run "$PSScriptRoot/windows_package.dart" --arch $Arch --zip $ZipPath --compare-installed $installed
    if ($LASTEXITCODE -ne 0) { throw 'Installed payload does not match the ZIP' }
    $version = (Get-Item "$installed/ReClash.exe").VersionInfo
    $appData = Join-Path ([Environment]::GetFolderPath('ApplicationData')) `
        (Join-Path $version.CompanyName $version.ProductName)
    if (Test-Path $appData) { throw 'Installation smoke requires a disposable Windows account with no ReClash data' }
    New-Item -ItemType Directory -Path $appData | Out-Null
    $ownsAppData = $true
    $config = @{
        appSettingProps = @{
            setupCompleted = $true; acceptedDisclaimerVersion = 1
            autoCheckUpdate = $false; autoLaunch = $false; autoRun = $false
        }
        vpnProps = @{ enable = $false; systemProxy = $false }
        networkProps = @{ systemProxy = $false; autoSetSystemDns = $false }
        patchClashConfig = @{ tun = @{ enable = $false } }
        themeProps = @{}
    } | ConvertTo-Json -Depth 10 -Compress
    @{ 'flutter.config' = $config; 'flutter.version' = 1; 'flutter.upgradeVersion' = 2 } |
        ConvertTo-Json -Compress | Set-Content -LiteralPath "$appData/shared_preferences.json" -Encoding utf8NoBOM
    Start-InstalledApp
    Invoke-Setup $SetupPath @('/VERYSILENT', '/SUPPRESSMSGBOXES', '/SP-', '/NORESTART',
        "/DIR=`"$installed`"", "/LOG=`"$diagnostics/upgrade.log`"")
    Confirm-OwnedExit
    & dart run "$PSScriptRoot/windows_package.dart" --arch $Arch --zip $ZipPath --compare-installed $installed
    if ($LASTEXITCODE -ne 0) { throw 'Upgraded payload does not match the ZIP' }
    Start-InstalledApp
    Write-Host 'This hosted-session smoke does not prove clean-OS dependencies, UAC or TUN operation.'
} finally {
    $cleanupErrors = @()
    $ownedCores = @{}
    if ($null -ne $coreProcess) { $ownedCores[$coreProcess.Id] = $coreProcess }
    if ($null -ne $uninstaller -and (Test-Path $uninstaller)) {
        try {
            Invoke-Setup $uninstaller @('/VERYSILENT', '/SUPPRESSMSGBOXES', '/NORESTART',
                "/LOG=`"$diagnostics/uninstall.log`"")
            Confirm-OwnedExit
            if (Test-Path "$installed/ReClash.exe") { throw 'Uninstaller left the installed GUI behind' }
            if (Test-Path "$installed/ReClashCore.exe") { throw 'Uninstaller left the installed Core behind' }
            if (Test-Path "$installed/ReClashService.exe") { throw 'Uninstaller left the installed service behind' }
            Assert-NoReClashService 'After uninstall'
        } catch { $cleanupErrors += $_ }
    }
    if ($null -ne $process) {
        try {
            foreach ($candidate in @(Get-InstalledCores)) {
                if (-not $ownedCores.ContainsKey($candidate.Id)) {
                    $ownedCores[$candidate.Id] = $candidate
                }
            }
        } catch { $cleanupErrors += $_ }
        try {
            if (-not $process.HasExited) { $process.Kill() }
            if (-not $process.WaitForExit(10000)) { throw 'GUI exit was not confirmed' }
        } catch { $cleanupErrors += $_ }
    }
    foreach ($ownedCore in $ownedCores.Values) {
        try {
            if (-not $ownedCore.WaitForExit(15000)) {
                throw "Installed Core $($ownedCore.Id) outlived the GUI"
            }
            Write-Host "Confirmed Core exit: $($ownedCore.Id)"
        } catch { $cleanupErrors += $_ }
    }
    if ($cleanupErrors.Count -eq 0 -and $ownsAppData) {
        Remove-Item -LiteralPath $appData -Recurse
    }
    Write-Host "Windows package check output: $root"
    if ($cleanupErrors.Count -gt 0) {
        foreach ($failure in $cleanupErrors) { Write-Warning $failure.ToString() }
        throw "Process cleanup failed; installation retained at $root"
    }
}
