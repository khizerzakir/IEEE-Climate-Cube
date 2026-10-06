SHELL := /usr/bin/env bash

YEAR ?= 2020
MONTH ?= 06
RES ?= 0.05

.PHONY: help setup download preprocess cube notebooks

help:
	@echo "Targets:"
	@echo "  setup        - create uv venv + install deps"
	@echo "  download     - download one-month sample (YEAR/MONTH)"
	@echo "  preprocess   - run CDO preprocessing (RES)"
	@echo "  cube         - build Zarr cube from data/interim"
	@echo "  notebooks    - start jupyter (requires extras installed)"

setup:
	uv venv
	uv sync

# Requires .env with USERNAME/PASSWORD
download:
	bash scripts/01_download_sample.sh $(YEAR) $(MONTH)

preprocess:
	bash scripts/02_preprocess_cdo.sh $(RES)

cube:
	uv run python scripts/build_zarr_cube.py

notebooks:
	uv run jupyter lab
