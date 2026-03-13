#!/usr/bin/env python3
import argparse
from pathlib import Path
from PIL import Image, ImageDraw

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--input-dir", required=True)
    parser.add_argument("--output", required=True)
    parser.add_argument("--thumb-width", type=int, default=300)
    args = parser.parse_args()

    input_dir = Path(args.input_dir)
    files = sorted([p for p in input_dir.iterdir() if p.suffix.lower() in [".ppm", ".png"]])
    if not files:
        raise SystemExit("No images found")

    thumbs = []
    for p in files[:9]:
        img = Image.open(p).convert("RGB")
        img.thumbnail((args.thumb_width, args.thumb_width))
        canvas = Image.new("RGB", (args.thumb_width, args.thumb_width + 26), "white")
        x = (args.thumb_width - img.width) // 2
        y = (args.thumb_width - img.height) // 2
        canvas.paste(img, (x, y))
        draw = ImageDraw.Draw(canvas)
        draw.text((8, args.thumb_width + 6), p.name, fill="black")
        thumbs.append(canvas)

    cols = 3
    rows = (len(thumbs) + cols - 1) // cols
    sheet = Image.new("RGB", (cols * args.thumb_width, rows * (args.thumb_width + 26)), "lightgray")
    for i, t in enumerate(thumbs):
        x = (i % cols) * args.thumb_width
        y = (i // cols) * (args.thumb_width + 26)
        sheet.paste(t, (x, y))

    Path(args.output).parent.mkdir(parents=True, exist_ok=True)
    sheet.save(args.output)

if __name__ == "__main__":
    main()
