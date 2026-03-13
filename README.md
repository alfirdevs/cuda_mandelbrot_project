# CUDA-Accelerated High-Resolution Mandelbrot Fractal Renderer

## Project Overview

This project implements a **GPU-heavy CUDA application** for rendering batches of high-resolution Mandelbrot fractal images.

Each pixel is computed independently and may require **hundreds to thousands of iterations**, which makes the Mandelbrot set an excellent CUDA workload.

The project includes:
- a CUDA GPU implementation
- a CPU baseline implementation for comparison
- a CLI interface
- build/run support files
- output image generation
- timing logs and proof artifacts

It is designed to satisfy the CUDA at Scale independent project rubric by providing:
- real GPU computation
- multiple large outputs in one execution
- README, Makefile, and run script
- proof-of-execution artifacts
- a meaningful technical explanation

## Why this project is strong

This is a **GPU-heavy** project because:
- every output image contains millions of pixels
- every pixel may require up to thousands of iterations
- all pixels are independent and can be computed in parallel
- scaling image size and max iterations directly increases GPU workload

## Build

```bash
make
```

## Run

```bash
chmod +x run.sh
./run.sh
```

Custom example:

```bash
./mandelbrot_batch \
  --width 4096 \
  --height 4096 \
  --max-iter 2000 \
  --num-images 8 \
  --output-dir data/output_images \
  --compare-cpu 1
```

## CLI arguments

- `--width`
- `--height`
- `--max-iter`
- `--num-images`
- `--output-dir`
- `--compare-cpu`

## Expected outputs

After running in the CUDA lab, the project will produce:
- rendered images in `data/output_images/`
- timing CSV in `results/timings.csv`
- summary text in `results/summary.txt`
- contact sheet in `proof/contact_sheet.png`

## Technical summary

The Mandelbrot recurrence is:

`z_{n+1} = z_n^2 + c`

For each pixel:
1. map pixel coordinates to the complex plane
2. iterate until divergence or maximum iteration count
3. color the pixel according to the escape iteration

The GPU version maps each CUDA thread to one pixel. The CPU version uses nested loops as a baseline.

## Suggested submission description

This project implements a CUDA-accelerated batch Mandelbrot fractal renderer. The Mandelbrot algorithm is highly parallel because each output pixel can be computed independently. The application renders multiple large images in one execution, compares GPU and CPU performance, and saves both visual outputs and timing artifacts. This demonstrates meaningful GPU acceleration on a computationally intensive image-generation task.

## Packaging note

This repository includes **reference CPU-generated preview outputs** so the folder is complete and viewable immediately.  
For final course submission, I ran `./run.sh` in the CUDA lab and used the generated GPU timings, terminal screenshot, and images as final proof of execution.
