# LSA SAF Climate Data to Zarr Cube

This repository is a minimal, reproducible example that shows how to:

1. Create an LSA SAF Data Service account and obtain download credentials

2. Download one month of LSA SAF (EUMETSAT) data (METREF product)

3. Preprocess the NetCDF files using CDO (clip → remap → clip) with dynamic grid generation

4. Create a Zarr data cube using xarray + zarr

5. Validate both interim NetCDF outputs and the final Zarr store using a small test notebook

------------------------------------------------------------------------

## Repository Structure

The repository follows a clean research data management structure:

    lsasaf-zarr-cube/
    │
    ├── README.md
    ├── CITATION.cff
    ├── pyproject.toml
    ├── uv.lock
    ├── requirements.txt
    ├── .env.example
    ├── .gitignore
    │
    ├── configs/
    │   ├── config.txt                 # CDO bounding box & processing defaults
    │   └── config_resolution.yaml     # Domain definition for grid generation
    │
    ├── scripts/
    │   ├── 01_download_sample.sh      # Download ONE month of data
    │   ├── 02_preprocess_cdo.sh       # Run preprocessing pipeline
    │   ├── 03_build_zarr_cube.py      # Build Zarr cube from interim data
    │   ├── cdo_preprocess.sh          # Core CDO pipeline (clip → remap → clip)
    │   ├── generate_grid.py           # Dynamic grid generator
    │   └── evpt_full.sh               # Original multi-year downloader (reference)
    │
    ├── notebooks/
    │   ├── test_outputs.ipynb         # Validate interim & Zarr outputs
    │   └── test_cube.ipynb            # Original exploration notebook
    │
    └── data/                          # NOT committed (ignored)
        ├── raw/       # Downloaded NetCDF files
        ├── interim/   # CDO-processed NetCDF files
        └── zarr/      # Final Zarr data cubes

------------------------------------------------------------------------

## 1. Register for LSA SAF Data Service

Access to LSA SAF data requires registration.

1.  Visit: https://datalsasaf.lsasvcs.ipma.pt\
2.  Click **Register**
3.  Create account:
    -   Username: lowercase alphanumeric
    -   Password: minimum 8 characters including number or special
        character

After registration, use your credentials for authenticated downloads.

These are used for HTTP basic authentication during download.

    LSA SAF products are distributed under CC BY 4.0. Please follow attribution requirements.

------------------------------------------------------------------------

## 2. Environment Setup (uv)

#### Pre-requisites:
System tools (not managed by uv)

You need:

    wget

    GNU date

    cdo

    python3

This repository uses uv for deterministic dependency management.

Install Python environment using uv:

```bash
uv venv "name for the env"
uv sync
``` 
Optional (for notebooks):
```bash
uv sync --extra notebook
```
### Alternative using pip
```bash
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

To regenerate requirements.txt:

    uv export --format requirements-txt -o requirements.txt

------------------------------------------------------------------------

## 3. Configure Credentials

Create a `.env` file:

```bash
cp .env.example .env
```
Edit:

    USERNAME=your_username
    PASSWORD=your_password

.env is ignored by git.

------------------------------------------------------------------------

## 4. Download One Month Sample

Download METREF example month data:

```bash
## before running the script it is a good practice

## chmod +x scripts/01_download_sample.sh 
## to make the script executable
## for default month
bash scripts/01_download_sample.sh
## for specific monnth
bash scripts/01_download_sample.sh 2020 06
```
Output:

    data/raw/YYYY/MM/DD/*.nc

------------------------------------------------------------------------

## 5. Preprocess with CDO

Run preprocessing (default resolution from config.txt):
```bash
bash scripts/02_preprocess_cdo.sh
```
Or specify resolution:
```bash
bash scripts/02_preprocess_cdo.sh 0.1
```
Output:

    data/interim/YYYY/MM/*_processed.nc

Log file:

    data/interim/cdo.log

Processing steps per file: 1. Buffer clip 2. Remap to regular lon/lat
grid 3. Final exact clip

------------------------------------------------------------------------

## 6. Build Zarr Cube

Assumes `data/interim/` contains processed NetCDF files.

```bash
uv run python scripts/build_zarr_cube.py 
```
Output:

    data/zarr/metref_sample_1month.zarr

The script: - Loads all `.nc` files in `data/interim` - Uses
`xarray.open_mfdataset` - Writes consolidated Zarr store - Validates by
reopening the store

------------------------------------------------------------------------

## 7. Test notebook

Open:

    notebooks/test_outputs.ipynb

Launch:

    uv run jupyter lab

Notebook checks:

- interim files load

- Zarr opens

- small computation works

### Configuration notes
```bash
configs/config.txt

- Bounding box (Sahel default)

- BUFFER

- REMAP_METHOD

- PARALLEL

- RES
```
```bash
configs/config_resolution.yaml
```
Used by generate_grid.py to compute grid size.


### Security notes

- Do not commit `.env`

- Avoid passing passwords directly on command line

- Prefer `.env` or `.netrc`

### Citation / acknowledgement

If using LSA SAF data in publications, follow LSA SAF attribution guidance and CC BY 4.0 requirements.

If you use this repository in research, please cite it as described in:

    CITATION.cff
