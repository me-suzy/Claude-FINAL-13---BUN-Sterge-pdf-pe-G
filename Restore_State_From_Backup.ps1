# ═══════════════════════════════════════════════════════════════════════════
#   SCRIPT DE RECUPERARE STATE.JSON
#   Restaurează state.json dintr-un backup timestamped
# ═══════════════════════════════════════════════════════════════════════════

$BackupDir = "D:\TEST\State_Backups"
$StatePath = "D:\TEST\state.json"

Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "          RECUPERARE STATE.JSON DIN BACKUP" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# Verifică dacă există director de backup
if (-not (Test-Path $BackupDir)) {
    Write-Host "❌ EROARE: Directorul de backup nu există: $BackupDir" -ForegroundColor Red
    Write-Host ""
    Read-Host "Apasă Enter pentru a închide"
    exit 1
}

# Găsește toate backup-urile
$Backups = Get-ChildItem -Path $BackupDir -Filter "state_*.json" | Sort-Object Name -Descending

if ($Backups.Count -eq 0) {
    Write-Host "❌ EROARE: Nu s-au găsit backup-uri în: $BackupDir" -ForegroundColor Red
    Write-Host ""
    Read-Host "Apasă Enter pentru a închide"
    exit 1
}

Write-Host "📋 BACKUP-URI DISPONIBILE (cele mai recente primele):" -ForegroundColor Green
Write-Host ""

# Afișează primele 20 de backup-uri
$DisplayCount = [Math]::Min(20, $Backups.Count)
for ($i = 0; $i -lt $DisplayCount; $i++) {
    $Backup = $Backups[$i]
    
    # Extrage timestamp din nume (format: state_YYYYMMDD_HHMMSS.json)
    if ($Backup.Name -match "state_(\d{4})(\d{2})(\d{2})_(\d{2})(\d{2})(\d{2})\.json") {
        $Year = $matches[1]
        $Month = $matches[2]
        $Day = $matches[3]
        $Hour = $matches[4]
        $Minute = $matches[5]
        $Second = $matches[6]
        
        $DateStr = "$Year-$Month-$Day $Hour`:$Minute`:$Second"
    } else {
        $DateStr = "N/A"
    }
    
    $SizeMB = [math]::Round($Backup.Length / 1MB, 2)
    
    Write-Host "  [$($i+1)] $DateStr - $($Backup.Name) ($SizeMB MB)" -ForegroundColor White
}

if ($Backups.Count -gt $DisplayCount) {
    Write-Host "  ... și încă $($Backups.Count - $DisplayCount) backup-uri mai vechi" -ForegroundColor Gray
}

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# Cere utilizatorului să selecteze un backup
do {
    $Selection = Read-Host "Introdu numărul backup-ului pe care vrei să-l restaurezi (1-$DisplayCount) sau 0 pentru ANULARE"
    
    if ($Selection -eq "0") {
        Write-Host ""
        Write-Host "❌ Operațiune anulată." -ForegroundColor Yellow
        Write-Host ""
        Read-Host "Apasă Enter pentru a închide"
        exit 0
    }
    
    $SelectedIndex = [int]$Selection - 1
    
} while ($SelectedIndex -lt 0 -or $SelectedIndex -ge $DisplayCount)

$SelectedBackup = $Backups[$SelectedIndex]

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  AI SELECTAT: $($SelectedBackup.Name)" -ForegroundColor Yellow
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# Analiză rapidă a backup-ului selectat
try {
    $BackupContent = Get-Content -Path $SelectedBackup.FullName -Raw | ConvertFrom-Json
    $IssueCount = $BackupContent.downloaded_issues.Count
    $CompletedCount = ($BackupContent.downloaded_issues | Where-Object { $_.pages -gt 0 -and $_.completed_at }).Count
    
    Write-Host "📊 INFORMAȚII BACKUP:" -ForegroundColor Green
    Write-Host "   Total issues: $IssueCount" -ForegroundColor White
    Write-Host "   Issues complete: $CompletedCount" -ForegroundColor White
    Write-Host ""
} catch {
    Write-Host "⚠ Nu am putut analiza backup-ul (posibil corupt)" -ForegroundColor Yellow
    Write-Host ""
}

# Confirmare finală
Write-Host "⚠️  ATENȚIE: Această operațiune va SUPRASCRIE state.json curent!" -ForegroundColor Red
Write-Host ""

$Confirm = Read-Host "Ești sigur că vrei să continui? (DA/nu)"

if ($Confirm -ne "DA") {
    Write-Host ""
    Write-Host "❌ Operațiune anulată. State.json NU a fost modificat." -ForegroundColor Yellow
    Write-Host ""
    Read-Host "Apasă Enter pentru a închide"
    exit 0
}

# Creează backup de siguranță al state.json curent
if (Test-Path $StatePath) {
    $BackupBeforeRestore = "$StatePath.before_restore_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
    Write-Host ""
    Write-Host "📦 Creez backup de siguranță: $BackupBeforeRestore" -ForegroundColor Cyan
    Copy-Item -Path $StatePath -Destination $BackupBeforeRestore -Force
    Write-Host "✅ Backup de siguranță creat" -ForegroundColor Green
}

# Restaurează backup-ul
try {
    Write-Host ""
    Write-Host "🔄 Restaurez state.json din backup..." -ForegroundColor Cyan
    
    Copy-Item -Path $SelectedBackup.FullName -Destination $StatePath -Force
    
    Write-Host "✅ STATE.JSON RESTAURAT CU SUCCES!" -ForegroundColor Green
    Write-Host ""
    Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Green
    Write-Host "          RECUPERARE FINALIZATĂ!" -ForegroundColor Green
    Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Green
    Write-Host ""
    Write-Host "📝 Notă: Backup-ul anterior a fost salvat ca:" -ForegroundColor Yellow
    if (Test-Path $BackupBeforeRestore) {
        Write-Host "   $BackupBeforeRestore" -ForegroundColor White
    }
    Write-Host ""
    
} catch {
    Write-Host ""
    Write-Host "❌ EROARE la restaurarea backup-ului: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
}

Read-Host "Apasă Enter pentru a închide"

