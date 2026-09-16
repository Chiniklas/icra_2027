#!/usr/bin/env bash
set -euo pipefail

paper_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
pdf="${1:-$paper_dir/main.pdf}"
max_bytes=$((2 * 1024 * 1024))
failed=0

pass() {
  printf 'PASS  %s\n' "$1"
}

fail() {
  printf 'FAIL  %s\n' "$1" >&2
  failed=1
}

for command_name in pdfinfo pdffonts pdftotext rg; do
  if ! command -v "$command_name" >/dev/null 2>&1; then
    fail "required command is unavailable: $command_name"
  fi
done

if ((failed)); then
  exit 1
fi

if [[ ! -f "$pdf" ]]; then
  fail "PDF does not exist: $pdf"
  exit 1
fi

pdf_info="$(pdfinfo "$pdf")"
font_info="$(pdffonts "$pdf")"
page_count="$(awk '/^Pages:/ {print $2}' <<<"$pdf_info")"
pdf_version="$(awk '/^PDF version:/ {print $3}' <<<"$pdf_info")"
pdf_bytes="$(wc -c <"$pdf")"

((page_count <= 8)) \
  && pass "page count is within the 8-page limit ($page_count pages)" \
  || fail "page count is $page_count; ICRA 2027 permits at most 8 pages"

grep -q '^Page size:.*612 x 792 pts (letter)' <<<"$pdf_info" \
  && pass "page size is US Letter" \
  || fail "page size is not US Letter"

[[ "$pdf_version" == "1.4" ]] \
  && pass "PDF version is 1.4" \
  || fail "PDF version is $pdf_version; PaperCept prefers 1.4"

grep -q '^Encrypted:.*no' <<<"$pdf_info" \
  && pass "PDF has no security restrictions" \
  || fail "PDF is encrypted or has security restrictions"

if awk 'NR > 2 && $(NF-4) != "yes" {bad=1} END {exit !bad}' <<<"$font_info"; then
  fail "one or more fonts are not embedded"
else
  pass "all fonts are embedded"
fi

if rg -q 'Type 3|CID' <<<"$font_info"; then
  fail "PDF contains a Type 3 or CID font; inspect with pdffonts"
else
  pass "PDF contains no Type 3 or CID fonts"
fi

if ((pdf_bytes <= max_bytes)); then
  pass "PDF size is within 2 MiB ($pdf_bytes bytes)"
else
  fail "PDF is larger than 2 MiB ($pdf_bytes bytes)"
fi

if [[ ! -f "$paper_dir/.latex-build/main.log" ]]; then
  fail "LaTeX log is missing; build the paper before running preflight"
elif rg -n -i 'undefined references|citation .* undefined|reference .* undefined|multiply defined|pdf inclusion: found PDF version' \
    "$paper_dir/.latex-build/main.log"; then
  fail "LaTeX log contains unresolved references/citations or incompatible included PDFs"
else
  pass "LaTeX log has no unresolved references/citations or PDF-version warnings"
fi

if rg -n 'SUBMISSION-BLOCKER' \
    --glob '*.tex' --glob '*.bib' --glob '*.md' "$paper_dir"; then
  fail "source contains unresolved SUBMISSION-BLOCKER markers"
else
  pass "source contains no submission-blocker markers"
fi

if ! rg -q '^\\icraanonymoustrue$' "$paper_dir/main.tex"; then
  fail "anonymous review mode is not enabled"
elif pdftotext "$pdf" - | rg -q 'Chi Zhang|Carsten Oertel|Lei Zhang|Zhenshan Bing|Alois Knoll'; then
  fail "known author identity appears in rendered PDF"
else
  pass "anonymous review mode is enabled and known author names are absent"
fi

if ((failed)); then
  printf '\nSubmission preflight failed. Resolve the FAIL items above.\n' >&2
  exit 1
fi

printf '\nSubmission preflight passed. Upload main.pdf to PaperCept for its server-side check.\n'
