GUIX:=/usr/local/bin/guix
GUIXTME:=${GUIX} time-machine --channels=../guix/channels.pinned.scm -- \
		shell --manifest=../guix/manifest-ethics.scm
MD=$(wildcard *.md)
RMD=$(wildcard *.Rmd)
OUTPUTDIR:=output
ODT=$(RMD:%.Rmd=$(OUTPUTDIR)/%.odt)
DOCX=$(RMD:%.Rmd=$(OUTPUTDIR)/%.docx)
PDF=$(MD:%.md=$(OUTPUTDIR)/%.pdf)
SUBMISSIONDIR:=submission

.DELETE_ON_ERROR:

all: $(ODT) $(PDF)

.PHONEY:
shell:
	${GUIXTME}

$(OUTPUTDIR):
	@mkdir -p $(OUTPUTDIR)

$(SUBMISSIONDIR):
	@mkdir -p $(SUBMISSIONDIR)

output/%.odt: %.Rmd | $(OUTPUTDIR)
	${GUIXTME} -- Rscript -e "rmarkdown::render('$<', output_dir = '$(OUTPUTDIR)')"

output/%.docx: $(ODT) | $(OUTPUTDIR)
	${GUIXTME} libreoffice -- libreoffice --headless --convert-to docx $< --outdir $(OUTPUTDIR)

output/%.pdf: %.md | $(OUTPUTDIR)
	${GUIXTME} pandoc -- pandoc $< --template=pandoc/templates/letter.tex --output $@

.PHONEY:
dist: $(DOCX) $(PDF) | $(SUBMISSIONDIR)
	cp $< $(SUBMISSIONDIR)/

.PHONEY:
clean:
	@rm -rf $(DOCX) $(ODT) $(PDF)
