.PHONY: all pdf clean

all: pdf

pdf:
	./build-paper.sh

clean:
	latexmk -C -outdir=.latex-build main.tex
	$(RM) main.pdf
