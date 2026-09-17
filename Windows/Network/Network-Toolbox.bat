@echo off
setlocal ENABLEDELAYEDEXPANSION
title Network Toolbox - HOSTS, DNS & Diagnostics
color 0a

REM Some operations require Administrator privileges.
REM Logs are stored in the local "logs" subfolder.

REM Cartella log (stessa cartella dello script, sottocartella "logs")
set "LOGDIR=%~dp0logs"
if not exist "%LOGDIR%" md "%LOGDIR%"

:menu
cls
echo ==============================================
echo          NETWORK TOOLBOX - MENU PRINCIPALE
echo ==============================================
echo.
echo  1) Flush DNS (ricarica file HOSTS)
echo  2) Riavvia scheda di rete
echo  3) IPConfig /ALL  (salva LOG)
echo  4) Mostra cache DNS (ipconfig /displaydns + LOG)
echo  5) Ping test singolo (salva LOG)
echo  6) Traceroute / Tracert (salva LOG)
echo  7) DNS lookup (nslookup + LOG)
echo  8) Tabella di routing (route print + LOG)
echo  9) Tabella ARP (arp -a + LOG)
echo 10) Connessioni attive (netstat -ano + LOG)
echo 11) IP release/renew (fix rapido rete + LOG)
echo 12) Ping test multiplo (gateway + DNS noti, LOG)
echo 13) Pacchetto diagnostico completo (MEGA LOG)
echo 14) Esci
echo.
set /p choice=Seleziona un'opzione (1-14): 

if "%choice%"=="1" goto flush
if "%choice%"=="2" goto restart
if "%choice%"=="3" goto ipall
if "%choice%"=="4" goto displaydns
if "%choice%"=="5" goto pingtest
if "%choice%"=="6" goto tracerttest
if "%choice%"=="7" goto nslookuptest
if "%choice%"=="8" goto routeprint
if "%choice%"=="9" goto arptable
if "%choice%"=="10" goto netstat
if "%choice%"=="11" goto iprenew
if "%choice%"=="12" goto pingmulti
if "%choice%"=="13" goto diagfull
if "%choice%"=="14" goto end
goto menu


REM =========================
REM   FUNZIONI DI SERVIZIO
REM =========================

:GetTimestamp
REM Crea una stringa TIMESTAMP adatta ai nomi file (niente caratteri strani)
set "DATETIME=%DATE%_%TIME%"
set "DATETIME=%DATETIME::=-%"
set "DATETIME=%DATETIME:/=-%"
set "DATETIME=%DATETIME: =_%"
set "DATETIME=%DATETIME:,=%"
set "DATETIME=%DATETIME:.=-%"
set "TIMESTAMP=%DATETIME%"
goto :eof


REM =========================
REM   FUNZIONI PRINCIPALI
REM =========================

:flush
cls
echo [*] Svuoto la cache DNS...
ipconfig /flushdns
echo.
echo [OK] Il file HOSTS e' stato ricaricato.
echo.
pause
goto menu


:restart
cls
echo [*] Schede di rete rilevate:
echo.
powershell -command "Get-NetAdapter | Select-Object -Property Name, Status | Format-Table -AutoSize"
echo.
set /p nicname=Inserisci il nome ESATTO della scheda da riavviare: 

echo.
echo [*] Disattivo la scheda "%nicname%"...
powershell -command "Disable-NetAdapter -Name '%nicname%' -Confirm:$false"
timeout /t 2 >nul

echo [*] Riattivo la scheda "%nicname%"...
powershell -command "Enable-NetAdapter -Name '%nicname%'"

echo.
echo [OK] Scheda di rete "%nicname%" riavviata con successo!
echo.
pause
goto menu


:ipall
cls
call :GetTimestamp
set "LOGFILE=%LOGDIR%\ipconfig_all_%TIMESTAMP%.log"

echo [*] Eseguo: ipconfig /all
echo [*] Salvo il log in:
echo     "%LOGFILE%"
echo.

ipconfig /all > "%LOGFILE%"

type "%LOGFILE%"
echo.
echo [OK] Operazione completata.
echo.
pause
goto menu


:displaydns
cls
call :GetTimestamp
set "LOGFILE=%LOGDIR%\displaydns_%TIMESTAMP%.log"

echo [*] Eseguo: ipconfig /displaydns
echo [*] Salvo il log in:
echo     "%LOGFILE%"
echo.

ipconfig /displaydns > "%LOGFILE%"

type "%LOGFILE%"
echo.
echo [OK] Operazione completata.
echo.
pause
goto menu


:pingtest
cls
set /p target=Inserisci host/IP da pingare (es. 8.8.8.8 o google.com): 
if "%target%"=="" goto menu

call :GetTimestamp
set "LOGFILE=%LOGDIR%\ping_%target%_%TIMESTAMP%.log"

echo.
echo [*] Eseguo: ping %target%
echo [*] Salvo il log in:
echo     "%LOGFILE%"
echo.

ping %target% > "%LOGFILE%"

type "%LOGFILE%"
echo.
echo [OK] Operazione completata.
echo.
pause
goto menu


:tracerttest
cls
set /p target=Inserisci host/IP per traceroute (es. 8.8.8.8 o google.com): 
if "%target%"=="" goto menu

call :GetTimestamp
set "LOGFILE=%LOGDIR%\tracert_%target%_%TIMESTAMP%.log"

echo.
echo [*] Eseguo: tracert %target%
echo [*] Salvo il log in:
echo     "%LOGFILE%"
echo.

tracert %target% > "%LOGFILE%"

type "%LOGFILE%"
echo.
echo [OK] Operazione completata.
echo.
pause
goto menu


:nslookuptest
cls
set /p target=Inserisci host o dominio per nslookup: 
if "%target%"=="" goto menu

call :GetTimestamp
set "LOGFILE=%LOGDIR%\nslookup_%target%_%TIMESTAMP%.log"

echo.
echo [*] Eseguo: nslookup %target%
echo [*] Salvo il log in:
echo     "%LOGFILE%"
echo.

nslookup %target% > "%LOGFILE%"

type "%LOGFILE%"
echo.
echo [OK] Operazione completata.
echo.
pause
goto menu


:routeprint
cls
call :GetTimestamp
set "LOGFILE=%LOGDIR%\route_print_%TIMESTAMP%.log"

echo [*] Eseguo: route print
echo [*] Salvo il log in:
echo     "%LOGFILE%"
echo.

route print > "%LOGFILE%"

type "%LOGFILE%"
echo.
echo [OK] Operazione completata.
echo.
pause
goto menu


:arptable
cls
call :GetTimestamp
set "LOGFILE=%LOGDIR%\arp_a_%TIMESTAMP%.log"

echo [*] Eseguo: arp -a
echo [*] Salvo il log in:
echo     "%LOGFILE%"
echo.

arp -a > "%LOGFILE%"

type "%LOGFILE%"
echo.
echo [OK] Operazione completata.
echo.
pause
goto menu


:netstat
cls
call :GetTimestamp
set "LOGFILE=%LOGDIR%\netstat_ano_%TIMESTAMP%.log"

echo [*] Eseguo: netstat -ano
echo [*] Salvo il log in:
echo     "%LOGFILE%"
echo.

netstat -ano > "%LOGFILE%"

type "%LOGFILE%"
echo.
echo [OK] Operazione completata.
echo.
pause
goto menu


:iprenew
cls
call :GetTimestamp
set "LOGFILE=%LOGDIR%\ip_renew_%TIMESTAMP%.log"

echo [*] ATTENZIONE: verranno eseguiti ipconfig /release e /renew.
echo     Potresti perdere temporaneamente la connettivita'.
echo.
pause

echo [*] Eseguo: ipconfig /release
ipconfig /release > "%LOGFILE%"

echo [*] Eseguo: ipconfig /renew
ipconfig /renew >> "%LOGFILE%"

echo.
type "%LOGFILE%"
echo.
echo [OK] Operazione completata (release/renew eseguiti).
echo.
pause
goto menu


:pingmulti
cls
call :GetTimestamp
set "LOGFILE=%LOGDIR%\ping_multi_%TIMESTAMP%.log"

echo [*] Rilevo il gateway predefinito (se presente)...
set "GW="

for /f "tokens=2 delims=:" %%G in ('ipconfig ^| findstr /R /C:"Gateway predefinito"') do (
    set "GW=%%G"
)

if defined GW (
    REM Rimuove spazi iniziali/finali
    set "GW=!GW: =!"
    echo     Gateway trovato: !GW!
) else (
    echo     Nessun gateway trovato in ipconfig.
)

echo.
echo [*] Eseguo ping multipli verso:
echo     - Gateway (se trovato)
echo     - 8.8.8.8 (Google DNS)
echo     - 1.1.1.1 (Cloudflare DNS)
echo     - www.google.com
echo.
echo [*] Salvo il log in:
echo     "%LOGFILE%"
echo.

(
    echo ===== PING MULTIPLO - %TIMESTAMP% =====
    echo.
) > "%LOGFILE%"

if defined GW (
    echo ---- PING Gateway (!GW!) ---->>"%LOGFILE%"
    ping -n 4 !GW!>>"%LOGFILE%"
    echo.>>"%LOGFILE%"
)

echo ---- PING 8.8.8.8 ---->>"%LOGFILE%"
ping -n 4 8.8.8.8>>"%LOGFILE%"
echo.>>"%LOGFILE%"

echo ---- PING 1.1.1.1 ---->>"%LOGFILE%"
ping -n 4 1.1.1.1>>"%LOGFILE%"
echo.>>"%LOGFILE%"

echo ---- PING www.google.com ---->>"%LOGFILE%"
ping -n 4 www.google.com>>"%LOGFILE%"
echo.>>"%LOGFILE%"

type "%LOGFILE%"
echo.
echo [OK] Ping multipli completati.
echo.
pause
goto menu


:diagfull
cls
call :GetTimestamp
set "LOGFILE=%LOGDIR%\diagnostic_pack_%TIMESTAMP%.log"

echo [*] Creo pacchetto diagnostico completo...
echo [*] Salvo TUTTO in:
echo     "%LOGFILE%"
echo.
echo Questo potrebbe richiedere un po' di tempo.
echo.
pause

(
    echo =============================================
    echo         NETWORK DIAGNOSTIC PACK
    echo =============================================
    echo Timestamp: %TIMESTAMP%
    echo.
    echo ---- ipconfig /all ----
) > "%LOGFILE%"

ipconfig /all >> "%LOGFILE%"
echo.>>"%LOGFILE%"
echo ---- ipconfig /displaydns ---->>"%LOGFILE%"
ipconfig /displaydns >> "%LOGFILE%"
echo.>>"%LOGFILE%"
echo ---- route print ---->>"%LOGFILE%"
route print >> "%LOGFILE%"
echo.>>"%LOGFILE%"
echo ---- arp -a ---->>"%LOGFILE%"
arp -a >> "%LOGFILE%"
echo.>>"%LOGFILE%"
echo ---- netstat -ano ---->>"%LOGFILE%"
netstat -ano >> "%LOGFILE%"
echo.>>"%LOGFILE%"

REM Ping rapidi di base
echo ---- PING 8.8.8.8 (Google DNS) ---->>"%LOGFILE%"
ping -n 4 8.8.8.8>>"%LOGFILE%"
echo.>>"%LOGFILE%"

echo ---- PING 1.1.1.1 (Cloudflare DNS) ---->>"%LOGFILE%"
ping -n 4 1.1.1.1>>"%LOGFILE%"
echo.>>"%LOGFILE%"

echo ---- PING www.google.com ---->>"%LOGFILE%"
ping -n 4 www.google.com>>"%LOGFILE%"
echo.>>"%LOGFILE%"

echo ---- TRACERT www.google.com ---->>"%LOGFILE%"
tracert www.google.com>>"%LOGFILE%"
echo.>>"%LOGFILE%"

echo ---- nslookup www.google.com ---->>"%LOGFILE%"
nslookup www.google.com>>"%LOGFILE%"
echo.>>"%LOGFILE%"

cls
echo [OK] Pacchetto diagnostico generato.
echo.
echo Puoi trovare il file qui:
echo "%LOGFILE%"
echo.
pause
goto menu


:end
echo.
echo Uscita dal Network Toolbox...
echo.
timeout /t 1 >nul
endlocal
exit /b
