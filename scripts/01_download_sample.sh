#!/usr/bin/env bash
set -euo pipefail

# Download a ONE-MONTH sample of LSA SAF METREF NetCDF files.
#
# Usage:
#   bash scripts/01_download_sample.sh 2020 06
#
# Requires:
#   .env at repo root with USERNAME and PASSWORD

YEAR="${1:-${SAMPLE_YEAR:-2020}}"
MONTH="${2:-${SAMPLE_MONTH:-06}}"

# METREF endpoint (same as in the original script)
src="https://datalsasaf.lsasvcs.ipma.pt/PRODUCTS/MSG/METREF/NETCDF"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Load credentials from .env in scripts folder
if [ -f "$SCRIPT_DIR/.env" ]; then
  set -a
  # shellcheck source=/dev/null
  . "$SCRIPT_DIR/.env"
  set +a
fi

: "${USERNAME:?USERNAME missing (set in .env)}" "${PASSWORD:?PASSWORD missing (set in .env)}"

OUT="$ROOT_DIR/data/raw"
mkdir -p "$OUT"

cd "$OUT"

for d in $(seq -w 01 31); do
  date --date="${YEAR}-${MONTH}-${d}" >/dev/null 2>&1 || continue
  mkdir -p "${YEAR}/${MONTH}/${d}"

  listing=$(wget -q -O- "${src}/${YEAR}/${MONTH}/${d}/" --user="$USERNAME" --password="$PASSWORD" || true)
  [ -z "$listing" ] && continue

  echo "$listing" | tr '"' '\n' | grep -E "\.nc$" | while read -r file; do
    # The directory listing contains absolute paths starting with /PRODUCTS/...
    url="$(echo "$src" | cut -f -3 -d "/")${file}"
    wget -N "$url" --user="$USERNAME" --password="$PASSWORD" --accept=nc -P "${YEAR}/${MONTH}/${d}"
  done

done
