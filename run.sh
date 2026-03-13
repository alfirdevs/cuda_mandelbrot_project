#!/usr/bin/env bash
set -e

echo "Building project..."
make

mkdir -p data/output_images results proof

echo "Running GPU Mandelbrot batch..."
./mandelbrot_batch \
  --width 4096 \
  --height 4096 \
  --max-iter 2000 \
  --num-images 8 \
  --output-dir data/output_images \
  --compare-cpu 1

if command -v python3 >/dev/null 2>&1; then
  python3 scripts/make_contact_sheet.py --input-dir data/output_images --output proof/contact_sheet.png || true
  python3 scripts/summarize_results.py --csv results/timings.csv --output results/summary.txt || true
fi

echo "Done."
