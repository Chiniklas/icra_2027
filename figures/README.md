# Figures

Put publication figures here. Prefer vector PDF for diagrams and plots; use PNG
or JPEG for raster images. Avoid EPS when compiling directly with PDFLaTeX.

The `.tex` files are compiling vector placeholders:

- `teaser_placeholder.tex` creates the page-one problem--method--result teaser.
- `pipeline_placeholder.tex` creates the full-width method overview.
- `simulation_scene_placeholder.png` reserves a single-column simulation image
  in the experimental setup.
- `hardware_family_placeholder.png` reserves a single-column photograph of the
  full nut, bolt, and holder family used in the hardware experiments.

Replace the relevant `\input{...}` in the paper with
`\includegraphics[width=\linewidth]{figures/your_figure.pdf}` when the final
artwork is ready.
