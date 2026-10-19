#Requires -Version 5.1
<#
    Software-Update-Checker.ps1
    Controllo aggiornamenti dei programmi installati tramite winget.
    FASE 1: impostazioni, controlli iniziali, inventario.

    Parametri:
      -Forza  : esegue il controllo anche se non e' il giorno previsto
      -Test   : mostra tutto a video e non modifica nulla
#>
[CmdletBinding()]
param(
    [switch]$Forza,
    [switch]$Test
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

    if ($Test) {
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

    $stato = Read-Json $FileStato
    $liste = Read-Liste

    if (-not (Test-DeveEseguire $config $stato)) { return }

    Import-Module Microsoft.WinGet.Client

    if (-not (Wait-Internet $config.AttesaInternetMinuti)) {
        Write-Log "Nessuna connessione internet dopo $($config.AttesaInternetMinuti) minuti. Controllo annullato." 'ERRORE'
        return
    }

    Write-Log 'Lettura inventario in corso...'
    $inventario = Get-Inventario
    Write-Log "Inventario letto: $($inventario.Count) voci."

    Write-Log 'Classificazione in corso...'
    Set-Classificazione -Inventario $inventario -Config $config -Liste $liste -Stato $stato

    if ($Test) { Show-RiepilogoTest $inventario }
}
catch {
    Write-Log "Errore non gestito: $($_.Exception.Message)" 'ERRORE'
    if ($Test) { throw }
}
