═══════════════════════════════════════════════════════════════════════════
   PDF DOWNLOADER - TASK SCHEDULER SETUP
   Configurare Automată pentru Rulare Zilnică la 04:30 AM
═══════════════════════════════════════════════════════════════════════════


🚀 START RAPID (3 PAȘI):
═══════════════════════════════════════════════════════════════════════════

1️⃣  Click DREAPTA pe: IMPORT_Task_Scheduler.bat
    └─ Selectează "Run as administrator"

2️⃣  Așteaptă mesajul "SUCCES! Task-ul a fost importat cu succes!"

3️⃣  GATA! Scriptul va rula automat în fiecare zi la 04:30 AM


📁 FIȘIERE INCLUSE:
═══════════════════════════════════════════════════════════════════════════

✓ PDF_Downloader_Task.xml         - Definiție task pentru Windows
✓ Run_PDF_Downloader.bat          - Script batch cu logging automat
✓ Run_PDF_Downloader.ps1          - Script PowerShell (alternativă)
✓ IMPORT_Task_Scheduler.bat       - Import automat în Task Scheduler
✓ INSTRUCȚIUNI Task Scheduler.txt - Ghid complet (citește pentru detalii!)
✓ README - Task Scheduler Setup.txt - Acest fișier


📊 CE VA FACE TASK-UL:
═══════════════════════════════════════════════════════════════════════════

⏰ Când: În fiecare zi la 04:30 AM
📝 Script: Claude-FINAL 13 - BUN Sterge pdf pe G.py
📁 Log-uri: D:\TEST\Logs\PDF_Downloader_YYYYMMDD_HHMMSS.log
💾 State: D:\TEST\state.json
🌐 Network: Așteaptă conexiune internet înainte de rulare
⚡ Wake: Poate trezi computerul din sleep (dacă activat)


🔍 VERIFICARE DUPĂ IMPORT:
═══════════════════════════════════════════════════════════════════════════

1. Deschide Task Scheduler (Windows + R → taskschd.msc)
2. Caută task-ul: "PDF Downloader Daily"
3. Verifică:
   ✓ Status: Ready
   ✓ Next Run Time: Mâine la 04:30:00 AM
   ✓ Last Run Result: (va fi 0x0 după prima rulare cu succes)


🧪 TEST MANUAL:
═══════════════════════════════════════════════════════════════════════════

Metodă 1 (Task Scheduler):
   1. Deschide Task Scheduler (taskschd.msc)
   2. Găsește "PDF Downloader Daily"
   3. Click dreapta → Run
   4. Verifică log-ul în D:\TEST\Logs\

Metodă 2 (Comandă):
   schtasks /Run /TN "PDF Downloader Daily"

Metodă 3 (Batch direct):
   Double-click pe Run_PDF_Downloader.bat


📋 LOG-URI:
═══════════════════════════════════════════════════════════════════════════

Locație: D:\TEST\Logs\
Format: PDF_Downloader_YYYYMMDD_HHMMSS.log

Fiecare log conține:
   - Data și ora începerii
   - Calea la Python folosit
   - Output complet al scriptului Python
   - Data și ora terminării
   - Status final (succes/eroare)

Exemplu nume log: PDF_Downloader_20251107_043000.log


⚙️ COMENZI UTILE:
═══════════════════════════════════════════════════════════════════════════

Verificare status:
   schtasks /Query /TN "PDF Downloader Daily"

Rulare manuală:
   schtasks /Run /TN "PDF Downloader Daily"

Dezactivare:
   schtasks /Change /TN "PDF Downloader Daily" /Disable

Activare:
   schtasks /Change /TN "PDF Downloader Daily" /Enable

Ștergere:
   schtasks /Delete /TN "PDF Downloader Daily" /F


🛠️ MODIFICARE ORA RULARE:
═══════════════════════════════════════════════════════════════════════════

Dacă vrei altă oră decât 04:30 AM:

Metodă 1 (GUI - Ușor):
   1. Task Scheduler → "PDF Downloader Daily"
   2. Click dreapta → Properties
   3. Triggers tab → Double-click pe trigger
   4. Schimbă ora în "Start time"
   5. OK → OK

Metodă 2 (XML - Înainte de import):
   1. Deschide PDF_Downloader_Task.xml în Notepad
   2. Caută: <StartBoundary>2025-11-07T04:30:00</StartBoundary>
   3. Schimbă 04:30:00 cu ora dorită (ex: 06:00:00 pentru 6 AM)
   4. Salvează
   5. Rulează IMPORT_Task_Scheduler.bat


❓ PROBLEME?
═══════════════════════════════════════════════════════════════════════════

Consultă fișierul "INSTRUCȚIUNI Task Scheduler.txt" pentru:
   - Troubleshooting detaliat
   - Configurări avansate
   - Soluții la probleme comune
   - Wake from sleep setup
   - Notificări și monitoring


📞 CHECKLIST RAPID:
═══════════════════════════════════════════════════════════════════════════

□ Am rulat IMPORT_Task_Scheduler.bat ca Administrator?
□ Task-ul apare în Task Scheduler?
□ Am testat rularea manuală?
□ Se creează log-uri în D:\TEST\Logs\?
□ "Next Run Time" arată corect (04:30 AM)?
□ Scriptul Python funcționează când rulez manual?


✅ SUCCESS!
═══════════════════════════════════════════════════════════════════════════

Dacă ai urmat pașii de mai sus, task-ul este configurat și va rula
automat în fiecare zi la 04:30 AM!

Pentru informații detaliate, citește: INSTRUCȚIUNI Task Scheduler.txt


═══════════════════════════════════════════════════════════════════════════
   Enjoy automated PDF downloading! 🎉
═══════════════════════════════════════════════════════════════════════════

