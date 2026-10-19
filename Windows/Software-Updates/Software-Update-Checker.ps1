#Requires -Version 5.1
<#
    Software-Update-Checker.ps1
    Controllo aggiornamenti dei programmi installati tramite winget.

    Parametri:
      -Forza     : esegue il controllo anche se non è il giorno previsto
      -Test      : SIMULAZIONE - mostra tutto a video e non modifica nulla
      -Dettagli  : mostra tutto a video ma agisce davvero
#>
[CmdletBinding()]
param(
    [switch]$Forza,
    [switch]$Test,
    [switch]$Dettagli
)

$ErrorActionPreference = 'Stop'

# ---------------------------------------------------------------
#  PERCORSI DI BASE
# ---------------------------------------------------------------
$CartellaScript = $PSScriptRoot
$FileConfig     = Join-Path $CartellaScript 'config.json'
$FileListe      = Join-Path $CartellaScript 'liste.json'
$FileStato      = Join-Path $CartellaScript 'stato.json'

# Finche' non leggiamo la config, eventuali errori vanno nella cartella dello script
$script:CartellaLog = $CartellaScript

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

    if ($Forza) { Write-Log 'Esecuzione forzata (-Forza).'; return $true }

    $oggi   = (Get-Date).Date
    $ultimo = $null
    if ($Stato -and $Stato.UltimoControllo) {
        if ($Stato.UltimoControllo -is [datetime]) { $ultimo = $Stato.UltimoControllo.Date }
        else { $ultimo = [datetime]::ParseExact([string]$Stato.UltimoControllo, 'yyyy-MM-dd', [Globalization.CultureInfo]::InvariantCulture) }
    }

    if ($ultimo -and $ultimo -eq $oggi) { Write-Log 'Controllo gia'' eseguito oggi.'; return $false }
    if ((Get-Date).DayOfWeek.ToString() -eq $Config.GiornoControllo) { Write-Log 'Oggi e'' il giorno del controllo.'; return $true }
    if (-not $ultimo) { Write-Log 'Nessun controllo precedente: primo avvio.'; return $true }

    $giorni = ($oggi - $ultimo).TotalDays
    if ($giorni -ge $Config.GiorniMassimiTraControlli) { Write-Log "Recupero: ultimo controllo $giorni giorni fa."; return $true }

    Write-Log 'Non e'' il giorno del controllo.'
    return $false
}

# ---------------------------------------------------------------
#  FASE 1b - C'E' INTERNET?
# ---------------------------------------------------------------
function Wait-Internet {
    param([int]$Minuti)

    # Interroghiamo direttamente il server dell'archivio di winget
    $url      = 'https://cdn.winget.microsoft.com/cache/source.msix'
    $scadenza = (Get-Date).AddMinutes($Minuti)
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

        $installata = [string]$p.InstalledVersion
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

    # Togliamo le voci MSIX "accessorie" che duplicano un programma gia' riconosciuto (es. Zed)
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

    # Storico dei fallimenti (lo scriverà la fase 4; per ora probabilmente non esiste)
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
            if     ($escluso)                                                      { $destinazione = 'Escluso' }
            elseif ($sistema -and $nascondiSistema)                                { $destinazione = 'Sistema' }
            elseif ($automatico -and -not $attenzione -and $p.Stato -eq 'Aggiornabile') { $destinazione = 'Automatico' }
            else                                                                   { $destinazione = 'Finestra' }
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
#  PROGRAMMA PRINCIPALE
# ---------------------------------------------------------------
try {
    $config = Read-Json $FileConfig
    if (-not $config) { throw "File di configurazione non trovato: $FileConfig" }

    # Cartella report: la creiamo se manca; se non si può (es. disco D: assente) ripieghiamo
    try {
        if (-not (Test-Path -LiteralPath $config.CartellaReport)) {
            New-Item -ItemType Directory -Path $config.CartellaReport -Force | Out-Null
        }
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
}
catch {
    Write-Log "Errore non gestito: $($_.Exception.Message)" 'ERRORE'
    if ($Test -or $Dettagli) { throw }
}
