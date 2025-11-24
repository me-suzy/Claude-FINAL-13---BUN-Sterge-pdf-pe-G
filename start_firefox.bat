@echo off
REM Script pentru pornirea Firefox cu profilul folosit de scriptul Python
REM Acest script pornește Firefox cu același profil ca cel folosit de automatizare

echo ========================================
echo Pornire Firefox cu profilul scriptului
echo ========================================
echo.

REM Calea către Firefox
set FIREFOX_PATH="C:\Program Files\Mozilla Firefox\firefox.exe"

REM Verifică dacă Firefox există
if not exist %FIREFOX_PATH% (
    echo ❌ Firefox nu a fost găsit la: %FIREFOX_PATH%
    echo 💡 Verifică calea către Firefox
    pause
    exit /b 1
)

REM Calea către profilurile Firefox
set PROFILES_PATH=%APPDATA%\Mozilla\Firefox\Profiles

REM Caută profilul default-release (cel mai comun)
for /d %%p in ("%PROFILES_PATH%\*.default-release") do (
    set PROFILE_PATH=%%p
    goto :found_profile
)

REM Dacă nu găsește default-release, caută default
for /d %%p in ("%PROFILES_PATH%\*.default") do (
    set PROFILE_PATH=%%p
    goto :found_profile
)

REM Dacă nu găsește niciun profil, folosește primul găsit
for /d %%p in ("%PROFILES_PATH%\*") do (
    set PROFILE_PATH=%%p
    goto :found_profile
)

:found_profile
if defined PROFILE_PATH (
    echo ✅ Profil găsit: %PROFILE_PATH%
    echo.
    echo 🚀 Pornesc Firefox cu profilul găsit...
    echo.
    
    REM Pornește Firefox cu profilul specificat
    start "" %FIREFOX_PATH% -profile "%PROFILE_PATH%"
    
    echo ✅ Firefox pornit cu succes!
    echo.
    echo 📝 Profil folosit: %PROFILE_PATH%
    echo.
) else (
    echo ⚠ Nu am găsit niciun profil Firefox!
    echo 💡 Căutare în: %PROFILES_PATH%
    echo.
    echo 🚀 Pornesc Firefox cu profilul implicit...
    start "" %FIREFOX_PATH%
)

echo.
echo ========================================
pause

