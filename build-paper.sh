#!/usr/bin/env bash
set -euo pipefail

paper_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
build_dir="$paper_dir/.latex-build"
raw_pdf="$build_dir/main.pdf"
optimized_pdf="$build_dir/main-optimized.pdf"

mkdir -p "$build_dir"
cd "$paper_dir"

latexmk \
  -pdf \
  -interaction=nonstopmode \
  -halt-on-error \
  -file-line-error \
  -outdir="$build_dir" \
  main.tex

# PaperCept recommends 300 dpi for color/grayscale images and 600 dpi for
# monochrome images. Keep vector content intact while reducing oversized raster
# captures and forcing Acrobat 5 / PDF 1.4 compatibility.
gs \
  -q \
  -dBATCH \
  -dNOPAUSE \
  -dSAFER \
  -dPDFSTOPONERROR \
  -sDEVICE=pdfwrite \
  -dCompatibilityLevel=1.4 \
  -dDetectDuplicateImages=true \
  -dCompressFonts=true \
  -dSubsetFonts=true \
  -dColorImageDownsampleType=/Bicubic \
  -dColorImageResolution=300 \
  -dGrayImageDownsampleType=/Bicubic \
  -dGrayImageResolution=300 \
  -dMonoImageDownsampleType=/Bicubic \
  -dMonoImageResolution=600 \
  -dAutoFilterColorImages=false \
  -dColorImageFilter=/DCTEncode \
  -dJPEGQ=90 \
  -dAutoFilterGrayImages=false \
  -dGrayImageFilter=/DCTEncode \
  -sOutputFile="$optimized_pdf.tmp" \
  "$raw_pdf"
mv -f "$optimized_pdf.tmp" "$optimized_pdf"

# Publish only a completed PDF so a viewer never sees an intermediate pass.
cp "$optimized_pdf" "$paper_dir/main.pdf.tmp"
mv -f "$paper_dir/main.pdf.tmp" "$paper_dir/main.pdf"
