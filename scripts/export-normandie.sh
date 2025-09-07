#!/usr/bin/env bash
set -euo pipefail

# export-normandie.sh
# Crée un dossier export/normandie-<date>/ puis une archive zip contenant:
#   normandie.osm.pbf, INFO.txt, SHA256SUMS.txt, verify.(sh|ps1)

DATE=""
while getopts ":d:h" opt; do
  case $opt in
    d) DATE="$OPTARG" ;;
    h) sed -n '1,25p' "$0"; exit 0 ;;
    *) echo "Option invalide"; exit 1 ;;
  esac
done

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
DATA_DIR="$ROOT_DIR/data"
EXPORT_DIR="$ROOT_DIR/export"
mkdir -p "$EXPORT_DIR"
[[ -f "$DATA_DIR/normandie.osm.pbf" ]] || { echo "normandie.osm.pbf manquant"; exit 1; }

if [[ -z "$DATE" ]]; then
  cand=$(ls -1 "$DATA_DIR"/haute-normandie-*.osm.pbf 2>/dev/null | head -n1 || true)
  if [[ $cand =~ haute-normandie-([0-9]{6})\.osm\.pbf$ ]]; then DATE="${BASH_REMATCH[1]}"; else DATE=$(date -u +%y%m%d); fi
fi

DEST="$EXPORT_DIR/normandie-$DATE"
rm -rf "$DEST" && mkdir -p "$DEST"
cp "$DATA_DIR/normandie.osm.pbf" "$DEST/"

hash=$(sha256sum "$DEST/normandie.osm.pbf" | awk '{print $1}')
echo "$hash  normandie.osm.pbf" > "$DEST/SHA256SUMS.txt"
size=$(du -h "$DEST/normandie.osm.pbf" | awk '{print $1}')
cat > "$DEST/INFO.txt" <<EOF
Normandie Nominatim Export
Date jeu de base: $DATE
Généré: $(date -u +%Y-%m-%dT%H:%M:%SZ)
Taille: $size
Hash: SHA256SUMS.txt
Import: docker compose -f contrib/docker-compose-normandie.yml up -d
EOF

cat > "$DEST/verify.sh" <<'VSH'
#!/usr/bin/env bash
set -euo pipefail
sha=$(sha256sum normandie.osm.pbf | awk '{print $1}')
ref=$(awk '{print $1}' SHA256SUMS.txt)
if [[ "$sha" == "$ref" ]]; then echo 'OK hash'; else echo 'ECHEC hash'; exit 1; fi
VSH
chmod +x "$DEST/verify.sh"

cat > "$DEST/verify.ps1" <<'VPS'
Write-Host "Vérification SHA256..." -ForegroundColor Cyan
$actual=(Get-FileHash .\normandie.osm.pbf -Algorithm SHA256).Hash.ToLower()
$expected=(Get-Content .\SHA256SUMS.txt).Split(' ')[0].ToLower()
if($actual -eq $expected){ Write-Host 'OK hash' -ForegroundColor Green } else { Write-Host 'ECHEC hash' -ForegroundColor Red; exit 1 }
VPS

zipFile="$EXPORT_DIR/normandie-$DATE.zip"
rm -f "$zipFile"
if command -v zip >/dev/null 2>&1; then
  (cd "$DEST" && zip -qr "$zipFile" .)
else
  # Fallback tar.gz
  tar -C "$DEST" -czf "$EXPORT_DIR/normandie-$DATE.tar.gz" .
  echo "zip indisponible -> archive tar.gz créée"
  exit 0
fi
echo "Archive créée: $zipFile"
