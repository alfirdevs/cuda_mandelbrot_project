#!/usr/bin/env python3
import argparse
from pathlib import Path
import numpy as np
from PIL import Image
import pandas as pd
import time

VIEWS = [
    (-2.5, 1.0, -1.5, 1.5),
    (-0.74877, -0.74872, 0.06505, 0.06510),
    (-0.74365, -0.74360, 0.13180, 0.13185),
    (-0.10115, -0.10090, 0.95620, 0.95645),
    (-1.25066, -1.25061, 0.02010, 0.02015),
    (-0.77570, -0.77545, 0.13635, 0.13660),
]

def render(width, height, max_iter, view):
    x_min, x_max, y_min, y_max = view
    xs = np.linspace(x_min, x_max, width)
    ys = np.linspace(y_min, y_max, height)
    X, Y = np.meshgrid(xs, ys)
    C = X + 1j * Y
    Z = np.zeros_like(C)
    M = np.full(C.shape, max_iter, dtype=np.int32)
    active = np.ones(C.shape, dtype=bool)

    for i in range(max_iter):
        if not active.any():
            break
        Z[active] = Z[active] * Z[active] + C[active]
        escaped = np.abs(Z) > 2.0
        new = escaped & active
        M[new] = i
        active[new] = False

    img = np.zeros((height, width, 3), dtype=np.uint8)
    img[..., 0] = (M * 9) % 256
    img[..., 1] = (M * 7) % 256
    img[..., 2] = (M * 5) % 256
    img[M == max_iter] = 0
    return img

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--width", type=int, default=640)
    parser.add_argument("--height", type=int, default=480)
    parser.add_argument("--max-iter", type=int, default=300)
    parser.add_argument("--num-images", type=int, default=6)
    parser.add_argument("--output-dir", default="data/output_images")
    args = parser.parse_args()

    outdir = Path(args.output_dir)
    outdir.mkdir(parents=True, exist_ok=True)
    results_dir = Path("results")
    results_dir.mkdir(exist_ok=True)
    rows = []

    for i in range(args.num_images):
        t0 = time.perf_counter()
        img = render(args.width, args.height, args.max_iter, VIEWS[i % len(VIEWS)])
        ms = (time.perf_counter() - t0) * 1000.0
        out = outdir / f"mandelbrot_ref_{i:02d}.png"
        Image.fromarray(img).save(out)
        rows.append({
            "image_id": i,
            "width": args.width,
            "height": args.height,
            "max_iter": args.max_iter,
            "gpu_ms": np.nan,
            "cpu_ms": ms,
            "output_file": str(out),
        })

    pd.DataFrame(rows).to_csv(results_dir / "timings.csv", index=False)
    (results_dir / "summary.txt").write_text(
        "Reference CPU-generated preview outputs created in the packaging environment.\n"
        "Run ./run.sh in the CUDA lab to generate true GPU timings and final proof artifacts.\n"
    )

if __name__ == "__main__":
    main()
