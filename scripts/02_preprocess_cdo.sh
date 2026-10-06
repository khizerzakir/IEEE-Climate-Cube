#!/usr/bin/env bash
set -euo pipefail

# Wrapper around the provided CDO preprocessing pipeline.
#
# Usage:
#   bash scripts/02_preprocess_cdo.sh 0.05
#
# Inputs:
#   data/raw/
# Outputs:
#   data/interim/

RESOLUTION="${1:-0.05}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

WORKDIR="$SCRIPT_DIR"

# Ensure the CDO script can find its config and grid generator relative to itself
cp -f "$ROOT_DIR/configs/config.txt" "$WORKDIR/config.txt"
cp -f "$ROOT_DIR/configs/config_resolution.yaml" "$WORKDIR/config_resolution.yaml"

bash "$WORKDIR/cdo_preprocess.sh" "$RESOLUTION" "$ROOT_DIR/data/raw" "$ROOT_DIR/data/interim"
