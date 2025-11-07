import os
import re
import json
from collections import defaultdict

def load_state_json(json_path):
    """Încarcă fișierul state.json"""
    if not os.path.exists(json_path):
        print(f"❌ Fișierul {json_path} nu există!")
        return []

    try:
        with open(json_path, 'r', encoding='utf-8') as f:
            data = json.load(f)

            if isinstance(data, list):
                return data
            elif isinstance(data, dict):
                for value in data.values():
                    if isinstance(value, list):
                        return value
                return []
            else:
                print(f"⚠️  Structură JSON neașteptată în {json_path}")
                return []
    except json.JSONDecodeError as e:
        print(f"❌ Eroare la parsarea JSON: {e}")
        return []

def extract_key_from_url(url):
    """
    Extrage cheia din URL pentru matching
    Exemplu: https://adt.arcanum.com/ro/view/Energetica_1969 -> Energetica_1969
    """
    if not isinstance(url, str):
        return None
    match = re.search(r'/view/([^/?]+)', url)
    if match:
        return match.group(1)
    return None

def extract_key_from_folder(folder_name):
    """
    Extrage cheia din numele folderului pentru matching
    Exemplu: "Energetica, 1969 (Anul 17, nr. 2-8)" -> Energetica_1969
    """
    match = re.search(r'^([^,]+),\s*(\d{4})', folder_name)
    if match:
        name = match.group(1).strip()
        year = match.group(2)
        # Elimină spațiile și diacriticele pentru matching
        name_clean = name.replace(' ', '').replace('ș', 's').replace('Ș', 'S').replace('ț', 't').replace('Ț', 'T')
        key = f"{name_clean}_{year}"
        return key
    return None

def extract_key_from_filename(filename):
    """
    Extrage cheia din numele fișierului PDF
    Exemplu: "StiintaSiTehnica_1964-1627417979__pages400-449.pdf" -> StiintaSiTehnica_1964
    """
    match = re.search(r'^([^_]+_\d{4})', filename)
    if match:
        return match.group(1)
    return None

def extract_page_range_from_filename(filename):
    """Extrage intervalul de pagini din numele fișierului"""
    match = re.search(r'__pages(\d+)-(\d+)\.pdf$', filename)
    if match:
        start_page = int(match.group(1))
        end_page = int(match.group(2))
        return (start_page, end_page)
    return None

def scan_root_pdfs(root_drive):
    """
    Scanează fișierele PDF din root-ul drive-ului și le grupează după cheie
    Returns: dict with key -> list of (start, end, filepath)
    """
    root_pdfs = defaultdict(list)

    if not os.path.exists(root_drive):
        print(f"⚠️  Drive-ul {root_drive} nu există!")
        return root_pdfs

    try:
        files = os.listdir(root_drive)
        for filename in files:
            if filename.endswith('.pdf') and '__pages' in filename:
                filepath = os.path.join(root_drive, filename)
                key = extract_key_from_filename(filename)
                page_range = extract_page_range_from_filename(filename)

                if key and page_range:
                    root_pdfs[key].append((page_range[0], page_range[1], filepath))
    except Exception as e:
        print(f"⚠️  Eroare la scanarea root-ului: {e}")

    return root_pdfs

def calculate_segment_size(pdf_segments):
    """Calculează dimensiunea standard a unui segment bazat pe PDF-urile existente"""
    if not pdf_segments:
        return 49  # Default

    sizes = [end - start + 1 for start, end, *_ in pdf_segments]

    if sizes:
        return max(set(sizes), key=sizes.count)
    return 49

def split_gap_into_segments(gap_start, gap_end, segment_size):
    """Împarte o gaură mare în segmente mai mici"""
    segments = []
    current = gap_start

    while current <= gap_end:
        segment_end = min(current + segment_size - 1, gap_end)
        segments.append((current, segment_end))
        current = segment_end + 1

    return segments

def find_all_gaps(base_directory, state_json_path, root_drive):
    """Găsește toate găurile din secvențele PDF, verificând atât Temporare cât și root-ul drive-ului"""

    # Încarcă state.json
    state_data = load_state_json(state_json_path)

    if not state_data:
        print("⚠️  Nu s-au putut încărca date din state.json")
        return

    # Creează un dicționar pentru matching rapid
    state_dict = {}
    for entry in state_data:
        if not isinstance(entry, dict):
            continue

        url = entry.get('url')
        if not url:
            continue

        key = extract_key_from_url(url)
        if key:
            state_dict[key] = {
                'total_pages': entry.get('total_pages', entry.get('pages', 0)),
                'title': entry.get('title', 'Unknown'),
                'last_successful_segment_end': entry.get('last_successful_segment_end', 0),
                'completed_at': entry.get('completed_at', '')
            }

    print(f"✅ Încărcat state.json cu {len(state_dict)} intrări\n")

    # Scanează PDF-urile din root
    print(f"🔍 Scanare PDF-uri din {root_drive}...")
    root_pdfs = scan_root_pdfs(root_drive)
    if root_pdfs:
        print(f"✅ Găsite {sum(len(v) for v in root_pdfs.values())} PDF-uri în root\n")
    else:
        print(f"ℹ️  Nu s-au găsit PDF-uri în root\n")

    # Parcurge toate subfolderele din Temporare
    folders_data = {}
    for root, dirs, files in os.walk(base_directory):
        if root == base_directory:
            continue

        folder_name = os.path.basename(root)
        folder_key = extract_key_from_folder(folder_name)

        if not folder_key:
            continue

        # Găsește toate fișierele PDF cu pattern-ul __pages din folder
        pdf_segments = []
        for filename in files:
            if filename.endswith('.pdf') and '__pages' in filename:
                page_range = extract_page_range_from_filename(filename)
                if page_range:
                    filepath = os.path.join(root, filename)
                    pdf_segments.append((page_range[0], page_range[1], filepath))

        folders_data[folder_key] = {
            'folder_name': folder_name,
            'folder_path': root,
            'segments': pdf_segments
        }

    # Procesează fiecare folder și combină cu PDF-urile din root
    all_keys = set(folders_data.keys()) | set(root_pdfs.keys())

    for key in sorted(all_keys):
        folder_info = folders_data.get(key, {})
        folder_name = folder_info.get('folder_name', f'[Folder lipsă pentru {key}]')
        folder_path = folder_info.get('folder_path', '')
        folder_segments = folder_info.get('segments', [])

        # Combină segmentele din folder și din root
        root_segments = root_pdfs.get(key, [])
        all_segments = folder_segments + root_segments

        if not all_segments:
            continue

        # Găsește informațiile despre total_pages din state.json
        state_info = state_dict.get(key, {})
        total_pages = state_info.get('total_pages', 0)
        last_successful = state_info.get('last_successful_segment_end', 0)
        completed_at = state_info.get('completed_at', '')
        is_incomplete = (not completed_at or completed_at == "")

        # Sortează segmentele după pagina de început și elimină duplicatele
        all_segments.sort(key=lambda x: x[0])

        # Elimină duplicate (același interval de pagini)
        unique_segments = []
        seen_ranges = set()
        for start, end, filepath in all_segments:
            range_key = (start, end)
            if range_key not in seen_ranges:
                unique_segments.append((start, end, filepath))
                seen_ranges.add(range_key)

        # Calculează dimensiunea standard a segmentelor
        segment_size = calculate_segment_size(unique_segments)

        # Verifică găurile în secvență
        gaps = []

        # IMPORTANT: Verifică dacă lipsesc segmente de la început (de la 1 până la primul segment)
        first_segment_start = unique_segments[0][0]
        if first_segment_start > 1:
            gaps.append((1, first_segment_start - 1))

        # Verifică găurile între segmente
        for i in range(len(unique_segments) - 1):
            current_end = unique_segments[i][1]
            next_start = unique_segments[i + 1][0]

            if next_start > current_end + 1:
                gaps.append((current_end + 1, next_start - 1))

        # Verifică dacă lipsesc PDF-uri de la final
        last_segment_end = unique_segments[-1][1]

        if total_pages and total_pages > last_segment_end:
            gaps.append((last_segment_end + 1, total_pages))

        # Afișează doar dacă sunt probleme
        if gaps or root_segments:
            print(f"{'='*80}")
            print(f"📁 {folder_name}")
            print(f"🔑 Key: {key}")

            if total_pages:
                print(f"📄 Total pagini (din state.json): {total_pages}")
            else:
                print(f"⚠️  Total pagini: NECUNOSCUT")

            if is_incomplete:
                print(f"⚠️  Colecție INCOMPLETĂ (completed_at este gol)")
                if last_successful:
                    print(f"   Ultimul segment cu succes: {last_successful}")

            print(f"📊 Segmente găsite:")
            print(f"   - În folder Temporare: {len(folder_segments)}")
            print(f"   - În root (G:\\): {len(root_segments)}")
            print(f"   - Total unice: {len(unique_segments)}")

            if unique_segments:
                print(f"   Primul segment: pages {unique_segments[0][0]}-{unique_segments[0][1]}")
                print(f"   Ultimul segment: pages {unique_segments[-1][0]}-{last_segment_end}")

            print(f"   Dimensiune segment standard: {segment_size} pagini")
            print(f"{'='*80}")

            # Afișează PDF-urile din root care trebuie mutate
            if root_segments:
                print(f"\n📦 PDF-uri în root care ar trebui mutate în folder:")
                for start, end, filepath in root_segments:
                    filename = os.path.basename(filepath)
                    in_folder = any(s[0] == start and s[1] == end for s in folder_segments)
                    status = "✓ (există deja în folder)" if in_folder else "⚠️  (lipsește din folder)"
                    print(f"   {status} {filename}")
                    print(f"      De la: {filepath}")
                    if folder_path:
                        print(f"      Către: {os.path.join(folder_path, filename)}")
                print()

            # Împarte fiecare gaură în segmente și afișează
            if gaps:
                print(f"❌ GĂURI în secvență:")
                for gap_start, gap_end in gaps:
                    gap_segments = split_gap_into_segments(gap_start, gap_end, segment_size)
                    for seg_start, seg_end in gap_segments:
                        print(f"   ❌ Lipsește: pages {seg_start}-{seg_end}")
                print()

def main():
    # Directoarele
    base_dir = r"g:\Temporare"
    state_json = r"g:\state.json"
    root_drive = r"g:\\"

    if not os.path.exists(base_dir):
        print(f"❌ Directorul {base_dir} nu există!")
        return

    if not os.path.exists(state_json):
        print(f"❌ Fișierul {state_json} nu există!")
        return

    print("🔍 Verificare PDF-uri lipsă în colecții...\n")
    find_all_gaps(base_dir, state_json, root_drive)
    print("✅ Verificare finalizată!")

if __name__ == "__main__":
    main()