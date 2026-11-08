#Requires -Version 5.1
<#
    Software-Update-Checker.ps1
    Controllo aggiornamenti dei programmi installati tramite winget.

    Parametri:
      -Forza        : esegue il controllo anche se non è il giorno previsto
      -Test         : SIMULAZIONE - mostra tutto a video e non modifica nulla
      -Dettagli     : mostra tutto a video ma agisce davvero
      -ApriReport   : apre il report del mese corrente ed esce
      -ApriCartella : apre la cartella dei report ed esce
#>
[CmdletBinding()]
param(
    [switch]$Forza,
    [switch]$Test,
    [switch]$Dettagli,
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
    param($Pacchetto, [int]$TimeoutMinuti = 15)

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
    if ($Test) {
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

        # Attesa con limite di tempo (il valore è in millisecondi)
        if (-not $processo.WaitForExit($TimeoutMinuti * 60 * 1000)) {
            & taskkill.exe /PID $processo.Id /T /F | Out-Null
            $risultato.Esito     = 'Fallito'
            $risultato.Messaggio = "Interrotto: superato il limite di $TimeoutMinuti minuti"
            return $risultato
        }

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
    <# Aggiorna un ELENCO di programmi: punto di ripristino, ordine, storico fallimenti #>
    param($Pacchetti, $Stato)

    # Ordine: tutti in ordine alfabetico, App Installer (winget stesso) sempre per ultimo
    $ordinati = @($Pacchetti | Sort-Object @{ Expression = { $_.Id -eq 'Microsoft.AppInstaller' } }, Nome)

    if (-not $Test) {
        if (-not (Test-Amministratore)) {
            Write-Log 'Lo script non ha i permessi di amministratore: alcuni aggiornamenti potrebbero fallire.' 'AVVISO'
        }
        New-PuntoRipristino
    }

    $risultati = foreach ($p in $ordinati) {
        $r = Invoke-Aggiornamento -Pacchetto $p

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
    param($Inventario, $Stato, $RisultatiAuto)

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
    $riavvio      = @($RisultatiAuto | Where-Object { $_.Riavvio })
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

    if (-not (Test-DeveEseguire $config $stato)) { return }

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

    # --- Fase 4: report e memoria ---
    Update-InventarioDopoAggiornamenti -Inventario $inventario -Risultati $risultatiAuto
    $blocco = New-BloccoReport -Inventario $inventario -Stato $stato -RisultatiAuto $risultatiAuto
    Write-Report -Inventario $inventario -Blocco $blocco -Cartella $cartellaReport

    if (-not $Test) { Save-Stato -Stato $stato -Inventario $inventario }
}
catch {
    Write-Log "Errore non gestito: $($_.Exception.Message)" 'ERRORE'
    if ($Test -or $Dettagli) { throw }
}
