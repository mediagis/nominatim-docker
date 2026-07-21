#!/bin/bash -ex
# Continue an interrupted Nominatim import at a detected stage.
# Invoked only from init.sh — not a public container entrypoint.

stage="$1"

if [ -z "$THREADS" ]; then
  THREADS=$(nproc)
fi

cd ${PROJECT_DIR}

case "${stage}" in
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
