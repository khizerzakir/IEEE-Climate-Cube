#!/usr/bin/env python3
"""Build a Zarr cube from preprocessed (interim) NetCDF files.

This repo is intentionally *script-first*:
- download + preprocessing are shell scripts
- cube creation is a single Python script (xarray + zarr)

Assumptions
-----------
- Preprocessed NetCDF files exist under:  data/interim/
  (e.g., data/interim/YYYY/MM/*_processed.nc)

Outputs
-------
- Zarr store is written to: data/zarr/metref_sample_1month.zarr

Run
---
    uv run python scripts/build_zarr_cube.py

Notes
-----
- If your interim files use different dimension names (e.g., y/x instead of lat/lon),
  adjust CHUNKS and/or add a rename step below.
"""

from __future__ import annotations

from pathlib import Path

import xarray as xr


def main() -> int:
    root = Path(__file__).resolve().parents[1]
    interim = root / "data" / "interim"
    out = root / "data" / "zarr" / "metref_sample_1month.zarr"
    out.parent.mkdir(parents=True, exist_ok=True)

    files = sorted(interim.rglob("*.nc"))
    if not files:
        raise RuntimeError(
            "No NetCDF files found under data/interim. "
            "Run preprocessing first or place your interim files there."
        )

    print(f"Found {len(files)} interim NetCDF files")

    # Chunking strategy (safe defaults for a 1-month sample; adjust if needed)
    # Try both lat/lon and y/x, depending on your preprocessing output.
    CHUNKS = {"time": 10, "lat": 200, "lon": 200}

    ds = xr.open_mfdataset(
        files,
        combine="by_coords",
        parallel=False,
        chunks=CHUNKS,
        engine="h5netcdf",
        lock=False,
    )

    # Optional: harmonize dimension names if your data uses y/x
    # if set(ds.dims).issuperset({"y", "x"}) and not set(ds.dims).issuperset({"lat", "lon"}):
    #     ds = ds.rename({"y": "lat", "x": "lon"})

    print(ds)

    # Write Zarr
    ds.to_zarr(out, mode="w", consolidated=True)
    print(f"\n✅ Zarr cube written to: {out}")

    # Validate
    reopened = xr.open_zarr(out, consolidated=True)
    # Trigger a tiny computation to confirm read path works
    _ = reopened.isel(time=0).to_array().mean().compute()
    print("✅ Validation OK (opened Zarr + computed a small statistic)")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
