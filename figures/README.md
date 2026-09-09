# Figures

Put publication figures here. Prefer vector PDF for diagrams and plots; use PNG
or JPEG for raster images. Avoid EPS when compiling directly with PDFLaTeX.

The two `.tex` files are compiling vector placeholders:

- `teaser_placeholder.tex` creates the page-one problem--method--result teaser.
- `pipeline_placeholder.tex` creates the full-width method overview.

Replace either `\input{...}` in the paper with
`\includegraphics[width=\linewidth]{figures/your_figure.pdf}` when the final
artwork is ready.
