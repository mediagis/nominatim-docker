#!/bin/bash -ex
# Continue an interrupted Nominatim import at a detected stage.
# Invoked only from init.sh — not a public container entrypoint.

stage="$1"

if [ -z "$THREADS" ]; then
  THREADS=$(nproc)
fi

OSMFILE=${PROJECT_DIR}/data.osm.pbf
if [ "$PBF_PATH" != "" ]; then
  OSMFILE=$PBF_PATH
fi

cd ${PROJECT_DIR}

case "${stage}" in
  import-from-file)
    if [ ! -f "${OSMFILE}" ] || [ ! -s "${OSMFILE}" ]; then
      echo "Missing OSM extract at ${OSMFILE}; cannot continue import-from-file (refusing DROP)"
      exit 1
    fi
    if [ "$REVERSE_ONLY" = "true" ]; then
      sudo -E -u nominatim nominatim import \
        --continue import-from-file \
        --osm-file "${OSMFILE}" \
        --threads "${THREADS}" \
        --reverse-only
    else
      sudo -E -u nominatim nominatim import \
        --continue import-from-file \
        --osm-file "${OSMFILE}" \
        --threads "${THREADS}"
    fi
    ;;
  load-data | indexing | db-postprocess)
    sudo -E -u nominatim nominatim import \
      --continue "${stage}" \
      --threads "${THREADS}"
    ;;
  *)
    echo "Unknown continue stage: ${stage}"
    exit 1
    ;;
esac
