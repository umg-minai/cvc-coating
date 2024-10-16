GUIX:=/usr/local/bin/guix
GUIXTME:=${GUIX} time-machine --channels=../guix/channels.pinned.scm -- \
		shell --manifest=../guix/manifest-ethics.scm
MD=$(wildcard *.md)
RMD=$(wildcard *.Rmd)
R=$(wildcard *.R)
OUTPUTDIR:=output
ODT=$(RMD:%.Rmd=$(OUTPUTDIR)/%.odt)
DOCX=$(RMD:%.Rmd=$(OUTPUTDIR)/%.docx)
PDF=$(MD:%.md=$(OUTPUTDIR)/%.pdf) $(R:%.R=$(OUTPUTDIR)/%.pdf)
DISTRIBUTIONDIR:=distribution
DISTRIBUTIONDOCX=$(wildcard $(DISTRIBUTIONDIR)/*.docx)
DISTRIBUTIONPDF=$(wildcard $(DISTRIBUTIONDIR)/*.pdf)
SUBMISSIONDIR:=submission
DATE=$(shell date +'%Y%m%d')

.DELETE_ON_ERROR:

all: $(ODT) $(PDF)

.PHONEY:
shell:
	${GUIXTME}

$(OUTPUTDIR):
	@mkdir -p $(OUTPUTDIR)

$(DISTRIBUTIONDIR):
	@mkdir -p $(DISTRIBUTIONDIR)

$(SUBMISSIONDIR):
	@mkdir -p $(SUBMISSIONDIR)

$(OUTPUTDIR)/%.odt: %.Rmd | $(OUTPUTDIR)
	${GUIXTME} -- Rscript -e "rmarkdown::render('$<', output_dir = '$(OUTPUTDIR)')"

$(OUTPUTDIR)/%.docx: $(OUTPUTDIR)/%.odt | $(OUTPUTDIR)
	${GUIXTME} libreoffice -- libreoffice --headless --convert-to docx $< --outdir $(OUTPUTDIR)

$(OUTPUTDIR)/%.pdf: %.md | $(OUTPUTDIR)
	${GUIXTME} pandoc -- pandoc $< --template=pandoc/templates/letter.tex --output $@

$(OUTPUTDIR)/%.pdf: %.R | $(OUTPUTDIR)
	${GUIXTME} -- Rscript $<

$(DISTRIBUTIONDIR)/%.pdf: $(OUTPUTDIR)/%.pdf | $(OUTPUTDIR)
	cp $< $(DISTRIBUTIONDIR)/$(basename $(notdir $<))_$(DATE)_$(shell git log -n 1 --pretty=format:%h -- $(notdir $(<:%.pdf=%.md))).pdf

$(DISTRIBUTIONDIR)/%.docx: $(OUTPUTDIR)/%.docx | $(DISTRIBUTIONDIR)
	if [ -f "checklists/$(basename $(notdir $<))-pre-submission-checklist.txt" ] ; then \
		../bin/ask-checklist.sh checklists/$(basename $(notdir $<))-pre-submission-checklist.txt ; \
		fi && cp $< $(DISTRIBUTIONDIR)/$(basename $(notdir $<))_$(DATE)_$(shell git log -n 1 --pretty=format:%h -- $(notdir $(<:%.docx=%.Rmd))).docx

$(SUBMISSIONDIR)/%.pdf: $(DISTRIBUTIONDIR)/%.pdf | $(SUBMISSIONDIR)
	cp $< $(SUBMISSIONDIR)/

$(SUBMISSIONDIR)/%.docx: $(DISTRIBUTIONDIR)/%.docx | $(SUBMISSIONDIR)
	${GUIXTME} libreoffice -- libreoffice --headless --convert-to pdf $< --outdir $(SUBMISSIONDIR)

.PHONEY:
dist: $(patsubst $(OUTPUTDIR)/%,$(DISTRIBUTIONDIR)/%,$(DOCX)) $(patsubst $(OUTPUTDIR)/%,$(DISTRIBUTIONDIR)/%,$(PDF)) | $(DISTRIBUTIONDIR)

.PHONEY:
submit: $(patsubst $(DISTRIBUTIONDIR)/%,$(SUBMISSIONDIR)/%,$(DISTRIBUTIONDOCX)) $(patsubst $(DISTRIBUTIONDIR)/%,$(SUBMISSIONDIR)/%,$(DISTRIBUTIONPDF)) | $(SUBMISSIONDIR)

.PHONEY:
FORCE:

.PHONEY:
clean: clean-dist clean-output

.PHONEY:
clean-output:
	@rm -rf $(OUTPUTDIR)

.PHONEY:
clean-dist:
	@rm -rf $(DISTRIBUTIONDIR)
