#!/usr/bin/env bash
set -euo pipefail

# prepare-normandie.sh
# Télécharge Haute & Basse Normandie (Geofabrik), vérifie MD5, fusionne + trie en normandie.osm.pbf.
# Usage:
#   ./scripts/prepare-normandie.sh            # auto-détection date (jusqu'à J-6)
#   ./scripts/prepare-normandie.sh -d 250906  # date précise yymmdd
#   FORCE=1 ./scripts/prepare-normandie.sh    # force re-téléchargement et refusion
# Dépendances: bash, curl, grep, awk, md5sum, osmium-tool (ou Docker pour fallback)

DATE=""
while getopts ":d:h" opt; do
  case $opt in
    d) DATE="$OPTARG" ;;
    h) sed -n '1,20p' "$0"; exit 0 ;;
    *) echo "Option invalide"; exit 1 ;;
  esac
done

DATA_DIR="$(cd "$(dirname "$0")/.." && pwd)/data"
mkdir -p "$DATA_DIR"

log(){ printf "\033[36m[INFO]\033[0m %s\n" "$*"; }
warn(){ printf "\033[33m[WARN]\033[0m %s\n" "$*"; }
err(){ printf "\033[31m[ERR ]\033[0m %s\n" "$*"; }

need(){ command -v "$1" >/dev/null 2>&1 || { err "Commande requise manquante: $1"; exit 1; }; }
need curl
need grep
need awk
need md5sum

# Détection date si non fournie
if [[ -z "$DATE" ]]; then
  for i in $(seq 0 6); do
    cand=$(date -u -d "-$i day" +%y%m%d 2>/dev/null || date -u -v -"$i"d +%y%m%d 2>/dev/null || true)
    test_url="https://download.geofabrik.de/europe/france/haute-normandie-${cand}.osm.pbf"
    if curl -sI "$test_url" | grep -qi '200'; then
      DATE="$cand"; log "Date trouvée: $DATE"; break
    fi
  done
  [[ -z "$DATE" ]] && { err "Aucune date trouvée sur 7 jours"; exit 1; }
else
  [[ ! "$DATE" =~ ^[0-9]{6}$ ]] && { err "Format date attendu yymmdd"; exit 1; }
fi

FILES=("haute-normandie-$DATE.osm.pbf" "basse-normandie-$DATE.osm.pbf")

download(){
  local name="$1"; local url="https://download.geofabrik.de/europe/france/${name}"; local target="$DATA_DIR/$name"
  if [[ -f "$target" && -z "${FORCE:-}" ]]; then
    log "$name existe (skip)"; return
  fi
  log "Téléchargement $url"
  curl -L --fail -o "$target" "$url"
  log "MD5 $url.md5"
  curl -L --fail -o "$target.md5" "$url.md5"
  exp=$(awk '{print $1}' "$target.md5")
  act=$(md5sum "$target" | awk '{print $1}')
  [[ "$exp" == "$act" ]] || { err "MD5 mismatch $name ($exp != $act)"; exit 1; }
  log "MD5 ok $name"
}

for f in "${FILES[@]}"; do download "$f"; done

OSMIUM_BIN="osmium"
if ! command -v osmium >/dev/null 2>&1; then
  if command -v docker >/dev/null 2>&1; then
    log "osmium non trouvé localement: fallback Docker (ubuntu + osmium-tool)"
    docker run --rm -v "$DATA_DIR:/data" ubuntu:24.04 bash -lc "set -e; apt-get update -qq && apt-get install -yqq osmium-tool >/dev/null && \
      osmium merge /data/haute-normandie-$DATE.osm.pbf /data/basse-normandie-$DATE.osm.pbf -o /data/_tmp-normandie.osm.pbf --overwrite && \
      osmium sort /data/_tmp-normandie.osm.pbf -o /data/normandie.osm.pbf --overwrite && rm /data/_tmp-normandie.osm.pbf && \
      osmium fileinfo -e /data/normandie.osm.pbf | head -n 12" || { err "Fusion via docker échouée"; exit 1; }
    log "Fichier final: $DATA_DIR/normandie.osm.pbf"
    exit 0
  else
    err "osmium absent et docker indisponible"; exit 1
  fi
fi

log "Fusion (osmium merge + sort)"
osmium merge "$DATA_DIR/haute-normandie-$DATE.osm.pbf" "$DATA_DIR/basse-normandie-$DATE.osm.pbf" -o "$DATA_DIR/_tmp-normandie.osm.pbf" --overwrite
osmium sort  "$DATA_DIR/_tmp-normandie.osm.pbf" -o "$DATA_DIR/normandie.osm.pbf" --overwrite
rm -f "$DATA_DIR/_tmp-normandie.osm.pbf"
osmium fileinfo -e "$DATA_DIR/normandie.osm.pbf" | head -n 12 || true
size=$(du -h "$DATA_DIR/normandie.osm.pbf" | awk '{print $1}')
log "Terminé: normandie.osm.pbf ($size)"
echo "Lancer ensuite: docker compose -f contrib/docker-compose-normandie.yml up -d --force-recreate"
