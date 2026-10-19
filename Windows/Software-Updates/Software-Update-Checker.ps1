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
#  PROGRAMMA PRINCIPALE
# ---------------------------------------------------------------
try {
    $config = Read-Json $FileConfig
    if (-not $config) { throw "File di configurazione non trovato: $FileConfig" }

    # Cartella report: la creiamo se manca; se non si puo' (es. disco D: assente) ripieghiamo
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

    if (-not (Test-DeveEseguire $config $stato)) { return }

    Import-Module Microsoft.WinGet.Client

    if (-not (Wait-Internet $config.AttesaInternetMinuti)) {
        Write-Log "Nessuna connessione internet dopo $($config.AttesaInternetMinuti) minuti. Controllo annullato." 'ERRORE'
        return
    }

    Write-Log 'Lettura inventario in corso...'
    $inventario = Get-Inventario
    Write-Log "Inventario letto: $($inventario.Count) voci."

    if ($Test) {
        Write-Host ''
        Write-Host '=== RIEPILOGO PER STATO ===' -ForegroundColor Cyan
        $inventario | Group-Object Stato | Sort-Object Name |
            Format-Table Count, Name -AutoSize | Out-Host

        Write-Host '=== DA AGGIORNARE ===' -ForegroundColor Cyan
        $inventario | Where-Object { $_.Stato -in 'Aggiornabile','SoloManuale' } |
            Sort-Object Stato, Nome |
            Format-Table Nome, Id, Installata, Disponibile, Stato, VersioneSconosciuta -AutoSize | Out-Host
    }
}
catch {
    Write-Log "Errore non gestito: $($_.Exception.Message)" 'ERRORE'
    if ($Test) { throw }
}
