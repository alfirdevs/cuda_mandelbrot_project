#!/usr/bin/env python3
import argparse
from pathlib import Path
import pandas as pd

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--csv", required=True)
    parser.add_argument("--output", required=True)
    args = parser.parse_args()

    df = pd.read_csv(args.csv)
    lines = []
    lines.append("Mandelbrot Batch Run Summary")
    lines.append("============================")
    lines.append(f"Images: {len(df)}")
    if "gpu_ms" in df.columns and df["gpu_ms"].notna().any():
        gpu = df["gpu_ms"].dropna()
        lines.append(f"Average GPU time (ms): {gpu.mean():.3f}")
        lines.append(f"Min GPU time (ms): {gpu.min():.3f}")
        lines.append(f"Max GPU time (ms): {gpu.max():.3f}")
    if "cpu_ms" in df.columns and (df["cpu_ms"].fillna(-1) > 0).any():
        cpu = df.loc[df["cpu_ms"] > 0, "cpu_ms"].iloc[0]
        gpu0 = df.loc[df["gpu_ms"].notna(), "gpu_ms"].iloc[0] if df["gpu_ms"].notna().any() else None
        lines.append(f"CPU baseline first image (ms): {cpu:.3f}")
        if gpu0 and gpu0 > 0:
            lines.append(f"GPU speedup first image: {cpu/gpu0:.2f}x")
    Path(args.output).write_text("\n".join(lines))

if __name__ == "__main__":
    main()
