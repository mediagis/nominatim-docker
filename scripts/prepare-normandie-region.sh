#!/usr/bin/env bash
set -euo pipefail

# prepare-normandie-region.sh
# Produit normandie-region.osm.pbf en combinant normandie.osm.pbf + (bretagne, pays-de-la-loire, ile-de-france)
# Usage:
#   ./scripts/prepare-normandie-region.sh            # auto-détection date comme script de base
#   ./scripts/prepare-normandie-region.sh -d 250906  # date explicite
#   FORCE=1 ./scripts/prepare-normandie-region.sh    # force re-téléchargement/refusion

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
mkdir -p "$DATA_DIR"

log(){ printf "\033[36m[INFO]\033[0m %s\n" "$*"; }
err(){ printf "\033[31m[ERR ]\033[0m %s\n" "$*"; }

# Assure que normandie.osm.pbf est présent (sinon exécute script précédent)
if [[ ! -f "$DATA_DIR/normandie.osm.pbf" || -n "${FORCE:-}" ]]; then
  log "Préparation de la base Normandie (script bash)"
  bash "$ROOT_DIR/scripts/prepare-normandie.sh" ${DATE:+-d $DATE}
fi

# Déduire DATE si absent à partir d'un fichier haute-normandie-* déjà téléchargé
if [[ -z "$DATE" ]]; then
  cand=$(ls -1 "$DATA_DIR"/haute-normandie-*.osm.pbf 2>/dev/null | head -n1 || true)
  if [[ "$cand" =~ haute-normandie-([0-9]{6})\.osm\.pbf$ ]]; then
    DATE="${BASH_REMATCH[1]}"; log "Date déduite: $DATE";
  else
    err "Impossible de déduire la date (fichier haute-normandie-* absent)"; exit 1
  fi
fi

REGIONS=(bretagne pays-de-la-loire ile-de-france)

need(){ command -v "$1" >/dev/null 2>&1 || { err "Commande requise manquante: $1"; exit 1; }; }
need curl
need md5sum
need awk

download(){
  local id="$1"; local name="${id}-${DATE}.osm.pbf"; local url="https://download.geofabrik.de/europe/france/${name}"; local target="$DATA_DIR/$name"
  if [[ -f "$target" && -z "${FORCE:-}" ]]; then
    log "$name existe (skip)"; return
  fi
  log "Téléchargement $url"; curl -L --fail -o "$target" "$url"
  curl -L --fail -o "$target.md5" "$url.md5"
  exp=$(awk '{print $1}' "$target.md5")
  act=$(md5sum "$target" | awk '{print $1}')
  [[ "$exp" == "$act" ]] || { err "MD5 mismatch $name"; exit 1; }
  log "MD5 ok $name"
}

for r in "${REGIONS[@]}"; do download "$r"; done

OSMIUM_BIN="osmium"
if ! command -v osmium >/dev/null 2>&1; then
  if command -v docker >/dev/null 2>&1; then
    log "osmium absent: fallback docker"
    docker run --rm -v "$DATA_DIR:/data" ubuntu:24.04 bash -lc "set -e; apt-get update -qq && apt-get install -yqq osmium-tool >/dev/null && \
      osmium merge /data/normandie.osm.pbf /data/bretagne-$DATE.osm.pbf /data/pays-de-la-loire-$DATE.osm.pbf /data/ile-de-france-$DATE.osm.pbf -o /data/_tmp-region.osm.pbf --overwrite && \
      osmium sort /data/_tmp-region.osm.pbf -o /data/normandie-region.osm.pbf --overwrite && rm /data/_tmp-region.osm.pbf && \
      osmium fileinfo -e /data/normandie-region.osm.pbf | head -n 10" || { err "Fusion via docker échouée"; exit 1; }
    log "Terminé: $DATA_DIR/normandie-region.osm.pbf"; exit 0
  else
    err "osmium absent et docker indisponible"; exit 1
  fi
fi

log "Fusion région étendue"
osmium merge "$DATA_DIR/normandie.osm.pbf" \
             "$DATA_DIR/bretagne-$DATE.osm.pbf" \
             "$DATA_DIR/pays-de-la-loire-$DATE.osm.pbf" \
             "$DATA_DIR/ile-de-france-$DATE.osm.pbf" \
             -o "$DATA_DIR/_tmp-region.osm.pbf" --overwrite
osmium sort "$DATA_DIR/_tmp-region.osm.pbf" -o "$DATA_DIR/normandie-region.osm.pbf" --overwrite
rm -f "$DATA_DIR/_tmp-region.osm.pbf"
osmium fileinfo -e "$DATA_DIR/normandie-region.osm.pbf" | head -n 10 || true
log "Fichier final: $DATA_DIR/normandie-region.osm.pbf"
echo "Lancer ensuite: docker compose -f contrib/docker-compose-normandie-region.yml up -d --force-recreate"
