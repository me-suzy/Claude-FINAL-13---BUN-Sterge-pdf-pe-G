# ═══════════════════════════════════════════════════════════════════════════
#   SCRIPT DE MONITORIZARE - Verifică dacă Task-ul este ENABLED
#   Rulează automat și reactivează task-ul dacă este dezactivat
# ═══════════════════════════════════════════════════════════════════════════

$TaskName = "PDF Downloader Daily"
$LogFile = "D:\TEST\Logs\Task_Status_Check.log"

# Creează director pentru log-uri dacă nu există
$LogDir = Split-Path $LogFile -Parent
if (-not (Test-Path $LogDir)) {
    New-Item -ItemType Directory -Path $LogDir -Force | Out-Null
}

# Funcție pentru logging
function Write-TaskLog {
    param([string]$Message)
    $TimeStamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogMessage = "[$TimeStamp] $Message"
    Add-Content -Path $LogFile -Value $LogMessage
}

Write-TaskLog "═══════════════════════════════════════════════════════════════"
Write-TaskLog "VERIFICARE STATUS TASK: $TaskName"

try {
    # Verifică statusul task-ului
    $TaskInfo = schtasks /Query /TN $TaskName /FO LIST | Out-String
    
    if ($TaskInfo -match "Status:\s+(\w+)") {
        $Status = $Matches[1]
        Write-TaskLog "Status curent: $Status"
        
        if ($Status -eq "Disabled") {
            Write-TaskLog "⚠️ ALERTĂ: Task-ul este DISABLED!"
            Write-TaskLog "Încerc să reactivez task-ul..."
            
            # Reactivează task-ul cu privilegii admin
            $Result = Start-Process schtasks -ArgumentList "/Change /TN `"$TaskName`" /ENABLE" -Verb RunAs -Wait -PassThru -WindowStyle Hidden
            
            if ($Result.ExitCode -eq 0) {
                Write-TaskLog "✅ Task-ul a fost REACTIVAT cu succes!"
            } else {
                Write-TaskLog "❌ EROARE: Nu am putut reactiva task-ul (Cod: $($Result.ExitCode))"
            }
        } else {
            Write-TaskLog "✅ Task-ul este activ și funcțional"
        }
    }
    
    # Verifică și ultima dată când task-ul a rulat
    if ($TaskInfo -match "Last Run Time:\s+(.+)") {
        $LastRun = $Matches[1]
        Write-TaskLog "Ultima rulare: $LastRun"
    }
    
    # Verifică următoarea rulare programată
    if ($TaskInfo -match "Next Run Time:\s+(.+)") {
        $NextRun = $Matches[1]
        Write-TaskLog "Următoarea rulare: $NextRun"
    }
    
} catch {
    Write-TaskLog "❌ EROARE la verificarea task-ului: $($_.Exception.Message)"
}

Write-TaskLog "═══════════════════════════════════════════════════════════════"
Write-TaskLog ""

