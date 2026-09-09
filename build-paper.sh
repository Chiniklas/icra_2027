#!/usr/bin/env bash
set -euo pipefail

paper_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
build_dir="$paper_dir/.latex-build"

mkdir -p "$build_dir"
cd "$paper_dir"

latexmk \
  -pdf \
  -interaction=nonstopmode \
  -halt-on-error \
  -file-line-error \
  -outdir="$build_dir" \
  main.tex

# Publish only a completed PDF so a viewer never sees an intermediate pass.
cp "$build_dir/main.pdf" "$paper_dir/main.pdf.tmp"
mv -f "$paper_dir/main.pdf.tmp" "$paper_dir/main.pdf"
