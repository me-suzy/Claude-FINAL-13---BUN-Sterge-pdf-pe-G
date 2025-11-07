@echo off
REM ═══════════════════════════════════════════════════════════════════════════
REM   SCRIPT pentru importarea automată a task-ului în Windows Task Scheduler
REM   ATENȚIE: Trebuie rulat ca Administrator!
REM ═══════════════════════════════════════════════════════════════════════════

echo.
echo ═══════════════════════════════════════════════════════════════════════════
echo   IMPORTARE TASK în WINDOWS TASK SCHEDULER
echo ═══════════════════════════════════════════════════════════════════════════
echo.

REM Verifică dacă scriptul rulează ca Administrator
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo EROARE: Acest script trebuie rulat ca Administrator!
    echo.
    echo Cum să rulezi ca Administrator:
    echo   1. Click dreapta pe acest fișier
    echo   2. Selectează "Run as administrator"
    echo.
    pause
    exit /b 1
)

echo Verificare Administrator... OK
echo.

REM Verifică dacă fișierul XML există
if not exist "D:\TEST\PDF_Downloader_Task.xml" (
    echo EROARE: Fișierul PDF_Downloader_Task.xml nu a fost găsit!
    echo Locație așteptată: D:\TEST\PDF_Downloader_Task.xml
    pause
    exit /b 1
)

echo Verificare fișier XML... OK
echo.

REM Șterge task-ul existent dacă există
echo Verificare task existent...
schtasks /Query /TN "PDF Downloader Daily" >nul 2>&1
if %errorlevel% equ 0 (
    echo Task existent găsit - îl șterg...
    schtasks /Delete /TN "PDF Downloader Daily" /F >nul 2>&1
    echo Task existent șters.
)
echo.

REM Importă task-ul nou
echo Importare task nou...
schtasks /Create /XML "D:\TEST\PDF_Downloader_Task.xml" /TN "PDF Downloader Daily"

if %errorlevel% equ 0 (
    echo.
    echo ═══════════════════════════════════════════════════════════════════════════
    echo   SUCCES! Task-ul a fost importat cu succes!
    echo ═══════════════════════════════════════════════════════════════════════════
    echo.
    echo DETALII TASK:
    echo   Nume: PDF Downloader Daily
    echo   Frecvență: Zilnic la ora 04:30 AM
    echo   Script: D:\TEST\Claude-FINAL 13 - BUN Sterge pdf pe G.py
    echo   Log-uri: D:\TEST\Logs\
    echo.
    echo ACȚIUNI DISPONIBILE:
    echo   - Pentru a vedea task-ul: taskschd.msc
    echo   - Pentru a rula manual: schtasks /Run /TN "PDF Downloader Daily"
    echo   - Pentru a dezactiva: schtasks /Change /TN "PDF Downloader Daily" /Disable
    echo   - Pentru a șterge: schtasks /Delete /TN "PDF Downloader Daily" /F
    echo.
) else (
    echo.
    echo ═══════════════════════════════════════════════════════════════════════════
    echo   EROARE! Task-ul nu a putut fi importat.
    echo ═══════════════════════════════════════════════════════════════════════════
    echo.
    echo Cod eroare: %errorlevel%
    echo.
)

pause

