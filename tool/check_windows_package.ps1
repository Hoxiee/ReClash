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
$process = $null
$uninstaller = $null
$coreProcess = $null

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
    foreach ($file in @($SetupPath, "$expanded/ReClash.exe", "$expanded/ReClashCore.exe", "$expanded/rust_api.dll")) {
        Assert-Signature $file
    }
    if (-not $AllowInstall) { return }
    if (Get-Process -Name 'ReClash', 'ReClashCore', 'ReClashHelperService' -ErrorAction SilentlyContinue) {
        throw 'Installation smoke requires a disposable Windows session with no running ReClash'
    }
    $appId = 'E642C6C1-B712-41C2-969E-3C2049CA883F_is1'
    foreach ($hive in @('HKLM:', 'HKCU:')) {
        foreach ($view in @('Software', 'Software\WOW6432Node')) {
            if (Test-Path "$hive\$view\Microsoft\Windows\CurrentVersion\Uninstall\$appId") {
                throw 'Installation smoke must not overwrite an existing ReClash installation'
            }
        }
    }
    $uninstaller = Join-Path $installed 'unins000.exe'
    Invoke-Setup $SetupPath @('/VERYSILENT', '/SUPPRESSMSGBOXES', '/SP-', '/NORESTART',
        "/DIR=`"$installed`"", "/LOG=`"$diagnostics/setup.log`"")
    & dart run "$PSScriptRoot/windows_package.dart" --arch $Arch --zip $ZipPath --compare-installed $installed
    if ($LASTEXITCODE -ne 0) { throw 'Installed payload does not match the ZIP' }
    New-Item -ItemType Directory -Path "$installed/config" | Out-Null
    $process = Start-Process -FilePath "$installed/ReClash.exe" -WorkingDirectory $installed -PassThru
    $deadline = [DateTime]::UtcNow.AddSeconds(60)
    do {
        $process.Refresh()
        if ($process.HasExited) { throw "GUI exited before showing a window: $($process.ExitCode)" }
        if ($process.MainWindowHandle -ne 0) { break }
        Start-Sleep -Milliseconds 250
    } while ([DateTime]::UtcNow -lt $deadline)
    if ($process.MainWindowHandle -eq 0) { throw 'GUI did not show a window within 60 seconds' }
    $rpcReady = $false
    do {
        $process.Refresh()
        if ($process.HasExited) { throw "GUI exited during Core startup: $($process.ExitCode)" }
        $logs = @(Get-ChildItem "$installed/config/logs" -Filter '*.log' -ErrorAction SilentlyContinue)
        $rpcReady = $logs.Count -gt 0 -and
            ($null -ne (Select-String -Path $logs.FullName -SimpleMatch 'init result: true' | Select-Object -First 1))
        if ($rpcReady) { break }
        Start-Sleep -Milliseconds 250
    } while ([DateTime]::UtcNow -lt $deadline)
    if (-not $rpcReady) { throw 'GUI never received a successful Core init RPC response within 60 seconds' }
    $cores = @(Get-InstalledCores)
    if ($cores.Count -ne 1) { throw "Expected one installed Core after RPC init, found $($cores.Count)" }
    $coreProcess = $cores[0]
    if ($coreProcess.HasExited) { throw 'Core exited immediately after initialization' }
    Write-Host "Installed GUI and Core ($($coreProcess.Id)) completed authenticated IPC and init RPC."
    Write-Host 'This hosted-session smoke does not prove clean-OS dependencies, UAC or TUN operation.'
} finally {
    $cleanupErrors = @()
    $ownedCores = @{}
    if ($null -ne $coreProcess) { $ownedCores[$coreProcess.Id] = $coreProcess }
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
    try {
        if (Test-Path "$installed/config/logs") {
            Copy-Item -Path "$installed/config/logs" -Destination "$diagnostics/app" -Recurse
        }
    } catch { Write-Warning "Could not copy application logs: $_" }
    if ($cleanupErrors.Count -eq 0 -and $null -ne $uninstaller -and (Test-Path $uninstaller)) {
        Invoke-Setup $uninstaller @('/VERYSILENT', '/SUPPRESSMSGBOXES', '/NORESTART', "/LOG=`"$diagnostics/uninstall.log`"")
    }
    Write-Host "Windows package check output: $root"
    if ($cleanupErrors.Count -gt 0) {
        foreach ($failure in $cleanupErrors) { Write-Warning $failure.ToString() }
        throw "Process cleanup failed; installation retained at $root"
    }
}
