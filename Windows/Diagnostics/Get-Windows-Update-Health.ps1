# Get-Windows-Update-Health.ps1
# Reports failed/aborted update attempts, Windows Update events, DISM package states, and pending reboot signals.
# Output folder: C:\UpdateAudit

$OutDir = "C:\UpdateAudit"
New-Item -ItemType Directory -Force -Path $OutDir | Out-Null
$stamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"

$ReportTxt = Join-Path $OutDir "UpdateHealthReport_$stamp.txt"
$HistoryCsv = Join-Path $OutDir "WU_History_NonSuccess_$stamp.csv"
$EventsCsv  = Join-Path $OutDir "WU_Events_Errors_$stamp.csv"
$DismCsv    = Join-Path $OutDir "DISM_NonInstalled_$stamp.csv"

function Add-Section([string]$title) {
    Add-Content -Path $ReportTxt -Encoding UTF8 -Value ""
    Add-Content -Path $ReportTxt -Encoding UTF8 -Value ("=" * 80)
    Add-Content -Path $ReportTxt -Encoding UTF8 -Value $title
    Add-Content -Path $ReportTxt -Encoding UTF8 -Value ("=" * 80)
}

function Test-PendingReboot {
    $rebootFlags = [ordered]@{
        "CBServicing\RebootPending" = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending"
        "WU\RebootRequired"         = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired"
        "PendingFileRenameOps"      = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager"
    }

    $results = [ordered]@{}
    $results["CBServicing\RebootPending"] = Test-Path $rebootFlags["CBServicing\RebootPending"]
    $results["WU\RebootRequired"]         = Test-Path $rebootFlags["WU\RebootRequired"]

    $pfr = $false
    try {
        $v = (Get-ItemProperty -Path $rebootFlags["PendingFileRenameOps"] -Name "PendingFileRenameOperations" -ErrorAction Stop).PendingFileRenameOperations
        if ($v) { $pfr = $true }
    } catch { $pfr = $false }
    $results["PendingFileRenameOperations"] = $pfr

    return $results
}

# Header
@"
Computer: $env:COMPUTERNAME
User: $env:USERNAME
Date: $(Get-Date)
"@ | Set-Content -Path $ReportTxt -Encoding UTF8

# 1) Windows Update History (non-success)
Add-Section "1) Windows Update History - NON Success (failed/aborted/etc.)"
$historyNonSuccess = @()
try {
    $session = New-Object -ComObject Microsoft.Update.Session
    $searcher = $session.CreateUpdateSearcher()
    $count = $searcher.GetTotalHistoryCount()

    # ResultCode mapping (WUA)
    # 0=NotStarted, 1=InProgress, 2=Succeeded, 3=SucceededWithErrors, 4=Failed, 5=Aborted
    $history = $searcher.QueryHistory(0, $count)

    $historyNonSuccess = $history |
        Select-Object Date, Title,
            @{n="ResultCode";e={$_.ResultCode}},
            @{n="ResultText";e={
                switch ($_.ResultCode) {
                    0 {"NotStarted"}
                    1 {"InProgress"}
                    2 {"Succeeded"}
                    3 {"SucceededWithErrors"}
                    4 {"Failed"}
                    5 {"Aborted"}
                    default {"Unknown"}
                }
            }},
            @{n="HResult";e={ "{0:X8}" -f ($_.HResult -band 0xFFFFFFFF) }} |
        Where-Object { $_.ResultCode -ne 2 } |
        Sort-Object Date -Descending

    if ($historyNonSuccess.Count -gt 0) {
        $historyNonSuccess | Export-Csv $HistoryCsv -NoTypeInformation -Encoding UTF8
        ($historyNonSuccess | Format-Table -AutoSize | Out-String -Width 400) | Add-Content -Path $ReportTxt -Encoding UTF8
        Add-Content -Path $ReportTxt -Encoding UTF8 -Value "CSV: $HistoryCsv"
    } else {
        Add-Content -Path $ReportTxt -Encoding UTF8 -Value "Nessuna voce NON-success trovata nella Update History."
    }
} catch {
    Add-Content -Path $ReportTxt -Encoding UTF8 -Value "Errore nel leggere Windows Update History (COM). Dettagli: $($_.Exception.Message)"
}

# 2) Event Log: WindowsUpdateClient Operational (errors / failed install)
Add-Section "2) Event Log - Microsoft-Windows-WindowsUpdateClient/Operational (errori & install fail)"
$events = @()
try {
    # IDs più comuni per fallimenti/issue (non esaustivo). Filtriamo anche per Level Error/Warning.
    $interestingIds = @(20, 24, 25, 31, 34, 35, 41, 43, 44, 45)

    $events = Get-WinEvent -LogName "Microsoft-Windows-WindowsUpdateClient/Operational" -ErrorAction Stop |
        Where-Object {
            ($_.LevelDisplayName -in @("Error","Warning")) -or ($_.Id -in $interestingIds)
        } |
        Select-Object TimeCreated, Id, LevelDisplayName, ProviderName,
            @{n="Message";e={ ($_.Message -replace "\s+"," ").Trim() }} |
        Sort-Object TimeCreated -Descending

    if ($events.Count -gt 0) {
        $events | Export-Csv $EventsCsv -NoTypeInformation -Encoding UTF8
        ($events | Select-Object -First 60 | Format-Table -AutoSize | Out-String -Width 400) | Add-Content -Path $ReportTxt -Encoding UTF8
        Add-Content -Path $ReportTxt -Encoding UTF8 -Value ""
        Add-Content -Path $ReportTxt -Encoding UTF8 -Value "Mostrate le prime 60 righe nel TXT (per non farlo infinito)."
        Add-Content -Path $ReportTxt -Encoding UTF8 -Value "CSV completo: $EventsCsv"
    } else {
        Add-Content -Path $ReportTxt -Encoding UTF8 -Value "Nessun evento rilevante trovato nel log Operational."
    }
} catch {
    Add-Content -Path $ReportTxt -Encoding UTF8 -Value "Errore nel leggere Event Log Operational. Dettagli: $($_.Exception.Message)"
    Add-Content -Path $ReportTxt -Encoding UTF8 -Value "Suggerimento: assicurati che il log esista e sia abilitato."
}

# 3) DISM / Package states not Installed (Pending/Staged/etc.)
Add-Section "3) DISM - Pacchetti NON in stato 'Installed' (pending/staged/...)"
$dismNonInstalled = @()
try {
    $dismNonInstalled = Get-WindowsPackage -Online -ErrorAction Stop |
        Where-Object { $_.PackageState -ne "Installed" } |
        Select-Object PackageName, ReleaseType, PackageState, InstallTime, Applicable |
        Sort-Object PackageState, PackageName

    if ($dismNonInstalled.Count -gt 0) {
        $dismNonInstalled | Export-Csv $DismCsv -NoTypeInformation -Encoding UTF8
        ($dismNonInstalled | Select-Object -First 80 | Format-Table -AutoSize | Out-String -Width 400) | Add-Content -Path $ReportTxt -Encoding UTF8
        Add-Content -Path $ReportTxt -Encoding UTF8 -Value ""
        Add-Content -Path $ReportTxt -Encoding UTF8 -Value "Mostrate le prime 80 righe nel TXT."
        Add-Content -Path $ReportTxt -Encoding UTF8 -Value "CSV completo: $DismCsv"
    } else {
        Add-Content -Path $ReportTxt -Encoding UTF8 -Value "Nessun pacchetto in stato diverso da 'Installed'."
    }
} catch {
    Add-Content -Path $ReportTxt -Encoding UTF8 -Value "Errore nel leggere pacchetti con Get-WindowsPackage. Dettagli: $($_.Exception.Message)"
}

# 4) Pending reboot signals
Add-Section "4) Stato riavvio (Pending Reboot) - segnali tipici"
$pending = Test-PendingReboot
$pending.GetEnumerator() | ForEach-Object {
    Add-Content -Path $ReportTxt -Encoding UTF8 -Value ("{0}: {1}" -f $_.Key, $_.Value)
}

# 5) Quick Summary
Add-Section "5) Riepilogo rapido"
$lastNonSuccess = $historyNonSuccess | Select-Object -First 1
$lastEvent      = $events | Select-Object -First 1

Add-Content -Path $ReportTxt -Encoding UTF8 -Value ("Non-success in Update History: {0}" -f ($historyNonSuccess.Count))
if ($lastNonSuccess) {
    Add-Content -Path $ReportTxt -Encoding UTF8 -Value ("Ultima voce non-success: {0} | {1} | {2} | HResult {3}" -f $lastNonSuccess.Date, $lastNonSuccess.ResultText, $lastNonSuccess.Title, $lastNonSuccess.HResult)
}

Add-Content -Path $ReportTxt -Encoding UTF8 -Value ("Eventi (Error/Warning o IDs interessanti): {0}" -f ($events.Count))
if ($lastEvent) {
    Add-Content -Path $ReportTxt -Encoding UTF8 -Value ("Ultimo evento: {0} | ID {1} | {2}" -f $lastEvent.TimeCreated, $lastEvent.Id, $lastEvent.LevelDisplayName)
}

Add-Content -Path $ReportTxt -Encoding UTF8 -Value ("Pacchetti DISM non-Installed: {0}" -f ($dismNonInstalled.Count))
Add-Content -Path $ReportTxt -Encoding UTF8 -Value ("Pending reboot flags TRUE: {0}" -f (($pending.Values | Where-Object {$_ -eq $true}).Count))

Write-Host "OK! Report creato in:" $ReportTxt
Write-Host "Cartella output:" $OutDir
