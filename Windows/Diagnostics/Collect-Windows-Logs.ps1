<#
    Collect-Windows-Logs.ps1

    Script generico per raccogliere log utili di Windows:
    - CBS.log e CbsPersist*
    - WindowsUpdate.log generato da Get-WindowsUpdateLog
    - Eventi System filtrati
    - Eventi Application filtrati
    - Informazioni opzionali su file specifici
    - Filtro opzionale per pattern personalizzati

    Uso consigliato:
    1. Avvia PowerShell come amministratore
    2. Esegui:
       .\Collect-Windows-Logs.ps1

    Nota:
    nei pattern puoi usare il simbolo | per separare più parole, esempio:
    uxtheme|themeui|uxinit|TrustedInstaller|repair|hash mismatch
	
	Quando ti chiede i pattern, puoi mettere per esempio:
	uxtheme|themeui|uxinit|TrustedInstaller|TiWorker|repair|hash mismatch
	
	Oppure per problemi USB:
	USB|Kernel-PnP|DriverFrameworks|Disk|Event ID 153|Event ID 51|explorer.exe

	Da PowerShell amministratore, se lo salvi sul Desktop:
	cd $env:USERPROFILE\Desktop
    .\Collect-Windows-Logs.ps1
	
	Se PowerShell blocca l’esecuzione degli script, solo per quella sessione puoi fare:
	Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
#>

Clear-Host

Write-Host "==============================================="
Write-Host " Collect Windows Logs - diagnostica generica"
Write-Host "==============================================="
Write-Host ""

# Desktop utente
$Desktop = [Environment]::GetFolderPath("Desktop")

# Timestamp cartella
$Timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$OutputRoot = Join-Path $Desktop "Diagnosi_WindowsLogs_$Timestamp"

New-Item -ItemType Directory -Path $OutputRoot -Force | Out-Null

Write-Host "Cartella output:"
Write-Host $OutputRoot
Write-Host ""

# Giorni da analizzare
$DaysInput = Read-Host "Quanti giorni indietro vuoi analizzare? Premi INVIO per default 14"
if ([string]::IsNullOrWhiteSpace($DaysInput)) {
    $Days = 14
} else {
    [int]$Days = $DaysInput
}

$StartDate = (Get-Date).AddDays(-$Days)

Write-Host ""
Write-Host "Analisi eventi da: $StartDate"
Write-Host ""

# Pattern opzionali
Write-Host "Vuoi inserire pattern personalizzati per filtrare CBS/eventi?"
Write-Host "Esempio: uxtheme|themeui|uxinit|TrustedInstaller|repair|hash mismatch"
$PatternInput = Read-Host "Pattern opzionali, oppure INVIO per saltare"

$UsePatterns = -not [string]::IsNullOrWhiteSpace($PatternInput)

if ($UsePatterns) {
    $CustomPatterns = $PatternInput
    Write-Host ""
    Write-Host "Pattern usati:"
    Write-Host $CustomPatterns
} else {
    $CustomPatterns = $null
    Write-Host ""
    Write-Host "Nessun pattern personalizzato inserito."
}

Write-Host ""

# ============================================================
# 1) Copia CBS.log e CbsPersist*
# ============================================================

Write-Host "[1/7] Copio i log CBS..."

$CBSFolder = "C:\Windows\Logs\CBS"
$CBSOut = Join-Path $OutputRoot "CBS_logs"
New-Item -ItemType Directory -Path $CBSOut -Force | Out-Null

Copy-Item "$CBSFolder\CBS.log" $CBSOut -ErrorAction SilentlyContinue
Copy-Item "$CBSFolder\CbsPersist*" $CBSOut -ErrorAction SilentlyContinue

$CBSZip = Join-Path $OutputRoot "CBS_logs.zip"

try {
    Compress-Archive -Path "$CBSOut\*" -DestinationPath $CBSZip -Force -ErrorAction Stop
} catch {
    "Errore nella compressione dei log CBS: $($_.Exception.Message)" |
        Out-File (Join-Path $OutputRoot "ERRORE_CBS_zip.txt") -Encoding UTF8
}

# ============================================================
# 2) Filtro opzionale sul CBS.log
# ============================================================

Write-Host "[2/7] Creo eventuale CBS filtrato..."

$CBSLogPath = "C:\Windows\Logs\CBS\CBS.log"
$CBSFilteredOut = Join-Path $OutputRoot "CBS_filtrato_pattern.txt"

if ($UsePatterns -and (Test-Path $CBSLogPath)) {
    Select-String -Path $CBSLogPath -Pattern $CustomPatterns -ErrorAction SilentlyContinue |
        Select-Object LineNumber, Line |
        Out-File $CBSFilteredOut -Encoding UTF8
} else {
    @"
Nessun filtro CBS eseguito.

Per usare il filtro, rilancia lo script e inserisci pattern separati da |, esempio:

uxtheme|themeui|uxinit|TrustedInstaller|repair|hash mismatch
"@ | Out-File $CBSFilteredOut -Encoding UTF8
}

# ============================================================
# 3) Genera WindowsUpdate.log
# ============================================================

Write-Host "[3/7] Genero WindowsUpdate.log..."

$WUOut = Join-Path $OutputRoot "WindowsUpdate.log"

try {
    Get-WindowsUpdateLog -LogPath $WUOut -ErrorAction Stop
} catch {
    "Errore durante Get-WindowsUpdateLog: $($_.Exception.Message)" |
        Out-File (Join-Path $OutputRoot "ERRORE_WindowsUpdateLog.txt") -Encoding UTF8
}

# ============================================================
# 4) Eventi System generici
# ============================================================

Write-Host "[4/7] Esporto eventi System rilevanti..."

$SystemOut = Join-Path $OutputRoot "Eventi_System_generici.txt"

$SystemProviders = @(
    'Microsoft-Windows-WindowsUpdateClient',
    'Microsoft-Windows-Servicing',
    'Microsoft-Windows-Wininit',
    'Microsoft-Windows-Kernel-General',
    'Microsoft-Windows-Kernel-PnP',
    'Microsoft-Windows-UserPnp',
    'Microsoft-Windows-DriverFrameworks-UserMode',
    'Disk',
    'Ntfs',
    'Service Control Manager',
    'EventLog'
)

$SystemBasePattern = 'TrustedInstaller|Windows Modules Installer|servicing|update|SFC|DISM|repair|restore|corrupt|hash|disk|USB|PnP|driver'

if ($UsePatterns) {
    $SystemPattern = "$SystemBasePattern|$CustomPatterns"
} else {
    $SystemPattern = $SystemBasePattern
}

try {
    Get-WinEvent -FilterHashtable @{
        LogName   = 'System'
        StartTime = $StartDate
    } -ErrorAction Stop |
    Where-Object {
        $SystemProviders -contains $_.ProviderName -or
        $_.Message -match $SystemPattern
    } |
    Select-Object TimeCreated, Id, ProviderName, LevelDisplayName, Message |
    Out-File $SystemOut -Encoding UTF8
} catch {
    "Errore esportazione eventi System: $($_.Exception.Message)" |
        Out-File (Join-Path $OutputRoot "ERRORE_Eventi_System.txt") -Encoding UTF8
}

# ============================================================
# 5) Eventi Application generici
# ============================================================

Write-Host "[5/7] Esporto eventi Application rilevanti..."

$ApplicationOut = Join-Path $OutputRoot "Eventi_Application_generici.txt"

$ApplicationProviderPattern = 'Windows Error Reporting|Application Error|MsiInstaller|Application Hang|RestartManager'
$ApplicationBasePattern = 'explorer.exe|crash|faulting|errore|installer|MSI|repair|restore|update|TrustedInstaller|servicing'

if ($UsePatterns) {
    $ApplicationPattern = "$ApplicationBasePattern|$CustomPatterns"
} else {
    $ApplicationPattern = $ApplicationBasePattern
}

try {
    Get-WinEvent -FilterHashtable @{
        LogName   = 'Application'
        StartTime = $StartDate
    } -ErrorAction Stop |
    Where-Object {
        $_.ProviderName -match $ApplicationProviderPattern -or
        $_.Message -match $ApplicationPattern
    } |
    Select-Object TimeCreated, Id, ProviderName, LevelDisplayName, Message |
    Out-File $ApplicationOut -Encoding UTF8
} catch {
    "Errore esportazione eventi Application: $($_.Exception.Message)" |
        Out-File (Join-Path $OutputRoot "ERRORE_Eventi_Application.txt") -Encoding UTF8
}

# ============================================================
# 6) Eventi Windows Update specifici, se log disponibili
# ============================================================

Write-Host "[6/7] Esporto eventi Windows Update dedicati..."

$WUEventsOut = Join-Path $OutputRoot "Eventi_WindowsUpdateClient.txt"

try {
    Get-WinEvent -FilterHashtable @{
        LogName      = 'System'
        ProviderName = 'Microsoft-Windows-WindowsUpdateClient'
        StartTime    = $StartDate
    } -ErrorAction Stop |
    Select-Object TimeCreated, Id, ProviderName, LevelDisplayName, Message |
    Out-File $WUEventsOut -Encoding UTF8
} catch {
    "Errore esportazione eventi WindowsUpdateClient: $($_.Exception.Message)" |
        Out-File (Join-Path $OutputRoot "ERRORE_Eventi_WindowsUpdateClient.txt") -Encoding UTF8
}

# ============================================================
# 7) Info opzionali su file specifici
# ============================================================

Write-Host "[7/7] Raccolta info opzionali su file specifici..."

Write-Host ""
Write-Host "Vuoi controllare info/hash di file specifici?"
Write-Host "Esempio:"
Write-Host "C:\Windows\System32\uxtheme.dll,C:\Windows\System32\themeui.dll"
$FilesInput = Read-Host "Percorsi file separati da virgola, oppure INVIO per saltare"

$FilesOut = Join-Path $OutputRoot "File_info_hash.txt"

if (-not [string]::IsNullOrWhiteSpace($FilesInput)) {
    $Files = $FilesInput.Split(",") | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne "" }

    $Results = foreach ($File in $Files) {
        if (Test-Path $File) {
            $Item = Get-Item $File
            $Hash = Get-FileHash $File -Algorithm SHA256

            [PSCustomObject]@{
                File          = $Item.FullName
                Exists        = $true
                LastWriteTime = $Item.LastWriteTime
                Length        = $Item.Length
                Version       = $Item.VersionInfo.FileVersion
                SHA256        = $Hash.Hash
            }
        } else {
            [PSCustomObject]@{
                File          = $File
                Exists        = $false
                LastWriteTime = $null
                Length        = $null
                Version       = $null
                SHA256        = $null
            }
        }
    }

    $Results | Format-List | Out-File $FilesOut -Encoding UTF8
} else {
    @"
Nessun file specifico controllato.

Puoi rilanciare lo script e inserire percorsi separati da virgola, esempio:

C:\Windows\System32\uxtheme.dll,C:\Windows\System32\themeui.dll,C:\Windows\System32\uxinit.dll
"@ | Out-File $FilesOut -Encoding UTF8
}

# ============================================================
# Crea riepilogo
# ============================================================

Write-Host ""
Write-Host "Creo riepilogo..."

$SummaryOut = Join-Path $OutputRoot "RIEPILOGO.txt"

@"
Diagnosi Windows Logs
=====================

Data esecuzione:
$(Get-Date)

Giorni analizzati:
$Days

Data inizio analisi eventi:
$StartDate

Pattern personalizzati usati:
$(if ($UsePatterns) { $CustomPatterns } else { "Nessuno" })

Cartella output:
$OutputRoot

File principali creati:
- CBS_logs.zip
- CBS_filtrato_pattern.txt
- WindowsUpdate.log
- Eventi_System_generici.txt
- Eventi_Application_generici.txt
- Eventi_WindowsUpdateClient.txt
- File_info_hash.txt

Note:
- CBS_logs.zip contiene CBS.log e CbsPersist*, se presenti.
- WindowsUpdate.log viene generato tramite Get-WindowsUpdateLog.
- I file Eventi_* contengono eventi degli ultimi giorni selezionati.
- CBS_filtrato_pattern.txt contiene solo le righe CBS che corrispondono ai pattern inseriti.
"@ | Out-File $SummaryOut -Encoding UTF8

# ============================================================
# Comprimi tutto
# ============================================================

Write-Host "Comprimo il pacchetto finale..."

$FinalZip = Join-Path $Desktop "Diagnosi_WindowsLogs_$Timestamp.zip"

try {
    Compress-Archive -Path "$OutputRoot\*" -DestinationPath $FinalZip -Force -ErrorAction Stop
    Write-Host ""
    Write-Host "==============================================="
    Write-Host " Finito!"
    Write-Host "==============================================="
    Write-Host ""
    Write-Host "Pacchetto creato:"
    Write-Host $FinalZip
    Write-Host ""
} catch {
    Write-Host ""
    Write-Host "Errore durante la compressione finale:"
    Write-Host $_.Exception.Message
    Write-Host ""
    Write-Host "I file sono comunque nella cartella:"
    Write-Host $OutputRoot
}

Pause