.PHONY: all pdf preflight clean

all: pdf

pdf:
	./build-paper.sh

preflight: pdf
	./check-submission.sh main.pdf

clean:
	-latexmk -C -outdir=.latex-build main.tex
	$(RM) -r .latex-build
	$(RM) main.pdf main.pdf.tmp main-optimized.pdf.tmp
	$(RM) main.aux main.bbl main.blg main.fdb_latexmk main.fls main.log
	$(RM) main.out main.toc main.lof main.lot main.synctex.gz
