#requires -RunAsAdministrator
<#
.SYNOPSIS
  Utility interattiva per i permessi dei file usati da UltraUXThemePatcher.

.DESCRIPTION
  Gestisce:
    C:\Windows\System32\uxtheme.dll
    C:\Windows\System32\uxinit.dll
    C:\Windows\System32\themeui.dll

  Menu:
    1) Verifica owner e permessi
    2) Backup dei file + ACL correnti sul Desktop
    3) Imposta owner = Administrators e Full Control agli Administrators
    4) Ripristina owner e permessi da un backup creato dallo script
    5) Ripristina solo owner = TrustedInstaller
    0) Esci

  NOTA:
  - Il ripristino piu' sicuro dei permessi e' quello da backup, perche'
    conserva esattamente ACL/owner presenti prima della modifica.
  - Lo script NON patcha i file e NON esegue UltraUXThemePatcher.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$ThemeFiles = @(
    'C:\Windows\System32\uxtheme.dll',
    'C:\Windows\System32\uxinit.dll',
    'C:\Windows\System32\themeui.dll'
)

$Desktop = [Environment]::GetFolderPath('Desktop')
$BackupPrefix = 'backup_uxthemepatcher_'

function Write-Header {
    Clear-Host
    Write-Host '============================================================' -ForegroundColor Cyan
    Write-Host ' UltraUXThemePatcher - Gestione file / Owner / Permessi' -ForegroundColor Cyan
    Write-Host '============================================================' -ForegroundColor Cyan
    Write-Host ''
}

function Pause-Script {
    Write-Host ''
    Read-Host 'Premi INVIO per continuare'
}

function Test-ThemeFiles {
    $missing = @($ThemeFiles | Where-Object { -not (Test-Path -LiteralPath $_) })
    if ($missing.Count -gt 0) {
        Write-Host 'ERRORE: mancano uno o piu file:' -ForegroundColor Red
        $missing | ForEach-Object { Write-Host "  $_" -ForegroundColor Red }
        return $false
    }
    return $true
}

function Show-Status {
    Write-Header
    Write-Host '[1] VERIFICA OWNER E PERMESSI' -ForegroundColor Yellow
    Write-Host ''

    if (-not (Test-ThemeFiles)) {
        Pause-Script
        return
    }

    foreach ($file in $ThemeFiles) {
        $acl = Get-Acl -LiteralPath $file
        Write-Host ('-' * 60) -ForegroundColor DarkGray
        Write-Host $file -ForegroundColor White
        Write-Host ("Owner : {0}" -f $acl.Owner) -ForegroundColor Green
        Write-Host 'ACL:' -ForegroundColor Green
        & icacls.exe $file
        Write-Host ''
    }

    Pause-Script
}

function New-Backup {
    Write-Header
    Write-Host '[2] BACKUP FILE ORIGINALI + ACL' -ForegroundColor Yellow
    Write-Host ''

    if (-not (Test-ThemeFiles)) {
        Pause-Script
        return
    }

    $stamp = Get-Date -Format 'yyyy-MM-dd_HHmmss'
    $backupDir = Join-Path $Desktop ($BackupPrefix + $stamp)
    New-Item -ItemType Directory -Path $backupDir -Force | Out-Null

    $manifest = [ordered]@{
        Created     = (Get-Date).ToString('o')
        Computer    = $env:COMPUTERNAME
        Windows     = [Environment]::OSVersion.VersionString
        BackupPath  = $backupDir
        Files       = @()
    }

    foreach ($file in $ThemeFiles) {
        $name = Split-Path $file -Leaf

        Copy-Item -LiteralPath $file -Destination (Join-Path $backupDir $name) -Force

        $acl = Get-Acl -LiteralPath $file
        $acl | Export-Clixml -LiteralPath (Join-Path $backupDir ($name + '.acl.xml'))

        (& icacls.exe $file) | Out-File -LiteralPath (Join-Path $backupDir ($name + '.icacls.txt')) -Encoding utf8

        $manifest.Files += [ordered]@{
            Path   = $file
            Name   = $name
            Owner  = $acl.Owner
            SHA256 = (Get-FileHash -LiteralPath $file -Algorithm SHA256).Hash
        }
    }

    $manifest | ConvertTo-Json -Depth 5 | Out-File -LiteralPath (Join-Path $backupDir 'manifest.json') -Encoding utf8

    Write-Host 'Backup completato:' -ForegroundColor Green
    Write-Host "  $backupDir" -ForegroundColor Cyan
    Write-Host ''
    Write-Host 'Sono stati salvati:' -ForegroundColor Gray
    Write-Host '  - i 3 file DLL'
    Write-Host '  - ACL/owner completi (.acl.xml)'
    Write-Host '  - output icacls leggibile'
    Write-Host '  - hash SHA-256 e manifest'
    Pause-Script
}

function Set-PatcherPermissions {
    Write-Header
    Write-Host '[3] MODIFICA OWNER E PERMESSI PER ULTRAUXTHEMEPATCHER' -ForegroundColor Yellow
    Write-Host ''

    if (-not (Test-ThemeFiles)) {
        Pause-Script
        return
    }

    Write-Host 'Questa operazione imposta:' -ForegroundColor Gray
    Write-Host '  Owner          -> BUILTIN\Administrators'
    Write-Host '  Administrators -> Full Control'
    Write-Host ''
    Write-Host 'Consiglio: esegui prima il backup (opzione 2).' -ForegroundColor Yellow
    Write-Host ''

    $confirm = Read-Host 'Continuare? Digita SI per confermare'
    if ($confirm -notmatch '^(?i:si|sì)$') {
        Write-Host 'Operazione annullata.' -ForegroundColor DarkYellow
        Pause-Script
        return
    }

    foreach ($file in $ThemeFiles) {
        Write-Host ''
        Write-Host "Elaborazione: $file" -ForegroundColor Cyan

        & takeown.exe /F $file /A | Out-Host
        if ($LASTEXITCODE -ne 0) {
            throw "takeown non riuscito su $file (codice $LASTEXITCODE)"
        }

        & icacls.exe $file /grant '*S-1-5-32-544:F' | Out-Host
        if ($LASTEXITCODE -ne 0) {
            throw "icacls /grant non riuscito su $file (codice $LASTEXITCODE)"
        }
    }

    Write-Host ''
    Write-Host 'Operazione completata.' -ForegroundColor Green
    Write-Host 'Ora puoi riavviare e lanciare UltraUXThemePatcher come amministratore.' -ForegroundColor Green
    Pause-Script
}

function Get-BackupFolders {
    if (-not (Test-Path -LiteralPath $Desktop)) {
        return @()
    }

    return @(
        Get-ChildItem -LiteralPath $Desktop -Directory -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -like ($BackupPrefix + '*') } |
        Sort-Object LastWriteTime -Descending
    )
}

function Restore-AclFromBackup {
    Write-Header
    Write-Host '[4] RIPRISTINA OWNER E PERMESSI DA BACKUP' -ForegroundColor Yellow
    Write-Host ''

    $backups = Get-BackupFolders
    if ($backups.Count -eq 0) {
        Write-Host "Nessun backup '$BackupPrefix*' trovato sul Desktop." -ForegroundColor Red
        Pause-Script
        return
    }

    Write-Host 'Backup disponibili:' -ForegroundColor Gray
    for ($i = 0; $i -lt $backups.Count; $i++) {
        Write-Host ("  [{0}] {1}   ({2})" -f ($i + 1), $backups[$i].Name, $backups[$i].LastWriteTime)
    }
    Write-Host ''

    $choice = Read-Host 'Numero del backup da usare (INVIO = piu recente)'
    if ([string]::IsNullOrWhiteSpace($choice)) {
        $selected = $backups[0]
    }
    else {
        $n = 0
        if (-not [int]::TryParse($choice, [ref]$n) -or $n -lt 1 -or $n -gt $backups.Count) {
            Write-Host 'Scelta non valida.' -ForegroundColor Red
            Pause-Script
            return
        }
        $selected = $backups[$n - 1]
    }

    Write-Host ''
    Write-Host "Ripristino ACL da: $($selected.FullName)" -ForegroundColor Cyan
    $confirm = Read-Host 'Continuare? Digita SI per confermare'
    if ($confirm -notmatch '^(?i:si|sì)$') {
        Write-Host 'Operazione annullata.' -ForegroundColor DarkYellow
        Pause-Script
        return
    }

    foreach ($file in $ThemeFiles) {
        $name = Split-Path $file -Leaf
        $aclFile = Join-Path $selected.FullName ($name + '.acl.xml')

        if (-not (Test-Path -LiteralPath $aclFile)) {
            Write-Host "ACL di backup mancante per ${name}: $aclFile" -ForegroundColor Red
            continue
        }

        try {
            $savedAcl = Import-Clixml -LiteralPath $aclFile

            & takeown.exe /F $file /A | Out-Null
            & icacls.exe $file /grant '*S-1-5-32-544:F' | Out-Null

            Set-Acl -LiteralPath $file -AclObject $savedAcl
            Write-Host "OK: $name -> ACL/owner ripristinati dal backup." -ForegroundColor Green
        }
        catch {
            Write-Host "ERRORE su ${name}: $($_.Exception.Message)" -ForegroundColor Red
        }
    }

    Write-Host ''
    Write-Host 'Ripristino completato. Riavvia Windows prima di ulteriori modifiche.' -ForegroundColor Green
    Pause-Script
}

function Restore-TrustedInstallerOwner {
    Write-Header
    Write-Host '[5] RIPRISTINA SOLO OWNER = TRUSTEDINSTALLER' -ForegroundColor Yellow
    Write-Host ''

    if (-not (Test-ThemeFiles)) {
        Pause-Script
        return
    }

    Write-Host 'ATTENZIONE:' -ForegroundColor Yellow
    Write-Host 'Questa opzione cambia SOLO il proprietario.' -ForegroundColor Yellow
    Write-Host 'Non rimuove eventuali Full Control aggiunti in precedenza.' -ForegroundColor Yellow
    Write-Host 'Per un ripristino completo usa l''opzione 4 con un backup pulito.' -ForegroundColor Yellow
    Write-Host ''

    $confirm = Read-Host 'Impostare TrustedInstaller come owner? Digita SI'
    if ($confirm -notmatch '^(?i:si|sì)$') {
        Write-Host 'Operazione annullata.' -ForegroundColor DarkYellow
        Pause-Script
        return
    }

    foreach ($file in $ThemeFiles) {
        & icacls.exe $file /setowner 'NT SERVICE\TrustedInstaller' | Out-Host
        if ($LASTEXITCODE -eq 0) {
            Write-Host "OK: $file" -ForegroundColor Green
        }
        else {
            Write-Host "ERRORE: $file (codice $LASTEXITCODE)" -ForegroundColor Red
        }
    }

    Pause-Script
}

do {
    Write-Header
    Write-Host '1 - Verifica owner e permessi'
    Write-Host '2 - Backup file originali + owner/ACL sul Desktop'
    Write-Host '3 - Modifica owner/permessi per UltraUXThemePatcher'
    Write-Host '4 - Ripristina owner/permessi da un backup'
    Write-Host '5 - Ripristina SOLO owner a TrustedInstaller'
    Write-Host '0 - Esci'
    Write-Host ''

    $selection = Read-Host 'Seleziona un''opzione'

    try {
        switch ($selection) {
            '1' { Show-Status }
            '2' { New-Backup }
            '3' { Set-PatcherPermissions }
            '4' { Restore-AclFromBackup }
            '5' { Restore-TrustedInstallerOwner }
            '0' { }
            default {
                Write-Host 'Opzione non valida.' -ForegroundColor Red
                Start-Sleep -Seconds 1
            }
        }
    }
    catch {
        Write-Host ''
        Write-Host "ERRORE: $($_.Exception.Message)" -ForegroundColor Red
        Pause-Script
    }

} while ($selection -ne '0')
