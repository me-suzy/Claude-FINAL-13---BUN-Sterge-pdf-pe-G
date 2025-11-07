@echo off
REM ═══════════════════════════════════════════════════════════════════════════
REM   BATCH SCRIPT pentru rularea automată a PDF Downloader
REM   Acest script rulează scriptul Python și loghează output-ul
REM ═══════════════════════════════════════════════════════════════════════════

REM Setează directorul de lucru
cd /d "D:\TEST"

REM Creează director pentru log-uri dacă nu există
if not exist "D:\TEST\Logs" mkdir "D:\TEST\Logs"

REM Generează numele fișierului de log cu data curentă
set "LOGFILE=D:\TEST\Logs\PDF_Downloader_%date:~-4%%date:~3,2%%date:~0,2%_%time:~0,2%%time:~3,2%%time:~6,2%.log"
set "LOGFILE=%LOGFILE: =0%"

echo ═══════════════════════════════════════════════════════════════════════════ > "%LOGFILE%"
echo   PDF DOWNLOADER - START RULARE >> "%LOGFILE%"
echo   Data: %date% %time% >> "%LOGFILE%"
echo ═══════════════════════════════════════════════════════════════════════════ >> "%LOGFILE%"
echo. >> "%LOGFILE%"

REM Găsește Python (verifică mai multe locații posibile)
set "PYTHON_EXE="

REM Verifică Python în PATH
where python >nul 2>&1
if %errorlevel% equ 0 (
    set "PYTHON_EXE=python"
    goto :found_python
)

REM Verifică Python 3.11
if exist "C:\Python311\python.exe" (
    set "PYTHON_EXE=C:\Python311\python.exe"
    goto :found_python
)

REM Verifică Python 3.10
if exist "C:\Python310\python.exe" (
    set "PYTHON_EXE=C:\Python310\python.exe"
    goto :found_python
)

REM Verifică Python 3.9
if exist "C:\Python39\python.exe" (
    set "PYTHON_EXE=C:\Python39\python.exe"
    goto :found_python
)

REM Verifică Python din AppData
if exist "%LOCALAPPDATA%\Programs\Python\Python311\python.exe" (
    set "PYTHON_EXE=%LOCALAPPDATA%\Programs\Python\Python311\python.exe"
    goto :found_python
)

if exist "%LOCALAPPDATA%\Programs\Python\Python310\python.exe" (
    set "PYTHON_EXE=%LOCALAPPDATA%\Programs\Python\Python310\python.exe"
    goto :found_python
)

REM Python nu a fost găsit
echo EROARE: Python nu a fost găsit! >> "%LOGFILE%"
echo Verifică că Python este instalat și adaugă-l în PATH. >> "%LOGFILE%"
exit /b 1

:found_python
echo Python găsit: %PYTHON_EXE% >> "%LOGFILE%"
echo. >> "%LOGFILE%"

REM Setează encoding UTF-8 pentru Python (rezolvă problema cu emoji-uri)
set PYTHONIOENCODING=utf-8

REM Rulează scriptul Python și capturează output-ul
echo Începe rularea scriptului... >> "%LOGFILE%"
echo. >> "%LOGFILE%"

"%PYTHON_EXE%" "D:\TEST\Claude-FINAL 13 - BUN Sterge pdf pe G.py" >> "%LOGFILE%" 2>&1

REM Verifică codul de ieșire
if %errorlevel% equ 0 (
    echo. >> "%LOGFILE%"
    echo ═══════════════════════════════════════════════════════════════════════════ >> "%LOGFILE%"
    echo   SCRIPTUL S-A TERMINAT CU SUCCES >> "%LOGFILE%"
    echo   Data: %date% %time% >> "%LOGFILE%"
    echo ═══════════════════════════════════════════════════════════════════════════ >> "%LOGFILE%"
) else (
    echo. >> "%LOGFILE%"
    echo ═══════════════════════════════════════════════════════════════════════════ >> "%LOGFILE%"
    echo   SCRIPTUL S-A TERMINAT CU EROARE ^(cod: %errorlevel%^) >> "%LOGFILE%"
    echo   Data: %date% %time% >> "%LOGFILE%"
    echo ═══════════════════════════════════════════════════════════════════════════ >> "%LOGFILE%"
)

exit /b %errorlevel%

