# ═══════════════════════════════════════════════════════════════════════════
#   POWERSHELL SCRIPT pentru rularea automată a PDF Downloader
#   Alternative la Run_PDF_Downloader.bat
# ═══════════════════════════════════════════════════════════════════════════

# Setează directorul de lucru
Set-Location "D:\TEST"

# Creează director pentru log-uri dacă nu există
$LogDir = "D:\TEST\Logs"
if (-not (Test-Path $LogDir)) {
    New-Item -ItemType Directory -Path $LogDir -Force | Out-Null
}

# Generează numele fișierului de log cu timestamp
$Timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$LogFile = Join-Path $LogDir "PDF_Downloader_$Timestamp.log"

# Funcție pentru logging
function Write-Log {
    param([string]$Message)
    $TimeStamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogMessage = "[$TimeStamp] $Message"
    Write-Host $LogMessage
    Add-Content -Path $LogFile -Value $LogMessage
}

# Header log
Write-Log "═══════════════════════════════════════════════════════════════════════════"
Write-Log "  PDF DOWNLOADER - START RULARE"
Write-Log "  Data: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
Write-Log "═══════════════════════════════════════════════════════════════════════════"
Write-Log ""

# Caută Python
Write-Log "Căutare Python..."

$PythonExe = $null

# Verifică Python în PATH
$PythonExe = Get-Command python -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source

if (-not $PythonExe) {
    # Verifică locații comune
    $PythonPaths = @(
        "C:\Python311\python.exe",
        "C:\Python310\python.exe",
        "C:\Python39\python.exe",
        "$env:LOCALAPPDATA\Programs\Python\Python311\python.exe",
        "$env:LOCALAPPDATA\Programs\Python\Python310\python.exe",
        "$env:LOCALAPPDATA\Programs\Python\Python39\python.exe"
    )
    
    foreach ($Path in $PythonPaths) {
        if (Test-Path $Path) {
            $PythonExe = $Path
            break
        }
    }
}

if (-not $PythonExe) {
    Write-Log "EROARE: Python nu a fost găsit!"
    Write-Log "Verifică că Python este instalat și adaugă-l în PATH."
    exit 1
}

Write-Log "Python găsit: $PythonExe"
Write-Log ""

# Script Python
$ScriptPath = "D:\TEST\Claude-FINAL 13 - BUN Sterge pdf pe G.py"

if (-not (Test-Path $ScriptPath)) {
    Write-Log "EROARE: Scriptul Python nu a fost găsit!"
    Write-Log "Locație așteptată: $ScriptPath"
    exit 1
}

Write-Log "Script găsit: $ScriptPath"
Write-Log ""

# Rulează scriptul Python
Write-Log "Începe rularea scriptului..."
Write-Log ""

try {
    # Capturează output-ul scriptului
    $Process = Start-Process -FilePath $PythonExe -ArgumentList "`"$ScriptPath`"" -WorkingDirectory "D:\TEST" -NoNewWindow -Wait -PassThru -RedirectStandardOutput "$LogFile.stdout" -RedirectStandardError "$LogFile.stderr"
    
    # Adaugă stdout și stderr la log principal
    if (Test-Path "$LogFile.stdout") {
        Get-Content "$LogFile.stdout" | Add-Content -Path $LogFile
        Remove-Item "$LogFile.stdout" -Force
    }
    
    if (Test-Path "$LogFile.stderr") {
        Write-Log ""
        Write-Log "--- STDERR OUTPUT ---"
        Get-Content "$LogFile.stderr" | Add-Content -Path $LogFile
        Remove-Item "$LogFile.stderr" -Force
    }
    
    $ExitCode = $Process.ExitCode
    
    Write-Log ""
    Write-Log "═══════════════════════════════════════════════════════════════════════════"
    
    if ($ExitCode -eq 0) {
        Write-Log "  SCRIPTUL S-A TERMINAT CU SUCCES"
    } else {
        Write-Log "  SCRIPTUL S-A TERMINAT CU EROARE (cod: $ExitCode)"
    }
    
    Write-Log "  Data: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
    Write-Log "═══════════════════════════════════════════════════════════════════════════"
    
    exit $ExitCode
    
} catch {
    Write-Log ""
    Write-Log "═══════════════════════════════════════════════════════════════════════════"
    Write-Log "  EROARE CRITICĂ LA RULAREA SCRIPTULUI"
    Write-Log "  Eroare: $($_.Exception.Message)"
    Write-Log "  Data: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
    Write-Log "═══════════════════════════════════════════════════════════════════════════"
    exit 1
}

