# ICRA 2027 LaTeX workspace

This workspace follows the official IEEE Robotics and Automation Society
PaperCept template: US Letter, 10-point text, two columns, and the bundled
`ieeeconf` class. The manuscript is anonymous by default for ICRA 2027 review.

## Build locally

You need a TeX Live distribution with PDFLaTeX, BibTeX, `latexmk`, Ghostscript,
and Poppler's PDF utilities.

```sh
make
```

The compiled paper is written to `main.pdf` in this directory. Intermediate
LaTeX and BibTeX files stay in `.latex-build/`. Remove all generated files with
`make clean`.

Run the local submission checks with:

```sh
make preflight
```

The preflight verifies the eight-page limit, US Letter page size, PDF 1.4,
font embedding, absence of Type 3/CID fonts, file size, anonymity, unresolved
references, and explicit submission-blocker markers. It complements rather
than replaces PaperCept's server-side PDF test.

On Debian or Ubuntu, a typical installation is:

```sh
sudo apt install latexmk texlive-latex-base texlive-latex-recommended \
  texlive-latex-extra texlive-fonts-recommended ghostscript poppler-utils \
  ripgrep
```

On macOS, install MacTeX; on Windows, install TeX Live or MiKTeX. No downloaded
packages are required at build time because `ieeeconf.cls` is vendored here.

## Edit the paper

- `main.tex` controls packages, title, anonymity, section order, and references.
- `01_introduction.tex` through `06_appendix.tex` contain the paper body.
- `main.bib` contains BibTeX entries.
- `figures/`, `table/`, and `alg/` hold reusable paper components.
- `build-paper.sh` performs an atomic, submission-sized PDF publication to
  `main.pdf`.
- `check-submission.sh` performs the reproducible local preflight used by
  `make preflight`.

Leave `\icraanonymoustrue` enabled for review. Only switch it to
`\icraanonymousfalse` and fill in author details when the conference requests a
non-anonymous version. Check acknowledgments, PDF metadata, repository links,
and self-citations for identity leaks before submission.

The current ICRA 2027 call limits the complete submission---including figures,
acknowledgments, and references---to eight pages and requires a
double-anonymous manuscript. Always re-check the conference site before the
final submission in case requirements change:

- <https://2027.ieee-icra.org/contribute/call-for-icra-2027-papers-now-accepting-submissions/>
- <https://ras.papercept.net/conferences/support/tex.php>

The bundled `ieeeconf.cls` was downloaded from the PaperCept LaTeX support page
on 2026-09-09. SHA-256:
`4befef671c2a996889d325f5170d3387bf42aac9a37dcaa93724ad49816e4ec2`.
