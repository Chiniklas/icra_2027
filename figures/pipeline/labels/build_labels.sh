#!/usr/bin/env bash
# Renders the pipeline-figure labels and components for reuse in PowerPoint.
#   labels (labels.txt): <name>.svg with glyphs as paths, <name>.pdf, and a
#     transparent 2400 dpi <name>.png in figures/pipeline/labels/
#   components: .svg, .pdf and transparent 1200 dpi .png next to their .tex sources
# Run from the repository root (ieeeconf.cls lives there):
#   bash figures/pipeline/labels/build_labels.sh
set -euo pipefail
OUT=figures/pipeline/labels
TMP=$(mktemp -d .labels_build.XXXXXX)  # relative: TeX rejects '~' in Windows short paths
trap 'rm -rf "$TMP"' EXIT
SVGDRV='\def\pgfsysdriver{pgfsys-dvisvgm.def}'
OPTS=(-interaction=nonstopmode -halt-on-error -output-directory="$TMP")

run() {  # run <engine...> -- <jobname> <tex input>
  local eng=() job src
  while [[ $1 != -- ]]; do eng+=("$1"); shift; done
  job=$2 src=$3
  if ! "${eng[@]}" "${OPTS[@]}" -jobname="$job" "$src" > "$TMP/$job.stdout" 2>&1; then
    echo "FAILED: $job"; grep -A5 '^!' "$TMP/$job.stdout" || tail -20 "$TMP/$job.stdout"
    exit 1
  fi
}

# ---------------------------------------------------------------- math labels
while IFS=$'\t' read -r name code; do
  [[ -z $name || $name == \#* ]] && continue
  printf '%s\n' \
    '\documentclass[class=ieeeconf,letterpaper,10pt,conference,border=1pt]{standalone}' \
    '\usepackage[T1]{fontenc}' \
    '\usepackage{amsmath,amssymb,bm,xcolor}' \
    '\definecolor{simblue}{HTML}{2E6FD0}' \
    '\definecolor{realred}{HTML}{D9224C}' \
    '\begin{document}' "\$${code}\$" '\end{document}' > "$TMP/src_$name.tex"
  run latex -- "$name" "$TMP/src_$name.tex"
  dvisvgm -v0 --no-fonts --exact-bbox --output="$OUT/$name.svg" "$TMP/$name.dvi"
  run pdflatex -- "$name" "$TMP/src_$name.tex"
  cp "$TMP/$name.pdf" "$OUT/$name.pdf"
  pdftocairo -png -transp -r 2400 -singlefile "$OUT/$name.pdf" "$OUT/$name"
  echo "label: $name"
done < "$OUT/labels.txt"

# ---------------------------------------------------------------- components
component() {  # component <latex|lualatex> <dir> <source basename> <jobname> [preamble]
  local eng=$1 dir=$2 src=$3 job=$4 pre=${5:-} pdfeng=pdflatex dvieng=(latex)
  if [[ $eng == lualatex ]]; then pdfeng=lualatex; dvieng=(lualatex --output-format=dvi); fi
  run "${dvieng[@]}" -- "$job" "$SVGDRV$pre\\input{$dir/$src.tex}"
  run "$pdfeng" -- "$job" "$pre\\input{$dir/$src.tex}"
  cp "$TMP/$job.pdf" "$dir/$job.pdf"
  local pages
  pages=$(pdfinfo "$dir/$job.pdf" | awk '/^Pages:/ {print $2}')
  if [[ $pages -gt 1 ]]; then
    dvisvgm -v0 --no-fonts --exact-bbox -p1- --output="$dir/$job-%p.svg" "$TMP/$job.dvi"
    pdftocairo -png -transp -r 1200 "$dir/$job.pdf" "$dir/$job"
  else
    dvisvgm -v0 --no-fonts --exact-bbox --output="$dir/$job.svg" "$TMP/$job.dvi"
    pdftocairo -png -transp -r 1200 -singlefile "$dir/$job.pdf" "$dir/$job"
  fi
  echo "component: $dir/$job"
}

component latex    figures/pipeline pointnet_block pointnet_block
component latex    figures/pipeline mlp_block      mlp_block
component latex    figures/pipeline fusion_block   fusion_block
component latex    figures/pipeline latent_vector  latent_vector
component latex    figures/datasets dataset_merged dataset_merged
component latex    figures/datasets dataset_merged dataset_merged_curves '\def\nolabel{}'
component lualatex figures/pipeline flow_field     flow_field
component lualatex figures/pipeline nut_pointcloud nut_pointcloud
