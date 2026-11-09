#Requires -Version 5.1
<#
    Software-Update-Checker.ps1
    Controllo aggiornamenti dei programmi installati tramite winget.

    Parametri:
      -Forza        : esegue il controllo anche se non è il giorno previsto
      -Test         : SIMULAZIONE - mostra tutto a video e non modifica nulla
      -Dettagli     : mostra tutto a video ma agisce davvero
      -Info         : apre la finestra in sola consultazione (nessun aggiornamento,
                      nessun report, non conta come controllo del sabato)
      -ApriReport   : apre il report del mese corrente ed esce
      -ApriCartella : apre la cartella dei report ed esce
#>
[CmdletBinding()]
param(
    [switch]$Forza,
    [switch]$Test,
    [switch]$Dettagli,
    [switch]$Info,
    [switch]$ApriReport,
    [switch]$ApriCartella
)

$ErrorActionPreference = 'Stop'

# ---------------------------------------------------------------
#  PERCORSI DI BASE
# ---------------------------------------------------------------
$CartellaScript = $PSScriptRoot
$FileConfig     = Join-Path $CartellaScript 'config.json'
$FileListe      = Join-Path $CartellaScript 'liste.json'
$FileStato      = Join-Path $CartellaScript 'stato.json'

# Finché non leggiamo la config, eventuali errori vanno nella cartella dello script
$script:CartellaLog = $CartellaScript

# Perché è partito il controllo (lo scrive Test-DeveEseguire, lo legge il report)
$script:MotivoEsecuzione = ''

# Tutte le righe di log della sessione: la finestra le mostra quando si apre
$script:LogSessione = New-Object System.Collections.Generic.List[object]
$script:BoxLog = $null

# Esiti degli aggiornamenti lanciati dalla finestra (finiscono nel report)
$script:RisultatiFinestra = New-Object System.Collections.Generic.List[object]
$script:AggiornamentoInCorso = $false

# ---------------------------------------------------------------
#  FUNZIONI DI SUPPORTO
# ---------------------------------------------------------------

function Write-Log {
    param(
        [string]$Messaggio,
        [ValidateSet('INFO','AVVISO','ERRORE')][string]$Livello = 'INFO'
    )
    $riga = '{0} [{1}] {2}' -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $Livello, $Messaggio

    if ($Test -or $Dettagli) {
        $colore = switch ($Livello) { 'ERRORE' {'Red'} 'AVVISO' {'Yellow'} default {'Gray'} }
        Write-Host $riga -ForegroundColor $colore
    }

    # Memoria della sessione + pannello di log della finestra (se aperta)
    $script:LogSessione.Add([pscustomobject]@{ Riga = $riga; Livello = $Livello })
    Add-LogFinestra $riga $Livello

    # Sul file finiscono solo avvisi ed errori
    if ($Livello -ne 'INFO') {
        $fileLog = Join-Path $script:CartellaLog ('Errori_{0}.log' -f (Get-Date -Format 'yyyy-MM'))
        Add-Content -LiteralPath $fileLog -Value $riga -Encoding UTF8
    }
}

function Read-Json {
    param([string]$Percorso)
    if (-not (Test-Path -LiteralPath $Percorso)) { return $null }
    return (Get-Content -LiteralPath $Percorso -Raw -Encoding UTF8 | ConvertFrom-Json)
}

function Compare-Versione {
    <#
        Confronta due versioni "a pezzi numerici".
        Restituisce -1 se A < B, 0 se uguali, 1 se A > B,
        $null se una delle due non contiene numeri (es. "Unknown").
    #>
    param([string]$A, [string]$B)

    $pa = @([regex]::Matches($A, '\d+') | ForEach-Object { [long]$_.Value })
    $pb = @([regex]::Matches($B, '\d+') | ForEach-Object { [long]$_.Value })
    if ($pa.Count -eq 0 -or $pb.Count -eq 0) { return $null }

    $max = [Math]::Max($pa.Count, $pb.Count)
    for ($i = 0; $i -lt $max; $i++) {
        $x = if ($i -lt $pa.Count) { $pa[$i] } else { 0 }
        $y = if ($i -lt $pb.Count) { $pb[$i] } else { 0 }
        if ($x -lt $y) { return -1 }
        if ($x -gt $y) { return 1 }
    }
    return 0
}

function Get-NumeroPrincipale {
    <#
        Restituisce il primo numero di una versione ("versione principale").
        Esempio: "2.18" -> 2   |   "26.002.22031" -> 26   |   "Unknown" -> $null
    #>
    param([string]$Versione)
    $m = [regex]::Match($Versione, '\d+')
    if ($m.Success) { return [long]$m.Value }
    return $null
}

function Read-Liste {
    <#
        Legge liste.json. Se il file manca o una lista non c'è,
        crea liste vuote: così lo script non si blocca mai per colpa di questo file.
    #>
    $liste = Read-Json $FileListe
    if (-not $liste) { $liste = [pscustomobject]@{} }

    foreach ($nome in 'Esclusi', 'Automatici', 'Attenzione', 'AttenzioneRimossa') {
        if ($liste.PSObject.Properties.Name -notcontains $nome) {
            $liste | Add-Member -NotePropertyName $nome -NotePropertyValue @()
        }
    }
    return $liste
}

# ---------------------------------------------------------------
#  FASE 1a - TOCCA A ME?
# ---------------------------------------------------------------
function Test-DeveEseguire {
    param($Config, $Stato)

    if ($Forza) {
        $script:MotivoEsecuzione = 'esecuzione manuale'
        Write-Log 'Esecuzione forzata (-Forza).'
        return $true
    }

    $oggi   = (Get-Date).Date
    $ultimo = $null
    if ($Stato -and $Stato.UltimoControllo) {
        if ($Stato.UltimoControllo -is [datetime]) { $ultimo = $Stato.UltimoControllo.Date }
        else { $ultimo = [datetime]::ParseExact([string]$Stato.UltimoControllo, 'yyyy-MM-dd', [Globalization.CultureInfo]::InvariantCulture) }
    }

    if ($ultimo -and $ultimo -eq $oggi) { Write-Log 'Controllo già eseguito oggi.'; return $false }

    if ((Get-Date).DayOfWeek.ToString() -eq $Config.GiornoControllo) {
        $script:MotivoEsecuzione = 'esecuzione programmata'
        Write-Log 'Oggi è il giorno del controllo.'
        return $true
    }

    if (-not $ultimo) {
        $script:MotivoEsecuzione = 'primo avvio'
        Write-Log 'Nessun controllo precedente: primo avvio.'
        return $true
    }

    $giorni = [int]($oggi - $ultimo).TotalDays
    if ($giorni -ge $Config.GiorniMassimiTraControlli) {
        $script:MotivoEsecuzione = "recupero: ultimo controllo $giorni giorni fa"
        Write-Log "Recupero: ultimo controllo $giorni giorni fa."
        return $true
    }

    Write-Log 'Non è il giorno del controllo.'
    return $false
}

# ---------------------------------------------------------------
#  FASE 1b - C'È INTERNET?
# ---------------------------------------------------------------
function Wait-Internet {
    param([int]$Minuti)

    # Interroghiamo direttamente il server dell'archivio di winget
    $url       = 'https://cdn.winget.microsoft.com/cache/source.msix'
    $scadenza  = (Get-Date).AddMinutes($Minuti)
    $tentativo = 0

    do {
        $tentativo++
        try {
            Invoke-WebRequest -Uri $url -Method Head -UseBasicParsing -TimeoutSec 15 | Out-Null
            Write-Log "Connessione OK (tentativo $tentativo)."
            return $true
        }
        catch {
            Write-Log "Connessione assente (tentativo $tentativo), riprovo tra 30 secondi..."
            Start-Sleep -Seconds 30
        }
    } while ((Get-Date) -lt $scadenza)

    return $false
}

# ---------------------------------------------------------------
#  FASE 1c - INVENTARIO
# ---------------------------------------------------------------
function Get-Inventario {
    $pacchetti = @(Get-WinGetPackage)
    $risultato = foreach ($p in $pacchetti) {

        $tipo = if ($p.Source) { [string]$p.Source }
                elseif ($p.Id -like 'MSIX\*') { 'MSIX' }
                elseif ($p.Id -like 'ARP\*')  { 'ARP' }
                else { 'Altro' }

        $installata  = [string]$p.InstalledVersion
        $disponibile = $null
        if ($p.AvailableVersions -and @($p.AvailableVersions).Count -gt 0) {
            $disponibile = [string]@($p.AvailableVersions)[0]
        }

        $sconosciuta = $false
        if (-not $p.Source -or -not $disponibile) {
            $stato = 'NonVerificabile'
        }
        else {
            $confronto = Compare-Versione $installata $disponibile
            if ($null -eq $confronto) {
                if ($p.IsUpdateAvailable) { $stato = 'Aggiornabile'; $sconosciuta = $true }
                else { $stato = 'NonVerificabile' }
            }
            elseif ($confronto -lt 0) {
                $stato = if ($p.IsUpdateAvailable) { 'Aggiornabile' } else { 'SoloManuale' }
            }
            elseif ($p.IsUpdateAvailable) {
                $stato = 'Aggiornabile'   # caso raro: ci fidiamo del modulo
            }
            else {
                $stato = 'Aggiornato'
            }
        }

        [pscustomobject]@{
            Nome                = [string]$p.Name
            Id                  = [string]$p.Id
            Tipo                = $tipo
            Installata          = $installata
            Disponibile         = $disponibile
            Stato               = $stato
            VersioneSconosciuta = $sconosciuta
        }
    }

    # Togliamo le voci MSIX "accessorie" che duplicano un programma già riconosciuto (es. Zed)
    $nomiWinget = @($risultato | Where-Object { $_.Tipo -notin 'MSIX','ARP','Altro' } | ForEach-Object { $_.Nome })
    return @($risultato | Where-Object { -not ($_.Tipo -eq 'MSIX' -and $nomiWinget -contains $_.Nome) })
}

# ---------------------------------------------------------------
#  FASE 2 - CLASSIFICAZIONE
# ---------------------------------------------------------------
function Set-Classificazione {
    param($Inventario, $Config, $Liste, $Stato)

    # Prepariamo gli elenchi una volta sola, prima del ciclo
    $criteri         = @($Config.CriteriSistema)
    $esclusi         = @($Liste.Esclusi)
    $automatici      = @($Liste.Automatici)
    $segnalati       = @($Liste.Attenzione)
    $regoleSospese   = @($Liste.AttenzioneRimossa)
    $nascondiSistema = [bool]$Config.EscludiComponentiSistema

    # Storico dei fallimenti
    $fallimenti = $null
    if ($Stato -and $Stato.Fallimenti) { $fallimenti = $Stato.Fallimenti }

    foreach ($p in $Inventario) {

        # --- È un componente di sistema? ---
        $sistema = $false
        foreach ($criterio in $criteri) {
            if ($p.Id -like $criterio) { $sistema = $true; break }
        }

        $escluso      = $esclusi    -contains $p.Id
        $automatico   = $automatici -contains $p.Id
        $daAggiornare = $p.Stato -in 'Aggiornabile', 'SoloManuale'

        # --- Motivi di attenzione ---
        $motivi = @()

        if ($segnalati -contains $p.Id) { $motivi += 'Segnalato da te' }

        if ($daAggiornare) {

            # Regole automatiche "sospendibili" (salvo che tu le abbia disattivate per questo programma)
            if ($regoleSospese -notcontains $p.Id) {
                if ($p.VersioneSconosciuta) {
                    $motivi += 'Versione installata sconosciuta'
                }
                else {
                    $vecchia = Get-NumeroPrincipale $p.Installata
                    $nuova   = Get-NumeroPrincipale $p.Disponibile
                    if ($null -ne $vecchia -and $null -ne $nuova -and $nuova -gt $vecchia) {
                        $motivi += "Salto di versione principale ($vecchia -> $nuova)"
                    }
                }
            }

            # Regole sempre attive
            if ($p.Id -eq 'Microsoft.AppInstaller') {
                $motivi += 'Aggiorna winget stesso (eseguito per ultimo)'
            }
            if ($fallimenti -and $fallimenti.PSObject.Properties[$p.Id]) {
                $dataFallimento = $fallimenti.PSObject.Properties[$p.Id].Value.Data
                $motivi += "Aggiornamento fallito il $dataFallimento"
            }
        }

        $attenzione = $motivi.Count -gt 0

        # --- Destinazione finale (solo per i programmi da aggiornare) ---
        $destinazione = ''
        if ($daAggiornare) {
            if     ($escluso)                                                           { $destinazione = 'Escluso' }
            elseif ($sistema -and $nascondiSistema)                                     { $destinazione = 'Sistema' }
            elseif ($automatico -and -not $attenzione -and $p.Stato -eq 'Aggiornabile') { $destinazione = 'Automatico' }
            else                                                                        { $destinazione = 'Finestra' }
        }

        # --- Aggiungiamo le nuove "colonne" alla riga di questo programma ---
        $p | Add-Member -Force -NotePropertyMembers @{
            Sistema          = $sistema
            Escluso          = $escluso
            Automatico       = $automatico
            Attenzione       = $attenzione
            MotiviAttenzione = ($motivi -join '; ')
            Destinazione     = $destinazione
        }
    }
}

function Show-RiepilogoTest {
    param($Inventario)

    $daAggiornare = @($Inventario | Where-Object { $_.Destinazione })

    $righe = [ordered]@{
        'Programmi totali'               = $Inventario.Count
        'Aggiornabili via winget'        = @($daAggiornare | Where-Object { $_.Stato -eq 'Aggiornabile' }).Count
        'Solo aggiornamento manuale'     = @($daAggiornare | Where-Object { $_.Stato -eq 'SoloManuale' }).Count
        'Con flag Attenzione'            = @($daAggiornare | Where-Object { $_.Attenzione }).Count
        '  -> nella finestra'            = @($daAggiornare | Where-Object { $_.Destinazione -eq 'Finestra' }).Count
        '  -> aggiornamento automatico'  = @($daAggiornare | Where-Object { $_.Destinazione -eq 'Automatico' }).Count
        '  -> sistema (sezione finale)'  = @($daAggiornare | Where-Object { $_.Destinazione -eq 'Sistema' }).Count
        '  -> esclusi'                   = @($daAggiornare | Where-Object { $_.Destinazione -eq 'Escluso' }).Count
    }

    Write-Host ''
    Write-Host '=== RIEPILOGO CLASSIFICAZIONE ===' -ForegroundColor Cyan
    foreach ($voce in $righe.Keys) {
        Write-Host ('{0,-32} {1,4}' -f $voce, $righe[$voce])
    }

    Write-Host ''
    Write-Host '=== DETTAGLIO ===' -ForegroundColor Cyan
    $daAggiornare | Sort-Object Destinazione, Nome |
        Format-Table Nome, Stato, Destinazione, MotiviAttenzione -AutoSize -Wrap | Out-Host
}

# ---------------------------------------------------------------
#  FASE 3 - MOTORE DEGLI AGGIORNAMENTI
# ---------------------------------------------------------------

# Codici di uscita di winget che sappiamo interpretare (dalla documentazione ufficiale)
$script:CodiciWinget = @{
    '0x8A150109' = @{ Esito = 'OK';      Riavvio = $true;  Testo = 'Installato: serve un riavvio per completare' }
    '0x8A15010D' = @{ Esito = 'OK';      Riavvio = $false; Testo = 'Versione già installata' }
    '0x8A15010A' = @{ Esito = 'Fallito'; Riavvio = $true;  Testo = 'Serve un riavvio PRIMA di poter installare' }
    '0x8A150101' = @{ Esito = 'Fallito'; Riavvio = $false; Testo = 'Il programma è in uso: chiudilo e riprova' }
    '0x8A150103' = @{ Esito = 'Fallito'; Riavvio = $false; Testo = 'Un file del programma è in uso' }
    '0x8A150105' = @{ Esito = 'Fallito'; Riavvio = $false; Testo = 'Spazio su disco insufficiente' }
    '0x8A150107' = @{ Esito = 'Fallito'; Riavvio = $false; Testo = 'Problema di rete durante l''installazione' }
    '0x8A15002B' = @{ Esito = 'Fallito'; Riavvio = $false; Testo = 'Nessun aggiornamento applicabile al sistema' }
}

function Initialize-Stato {
    <# Prepara l'oggetto "stato" con tutte le sue parti, anche se stato.json non esiste ancora #>
    param($Stato)
    if (-not $Stato) { $Stato = [pscustomobject]@{} }
    if ($Stato.PSObject.Properties.Name -notcontains 'Fallimenti' -or $null -eq $Stato.Fallimenti) {
        $Stato | Add-Member -Force -NotePropertyName 'Fallimenti' -NotePropertyValue ([pscustomobject]@{})
    }
    return $Stato
}

function Test-Amministratore {
    $identita   = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principale = New-Object Security.Principal.WindowsPrincipal($identita)
    return $principale.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function New-PuntoRipristino {
    try {
        Checkpoint-Computer -Description 'Software-Update-Checker' -RestorePointType 'APPLICATION_INSTALL' `
                            -WarningAction SilentlyContinue -WarningVariable avvisi
        if ($avvisi) { Write-Log "Punto di ripristino non creato: $($avvisi[0].Message)" }
        else         { Write-Log 'Punto di ripristino creato.' }
    }
    catch {
        Write-Log "Punto di ripristino non creato: $($_.Exception.Message)" 'AVVISO'
    }
}

function Invoke-Aggiornamento {
    <# Aggiorna UN programma e restituisce l'esito #>
    param($Pacchetto, [int]$TimeoutMinuti = 15, [switch]$Simula)

    $argomenti = @('upgrade', '--id', $Pacchetto.Id, '--exact', '--silent',
                   '--accept-package-agreements', '--accept-source-agreements',
                   '--disable-interactivity')

    $risultato = [pscustomobject]@{
        Nome      = $Pacchetto.Nome
        Id        = $Pacchetto.Id
        Da        = $Pacchetto.Installata
        A         = $Pacchetto.Disponibile
        Esito     = ''
        Riavvio   = $false
        Codice    = ''
        Messaggio = ''
    }

    # In simulazione ci limitiamo a dire cosa faremmo
    if ($Test -or $Simula) {
        $risultato.Esito     = 'Simulato'
        $risultato.Messaggio = "winget $($argomenti -join ' ')"
        return $risultato
    }

    $fileOutput = [IO.Path]::GetTempFileName()
    $fileErrori = [IO.Path]::GetTempFileName()
    try {
        Write-Log "Aggiornamento di $($Pacchetto.Nome) ($($Pacchetto.Installata) -> $($Pacchetto.Disponibile))..."

        $processo = Start-Process -FilePath 'winget' -ArgumentList $argomenti -NoNewWindow -PassThru `
                                  -RedirectStandardOutput $fileOutput -RedirectStandardError $fileErrori
        $null = $processo.Handle   # trucco tecnico: serve per poter leggere il codice di uscita alla fine

        # Attesa con limite di tempo. Controlliamo ogni 200 ms invece di "bloccarci":
        # così, se la finestra è aperta, resta reattiva (log e barra si aggiornano)
        $limite = (Get-Date).AddMinutes($TimeoutMinuti)
        while (-not $processo.HasExited) {
            if ((Get-Date) -gt $limite) {
                & taskkill.exe /PID $processo.Id /T /F | Out-Null
                $risultato.Esito     = 'Fallito'
                $risultato.Messaggio = "Interrotto: superato il limite di $TimeoutMinuti minuti"
                return $risultato
            }
            if ($script:GraficaPronta) { [Windows.Forms.Application]::DoEvents() }
            Start-Sleep -Milliseconds 200
        }
        $processo.WaitForExit()   # garantisce che il codice di uscita sia disponibile

        $codice = $processo.ExitCode
        $ultimaRiga = Get-Content -LiteralPath $fileOutput -Encoding UTF8 -ErrorAction SilentlyContinue |
                      Where-Object { $_.Trim() } | Select-Object -Last 1

        if ($null -eq $codice) {
            $risultato.Esito     = 'Fallito'
            $risultato.Messaggio = "Codice di uscita non disponibile. Ultima riga di winget: $ultimaRiga"
        }
        elseif ($codice -eq 0) {
            $risultato.Codice    = '0x00000000'
            $risultato.Esito     = 'OK'
            $risultato.Messaggio = 'Aggiornato correttamente'
        }
        else {
            $risultato.Codice = '0x{0:X8}' -f $codice
            if ($script:CodiciWinget.ContainsKey($risultato.Codice)) {
                $info = $script:CodiciWinget[$risultato.Codice]
                $risultato.Esito     = $info.Esito
                $risultato.Riavvio   = $info.Riavvio
                $risultato.Messaggio = $info.Testo
            }
            else {
                $risultato.Esito     = 'Fallito'
                $risultato.Messaggio = "Codice non previsto. Ultima riga di winget: $ultimaRiga"
            }
        }
    }
    catch {
        $risultato.Esito     = 'Fallito'
        $risultato.Messaggio = "Errore nell'avvio di winget: $($_.Exception.Message)"
    }
    finally {
        Remove-Item -LiteralPath $fileOutput, $fileErrori -Force -ErrorAction SilentlyContinue
    }

    return $risultato
}

function Invoke-Aggiornamenti {
    <#
        Aggiorna un ELENCO di programmi: punto di ripristino, ordine, storico fallimenti.
        -Simula      : nessuna installazione (dry-run)
        -Avanzamento : blocco di codice chiamato prima e dopo ogni programma (per la finestra)
    #>
    param($Pacchetti, $Stato, [switch]$Simula, [scriptblock]$Avanzamento)

    # Ordine: tutti in ordine alfabetico, App Installer (winget stesso) sempre per ultimo
    $ordinati = @($Pacchetti | Sort-Object @{ Expression = { $_.Id -eq 'Microsoft.AppInstaller' } }, Nome)

    if (-not ($Test -or $Simula)) {
        if (-not (Test-Amministratore)) {
            Write-Log 'Lo script non ha i permessi di amministratore: alcuni aggiornamenti potrebbero fallire.' 'AVVISO'
        }
        New-PuntoRipristino
    }

    $totale = $ordinati.Count
    $n = 0
    $risultati = foreach ($p in $ordinati) {
        $n++
        if ($Avanzamento) { & $Avanzamento $n $totale $p $null }

        $r = Invoke-Aggiornamento -Pacchetto $p -Simula:$Simula

        if ($r.Esito -eq 'OK') {
            $Stato.Fallimenti.PSObject.Properties.Remove($p.Id)
            Write-Log "OK: $($p.Nome)"
        }
        elseif ($r.Esito -eq 'Fallito') {
            $Stato.Fallimenti | Add-Member -Force -NotePropertyName $p.Id -NotePropertyValue ([pscustomobject]@{
                Data      = (Get-Date -Format 'yyyy-MM-dd')
                Codice    = $r.Codice
                Messaggio = $r.Messaggio
            })
            Write-Log "FALLITO: $($p.Nome) - $($r.Messaggio) [$($r.Codice)]" 'AVVISO'
        }
        elseif ($r.Esito -eq 'Simulato') {
            Write-Log "Simulato: $($p.Nome) ($($r.Da) -> $($r.A)) - $($r.Messaggio)"
        }
        if ($r.Riavvio) { Write-Log "Riavvio consigliato per: $($p.Nome)" 'AVVISO' }

        if ($Avanzamento) { & $Avanzamento $n $totale $p $r }
        $r   # "consegna" il risultato all'elenco $risultati
    }

    return @($risultati)
}

function Show-RisultatiAggiornamenti {
    param($Risultati, [string]$Titolo)
    Write-Host ''
    Write-Host "=== $Titolo ===" -ForegroundColor Cyan
    $Risultati | Format-Table Nome, Da, A, Esito, Riavvio, Codice, Messaggio -AutoSize -Wrap | Out-Host
}

# ---------------------------------------------------------------
#  FASE 4 - REPORT E MEMORIA DELLO SCRIPT
# ---------------------------------------------------------------

function Update-InventarioDopoAggiornamenti {
    <#
        Dopo gli aggiornamenti riusciti, l'inventario letto all'inizio è "vecchio".
        Correggiamo le righe dei programmi aggiornati, così report e stato.json
        rispecchiano la situazione reale DOPO gli aggiornamenti.
    #>
    param($Inventario, $Risultati)

    foreach ($r in @($Risultati | Where-Object { $_.Esito -eq 'OK' })) {
        foreach ($p in @($Inventario | Where-Object { $_.Id -eq $r.Id })) {
            $p.Installata   = $p.Disponibile
            $p.Stato        = 'Aggiornato'
            $p.Destinazione = ''
        }
    }
}

function Format-Cella {
    <# Adatta un testo a una larghezza fissa: lo allunga con spazi o lo tronca con "~" #>
    param([string]$Testo, [int]$Larghezza)
    if ($null -eq $Testo) { $Testo = '' }
    if ($Testo.Length -gt $Larghezza) { return $Testo.Substring(0, $Larghezza - 1) + '~' }
    return $Testo.PadRight($Larghezza)
}

function Format-RigaProgramma {
    <# Una riga di tabella: Nome | Installata | Disponibile | Note #>
    param($Pacchetto)
    $note = ''
    if ($Pacchetto.MotiviAttenzione) { $note = '! ' + $Pacchetto.MotiviAttenzione }
    return ('   {0} {1} {2} {3}' -f (Format-Cella $Pacchetto.Nome 40),
                                    (Format-Cella $Pacchetto.Installata 22),
                                    (Format-Cella $Pacchetto.Disponibile 22),
                                    $note).TrimEnd()
}

function Get-Variazioni {
    <#
        Confronta l'inventario di oggi con quello salvato all'ultimo controllo.
        Restituisce le righe già pronte per il report e il numero di variazioni MSIX (non mostrate).
    #>
    param($Inventario, $Precedente)

    # "Rubriche" Id -> programma, per cercare velocemente
    $vecchi = @{}
    foreach ($v in @($Precedente)) { $vecchi[[string]$v.Id] = $v }
    $nuovi = @{}
    foreach ($n in @($Inventario)) { $nuovi[[string]$n.Id] = $n }

    $righe = New-Object System.Collections.Generic.List[string]
    $msix  = 0
    $modello = '   {0} {1} {2}'   # etichetta | nome | versione/e

    # Installati e aggiornati
    foreach ($n in @($Inventario | Sort-Object Nome)) {
        $v = $vecchi[[string]$n.Id]
        $riga = $null
        if (-not $v) {
            $riga = $modello -f '[+] Installato   ', (Format-Cella $n.Nome 40), $n.Installata
        }
        elseif ([string]$v.Versione -ne [string]$n.Installata) {
            $etichetta = if ((Compare-Versione $v.Versione $n.Installata) -eq 1) { '[v] Retrocesso   ' } else { '[^] Aggiornato   ' }
            $riga = $modello -f $etichetta, (Format-Cella $n.Nome 40), "$($v.Versione) -> $($n.Installata)"
        }
        if ($riga) {
            if ($n.Tipo -eq 'MSIX') { $msix++ } else { $righe.Add($riga.TrimEnd()) }
        }
    }

    # Disinstallati
    foreach ($v in @($Precedente | Sort-Object Nome)) {
        if (-not $nuovi.ContainsKey([string]$v.Id)) {
            if ($v.Tipo -eq 'MSIX') { $msix++ }
            else { $righe.Add(($modello -f '[-] Disinstallato', (Format-Cella $v.Nome 40), $v.Versione).TrimEnd()) }
        }
    }

    return [pscustomobject]@{ Righe = $righe; Msix = $msix }
}

function New-InventarioMensile {
    <# L'inventario completo, scritto solo in cima al file alla prima esecuzione del mese #>
    param($Inventario)

    $cultura = [Globalization.CultureInfo]'it-IT'
    $r = New-Object System.Collections.Generic.List[string]
    $doppia = '=' * 100

    $r.Add($doppia)
    $r.Add(' REPORT AGGIORNAMENTI SOFTWARE - ' + (Get-Date).ToString('MMMM yyyy', $cultura).ToUpper())
    $r.Add(' Inventario completo al ' + (Get-Date -Format 'dd/MM/yyyy HH:mm'))
    $r.Add($doppia)

    $gruppi = [ordered]@{
        'RICONOSCIUTI DA WINGET'                         = @($Inventario | Where-Object { $_.Tipo -notin 'MSIX','ARP','Altro' })
        'NON VERIFICABILI (winget li vede ma non li conosce)' = @($Inventario | Where-Object { $_.Tipo -in 'ARP','Altro' })
        'COMPONENTI MSIX (app dello Store e di Windows)' = @($Inventario | Where-Object { $_.Tipo -eq 'MSIX' })
    }

    foreach ($titolo in $gruppi.Keys) {
        $elenco = $gruppi[$titolo]
        $r.Add('')
        $r.Add(" $titolo  ($($elenco.Count))")
        $r.Add('   ' + (Format-Cella 'Nome' 40) + ' ' + (Format-Cella 'Versione' 22) + ' Id')
        foreach ($p in @($elenco | Sort-Object Nome)) {
            $r.Add(('   {0} {1} {2}' -f (Format-Cella $p.Nome 40), (Format-Cella $p.Installata 22), $p.Id).TrimEnd())
        }
    }
    $r.Add('')
    return $r
}

function New-BloccoReport {
    <# Costruisce, riga per riga, il blocco di testo di questo controllo #>
    param($Inventario, $Stato, $RisultatiAuto, $RisultatiFinestra = @())

    $cultura   = [Globalization.CultureInfo]'it-IT'
    $r         = New-Object System.Collections.Generic.List[string]
    $doppia    = '=' * 100

    $daAggiornare = @($Inventario | Where-Object { $_.Destinazione })
    $finestra     = @($daAggiornare | Where-Object { $_.Destinazione -eq 'Finestra' })
    $disponibili  = @($finestra     | Where-Object { $_.Stato -eq 'Aggiornabile' } | Sort-Object Nome)
    $manuali      = @($finestra     | Where-Object { $_.Stato -eq 'SoloManuale' }  | Sort-Object Nome)
    $esclusi      = @($daAggiornare | Where-Object { $_.Destinazione -eq 'Escluso' } | Sort-Object Nome)
    $sistema      = @($daAggiornare | Where-Object { $_.Destinazione -eq 'Sistema' } | Sort-Object Nome)
    $autoOk       = @($RisultatiAuto | Where-Object { $_.Esito -eq 'OK' })
    $autoKo       = @($RisultatiAuto | Where-Object { $_.Esito -eq 'Fallito' })
    $finOk        = @($RisultatiFinestra | Where-Object { $_.Esito -eq 'OK' })
    $finKo        = @($RisultatiFinestra | Where-Object { $_.Esito -eq 'Fallito' })
    $riavvio      = @(@($RisultatiAuto) + @($RisultatiFinestra) | Where-Object { $_ -and $_.Riavvio })
    $riconosciuti = @($Inventario | Where-Object { $_.Tipo -notin 'MSIX','ARP','Altro' }).Count

    # --- Intestazione ---
    $adesso = Get-Date
    $r.Add('')
    $r.Add($doppia)
    $titolo = ' CONTROLLO DEL {0} ORE {1}  ({2} - {3})' -f $adesso.ToString('dd/MM/yyyy'), $adesso.ToString('HH:mm'),
              $adesso.ToString('dddd', $cultura), $script:MotivoEsecuzione
    $r.Add($titolo)
    $r.Add($doppia)

    if ($sistema.Count -gt 0) {
        $r.Add(" !!! $($sistema.Count) componenti di sistema/hardware aggiornabili -> vedi sezione finale !!!")
    }
    if ($riavvio.Count -gt 0) {
        $r.Add(' !!! Riavvio consigliato per: ' + (($riavvio | ForEach-Object { $_.Nome }) -join ', ') + ' !!!')
    }

    # --- Riepilogo ---
    $voci = [ordered]@{
        'Programmi installati'       = "$($Inventario.Count)  (riconosciuti da winget: $riconosciuti)"
        'Aggiornabili'               = @($daAggiornare | Where-Object { $_.Stato -eq 'Aggiornabile' }).Count
        'Solo aggiornamento manuale' = @($daAggiornare | Where-Object { $_.Stato -eq 'SoloManuale' }).Count
        'Con flag Attenzione'        = @($daAggiornare | Where-Object { $_.Attenzione }).Count
        'Esclusi'                    = $esclusi.Count
        'Componenti di sistema'      = $sistema.Count
        'Aggiornati in automatico'   = "$(@($RisultatiAuto).Count)  (riusciti: $($autoOk.Count), falliti: $($autoKo.Count))"
        'Aggiornati dalla finestra'  = "$(@($RisultatiFinestra).Count)  (riusciti: $($finOk.Count), falliti: $($finKo.Count))"
    }
    $r.Add('')
    $r.Add(' RIEPILOGO')
    foreach ($k in $voci.Keys) {
        $riga = '   {0} {1}' -f ($k + ' ').PadRight(32, '.'), $voci[$k]
        $r.Add($riga)
    }

    # --- Variazioni ---
    $r.Add('')
    if (-not $Stato.InventarioPrecedente) {
        $r.Add(" VARIAZIONI DALL'ULTIMO CONTROLLO")
        $r.Add('   Primo controllo: nessun confronto disponibile.')
    }
    else {
        $dataPrec = [string]$Stato.UltimoControllo
        if ($Stato.UltimoControllo -is [datetime]) { $dataPrec = $Stato.UltimoControllo.ToString('dd/MM/yyyy') }
        elseif ($dataPrec -match '^(\d{4})-(\d{2})-(\d{2})') { $dataPrec = "$($Matches[3])/$($Matches[2])/$($Matches[1])" }

        $var = Get-Variazioni -Inventario $Inventario -Precedente $Stato.InventarioPrecedente
        $r.Add(" VARIAZIONI DALL'ULTIMO CONTROLLO ($dataPrec)")
        if ($var.Righe.Count -eq 0) { $r.Add('   Nessuna variazione.') }
        foreach ($riga in $var.Righe) { $r.Add($riga) }
        if ($var.Msix -gt 0) { $r.Add("   (+ $($var.Msix) variazioni di componenti MSIX non mostrate)") }
    }

    # --- Aggiornamenti automatici ---
    if (@($RisultatiAuto).Count -gt 0) {
        $r.Add('')
        $r.Add(' AGGIORNAMENTI AUTOMATICI ESEGUITI')
        foreach ($x in @($RisultatiAuto | Sort-Object Nome)) {
            $etichetta = switch ($x.Esito) { 'OK' {'[OK]     '} 'Fallito' {'[FALLITO]'} default {"[$($x.Esito)]"} }
            $riga = '   {0} {1} {2} -> {3}' -f $etichetta, (Format-Cella $x.Nome 40), $x.Da, $x.A
            if ($x.Esito -eq 'Fallito') { $riga += "   ($($x.Messaggio) $($x.Codice))".Replace(' )', ')') }
            $r.Add($riga.TrimEnd())
        }
    }

    # --- Aggiornamenti eseguiti dalla finestra ---
    if (@($RisultatiFinestra).Count -gt 0) {
        $r.Add('')
        $r.Add(' AGGIORNAMENTI ESEGUITI DALLA FINESTRA')
        foreach ($x in @($RisultatiFinestra | Sort-Object Nome)) {
            $etichetta = switch ($x.Esito) { 'OK' {'[OK]     '} 'Fallito' {'[FALLITO]'} default {"[$($x.Esito)]"} }
            $riga = '   {0} {1} {2} -> {3}' -f $etichetta, (Format-Cella $x.Nome 40), $x.Da, $x.A
            if ($x.Esito -eq 'Fallito') { $riga += "   ($($x.Messaggio) $($x.Codice))".Replace(' )', ')') }
            $r.Add($riga.TrimEnd())
        }
    }

    # --- Disponibili ---
    $intestazione = '   ' + (Format-Cella 'Nome' 40) + ' ' + (Format-Cella 'Installata' 22) + ' ' + (Format-Cella 'Disponibile' 22) + ' Note'
    $r.Add('')
    $r.Add(' AGGIORNAMENTI DISPONIBILI')
    if ($disponibili.Count -eq 0) { $r.Add('   Nessuno.') }
    else {
        $r.Add($intestazione)
        foreach ($p in $disponibili) { $r.Add((Format-RigaProgramma $p)) }
    }

    # --- Solo manuali ---
    if ($manuali.Count -gt 0) {
        $r.Add('')
        $r.Add(' DA AGGIORNARE A MANO (winget non può: usa il sito o il programma stesso)')
        foreach ($p in $manuali) { $r.Add((Format-RigaProgramma $p)) }
    }

    # --- Esclusi ---
    if ($esclusi.Count -gt 0) {
        $r.Add('')
        $r.Add(' ESCLUSI')
        foreach ($p in $esclusi) { $r.Add((Format-RigaProgramma $p)) }
    }

    # --- Sistema (sempre per ultima, ben visibile) ---
    $cornice = ' ' + ('#' * 98)
    $r.Add('')
    $r.Add($cornice)
    $r.Add(' ##   COMPONENTI DI SISTEMA / HARDWARE'.PadRight(97) + '##')
    $r.Add($cornice)
    if ($sistema.Count -eq 0) { $r.Add('   Nessun componente da aggiornare.') }
    else { foreach ($p in $sistema) { $r.Add((Format-RigaProgramma $p)) } }
    $r.Add('')

    return $r
}

function Write-Report {
    <#
        Aggiunge il blocco al file del mese. Se il file non esiste ancora
        (prima esecuzione del mese) scrive prima l'inventario completo.
        In modalità -Test non scrive nulla: mostra il testo a video.
    #>
    param($Inventario, $Blocco, [string]$Cartella)

    $file   = Join-Path $Cartella ('Report_{0}.txt' -f (Get-Date -Format 'yyyy-MM'))
    $testo  = New-Object System.Collections.Generic.List[string]
    $nuovo  = -not (Test-Path -LiteralPath $file)

    if ($nuovo) { $testo.AddRange([string[]](New-InventarioMensile $Inventario)) }
    $testo.AddRange([string[]]$Blocco)

    if ($Test) {
        Write-Host ''
        Write-Host "=== ANTEPRIMA REPORT (non scritto) -> $file ===" -ForegroundColor Cyan
        if ($nuovo) { Write-Host '(file nuovo: verrebbe scritto anche l''inventario completo, qui omesso)' -ForegroundColor DarkGray }
        $Blocco | ForEach-Object { Write-Host $_ }
        return
    }

    # UTF-8 con BOM: così il Blocco note e qualsiasi editor mostrano correttamente gli accenti
    $codifica = New-Object System.Text.UTF8Encoding($true)
    [IO.File]::AppendAllText($file, (($testo -join "`r`n") + "`r`n"), $codifica)
    Write-Log "Report scritto: $file"
}

function Save-Stato {
    <#
        Salva la "memoria" dello script. Scrive prima un file temporaneo e poi lo
        sostituisce all'originale: se il PC si spegne a metà, stato.json non resta corrotto.
    #>
    param($Stato, $Inventario)

    $daSalvare = [pscustomobject]@{
        UltimoControllo      = (Get-Date -Format 'yyyy-MM-dd')
        Fallimenti           = $Stato.Fallimenti
        InventarioPrecedente = @($Inventario | ForEach-Object {
            [pscustomobject]@{ Id = $_.Id; Nome = $_.Nome; Versione = $_.Installata; Tipo = $_.Tipo }
        })
    }

    $json        = $daSalvare | ConvertTo-Json -Depth 5
    $temporaneo  = "$FileStato.tmp"
    $codifica    = New-Object System.Text.UTF8Encoding($true)
    [IO.File]::WriteAllText($temporaneo, $json, $codifica)
    Move-Item -LiteralPath $temporaneo -Destination $FileStato -Force
    Write-Log 'Stato salvato.'
}

# ---------------------------------------------------------------
#  FASE 5 - FINESTRA (5a: visualizzazione e filtri - 5b: liste - 5c: aggiornamento)
# ---------------------------------------------------------------

# Testi "umani" per stati e tipi
$script:NomiStato = @{
    'Aggiornabile'    = 'Aggiornabile'
    'SoloManuale'     = 'Solo manuale'
    'Aggiornato'      = 'Aggiornato'
    'NonVerificabile' = 'Non verificabile'
}

function Get-TipoLeggibile {
    param([string]$Tipo)
    switch ($Tipo) {
        'MSIX'  { return 'MSIX' }
        'ARP'   { return 'Non verificabile (ARP)' }
        'Altro' { return 'Non verificabile (ARP)' }
        default { return 'winget' }
    }
}

function Get-InfoControlli {
    <# Testi per l'intestazione: ultimo controllo e prossimo controllo previsto #>
    param($Config, $Stato)

    $cultura = [Globalization.CultureInfo]'it-IT'
    $oggi    = (Get-Date).Date
    $ultimo  = $null
    if ($Stato -and $Stato.UltimoControllo) {
        if ($Stato.UltimoControllo -is [datetime]) { $ultimo = $Stato.UltimoControllo.Date }
        else { $ultimo = [datetime]::ParseExact([string]$Stato.UltimoControllo, 'yyyy-MM-dd', [Globalization.CultureInfo]::InvariantCulture) }
    }

    $testoUltimo = 'mai eseguito'
    if ($ultimo) { $testoUltimo = $ultimo.ToString('ddd dd/MM/yyyy', $cultura) }

    # Prossimo giorno di controllo (oggi compreso, se oggi non è ancora stato fatto)
    $prossimo = $oggi
    while ($prossimo.DayOfWeek.ToString() -ne $Config.GiornoControllo -or ($ultimo -and $prossimo -eq $ultimo)) {
        $prossimo = $prossimo.AddDays(1)
    }
    $testoProssimo = $prossimo.ToString('ddd dd/MM/yyyy', $cultura)
    if (-not $ultimo) { $testoProssimo = 'al prossimo accesso (primo controllo)' }
    if ($ultimo -and ($oggi - $ultimo).TotalDays -ge $Config.GiorniMassimiTraControlli) {
        $testoProssimo = 'in ritardo: al prossimo accesso'
    }

    return [pscustomobject]@{ Ultimo = $testoUltimo; Prossimo = $testoProssimo }
}

function Select-Programmi {
    <#
        Applica i filtri a un elenco di programmi. Funzione "pura" (non tocca la finestra),
        così si può collaudare anche senza interfaccia grafica.
          -Testo      : cerca in nome e ID (ignora maiuscole/minuscole)
          -Stato      : Tutti | Aggiornabile | SoloManuale | Aggiornato | NonVerificabile
          -Attenzione : Tutti | Con | Senza
          -Tipo       : Tutti | winget | ARP | MSIX
          -Lista      : Tutti | Automatici | Esclusi | Segnalati | Sistema
    #>
    param($Elenco, [string]$Testo = '', [string]$Stato = 'Tutti', [string]$Attenzione = 'Tutti',
          [string]$Tipo = 'Tutti', [string]$Lista = 'Tutti', $Liste)

    $segnalati = @()
    if ($Liste) { $segnalati = @($Liste.Attenzione) }

    $confronto = [StringComparison]::OrdinalIgnoreCase
    $risultato = foreach ($p in @($Elenco)) {
        if ($Testo -and ([string]$p.Nome).IndexOf($Testo, $confronto) -lt 0 -and ([string]$p.Id).IndexOf($Testo, $confronto) -lt 0) { continue }
        if ($Stato -ne 'Tutti' -and $p.Stato -ne $Stato) { continue }
        if ($Attenzione -eq 'Con'   -and -not $p.Attenzione) { continue }
        if ($Attenzione -eq 'Senza' -and $p.Attenzione) { continue }
        if ($Tipo -ne 'Tutti') {
            $t = 'winget'
            if ($p.Tipo -eq 'MSIX') { $t = 'MSIX' }
            elseif ($p.Tipo -in 'ARP', 'Altro') { $t = 'ARP' }
            if ($t -ne $Tipo) { continue }
        }
        # (niente "continue" dentro switch: in PowerShell lo switch è un ciclo a sé)
        if ($Lista -eq 'Automatici' -and -not $p.Automatico)          { continue }
        if ($Lista -eq 'Esclusi'    -and -not $p.Escluso)             { continue }
        if ($Lista -eq 'Segnalati'  -and $segnalati -notcontains $p.Id) { continue }
        if ($Lista -eq 'Sistema'    -and -not $p.Sistema)             { continue }
        $p
    }
    return @($risultato)
}

function Add-LogFinestra {
    <# Scrive una riga nel pannello di log della finestra, se è aperta #>
    param([string]$Riga, [string]$Livello)
    $box = $script:BoxLog
    if (-not $box -or $box.IsDisposed) { return }
    $colore = switch ($Livello) {
        'ERRORE' { [Drawing.Color]::FromArgb(255, 110, 110) }
        'AVVISO' { [Drawing.Color]::FromArgb(240, 200, 80) }
        default  { [Drawing.Color]::FromArgb(190, 190, 190) }
    }
    $box.SelectionStart  = $box.TextLength
    $box.SelectionLength = 0
    $box.SelectionColor  = $colore
    $box.AppendText($Riga + "`r`n")
    $box.ScrollToCaret()
}

function Show-Attesa {
    <# Piccola finestra "Caricamento..." mentre si legge l'inventario #>
    param([string]$Testo)
    Initialize-Grafica
    $f = New-Object Windows.Forms.Form
    $f.Text = 'Software Update Checker'
    $f.FormBorderStyle = 'FixedToolWindow'
    $f.StartPosition = 'CenterScreen'
    $f.ClientSize = New-Object Drawing.Size(380, 70)
    $f.TopMost = $true
    $l = New-Object Windows.Forms.Label
    $l.Text = $Testo
    $l.Dock = 'Fill'
    $l.TextAlign = 'MiddleCenter'
    $l.Font = New-Object Drawing.Font('Segoe UI', 10)
    $f.Controls.Add($l)
    $f.Show()
    [Windows.Forms.Application]::DoEvents()
    return $f
}

$script:GraficaPronta = $false
function Initialize-Grafica {
    if ($script:GraficaPronta) { return }
    Add-Type -AssemblyName System.Windows.Forms, System.Drawing
    # Testo nitido sugli schermi ad alta risoluzione
    try {
        Add-Type -Namespace SUC -Name Dpi -MemberDefinition '[DllImport("user32.dll")] public static extern bool SetProcessDPIAware();' -ErrorAction Stop
        [void][SUC.Dpi]::SetProcessDPIAware()
    } catch { }
    [Windows.Forms.Application]::EnableVisualStyles()
    $script:GraficaPronta = $true
}

function New-Vista {
    <#
        Crea un elenco (ListView) con la sua barra dei filtri e il contatore.
        Restituisce un oggetto "vista" che contiene tutto ciò che serve per aggiornarlo.
    #>
    param(
        [Windows.Forms.Control]$Contenitore,
        [scriptblock]$Fonte,          # restituisce l'elenco dei programmi da mostrare
        [object[]]$Colonne,           # @{ Titolo; Proprieta; Larghezza }
        [string[]]$Filtri,            # quali filtri mostrare: Stato, Attenzione, Tipo, Lista
        [switch]$Caselle
    )

    $vista = [pscustomobject]@{
        Lista     = $null
        Fonte     = $Fonte
        Colonne   = $Colonne
        Contatore = $null
        Testo     = $null
        Combo     = @{}
        Ordine    = [pscustomobject]@{ Colonna = $Colonne[0].Proprieta; Discendente = $false }
    }

    # --- barra dei filtri ---
    $barra = New-Object Windows.Forms.FlowLayoutPanel
    $barra.Dock = 'Top'
    $barra.Height = 34
    $barra.WrapContents = $false
    $barra.Padding = New-Object Windows.Forms.Padding(4, 4, 4, 0)

    $lbl = New-Object Windows.Forms.Label
    $lbl.Text = 'Cerca:'
    $lbl.AutoSize = $true
    $lbl.Margin = New-Object Windows.Forms.Padding(0, 6, 4, 0)
    $barra.Controls.Add($lbl)

    $vista.Testo = New-Object Windows.Forms.TextBox
    $vista.Testo.Width = 220
    $vista.Testo.Tag = $vista
    $vista.Testo.Add_TextChanged({ Update-Vista $this.Tag })
    $barra.Controls.Add($vista.Testo)

    $voci = @{
        'Stato'      = @('Tutti', 'Aggiornabile', 'Solo manuale', 'Aggiornato', 'Non verificabile')
        'Attenzione' = @('Tutti', 'Con flag Attenzione', 'Senza flag Attenzione')
        'Tipo'       = @('Tutti', 'winget', 'Non verificabile (ARP)', 'MSIX')
        'Lista'      = @('Tutti', 'Automatici', 'Esclusi', 'Segnalati', 'Sistema')
    }
    foreach ($nome in $Filtri) {
        $l2 = New-Object Windows.Forms.Label
        $l2.Text = "$($nome):"
        $l2.AutoSize = $true
        $l2.Margin = New-Object Windows.Forms.Padding(12, 6, 4, 0)
        $barra.Controls.Add($l2)

        $cb = New-Object Windows.Forms.ComboBox
        $cb.DropDownStyle = 'DropDownList'
        $cb.Width = 170
        [void]$cb.Items.AddRange($voci[$nome])
        $cb.SelectedIndex = 0
        $cb.Tag = $vista
        $cb.Add_SelectedIndexChanged({ Update-Vista $this.Tag })
        $barra.Controls.Add($cb)
        $vista.Combo[$nome] = $cb
    }

    # --- elenco ---
    $lv = New-Object Windows.Forms.ListView
    $lv.Dock = 'Fill'
    $lv.View = 'Details'
    $lv.FullRowSelect = $true
    $lv.GridLines = $true
    $lv.HideSelection = $false
    $lv.CheckBoxes = [bool]$Caselle
    $lv.Tag = $vista
    foreach ($c in $Colonne) { [void]$lv.Columns.Add($c.Titolo, $c.Larghezza) }

    # Clic sull'intestazione = ordina (secondo clic = ordine inverso)
    $lv.Add_ColumnClick({
        param($s, $e)
        $v = $s.Tag
        $prop = $v.Colonne[$e.Column].Proprieta
        if ($v.Ordine.Colonna -eq $prop) { $v.Ordine.Discendente = -not $v.Ordine.Discendente }
        else { $v.Ordine.Colonna = $prop; $v.Ordine.Discendente = $false }
        Update-Vista $v
    })

    $vista.Lista = $lv

    # --- contatore ---
    $vista.Contatore = New-Object Windows.Forms.Label
    $vista.Contatore.Dock = 'Bottom'
    $vista.Contatore.Height = 20
    $vista.Contatore.TextAlign = 'MiddleRight'

    # L'ordine di aggiunta conta: Fill va aggiunto per primo
    $Contenitore.Controls.Add($lv)
    $Contenitore.Controls.Add($barra)
    $Contenitore.Controls.Add($vista.Contatore)

    return $vista
}

function Update-Vista {
    <# Riempie l'elenco applicando filtri e ordinamento #>
    param($Vista)

    $tutti = @(& $Vista.Fonte)

    $mappaStato = @{ 'Aggiornabile' = 'Aggiornabile'; 'Solo manuale' = 'SoloManuale'; 'Aggiornato' = 'Aggiornato'; 'Non verificabile' = 'NonVerificabile' }
    $mappaAtt   = @{ 'Con flag Attenzione' = 'Con'; 'Senza flag Attenzione' = 'Senza' }
    $mappaTipo  = @{ 'winget' = 'winget'; 'Non verificabile (ARP)' = 'ARP'; 'MSIX' = 'MSIX' }

    $par = @{ Elenco = $tutti; Testo = $Vista.Testo.Text.Trim(); Liste = $script:ListeFinestra }
    if ($Vista.Combo['Stato']      -and $Vista.Combo['Stato'].SelectedIndex      -gt 0) { $par.Stato      = $mappaStato[[string]$Vista.Combo['Stato'].SelectedItem] }
    if ($Vista.Combo['Attenzione'] -and $Vista.Combo['Attenzione'].SelectedIndex -gt 0) { $par.Attenzione = $mappaAtt[[string]$Vista.Combo['Attenzione'].SelectedItem] }
    if ($Vista.Combo['Tipo']       -and $Vista.Combo['Tipo'].SelectedIndex       -gt 0) { $par.Tipo       = $mappaTipo[[string]$Vista.Combo['Tipo'].SelectedItem] }
    if ($Vista.Combo['Lista']      -and $Vista.Combo['Lista'].SelectedIndex      -gt 0) { $par.Lista      = [string]$Vista.Combo['Lista'].SelectedItem }

    $filtrati = @(Select-Programmi @par | Sort-Object -Property $Vista.Ordine.Colonna -Descending:$Vista.Ordine.Discendente)

    $lv = $Vista.Lista
    $lv.BeginUpdate()
    $lv.Items.Clear()
    $giallo = [Drawing.Color]::FromArgb(255, 246, 200)
    foreach ($p in $filtrati) {
        $valori = foreach ($c in $Vista.Colonne) { [string]$p.($c.Proprieta) }
        $item = [Windows.Forms.ListViewItem]::new([string[]]@($valori))
        $item.Tag = $p
        if ($p.Attenzione) { $item.BackColor = $giallo }
        if ($p.Stato -eq 'SoloManuale' -or $p.Escluso) { $item.ForeColor = [Drawing.Color]::Gray }
        [void]$lv.Items.Add($item)
    }
    $lv.EndUpdate()

    $Vista.Contatore.Text = "$($filtrati.Count) di $($tutti.Count) visualizzati   "
}

function Edit-Liste {
    <#
        Applica un'azione delle liste a uno o più programmi. Funzione "pura":
        modifica solo l'oggetto $Liste e restituisce i messaggi per il log.
        Azioni: Automatici | Esclusi | Segnala | RimuoviSegnalazione | RimuoviDaLista
        (-Lista serve solo con RimuoviDaLista: Automatici, Esclusi, Attenzione, AttenzioneRimossa)
    #>
    param($Liste, $Programmi, [string]$Azione, [string]$Lista)

    $messaggi = New-Object System.Collections.Generic.List[object]
    function Msg([string]$Livello, [string]$Testo) { $messaggi.Add([pscustomobject]@{ Livello = $Livello; Testo = $Testo }) }
    function Has([string]$Chiave, [string]$Id) { return @($Liste.$Chiave) -contains $Id }
    function Add-Id([string]$Chiave, [string]$Id) {
        $Liste.$Chiave = [string[]]@(@($Liste.$Chiave) + $Id | Where-Object { $_ } | Sort-Object -Unique)
    }
    function Remove-Id([string]$Chiave, [string]$Id) {
        $Liste.$Chiave = [string[]]@(@($Liste.$Chiave) | Where-Object { $_ -and $_ -ne $Id })
    }

    $nomiListe = @{ Automatici = 'automatici'; Esclusi = 'esclusi'; Attenzione = 'segnalati'; AttenzioneRimossa = 'regole sospese' }

    foreach ($p in @($Programmi)) {
        $id = [string]$p.Id
        $nome = [string]$p.Nome
        if (-not $nome) { $nome = $id }

        switch ($Azione) {
            'Automatici' {
                if ($p.Tipo -in 'MSIX', 'ARP', 'Altro' -or $p.Stato -in 'NonVerificabile', 'SoloManuale') {
                    Msg 'AVVISO' "$nome non aggiunto agli automatici: winget non può aggiornarlo"
                }
                elseif (Has 'Automatici' $id) { Msg 'INFO' "$nome è già tra gli automatici" }
                else {
                    Add-Id 'Automatici' $id
                    Msg 'INFO' "Aggiunto agli automatici: $nome (sarà aggiornato da solo dal prossimo controllo)"
                    if (Has 'Esclusi' $id) { Remove-Id 'Esclusi' $id; Msg 'INFO' "  (tolto dagli esclusi)" }
                }
            }
            'Esclusi' {
                if (Has 'Esclusi' $id) { Msg 'INFO' "$nome è già tra gli esclusi" }
                else {
                    Add-Id 'Esclusi' $id
                    Msg 'INFO' "Aggiunto agli esclusi: $nome"
                    if (Has 'Automatici' $id) { Remove-Id 'Automatici' $id; Msg 'INFO' "  (tolto dagli automatici)" }
                }
            }
            'Segnala' {
                if (Has 'Attenzione' $id) { Msg 'INFO' "$nome è già segnalato" }
                else { Add-Id 'Attenzione' $id; Msg 'INFO' "Segnalato con Attenzione: $nome" }
                if (Has 'AttenzioneRimossa' $id) { Remove-Id 'AttenzioneRimossa' $id; Msg 'INFO' "  (riattivate le regole automatiche)" }
            }
            'RimuoviSegnalazione' {
                $fatto = $false
                if (Has 'Attenzione' $id) { Remove-Id 'Attenzione' $id; Msg 'INFO' "Tolta la segnalazione manuale: $nome"; $fatto = $true }
                $motivi = [string]$p.MotiviAttenzione
                if ($motivi -match 'Salto di versione|Versione installata sconosciuta') {
                    if (-not (Has 'AttenzioneRimossa' $id)) {
                        Add-Id 'AttenzioneRimossa' $id
                        Msg 'INFO' "Sospese le regole automatiche (salto di versione / versione sconosciuta): $nome"
                    }
                    $fatto = $true
                }
                if ($motivi -match 'fallito|winget stesso') {
                    Msg 'AVVISO' "$nome resta segnalato: 'aggiornamento fallito' e 'aggiorna winget' non si possono sospendere"
                }
                if (-not $fatto -and $motivi -notmatch 'fallito|winget stesso') { Msg 'INFO' "$nome non ha segnalazioni da togliere" }
            }
            'RimuoviDaLista' {
                if (Has $Lista $id) {
                    Remove-Id $Lista $id
                    Msg 'INFO' "Tolto dalla lista $($nomiListe[$Lista]): $nome"
                }
            }
        }
    }
    return $messaggi
}

function Save-Liste {
    <# Salva liste.json (UTF-8 con BOM, scrittura "sicura" con file temporaneo) #>
    param($Liste)
    $ordinato = [ordered]@{}
    foreach ($k in 'Esclusi', 'Automatici', 'Attenzione', 'AttenzioneRimossa') {
        $ordinato[$k] = [string[]]@(@($Liste.$k) | Where-Object { $_ })
    }
    $json = [pscustomobject]$ordinato | ConvertTo-Json -Depth 3
    $temporaneo = "$FileListe.tmp"
    [IO.File]::WriteAllText($temporaneo, $json, (New-Object System.Text.UTF8Encoding($true)))
    Move-Item -LiteralPath $temporaneo -Destination $FileListe -Force
}

function New-PannelloAzioni {
    <#
        Crea la fila di pulsanti in fondo a una scheda.
        Liste (5b) e Aggiorna (5c) attivi; Esporta (5d) non ancora.
        In modalità Info il pulsante Aggiorna resta spento: Info non installa mai nulla.
    #>
    param([Windows.Forms.Control]$Contenitore, [switch]$ConAggiorna, [switch]$ConEsporta)

    $pannello = New-Object Windows.Forms.FlowLayoutPanel
    $pannello.Dock = 'Bottom'
    $pannello.Height = 40
    $pannello.Padding = New-Object Windows.Forms.Padding(4)

    $pulsanti = New-Object System.Collections.Generic.List[object]
    function Add-Pulsante([string]$Testo, [string]$Azione, [string]$Suggerimento, [bool]$Attivo = $true) {
        $b = New-Object Windows.Forms.Button
        $b.Text = $Testo
        $b.Name = $Azione           # l'azione da eseguire viaggia nel nome del pulsante
        $b.AutoSize = $true
        $b.Enabled = $Attivo
        $script:Suggerimenti.SetToolTip($b, $Suggerimento)
        $pannello.Controls.Add($b)
        $pulsanti.Add($b)
    }

    Add-Pulsante 'Seleziona tutti' 'SelezionaTutti' 'Spunta tutti i programmi visualizzati'
    Add-Pulsante 'Nessuno'         'Nessuno'        'Toglie tutte le spunte'
    if ($ConAggiorna) {
        if ($Info) { Add-Pulsante '▶ Aggiorna selezionati' 'Aggiorna' 'Non disponibile in modalità Info (sola consultazione)' $false }
        else       { Add-Pulsante '▶ Aggiorna selezionati' 'Aggiorna' 'Aggiorna i programmi spuntati (prima chiede conferma)' }
    }
    Add-Pulsante '+ Automatici'          'Automatici'          'Aggiorna da solo, il sabato, i programmi spuntati'
    Add-Pulsante '+ Esclusi'             'Esclusi'             'Ignora per sempre i programmi spuntati'
    Add-Pulsante '! Segnala'             'Segnala'             'Segna con Attenzione: mai aggiornati in automatico'
    Add-Pulsante 'Rimuovi segnalazione'  'RimuoviSegnalazione' 'Toglie la segnalazione manuale e sospende le regole automatiche'

    if ($ConAggiorna) {
        $cb = New-Object Windows.Forms.CheckBox
        $cb.Text = 'Simulazione (dry-run)'; $cb.AutoSize = $true; $cb.Name = 'Simulazione'
        $cb.Margin = New-Object Windows.Forms.Padding(12, 8, 0, 0)
        if ($Test) { $cb.Checked = $true; $cb.Enabled = $false }      # in -Test si simula sempre
        if ($Info) { $cb.Enabled = $false }
        $script:Suggerimenti.SetToolTip($cb, 'Fa tutto il percorso ma non installa nulla: mostra i comandi che verrebbero eseguiti')
        $pannello.Controls.Add($cb)
        $pulsanti.Add($cb)
    }
    if ($ConEsporta) {
        Add-Pulsante 'Esporta vista…' 'EsportaVista' 'Disponibile dalla tappa 5d' $false
        Add-Pulsante 'Esporta tutto…' 'EsportaTutto' 'Disponibile dalla tappa 5d' $false
    }

    $Contenitore.Controls.Add($pannello)
    return $pulsanti
}

function Connect-Azioni {
    <# Collega i pulsanti di un pannello alla vista (elenco) della stessa scheda #>
    param($Pulsanti, $Vista)
    foreach ($b in $Pulsanti) {
        if ($b -is [Windows.Forms.CheckBox]) {
            $Vista | Add-Member -Force -NotePropertyName Simulazione -NotePropertyValue $b
            continue
        }
        $b.Tag = $Vista
        $b.Add_Click({ Invoke-AzioneFinestra -Vista $this.Tag -Azione $this.Name })
    }
}

function Get-ProgrammiScelti {
    <# I programmi spuntati; se non ce n'è nessuno, quelli selezionati (evidenziati) #>
    param([Windows.Forms.ListView]$Lista)
    $scelti = @($Lista.CheckedItems | ForEach-Object { $_.Tag })
    if ($scelti.Count -eq 0) { $scelti = @($Lista.SelectedItems | ForEach-Object { $_.Tag }) }
    return $scelti
}

function Invoke-AzioneFinestra {
    <# Esegue l'azione di un pulsante: selezione oppure modifica delle liste #>
    param($Vista, [string]$Azione)

    $lv = $Vista.Lista
    switch ($Azione) {
        'SelezionaTutti' { foreach ($i in $lv.Items) { $i.Checked = $true }; return }
        'Nessuno'        { foreach ($i in $lv.Items) { $i.Checked = $false }; return }
        'Aggiorna'       { Invoke-AggiornaFinestra -Vista $Vista; return }
    }

    $scelti = @(Get-ProgrammiScelti $lv)
    if ($scelti.Count -eq 0) {
        [void][Windows.Forms.MessageBox]::Show('Spunta (o seleziona) almeno un programma.', 'Software Update Checker',
            [Windows.Forms.MessageBoxButtons]::OK, [Windows.Forms.MessageBoxIcon]::Information)
        return
    }
    Invoke-ModificaListe -Programmi $scelti -Azione $Azione
}

function Invoke-AggiornaFinestra {
    <# Il pulsante "Aggiorna selezionati": conferma, aggiornamento con avanzamento, riepilogo #>
    param($Vista)

    $titolo = 'Software Update Checker'
    $scelti = @(Get-ProgrammiScelti $Vista.Lista)
    if ($scelti.Count -eq 0) {
        [void][Windows.Forms.MessageBox]::Show('Spunta (o seleziona) almeno un programma.', $titolo,
            [Windows.Forms.MessageBoxButtons]::OK, [Windows.Forms.MessageBoxIcon]::Information)
        return
    }

    $simula = $Test -or ($Vista.Simulazione -and $Vista.Simulazione.Checked)

    # Solo i programmi che winget sa aggiornare; gli altri vengono saltati con una spiegazione
    $daFare = @($scelti | Where-Object { $_.Stato -eq 'Aggiornabile' })
    foreach ($p in @($scelti | Where-Object { $_.Stato -ne 'Aggiornabile' })) {
        Write-Log "$($p.Nome) saltato: winget non può aggiornarlo ($($script:NomiStato[$p.Stato]))" 'AVVISO'
    }
    if ($daFare.Count -eq 0) {
        [void][Windows.Forms.MessageBox]::Show("Nessuno dei programmi scelti può essere aggiornato da winget.`r`nI dettagli sono nel log.",
            $titolo, [Windows.Forms.MessageBoxButtons]::OK, [Windows.Forms.MessageBoxIcon]::Information)
        return
    }

    # --- conferma ---
    $righe = New-Object System.Collections.Generic.List[string]
    $mostrati = 0
    foreach ($p in ($daFare | Sort-Object Nome)) {
        if ($mostrati -ge 20) { $righe.Add("   … e altri $($daFare.Count - 20)"); break }
        $riga = "   • $($p.Nome)   $($p.Installata) → $($p.Disponibile)"
        if ($p.Attenzione) { $riga += "`r`n        ⚠ $($p.MotiviAttenzione)" }
        $righe.Add($riga)
        $mostrati++
    }
    $testo = "Stai per aggiornare $($daFare.Count) programmi:`r`n`r`n" + ($righe -join "`r`n") +
             "`r`n`r`nChiudi i programmi che stai per aggiornare prima di continuare."
    if ($simula) {
        $testo += "`r`n`r`nSIMULAZIONE: non verrà installato nulla."
    }
    else {
        $testo += "`r`nPrima verrà creato un punto di ripristino (può richiedere fino a un minuto: la finestra potrebbe sembrare ferma)."
        if (-not (Test-Amministratore)) {
            $testo += "`r`n`r`nATTENZIONE: lo script NON è avviato come amministratore: molti aggiornamenti potrebbero fallire."
        }
    }
    $testo += "`r`n`r`nContinuare?"
    $risposta = [Windows.Forms.MessageBox]::Show($testo, $titolo, [Windows.Forms.MessageBoxButtons]::YesNo,
                                                 [Windows.Forms.MessageBoxIcon]::Question)
    if ($risposta -ne [Windows.Forms.DialogResult]::Yes) { Write-Log 'Aggiornamento annullato.'; return }

    # --- esecuzione ---
    $script:AggiornamentoInCorso = $true
    $script:SchedeFinestra.Enabled = $false
    $script:PannelloStato.Visible = $true
    $script:BarraAvanzamento.Maximum = $daFare.Count
    $script:BarraAvanzamento.Value = 0
    $script:EtichettaStato.Text = if ($simula) { 'Simulazione in corso…' } else { 'Creazione del punto di ripristino…' }
    [Windows.Forms.Application]::DoEvents()

    $avanzamento = {
        param($i, $tot, $p, $r)
        if ($null -eq $r) {
            $script:EtichettaStato.Text = "[$i/$tot]  $($p.Nome)  ($($p.Installata) → $($p.Disponibile))…"
        }
        else {
            $script:BarraAvanzamento.Value = $i
            $script:EtichettaStato.Text = "[$i/$tot]  $($p.Nome): $($r.Esito)"
        }
        [Windows.Forms.Application]::DoEvents()
    }

    $risultati = @()
    try {
        $risultati = @(Invoke-Aggiornamenti -Pacchetti $daFare -Stato $script:StatoFinestra -Simula:$simula -Avanzamento $avanzamento)
    }
    catch {
        Write-Log "Errore durante gli aggiornamenti: $($_.Exception.Message)" 'ERRORE'
    }
    finally {
        $script:AggiornamentoInCorso = $false
        $script:SchedeFinestra.Enabled = $true
    }

    # --- dopo: inventario, classificazione, finestra ---
    $ok      = @($risultati | Where-Object { $_.Esito -eq 'OK' })
    $ko      = @($risultati | Where-Object { $_.Esito -eq 'Fallito' })
    $sim     = @($risultati | Where-Object { $_.Esito -eq 'Simulato' })
    $riavvio = @($risultati | Where-Object { $_.Riavvio })

    if (-not $simula) {
        foreach ($r in $risultati) { $script:RisultatiFinestra.Add($r) }
        Update-InventarioDopoAggiornamenti -Inventario $script:InventarioFinestra -Risultati $risultati
        Set-Classificazione -Inventario $script:InventarioFinestra -Config $script:ConfigFinestra `
                            -Liste $script:ListeFinestra -Stato $script:StatoFinestra
        Update-Finestra
    }

    $riepilogo = if ($simula) { "Simulazione completata: $($sim.Count) programmi (nessuna installazione)." }
                 else { "Aggiornamento completato.`r`n`r`nRiusciti: $($ok.Count)`r`nFalliti: $($ko.Count)" }
    if ($ko.Count) { $riepilogo += "`r`n`r`nFalliti:`r`n" + (($ko | ForEach-Object { "   • $($_.Nome): $($_.Messaggio)" }) -join "`r`n") }
    if ($riavvio.Count) { $riepilogo += "`r`n`r`nRiavvio consigliato per: " + (($riavvio | ForEach-Object { $_.Nome }) -join ', ') }
    $script:EtichettaStato.Text = ($riepilogo -split "`r`n")[0]
    Write-Log ($riepilogo -replace "`r`n", ' ')

    $icona = if ($ko.Count) { [Windows.Forms.MessageBoxIcon]::Warning } else { [Windows.Forms.MessageBoxIcon]::Information }
    [void][Windows.Forms.MessageBox]::Show($riepilogo, $titolo, [Windows.Forms.MessageBoxButtons]::OK, $icona)
}

function Invoke-ModificaListe {
    <# Modifica le liste, le salva, ricalcola la classificazione e aggiorna la finestra #>
    param($Programmi, [string]$Azione, [string]$Lista)

    $messaggi = Edit-Liste -Liste $script:ListeFinestra -Programmi $Programmi -Azione $Azione -Lista $Lista
    foreach ($m in $messaggi) { Write-Log $m.Testo $m.Livello }

    if ($Test) {
        Write-Log 'Simulazione: liste.json NON salvato (le modifiche valgono solo per questa finestra).' 'AVVISO'
    }
    else {
        try {
            Save-Liste $script:ListeFinestra
            Write-Log 'liste.json salvato.'
        }
        catch {
            Write-Log "Impossibile salvare liste.json: $($_.Exception.Message)" 'ERRORE'
        }
    }

    # Le liste sono cambiate: ricalcoliamo dove va ogni programma
    Set-Classificazione -Inventario $script:InventarioFinestra -Config $script:ConfigFinestra `
                        -Liste $script:ListeFinestra -Stato $script:StatoFinestra
    Update-Finestra
}

function Update-Testata {
    $inv   = $script:InventarioFinestra
    $daAgg = @($inv | Where-Object { $_.Destinazione })
    $info  = Get-InfoControlli $script:ConfigFinestra $script:StatoFinestra
    $script:TestataFinestra.Text = ("Ultimo controllo: {0}   ·   Prossimo controllo: {1}   ·   Modalità: {2}`r`n" +
        "{3} programmi   ·   {4} aggiornabili ({5} da decidere)   ·   {6} solo manuali   ·   {7} con attenzione   ·   {8} di sistema   ·   {9} esclusi") -f
        $info.Ultimo, $info.Prossimo, $script:ModalitaFinestra, $inv.Count,
        @($daAgg | Where-Object { $_.Stato -eq 'Aggiornabile' }).Count,
        @($daAgg | Where-Object { $_.Stato -eq 'Aggiornabile' -and $_.Destinazione -eq 'Finestra' }).Count,
        @($daAgg | Where-Object { $_.Stato -eq 'SoloManuale'  -and $_.Destinazione -eq 'Finestra' }).Count,
        @($daAgg | Where-Object { $_.Attenzione }).Count,
        @($daAgg | Where-Object { $_.Destinazione -eq 'Sistema' }).Count,
        @($daAgg | Where-Object { $_.Destinazione -eq 'Escluso' }).Count
}

function Update-SchedaListe {
    $cb = $script:ComboListe
    $lv = $script:ElencoListe
    if (-not $cb -or $cb.SelectedIndex -lt 0) { return }
    $chiave = @('Automatici', 'Esclusi', 'Attenzione', 'AttenzioneRimossa')[$cb.SelectedIndex]
    $lv.BeginUpdate(); $lv.Items.Clear()
    foreach ($id in @($script:ListeFinestra.$chiave | Where-Object { $_ })) {
        $p = $script:InventarioFinestra | Where-Object { $_.Id -eq $id } | Select-Object -First 1
        $nome = if ($p) { $p.Nome } else { '(non trovato tra i programmi installati)' }
        $inst = if ($p) { 'sì' } else { 'no' }
        $item = [Windows.Forms.ListViewItem]::new([string[]]@($id, $nome, $inst))
        $item.Tag = [pscustomobject]@{ Id = $id; Nome = $nome }
        if (-not $p) { $item.ForeColor = [Drawing.Color]::Gray }
        [void]$lv.Items.Add($item)
    }
    $lv.EndUpdate()
    $script:ContatoreListe.Text = "$($lv.Items.Count) programmi nella lista   "
}

function Update-Finestra {
    <# Ridisegna tutto: intestazione, elenchi (mantenendo i filtri) e scheda Liste #>
    Update-Testata
    foreach ($v in $script:VisteFinestra) { Update-Vista $v }
    Update-SchedaListe
}

function Show-Finestra {
    <#
        Mostra la finestra principale.
        Tappa 5b: consultazione + gestione delle liste (automatici, esclusi, segnalati).
    #>
    param($Inventario, $Config, $Stato, $Liste, [string]$Modalita)

    Initialize-Grafica
    $script:InventarioFinestra = $Inventario
    $script:ConfigFinestra     = $Config
    $script:StatoFinestra      = $Stato
    $script:ListeFinestra      = $Liste
    $script:ModalitaFinestra   = $Modalita
    $script:Suggerimenti       = New-Object Windows.Forms.ToolTip

    # Colonne "di comodo" per la visualizzazione
    foreach ($p in $Inventario) {
        $p | Add-Member -Force -NotePropertyMembers @{
            StatoTesto = $script:NomiStato[$p.Stato]
            TipoTesto  = Get-TipoLeggibile $p.Tipo
        }
    }

    $form = New-Object Windows.Forms.Form
    $form.Text = "Software Update Checker - $Modalita"
    $form.Font = New-Object Drawing.Font('Segoe UI', 9)
    $form.AutoScaleMode = 'Dpi'
    $form.StartPosition = 'CenterScreen'
    $form.Size = New-Object Drawing.Size(1200, 820)
    $form.MinimumSize = New-Object Drawing.Size(900, 600)

    # --- intestazione ---
    $script:TestataFinestra = New-Object Windows.Forms.Label
    $script:TestataFinestra.Dock = 'Top'
    $script:TestataFinestra.Height = 48
    $script:TestataFinestra.Padding = New-Object Windows.Forms.Padding(8, 6, 8, 0)
    $script:TestataFinestra.Font = New-Object Drawing.Font('Segoe UI', 9.5)

    # --- schede ---
    $schede = New-Object Windows.Forms.TabControl
    $schede.Dock = 'Fill'
    $script:SchedeFinestra = $schede
    $tAgg   = New-Object Windows.Forms.TabPage; $tAgg.Text   = 'Aggiornamenti'
    $tSis   = New-Object Windows.Forms.TabPage; $tSis.Text   = 'Sistema'
    $tListe = New-Object Windows.Forms.TabPage; $tListe.Text = 'Liste'
    $tTutti = New-Object Windows.Forms.TabPage; $tTutti.Text = 'Tutti i programmi'
    $schede.TabPages.AddRange(@($tAgg, $tSis, $tListe, $tTutti))

    $colAgg = @(
        @{ Titolo = 'Nome';        Proprieta = 'Nome';             Larghezza = 300 },
        @{ Titolo = 'Installata';  Proprieta = 'Installata';       Larghezza = 150 },
        @{ Titolo = 'Disponibile'; Proprieta = 'Disponibile';      Larghezza = 150 },
        @{ Titolo = 'Stato';       Proprieta = 'StatoTesto';       Larghezza = 110 },
        @{ Titolo = 'Note';        Proprieta = 'MotiviAttenzione'; Larghezza = 400 }
    )
    $colTutti = @(
        @{ Titolo = 'Nome';        Proprieta = 'Nome';             Larghezza = 280 },
        @{ Titolo = 'Id';          Proprieta = 'Id';               Larghezza = 260 },
        @{ Titolo = 'Tipo';        Proprieta = 'TipoTesto';        Larghezza = 150 },
        @{ Titolo = 'Installata';  Proprieta = 'Installata';       Larghezza = 120 },
        @{ Titolo = 'Disponibile'; Proprieta = 'Disponibile';      Larghezza = 120 },
        @{ Titolo = 'Stato';       Proprieta = 'StatoTesto';       Larghezza = 110 },
        @{ Titolo = 'Note';        Proprieta = 'MotiviAttenzione'; Larghezza = 300 }
    )

    # Scheda Aggiornamenti (prima il pannello in basso, poi l'elenco)
    $bAgg = New-PannelloAzioni -Contenitore $tAgg -ConAggiorna
    $vAgg = New-Vista -Contenitore $tAgg -Colonne $colAgg -Filtri @('Stato', 'Attenzione') -Caselle `
            -Fonte { $script:InventarioFinestra | Where-Object { $_.Destinazione -eq 'Finestra' } }
    Connect-Azioni $bAgg $vAgg

    # Scheda Sistema
    $bSis = New-PannelloAzioni -Contenitore $tSis -ConAggiorna
    $vSis = New-Vista -Contenitore $tSis -Colonne $colAgg -Filtri @('Stato', 'Attenzione') -Caselle `
            -Fonte { $script:InventarioFinestra | Where-Object { $_.Destinazione -eq 'Sistema' } }
    Connect-Azioni $bSis $vSis

    # Scheda Tutti i programmi
    $bTutti = New-PannelloAzioni -Contenitore $tTutti -ConEsporta
    $vTutti = New-Vista -Contenitore $tTutti -Colonne $colTutti -Filtri @('Stato', 'Attenzione', 'Tipo', 'Lista') -Caselle `
              -Fonte { $script:InventarioFinestra }
    Connect-Azioni $bTutti $vTutti

    $script:VisteFinestra = @($vAgg, $vSis, $vTutti)

    # Scheda Liste: scegli la lista dalla tendina, spunta e rimuovi
    $pListeSu = New-Object Windows.Forms.FlowLayoutPanel
    $pListeSu.Dock = 'Top'; $pListeSu.Height = 34; $pListeSu.Padding = New-Object Windows.Forms.Padding(4, 4, 4, 0)
    $lL = New-Object Windows.Forms.Label; $lL.Text = 'Lista:'; $lL.AutoSize = $true
    $lL.Margin = New-Object Windows.Forms.Padding(0, 6, 4, 0)
    $script:ComboListe = New-Object Windows.Forms.ComboBox
    $script:ComboListe.DropDownStyle = 'DropDownList'; $script:ComboListe.Width = 260
    [void]$script:ComboListe.Items.AddRange(@('Automatici', 'Esclusi', 'Segnalati da te (Attenzione)', 'Regole automatiche sospese'))
    $pListeSu.Controls.AddRange(@($lL, $script:ComboListe))

    $script:ElencoListe = New-Object Windows.Forms.ListView
    $script:ElencoListe.Dock = 'Fill'; $script:ElencoListe.View = 'Details'; $script:ElencoListe.FullRowSelect = $true
    $script:ElencoListe.GridLines = $true; $script:ElencoListe.CheckBoxes = $true; $script:ElencoListe.HideSelection = $false
    [void]$script:ElencoListe.Columns.Add('Id', 320)
    [void]$script:ElencoListe.Columns.Add('Nome', 320)
    [void]$script:ElencoListe.Columns.Add('Installato', 100)

    $pListeGiu = New-Object Windows.Forms.FlowLayoutPanel
    $pListeGiu.Dock = 'Bottom'; $pListeGiu.Height = 40; $pListeGiu.Padding = New-Object Windows.Forms.Padding(4)
    $bRimuovi = New-Object Windows.Forms.Button; $bRimuovi.Text = 'Rimuovi dalla lista'; $bRimuovi.AutoSize = $true
    $script:Suggerimenti.SetToolTip($bRimuovi, 'Toglie dalla lista mostrata i programmi spuntati')
    $pListeGiu.Controls.Add($bRimuovi)
    $script:ContatoreListe = New-Object Windows.Forms.Label
    $script:ContatoreListe.Dock = 'Bottom'; $script:ContatoreListe.Height = 20; $script:ContatoreListe.TextAlign = 'MiddleRight'

    $tListe.Controls.Add($script:ElencoListe)
    $tListe.Controls.Add($pListeSu)
    $tListe.Controls.Add($pListeGiu)
    $tListe.Controls.Add($script:ContatoreListe)

    $script:ComboListe.Add_SelectedIndexChanged({ Update-SchedaListe })
    $bRimuovi.Add_Click({
        $scelti = @(Get-ProgrammiScelti $script:ElencoListe)
        if ($scelti.Count -eq 0) {
            [void][Windows.Forms.MessageBox]::Show('Spunta (o seleziona) almeno un programma.', 'Software Update Checker',
                [Windows.Forms.MessageBoxButtons]::OK, [Windows.Forms.MessageBoxIcon]::Information)
            return
        }
        $chiave = @('Automatici', 'Esclusi', 'Attenzione', 'AttenzioneRimossa')[$script:ComboListe.SelectedIndex]
        Invoke-ModificaListe -Programmi $scelti -Azione 'RimuoviDaLista' -Lista $chiave
    })

    # --- pannello di log ---
    $pLog = New-Object Windows.Forms.Panel
    $pLog.Dock = 'Bottom'; $pLog.Height = 170
    $barraLog = New-Object Windows.Forms.FlowLayoutPanel
    $barraLog.Dock = 'Top'; $barraLog.Height = 32; $barraLog.Padding = New-Object Windows.Forms.Padding(4, 2, 4, 0)
    $lLog = New-Object Windows.Forms.Label; $lLog.Text = 'Log'; $lLog.AutoSize = $true
    $lLog.Font = New-Object Drawing.Font('Segoe UI', 9, [Drawing.FontStyle]::Bold)
    $lLog.Margin = New-Object Windows.Forms.Padding(0, 6, 12, 0)
    $bCopia = New-Object Windows.Forms.Button; $bCopia.Text = 'Copia';  $bCopia.AutoSize = $true
    $bSalva = New-Object Windows.Forms.Button; $bSalva.Text = 'Salva…'; $bSalva.AutoSize = $true
    $bNasc  = New-Object Windows.Forms.Button; $bNasc.Text = '▼ Nascondi'; $bNasc.AutoSize = $true
    $barraLog.Controls.AddRange(@($lLog, $bCopia, $bSalva, $bNasc))

    $script:BoxLog = New-Object Windows.Forms.RichTextBox
    $script:BoxLog.Dock = 'Fill'
    $script:BoxLog.ReadOnly = $true
    $script:BoxLog.BackColor = [Drawing.Color]::FromArgb(30, 30, 30)
    $script:BoxLog.Font = New-Object Drawing.Font('Consolas', 9)
    $pLog.Controls.Add($script:BoxLog)
    $pLog.Controls.Add($barraLog)

    $bCopia.Add_Click({ if ($script:BoxLog.Text) { [Windows.Forms.Clipboard]::SetText($script:BoxLog.Text) } })
    $bSalva.Add_Click({
        $dlg = New-Object Windows.Forms.SaveFileDialog
        $dlg.Filter = 'Testo (*.txt)|*.txt'
        $dlg.FileName = 'Log_' + (Get-Date -Format 'yyyy-MM-dd_HHmm') + '.txt'
        if ($dlg.ShowDialog() -eq 'OK') {
            [IO.File]::WriteAllText($dlg.FileName, $script:BoxLog.Text, (New-Object Text.UTF8Encoding($true)))
        }
    })
    $bNasc.Tag = $pLog
    $bNasc.Add_Click({
        $pannello = $this.Tag
        if ($pannello.Height -gt 40) { $pannello.Height = 32; $this.Text = '▲ Mostra' }
        else { $pannello.Height = 170; $this.Text = '▼ Nascondi' }
    })

    # --- barra di avanzamento (visibile solo durante gli aggiornamenti) ---
    $script:PannelloStato = New-Object Windows.Forms.FlowLayoutPanel
    $script:PannelloStato.Dock = 'Bottom'; $script:PannelloStato.Height = 30
    $script:PannelloStato.Padding = New-Object Windows.Forms.Padding(6, 4, 6, 0)
    $script:PannelloStato.Visible = $false
    $script:BarraAvanzamento = New-Object Windows.Forms.ProgressBar
    $script:BarraAvanzamento.Width = 320; $script:BarraAvanzamento.Height = 18
    $script:EtichettaStato = New-Object Windows.Forms.Label
    $script:EtichettaStato.AutoSize = $true
    $script:EtichettaStato.Margin = New-Object Windows.Forms.Padding(10, 3, 0, 0)
    $script:PannelloStato.Controls.AddRange(@($script:BarraAvanzamento, $script:EtichettaStato))

    # Ordine di aggiunta: prima ciò che riempie (Fill), poi i bordi
    $form.Controls.Add($schede)
    $form.Controls.Add($script:PannelloStato)
    $form.Controls.Add($pLog)
    $form.Controls.Add($script:TestataFinestra)

    # Durante gli aggiornamenti la finestra non si chiude
    $form.Add_FormClosing({
        param($s, $e)
        if ($script:AggiornamentoInCorso) {
            $e.Cancel = $true
            [void][Windows.Forms.MessageBox]::Show('Attendi la fine degli aggiornamenti prima di chiudere.', 'Software Update Checker',
                [Windows.Forms.MessageBoxButtons]::OK, [Windows.Forms.MessageBoxIcon]::Information)
        }
    })

    # Le righe di log scritte prima che la finestra esistesse
    foreach ($r in $script:LogSessione) { Add-LogFinestra $r.Riga $r.Livello }

    $script:ComboListe.SelectedIndex = 0
    Update-Finestra

    # Se c'è qualcosa da decidere si parte dalla scheda Aggiornamenti, altrimenti da Tutti
    if ($vAgg.Lista.Items.Count -eq 0) { $schede.SelectedTab = $tTutti }

    $form.Add_Shown({ $this.TopMost = $true; $this.Activate(); $this.TopMost = $false })
    Write-Log "Finestra aperta ($Modalita)."
    [void]$form.ShowDialog()
    $script:BoxLog = $null
    $form.Dispose()
    Write-Log 'Finestra chiusa.'
}

# ---------------------------------------------------------------
#  PROGRAMMA PRINCIPALE
# ---------------------------------------------------------------
try {
    $config = Read-Json $FileConfig
    if (-not $config) { throw "File di configurazione non trovato: $FileConfig" }

    # Scorciatoie per il menu contestuale: aprono report o cartella ed escono subito
    if ($ApriReport -or $ApriCartella) {
        $fileMese = Join-Path $config.CartellaReport ('Report_{0}.txt' -f (Get-Date -Format 'yyyy-MM'))
        if ($ApriReport -and (Test-Path -LiteralPath $fileMese)) { Invoke-Item -LiteralPath $fileMese }
        elseif (Test-Path -LiteralPath $config.CartellaReport)   { Invoke-Item -LiteralPath $config.CartellaReport }
        return
    }

    # Cartella report: la creiamo se manca; se non si può (es. disco D: assente) ripieghiamo
    $cartellaReport = $CartellaScript
    try {
        if (-not (Test-Path -LiteralPath $config.CartellaReport)) {
            New-Item -ItemType Directory -Path $config.CartellaReport -Force | Out-Null
        }
        $cartellaReport     = $config.CartellaReport
        $script:CartellaLog = $config.CartellaReport
    }
    catch {
        Write-Log "Impossibile usare la cartella report '$($config.CartellaReport)': $($_.Exception.Message). Uso la cartella dello script." 'AVVISO'
    }

    $stato = Initialize-Stato (Read-Json $FileStato)
    $liste = Read-Liste

    if ($Info) {
        $script:MotivoEsecuzione = 'consultazione (Info)'
        Write-Log 'Modalità Info: sola consultazione.'
    }
    elseif (-not (Test-DeveEseguire $config $stato)) { return }

    # In modalità Info (avviata dal menu, senza console) mostriamo un "Caricamento..."
    $attesa = $null
    if ($Info) { $attesa = Show-Attesa 'Lettura dei programmi installati in corso...' }

    Import-Module Microsoft.WinGet.Client

    if (-not (Wait-Internet $config.AttesaInternetMinuti)) {
        Write-Log "Nessuna connessione internet dopo $($config.AttesaInternetMinuti) minuti. Controllo annullato." 'ERRORE'
        return
    }

    # --- Fase 1: inventario ---
    Write-Log 'Lettura inventario in corso...'
    $inventario = Get-Inventario
    Write-Log "Inventario letto: $($inventario.Count) voci."

    # --- Fase 2: classificazione ---
    Write-Log 'Classificazione in corso...'
    Set-Classificazione -Inventario $inventario -Config $config -Liste $liste -Stato $stato
    if ($Test -or $Dettagli) { Show-RiepilogoTest $inventario }

    # --- Modalità Info: solo la finestra, poi si esce senza toccare nulla ---
    if ($Info) {
        if ($attesa) { $attesa.Close(); $attesa.Dispose() }
        Show-Finestra -Inventario $inventario -Config $config -Stato $stato -Liste $liste -Modalita 'Info (sola consultazione)'
        return
    }

    # --- Fase 3: aggiornamenti automatici ---
    $automatici    = @($inventario | Where-Object { $_.Destinazione -eq 'Automatico' })
    $risultatiAuto = @()
    if ($automatici.Count -gt 0) {
        Write-Log "Aggiornamenti automatici da eseguire: $($automatici.Count)"
        $risultatiAuto = Invoke-Aggiornamenti -Pacchetti $automatici -Stato $stato
        if ($Test -or $Dettagli) { Show-RisultatiAggiornamenti $risultatiAuto 'AGGIORNAMENTI AUTOMATICI' }
    }
    else {
        Write-Log 'Nessun aggiornamento automatico da eseguire.'
    }

    Update-InventarioDopoAggiornamenti -Inventario $inventario -Risultati $risultatiAuto

    # --- Fase 5: la finestra, solo se resta qualcosa da decidere ---
    $daDecidere = @($inventario | Where-Object { $_.Destinazione -eq 'Finestra' })
    if ($daDecidere.Count -gt 0) {
        $modo = if ($Test) { 'Simulazione' } else { 'Controllo' }
        Show-Finestra -Inventario $inventario -Config $config -Stato $stato -Liste $liste -Modalita $modo
    }

    # --- Fase 4: report e memoria ---
    $blocco = New-BloccoReport -Inventario $inventario -Stato $stato -RisultatiAuto $risultatiAuto -RisultatiFinestra $script:RisultatiFinestra.ToArray()
    Write-Report -Inventario $inventario -Blocco $blocco -Cartella $cartellaReport

    if (-not $Test) { Save-Stato -Stato $stato -Inventario $inventario }
}
catch {
    Write-Log "Errore non gestito: $($_.Exception.Message)" 'ERRORE'
    if ($Test -or $Dettagli) { throw }
}
