#Requires -Version 5.1
<#
    Install-SoftwareUpdateChecker.ps1
    Installa (o aggiorna, o disinstalla) Software Update Checker.

    Va eseguito COME AMMINISTRATORE, dalla cartella del repo:
        .\Install-SoftwareUpdateChecker.ps1               installa / aggiorna
        .\Install-SoftwareUpdateChecker.ps1 -Prova        installa e poi fa subito un controllo di prova
        .\Install-SoftwareUpdateChecker.ps1 -Disinstalla  toglie tutto (chiede se cancellare anche i dati)

    Cosa fa l'installazione:
      1. controlla lo script del repo (sintassi e codifica) PRIMA di copiarlo;
      2. lo copia in C:\Program Files\Software-Update-Checker\ (solo se è cambiato);
      3. prepara la cartella dei dati %LOCALAPPDATA%\Software-Update-Checker\
         (spostando lì config/liste/stato se sono ancora nella cartella del repo);
      4. crea il compito pianificato: a ogni accesso, dopo 6 minuti, con i permessi
         più elevati, senza finestre (conhost --headless). È lo SCRIPT a decidere
         se oggi va fatto il controllo (sabato, recupero dopo 7 giorni...);
      5. aggiorna il protocollo dei pulsanti delle notifiche;
      6. verifica che tutto sia al suo posto.
#>
[CmdletBinding()]
param(
    [switch]$Disinstalla,
    [switch]$Prova
)

$ErrorActionPreference = 'Stop'

# ---------------------------------------------------------------
#  PERCORSI E NOMI
# ---------------------------------------------------------------
$NomeScript      = 'Software-Update-Checker.ps1'
$Sorgente        = Join-Path $PSScriptRoot $NomeScript
$EsempioConfig   = Join-Path $PSScriptRoot 'config.example.json'
$CartellaProg    = Join-Path $env:ProgramFiles 'Software-Update-Checker'
$ScriptInstallato = Join-Path $CartellaProg $NomeScript
$CartellaDati    = Join-Path $env:LOCALAPPDATA 'Software-Update-Checker'
$PercorsoCompito = '\Personal-Admin-Tools\'
$NomeCompito     = 'Software Update Checker'
$NomeCompitoProva = 'Software Update Checker - prova'
$RitardoMinuti   = 6
$Protocollo      = 'software-update-checker'
$AppId           = 'Neonlinx.SoftwareUpdateChecker'
$Conhost         = Join-Path $env:SystemRoot 'System32\conhost.exe'
$PowerShell      = Join-Path $env:SystemRoot 'System32\WindowsPowerShell\v1.0\powershell.exe'

function Write-Passo  ([string]$t) { Write-Host ''; Write-Host "== $t" -ForegroundColor Cyan }
function Write-Ok     ([string]$t) { Write-Host "   [OK]     $t" -ForegroundColor Green }
function Write-Nota   ([string]$t) { Write-Host "   [INFO]   $t" -ForegroundColor Gray }
function Write-Avviso ([string]$t) { Write-Host "   [AVVISO] $t" -ForegroundColor Yellow }
function Write-Errore ([string]$t) { Write-Host "   [ERRORE] $t" -ForegroundColor Red }

function Get-ArgomentiPowerShell {
    <# Gli argomenti con cui il compito lancia lo script (senza finestre) #>
    param([string]$Extra = '')
    return ('--headless "{0}" -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File "{1}" {2}' -f $PowerShell, $ScriptInstallato, $Extra).TrimEnd()
}

function New-Compito {
    <# Crea (o sostituisce) un compito pianificato per l'utente corrente #>
    param([string]$Nome, [string]$Extra = '', [switch]$SenzaTrigger)

    $utente = [Security.Principal.WindowsIdentity]::GetCurrent().Name
    $azione = New-ScheduledTaskAction -Execute $Conhost -Argument (Get-ArgomentiPowerShell $Extra)
    $principale = New-ScheduledTaskPrincipal -UserId $utente -LogonType Interactive -RunLevel Highest
    $impostazioni = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries `
                        -StartWhenAvailable -MultipleInstances IgnoreNew `
                        -ExecutionTimeLimit (New-TimeSpan -Hours 3)

    $parametri = @{
        TaskName    = $Nome
        TaskPath    = $PercorsoCompito
        Action      = $azione
        Principal   = $principale
        Settings    = $impostazioni
        Description = 'Controlla gli aggiornamenti dei programmi con winget (Personal-Admin-Tools). Lo script decide da solo se oggi è il giorno del controllo.'
        Force       = $true
    }
    if (-not $SenzaTrigger) {
        $trigger = New-ScheduledTaskTrigger -AtLogOn -User $utente
        $trigger.Delay = "PT$($RitardoMinuti)M"     # formato ISO 8601: PT6M = 6 minuti
        $parametri.Trigger = $trigger
    }
    Register-ScheduledTask @parametri | Out-Null
}

function Set-Protocollo {
    <# Il protocollo dei pulsanti delle notifiche punta allo script installato #>
    $chiave = "HKCU:\Software\Classes\$Protocollo"
    $comando = '"{0}" --headless "{1}" -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File "{2}" -DaNotifica "%1"' -f $Conhost, $PowerShell, $ScriptInstallato
    New-Item -Path "$chiave\shell\open\command" -Force | Out-Null
    Set-Item -LiteralPath $chiave -Value 'URL:Software Update Checker'
    New-ItemProperty -LiteralPath $chiave -Name 'URL Protocol' -Value '' -PropertyType String -Force | Out-Null
    Set-Item -LiteralPath "$chiave\shell\open\command" -Value $comando
}

# ---------------------------------------------------------------
#  CONTROLLO: SERVONO I PERMESSI DA AMMINISTRATORE
# ---------------------------------------------------------------
$principale = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $principale.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Errore 'Serve PowerShell aperto COME AMMINISTRATORE (Program Files e compiti pianificati lo richiedono).'
    return
}

# ===============================================================
#  DISINSTALLAZIONE
# ===============================================================
if ($Disinstalla) {
    Write-Passo 'Disinstallazione di Software Update Checker'

    foreach ($n in $NomeCompito, $NomeCompitoProva) {
        if (Get-ScheduledTask -TaskName $n -TaskPath $PercorsoCompito -ErrorAction SilentlyContinue) {
            Unregister-ScheduledTask -TaskName $n -TaskPath $PercorsoCompito -Confirm:$false
            Write-Ok "Compito pianificato rimosso: $n"
        }
    }

    if (Test-Path -LiteralPath $CartellaProg) {
        Remove-Item -LiteralPath $CartellaProg -Recurse -Force
        Write-Ok "Cartella rimossa: $CartellaProg"
    }

    foreach ($k in "HKCU:\Software\Classes\$Protocollo", "HKCU:\Software\Classes\AppUserModelId\$AppId") {
        if (Test-Path -LiteralPath $k) { Remove-Item -LiteralPath $k -Recurse -Force; Write-Ok "Chiave di registro rimossa: $k" }
    }

    if (Test-Path -LiteralPath $CartellaDati) {
        Write-Host ''
        Write-Host "   La cartella dei dati contiene le tue liste, la memoria dei controlli e la configurazione:" -ForegroundColor Yellow
        Write-Host "   $CartellaDati" -ForegroundColor Yellow
        $r = Read-Host '   Vuoi cancellare anche questa? (s/N)'
        if ($r -match '^[sS]') { Remove-Item -LiteralPath $CartellaDati -Recurse -Force; Write-Ok 'Cartella dei dati rimossa.' }
        else { Write-Nota 'Cartella dei dati conservata.' }
    }
    Write-Nota 'I report e i log nella cartella dei report NON vengono mai toccati.'
    Write-Nota 'Ricordati di togliere anche le voci del menu Nilesoft (o di rifare il Deploy).'
    return
}

# ===============================================================
#  INSTALLAZIONE / AGGIORNAMENTO
# ===============================================================
$errori = 0

# --- 1. Controllo dello script del repo ---------------------------
Write-Passo '1. Controllo dello script da installare'
if (-not (Test-Path -LiteralPath $Sorgente)) { Write-Errore "Non trovo $Sorgente"; return }

$byte = [IO.File]::ReadAllBytes($Sorgente)
if ($byte.Length -lt 3 -or $byte[0] -ne 0xEF -or $byte[1] -ne 0xBB -or $byte[2] -ne 0xBF) {
    Write-Errore 'Lo script non è salvato in UTF-8 con BOM: Windows PowerShell 5.1 leggerebbe male le lettere accentate.'
    return
}
Write-Ok 'Codifica UTF-8 con BOM.'

$erroriSintassi = $null
[void][Management.Automation.Language.Parser]::ParseFile($Sorgente, [ref]$null, [ref]$erroriSintassi)
if ($erroriSintassi.Count) {
    Write-Errore "Lo script contiene $($erroriSintassi.Count) errori di sintassi: installazione annullata."
    $erroriSintassi | Select-Object -First 5 | ForEach-Object { Write-Errore ("riga {0}: {1}" -f $_.Extent.StartLineNumber, $_.Message) }
    return
}
Write-Ok 'Sintassi corretta.'

# --- 2. Copia in Program Files ------------------------------------
Write-Passo "2. Copia in $CartellaProg"
if (-not (Test-Path -LiteralPath $CartellaProg)) { New-Item -ItemType Directory -Path $CartellaProg | Out-Null }

$daCopiare = @($Sorgente)
if (Test-Path -LiteralPath $EsempioConfig) { $daCopiare += $EsempioConfig }
foreach ($f in $daCopiare) {
    $dest = Join-Path $CartellaProg (Split-Path $f -Leaf)
    if (-not (Test-Path -LiteralPath $dest)) {
        Copy-Item -LiteralPath $f -Destination $dest
        Write-Ok "Nuovo: $(Split-Path $f -Leaf)"
    }
    elseif ((Get-FileHash -LiteralPath $f).Hash -ne (Get-FileHash -LiteralPath $dest).Hash) {
        Copy-Item -LiteralPath $dest -Destination "$dest.precedente" -Force     # la versione di prima, per sicurezza
        Copy-Item -LiteralPath $f -Destination $dest -Force
        Write-Ok "Aggiornato: $(Split-Path $f -Leaf) (la versione precedente è in $(Split-Path $f -Leaf).precedente)"
    }
    else {
        Write-Nota "Identico, non copiato: $(Split-Path $f -Leaf)"
    }
}

# --- 3. Cartella dei dati -----------------------------------------
Write-Passo "3. Cartella dei dati: $CartellaDati"
if (-not (Test-Path -LiteralPath $CartellaDati)) { New-Item -ItemType Directory -Path $CartellaDati | Out-Null }
foreach ($nome in 'config.json', 'liste.json', 'stato.json') {
    $vecchio = Join-Path $PSScriptRoot $nome
    $nuovo   = Join-Path $CartellaDati $nome
    if (Test-Path -LiteralPath $nuovo) {
        Write-Ok "$nome presente."
        if (Test-Path -LiteralPath $vecchio) { Write-Avviso "Esiste ancora una vecchia copia nel repo ($vecchio): non è più usata." }
    }
    elseif (Test-Path -LiteralPath $vecchio) {
        Copy-Item -LiteralPath $vecchio -Destination $nuovo
        Rename-Item -LiteralPath $vecchio -NewName "$nome.migrato.bak"
        Write-Ok "$nome spostato dal repo (l'originale ora si chiama $nome.migrato.bak)."
    }
    elseif ($nome -eq 'config.json' -and (Test-Path -LiteralPath $EsempioConfig)) {
        Copy-Item -LiteralPath $EsempioConfig -Destination $nuovo
        Write-Avviso "config.json creato dall'esempio: aprilo e controlla CartellaReport."
    }
    else {
        Write-Nota "$nome non c'è ancora: lo creerà lo script al primo controllo."
    }
}

# --- 4. Compito pianificato ---------------------------------------
Write-Passo '4. Compito pianificato'
try {
    New-Compito -Nome $NomeCompito
    Write-Ok "Creato/aggiornato: $PercorsoCompito$NomeCompito"
}
catch { Write-Errore "Compito non creato: $($_.Exception.Message)"; $errori++ }

# --- 5. Protocollo delle notifiche --------------------------------
Write-Passo '5. Pulsanti delle notifiche'
try { Set-Protocollo; Write-Ok "Il protocollo $($Protocollo): punta allo script installato." }
catch { Write-Errore "Protocollo non aggiornato: $($_.Exception.Message)"; $errori++ }

# --- 6. Verifica finale -------------------------------------------
Write-Passo '6. Verifica'
if (Test-Path -LiteralPath $ScriptInstallato) { Write-Ok "Script installato: $ScriptInstallato" } else { Write-Errore 'Script installato mancante.'; $errori++ }
if (Test-Path -LiteralPath (Join-Path $CartellaDati 'config.json')) { Write-Ok 'config.json presente nella cartella dei dati.' } else { Write-Errore 'config.json mancante.'; $errori++ }

$compito = Get-ScheduledTask -TaskName $NomeCompito -TaskPath $PercorsoCompito -ErrorAction SilentlyContinue
if ($compito) {
    $t = $compito.Triggers | Select-Object -First 1
    Write-Ok ("Compito: stato {0}, utente {1}, permessi {2}" -f $compito.State, $compito.Principal.UserId, $compito.Principal.RunLevel)
    Write-Ok ("Avvio: all'accesso, ritardo {0}" -f $t.Delay)
    Write-Nota ("Comando: {0} {1}" -f $compito.Actions[0].Execute, $compito.Actions[0].Arguments)
}
else { Write-Errore 'Il compito pianificato non risulta registrato.'; $errori++ }

Write-Host ''
if ($errori) { Write-Host "Installazione completata con $errori errori: leggi sopra." -ForegroundColor Red; return }
Write-Host 'Installazione completata.' -ForegroundColor Green

# ===============================================================
#  PROVA (facoltativa): un controllo vero, nelle stesse condizioni del sabato
# ===============================================================
if ($Prova) {
    Write-Passo 'Prova: controllo completo (-Forza) lanciato dal Pianificatore, come al sabato'
    Write-Nota 'Usa un compito temporaneo identico al vero, ma con -Forza (così parte anche oggi).'
    Write-Nota 'Se si apre la finestra, l''installatore aspetta che tu la chiuda.'
    try {
        New-Compito -Nome $NomeCompitoProva -Extra '-Forza' -SenzaTrigger
        Start-ScheduledTask -TaskName $NomeCompitoProva -TaskPath $PercorsoCompito
        $inizio = Get-Date
        Start-Sleep -Seconds 3
        while ((Get-ScheduledTask -TaskName $NomeCompitoProva -TaskPath $PercorsoCompito).State -eq 'Running') {
            Write-Host ("`r   In corso da {0:mm\:ss} ..." -f ((Get-Date) - $inizio)) -NoNewline
            Start-Sleep -Seconds 5
            if (((Get-Date) - $inizio).TotalMinutes -gt 120) { Write-Host ''; Write-Avviso 'Più di 2 ore: smetto di aspettare.'; break }
        }
        Write-Host ''
        $info = Get-ScheduledTaskInfo -TaskName $NomeCompitoProva -TaskPath $PercorsoCompito
        if ($info.LastTaskResult -eq 0) { Write-Ok 'Prova terminata correttamente (codice 0).' }
        else { Write-Avviso ("Prova terminata con codice 0x{0:X8}: guarda il file Errori del mese." -f $info.LastTaskResult) }
    }
    catch { Write-Errore "Prova non riuscita: $($_.Exception.Message)" }
    finally {
        Unregister-ScheduledTask -TaskName $NomeCompitoProva -TaskPath $PercorsoCompito -Confirm:$false -ErrorAction SilentlyContinue
        Write-Nota 'Compito temporaneo di prova rimosso.'
    }
}
