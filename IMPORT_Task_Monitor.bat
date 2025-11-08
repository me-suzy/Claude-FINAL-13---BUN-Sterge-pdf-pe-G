@echo off
REM ═══════════════════════════════════════════════════════════════════════════
REM   IMPORT TASK MONITOR în Task Scheduler
REM   Acest task verifică zilnic dacă task-ul principal este enabled
REM ═══════════════════════════════════════════════════════════════════════════

echo.
echo ═══════════════════════════════════════════════════════════════════════════
echo   IMPORT TASK MONITOR - PDF Downloader Status Check
echo ═══════════════════════════════════════════════════════════════════════════
echo.
echo Acest script va importa task-ul de monitorizare în Task Scheduler.
echo Task-ul va rula zilnic la 4:00 AM (cu 30 min înaintea task-ului principal)
echo pentru a verifica dacă task-ul PDF Downloader este enabled.
echo.
echo IMPORTANT: Trebuie să rulezi acest script ca ADMINISTRATOR!
echo.
pause

REM Verifică dacă rulează cu privilegii de administrator
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo ❌ EROARE: Acest script trebuie rulat ca ADMINISTRATOR!
    echo.
    echo Cum să rulezi ca administrator:
    echo    1. Click dreapta pe acest fișier
    echo    2. Selectează "Run as administrator"
    echo.
    pause
    exit /b 1
)

echo.
echo ✅ Privilegii de administrator confirmate.
echo.

REM Șterge task-ul vechi dacă există
echo 🔄 Verific dacă există un task vechi...
schtasks /Query /TN "PDF Downloader Monitor" >nul 2>&1
if %errorlevel% equ 0 (
    echo 🗑️  Șterg task-ul vechi...
    schtasks /Delete /TN "PDF Downloader Monitor" /F
)

REM Importă task-ul nou
echo.
echo 📥 Importez task-ul de monitorizare...
schtasks /Create /XML "D:\TEST\Task_Monitor.xml" /TN "PDF Downloader Monitor"

if %errorlevel% equ 0 (
    echo.
    echo ═══════════════════════════════════════════════════════════════════════════
    echo   ✅ TASK MONITOR IMPORTAT CU SUCCES!
    echo ═══════════════════════════════════════════════════════════════════════════
    echo.
    echo 📋 Detalii task:
    echo    • Nume: PDF Downloader Monitor
    echo    • Frecvență: Zilnic la 4:00 AM
    echo    • Scop: Verifică și reactivează automat task-ul principal
    echo    • Log: D:\TEST\Logs\Task_Status_Check.log
    echo.
    echo 🔍 Pentru a verifica task-ul în Task Scheduler:
    echo    1. Deschide Task Scheduler (taskschd.msc)
    echo    2. Caută "PDF Downloader Monitor" în lista de task-uri
    echo.
    echo 🧪 Pentru a testa task-ul acum:
    echo    schtasks /Run /TN "PDF Downloader Monitor"
    echo.
) else (
    echo.
    echo ═══════════════════════════════════════════════════════════════════════════
    echo   ❌ EROARE LA IMPORTAREA TASK-ULUI!
    echo ═══════════════════════════════════════════════════════════════════════════
    echo.
    echo Verifică următoarele:
    echo    1. Fișierul Task_Monitor.xml există în D:\TEST\
    echo    2. Ai rulat acest script ca ADMINISTRATOR
    echo    3. Task Scheduler service este activ
    echo.
)

echo.
pause

