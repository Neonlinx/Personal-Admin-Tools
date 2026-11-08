#Requires -Version 5.1
<#
    Deploy-NilesoftConfig.ps1
    Installa la configurazione di Nilesoft Shell dal repository a Program Files,
    dopo aver verificato che non contenga gli errori che fanno scartare a Nilesoft
    l'INTERA configurazione.

    Controlli eseguiti su shell.nss e su ogni file in imports\:
      1. BOM UTF-8 presente e UNICO (un BOM doppio blocca tutto)
      2. Parentesi ( ), graffe { } e virgolette bilanciate
      3. Ogni "import" punta a un file che esiste
      4. Nessun type= sconosciuto (es. type='unknown' blocca tutto)
      5. Avviso per le icone a glifo \uE... (non vengono disegnate)

    Se il controllo passa:
      - salva un backup della configurazione installata (cartella _backup\)
      - copia PRIMA i file di imports\ e PER ULTIMO shell.nss
        (Nilesoft ricarica appena shell.nss cambia: i file importati devono già esserci)
      - controlla shell.log per eventuali errori nuovi

    Parametri:
      -SoloVerifica : esegue solo i controlli, non copia nulla
      -Ripristina   : rimette in Program Files l'ultimo backup (annulla l'ultima installazione)
      -Destinazione : cartella di Nilesoft (predefinita: C:\Program Files\Nilesoft Shell)
#>
[CmdletBinding()]
param(
    [switch]$SoloVerifica,
    [switch]$Ripristina,
    [string]$Destinazione = 'C:\Program Files\Nilesoft Shell',
    [int]$BackupDaConservare = 10
)

$ErrorActionPreference = 'Stop'

$Sorgente        = $PSScriptRoot
$CartellaImports = Join-Path $Sorgente 'imports'
$FileShell       = Join-Path $Sorgente 'shell.nss'
$CartellaBackup  = Join-Path $Sorgente '_backup'

# Tipi di oggetto che sappiamo essere accettati da Nilesoft (collaudati sul campo)
# (i tipi composti come 'file|dir' vengono divisi e controllati pezzo per pezzo)
$TipiNoti = @('file', 'dir', 'drive', 'desktop', 'namespace', 'back', 'back.dir',
              'back.directory', 'back.drive', 'taskbar', '*')

$script:Errori = 0
$script:Avvisi = 0

function Write-Esito {
    param([ValidateSet('OK','AVVISO','ERRORE','INFO')][string]$Livello, [string]$Messaggio)
    $colore = switch ($Livello) { 'OK' {'Green'} 'AVVISO' {'Yellow'} 'ERRORE' {'Red'} default {'Gray'} }
    Write-Host ('  [{0,-6}] {1}' -f $Livello, $Messaggio) -ForegroundColor $colore
    if ($Livello -eq 'ERRORE') { $script:Errori++ }
    if ($Livello -eq 'AVVISO') { $script:Avvisi++ }
}

function Test-Bom {
    <# 1 = un solo BOM (giusto), 0 = nessun BOM, 2 = BOM doppio, -1 = altra codifica (UTF-16) #>
    param([byte[]]$Byte)
    if ($Byte.Length -ge 2 -and (($Byte[0] -eq 0xFF -and $Byte[1] -eq 0xFE) -or ($Byte[0] -eq 0xFE -and $Byte[1] -eq 0xFF))) { return -1 }
    $bom = 0
    $i = 0
    while ($i + 2 -lt $Byte.Length -and $Byte[$i] -eq 0xEF -and $Byte[$i + 1] -eq 0xBB -and $Byte[$i + 2] -eq 0xBF) {
        $bom++
        $i += 3
    }
    return $bom
}

function Get-TestoSenzaCommenti {
    <#
        Restituisce il testo con i commenti // e /* */ sostituiti da spazi
        (le stringhe restano intatte) e controlla il bilanciamento.
    #>
    param([string]$Testo)

    $sb = New-Object System.Text.StringBuilder
    $tonde = 0; $graffe = 0
    $virgoletta = [char]0
    $rigaApertura = 0
    $riga = 1
    $i = 0
    $n = $Testo.Length

    while ($i -lt $n) {
        $c = $Testo[$i]
        if ($c -eq "`n") { $riga++ }

        if ($virgoletta -ne [char]0) {
            if ($c -eq '\' -and $virgoletta -eq '"' -and $i + 1 -lt $n) {
                [void]$sb.Append($c).Append($Testo[$i + 1]); $i += 2; continue
            }
            if ($c -eq $virgoletta) { $virgoletta = [char]0 }
            [void]$sb.Append($c); $i++; continue
        }

        if ($c -eq '/' -and $i + 1 -lt $n -and $Testo[$i + 1] -eq '/') {
            while ($i -lt $n -and $Testo[$i] -ne "`n") { [void]$sb.Append(' '); $i++ }
            continue
        }
        if ($c -eq '/' -and $i + 1 -lt $n -and $Testo[$i + 1] -eq '*') {
            $fine = $Testo.IndexOf('*/', $i + 2)
            if ($fine -lt 0) { $fine = $n - 2 }
            for ($k = $i; $k -lt $fine + 2; $k++) {
                if ($Testo[$k] -eq "`n") { $riga++; [void]$sb.Append("`n") } else { [void]$sb.Append(' ') }
            }
            $i = $fine + 2
            continue
        }

        switch ($c) {
            "'" { $virgoletta = $c; $rigaApertura = $riga }
            '"' { $virgoletta = $c; $rigaApertura = $riga }
            '(' { $tonde++ }
            ')' { $tonde-- }
            '{' { $graffe++ }
            '}' { $graffe-- }
        }
        [void]$sb.Append($c)
        $i++
    }

    return [pscustomobject]@{
        Testo            = $sb.ToString()
        Tonde            = $tonde
        Graffe           = $graffe
        VirgolettaAperta = ($virgoletta -ne [char]0)
        RigaVirgoletta   = $rigaApertura
    }
}

function Test-FileNss {
    param([string]$Percorso)

    $nome = Split-Path $Percorso -Leaf
    Write-Host ''
    Write-Host "  $nome" -ForegroundColor Cyan

    $byte = [IO.File]::ReadAllBytes($Percorso)
    switch (Test-Bom $byte) {
        1       { Write-Esito OK 'Un solo BOM UTF-8' }
        0       { Write-Esito AVVISO 'Nessun BOM: gli accenti potrebbero essere letti male' }
        2       { Write-Esito ERRORE 'BOM DOPPIO: Nilesoft scarterebbe tutta la configurazione' }
        -1      { Write-Esito ERRORE 'Codifica UTF-16: va salvato come UTF-8 con BOM' }
        default { Write-Esito ERRORE 'Più di due BOM all''inizio del file' }
    }

    $testo = [IO.File]::ReadAllText($Percorso, [Text.Encoding]::UTF8).TrimStart([char]0xFEFF)
    $analisi = Get-TestoSenzaCommenti $testo

    if ($analisi.VirgolettaAperta) { Write-Esito ERRORE "Virgoletta non chiusa (aperta alla riga $($analisi.RigaVirgoletta))" }
    if ($analisi.Tonde -ne 0)      { Write-Esito ERRORE "Parentesi tonde sbilanciate (differenza: $($analisi.Tonde))" }
    if ($analisi.Graffe -ne 0)     { Write-Esito ERRORE "Parentesi graffe sbilanciate (differenza: $($analisi.Graffe))" }
    if (-not $analisi.VirgolettaAperta -and $analisi.Tonde -eq 0 -and $analisi.Graffe -eq 0) {
        Write-Esito OK 'Parentesi, graffe e virgolette bilanciate'
    }

    # Import: devono esistere. Il percorso è relativo alla cartella del file che importa
    # (shell.nss importa 'imports/x.nss'; un file dentro imports\ importa direttamente 'x.nss')
    $cartellaFile = Split-Path $Percorso -Parent
    foreach ($m in [regex]::Matches($analisi.Testo, "import\s+'([^']+)'")) {
        $rel = $m.Groups[1].Value -replace '/', '\'
        if (Test-Path -LiteralPath (Join-Path $cartellaFile $rel)) { Write-Esito OK "Import trovato: $($m.Groups[1].Value)" }
        else { Write-Esito ERRORE "Import di un file che NON esiste: $($m.Groups[1].Value)" }
    }

    # type= sconosciuti
    foreach ($m in [regex]::Matches($analisi.Testo, "\btype\s*=\s*'([^']*)'")) {
        foreach ($parte in ($m.Groups[1].Value.ToLower() -split '\|')) {
            $parte = $parte.Trim()
            if ($parte -eq 'unknown') { Write-Esito ERRORE "type='unknown' non è accettato da Nilesoft" }
            elseif ($TipiNoti -notcontains $parte) { Write-Esito AVVISO "type '$parte' mai collaudato: verifica il log dopo l'installazione" }
        }
    }

    # Icone a glifo: quelle del font di Nilesoft (\uE0xx-\uE2xx) funzionano,
    # quelle di Segoe (\uE7xx-\uE9xx, es. \uE71D \uE770 \uE8B7) non vengono disegnate
    $glifi = [regex]::Matches($analisi.Testo, 'image\s*=\s*\[?\\u[Ee][7-9][0-9A-Fa-f]{2}').Count
    if ($glifi -gt 0) { Write-Esito AVVISO "$glifi icone a glifo Segoe (\uE7..-\uE9..): non vengono disegnate, meglio icon.nome" }
}

function Test-Amministratore {
    $principale = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    return $principale.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# ---------------------------------------------------------------
#  0) RIPRISTINO DELL'ULTIMO BACKUP (solo con -Ripristina)
# ---------------------------------------------------------------
if ($Ripristina) {
    if (-not (Test-Amministratore)) {
        Write-Host '  Servono i permessi di amministratore: apri PowerShell come amministratore.' -ForegroundColor Red
        exit 1
    }
    $ultimo = Get-ChildItem -LiteralPath $CartellaBackup -Directory -ErrorAction SilentlyContinue |
              Sort-Object Name -Descending | Select-Object -First 1
    if (-not $ultimo) { Write-Host '  Nessun backup trovato in _backup\' -ForegroundColor Red; exit 1 }

    Write-Host ''
    Write-Host "=== RIPRISTINO DEL BACKUP $($ultimo.Name) ===" -ForegroundColor Cyan
    Get-ChildItem -LiteralPath (Join-Path $ultimo.FullName 'imports') -Filter '*.nss' -File |
        Copy-Item -Destination (Join-Path $Destinazione 'imports') -Force
    Copy-Item -LiteralPath (Join-Path $ultimo.FullName 'shell.nss') -Destination (Join-Path $Destinazione 'shell.nss') -Force
    Write-Esito OK "Configurazione del $($ultimo.Name) rimessa in $Destinazione (prima imports, poi shell.nss)"
    Write-Host '  Il backup resta in _backup\: puoi ripristinarlo di nuovo quando vuoi.' -ForegroundColor Gray
    exit 0
}

# ---------------------------------------------------------------
#  1) VERIFICA
# ---------------------------------------------------------------
Write-Host ''
Write-Host '=== VERIFICA DELLA CONFIGURAZIONE ===' -ForegroundColor Cyan
Write-Host "  Sorgente: $Sorgente"

if (-not (Test-Path -LiteralPath $FileShell)) { throw "shell.nss non trovato in $Sorgente" }
if (-not (Test-Path -LiteralPath $CartellaImports)) { throw "Cartella imports non trovata in $Sorgente" }

$fileImports = @(Get-ChildItem -LiteralPath $CartellaImports -Filter '*.nss' -File | Sort-Object Name)
Test-FileNss $FileShell
foreach ($f in $fileImports) { Test-FileNss $f.FullName }

Write-Host ''
Write-Host ('=== ESITO: {0} errori, {1} avvisi, {2} file controllati ===' -f $script:Errori, $script:Avvisi, ($fileImports.Count + 1)) `
    -ForegroundColor $(if ($script:Errori) { 'Red' } elseif ($script:Avvisi) { 'Yellow' } else { 'Green' })

if ($script:Errori -gt 0) {
    Write-Host '  Installazione ANNULLATA: correggi gli errori e riprova. Nulla è stato modificato.' -ForegroundColor Red
    exit 1
}
if ($SoloVerifica) {
    Write-Host '  Modalità -SoloVerifica: nessun file copiato.' -ForegroundColor Gray
    exit 0
}

# ---------------------------------------------------------------
#  2) INSTALLAZIONE
# ---------------------------------------------------------------
if (-not (Test-Amministratore)) {
    Write-Host '  Servono i permessi di amministratore per scrivere in Program Files.' -ForegroundColor Red
    Write-Host '  Apri PowerShell con "Esegui come amministratore" e rilancia lo script.' -ForegroundColor Red
    exit 1
}

$destImports = Join-Path $Destinazione 'imports'
if (-not (Test-Path -LiteralPath $destImports)) { throw "Cartella di Nilesoft non trovata: $destImports" }

Write-Host ''
Write-Host '=== INSTALLAZIONE ===' -ForegroundColor Cyan

# Backup della configurazione attualmente installata
$timbro   = Get-Date -Format 'yyyy-MM-dd_HHmmss'
$dirBackup = Join-Path $CartellaBackup $timbro
New-Item -ItemType Directory -Path (Join-Path $dirBackup 'imports') -Force | Out-Null
Copy-Item -LiteralPath (Join-Path $Destinazione 'shell.nss') -Destination $dirBackup
Get-ChildItem -LiteralPath $destImports -Filter '*.nss' -File | Copy-Item -Destination (Join-Path $dirBackup 'imports')
Write-Esito OK "Backup della configurazione installata: _backup\$timbro"

# Conserva solo gli ultimi N backup
$vecchi = @(Get-ChildItem -LiteralPath $CartellaBackup -Directory | Sort-Object Name -Descending | Select-Object -Skip $BackupDaConservare)
foreach ($v in $vecchi) { Remove-Item -LiteralPath $v.FullName -Recurse -Force }
if ($vecchi.Count) { Write-Esito INFO "Eliminati $($vecchi.Count) backup più vecchi (ne conservo $BackupDaConservare)" }

$inizio = Get-Date

# PRIMA gli imports...
$copiati = 0
foreach ($f in $fileImports) {
    $dest = Join-Path $destImports $f.Name
    $uguale = (Test-Path -LiteralPath $dest) -and
              ((Get-FileHash -LiteralPath $dest).Hash -eq (Get-FileHash -LiteralPath $f.FullName).Hash)
    if (-not $uguale) {
        Copy-Item -LiteralPath $f.FullName -Destination $dest -Force
        Write-Esito OK "Copiato: imports\$($f.Name)"
        $copiati++
    }
}
if ($copiati -eq 0) { Write-Esito INFO 'Nessun file di imports da aggiornare (già identici)' }

# ...e PER ULTIMO shell.nss: è il suo salvataggio che fa ricaricare Nilesoft
Copy-Item -LiteralPath $FileShell -Destination (Join-Path $Destinazione 'shell.nss') -Force
Write-Esito OK 'Copiato: shell.nss (per ultimo)'

# File presenti solo nell'installazione (non vengono toccati)
$nomiRepo = $fileImports | ForEach-Object { $_.Name }
$soloDest = @(Get-ChildItem -LiteralPath $destImports -File | Where-Object { $nomiRepo -notcontains $_.Name })
if ($soloDest.Count) {
    Write-Esito INFO ("File presenti solo in Program Files (lasciati intatti): " + (($soloDest | ForEach-Object { $_.Name }) -join ', '))
}

# ---------------------------------------------------------------
#  3) CONTROLLO DEL LOG DI NILESOFT
# ---------------------------------------------------------------
Write-Host ''
Write-Host '=== CONTROLLO DEL LOG (attendo 5 secondi) ===' -ForegroundColor Cyan
Start-Sleep -Seconds 5

$fileLog = Join-Path $Destinazione 'shell.log'
$nuove = @()
if (Test-Path -LiteralPath $fileLog) {
    foreach ($r in (Get-Content -LiteralPath $fileLog -Encoding UTF8)) {
        if ($r -match '^(\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2})') {
            $quando = [datetime]::ParseExact($Matches[1], 'yyyy-MM-dd HH:mm:ss', [Globalization.CultureInfo]::InvariantCulture)
            if ($quando -ge $inizio.AddSeconds(-1)) { $nuove += $r }
        }
    }
}

if ($nuove.Count -eq 0) {
    Write-Esito OK 'Nessuna riga nuova nel log: configurazione caricata senza errori'
}
else {
    foreach ($r in $nuove) {
        if ($r -match '\[error\]') { Write-Esito ERRORE $r } else { Write-Esito AVVISO $r }
    }
    Write-Host '  Per tornare alla versione precedente: .\Deploy-NilesoftConfig.ps1 -Ripristina' -ForegroundColor Yellow
}

Write-Host ''
Write-Host '  Fatto. Se il menu non si aggiorna, usa Restart Explorer.' -ForegroundColor Gray
