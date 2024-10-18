GUIX:=/usr/local/bin/guix
GUIXTME:=${GUIX} time-machine --channels=../guix/channels.pinned.scm -- \
		shell --manifest=../guix/manifest-ethics.scm
MD=$(filter-out README.md,$(wildcard *.md))
RMD=$(wildcard *.Rmd)
R=$(wildcard *.R)
OUTPUTDIR:=output
ODT=$(RMD:%.Rmd=$(OUTPUTDIR)/%.odt)
PDF=$(MD:%.md=$(OUTPUTDIR)/%.pdf) $(R:%.R=$(OUTPUTDIR)/%.pdf)
DISTRIBUTIONDIR:=distribution
# we rename files with git hash, so we have to determine filenames dynamically
DISTRIBUTIONODT=$(wildcard $(DISTRIBUTIONDIR)/*.odt)
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

$(OUTPUTDIR)/%.pdf: %.md | $(OUTPUTDIR)
	${GUIXTME} pandoc -- pandoc $< --template=pandoc/templates/letter.tex --output $@

$(OUTPUTDIR)/%.pdf: %.R | $(OUTPUTDIR)
	${GUIXTME} -- Rscript $<

$(DISTRIBUTIONDIR)/%.pdf: $(OUTPUTDIR)/%.pdf | $(DISTRIBUTIONDIR)
	cp $< $(DISTRIBUTIONDIR)/$(basename $(notdir $<))_$(DATE)_$(shell git log -n 1 --pretty=format:%h -- $(notdir $(<:%.pdf=%.*))).pdf

$(DISTRIBUTIONDIR)/%.odt: $(OUTPUTDIR)/%.odt | $(DISTRIBUTIONDIR)
	if [ -f "checklists/$(basename $(notdir $<))-pre-submission-checklist.txt" ] ; then \
		../bin/ask-checklist.sh checklists/$(basename $(notdir $<))-pre-submission-checklist.txt ; \
		fi && cp $< $(DISTRIBUTIONDIR)/$(basename $(notdir $<))_$(DATE)_$(shell git log -n 1 --pretty=format:%h -- $(notdir $(<:%.odt=%.Rmd))).odt

$(DISTRIBUTIONDIR)/%.docx: %.docx | $(DISTRIBUTIONDIR)
	cp $< $(DISTRIBUTIONDIR)/$(basename $(notdir $<))_$(DATE)_$(shell git log -n 1 --pretty=format:%h -- $(notdir $<)).docx

$(SUBMISSIONDIR)/%.pdf: $(DISTRIBUTIONDIR)/%.pdf | $(SUBMISSIONDIR)
	cp $< $(SUBMISSIONDIR)/

$(SUBMISSIONDIR)/%.pdf: $(DISTRIBUTIONDIR)/%.docx | $(SUBMISSIONDIR)
	${GUIXTME} libreoffice -- libreoffice --headless --convert-to pdf $< --outdir $(SUBMISSIONDIR)

$(SUBMISSIONDIR)/%.pdf: $(DISTRIBUTIONDIR)/%.odt | $(SUBMISSIONDIR)
	${GUIXTME} libreoffice -- libreoffice --headless --convert-to pdf $< --outdir $(SUBMISSIONDIR)

.PHONEY:
dist: $(ODT:$(OUTPUTDIR)/%.odt=$(DISTRIBUTIONDIR)/%.odt) $(PDF:$(OUTPUTDIR)/%.pdf=$(DISTRIBUTIONDIR)/%.pdf) $(DISTRIBUTIONDIR)/$(wildcard *.docx) | $(DISTRIBUTIONDIR)

.PHONEY:
submit: $(DISTRIBUTIONODT:$(DISTRIBUTIONDIR)/%.odt=$(SUBMISSIONDIR)/%.pdf) $(DISTRIBUTIONDOCX:$(DISTRIBUTIONDIR)/%.docx=$(SUBMISSIONDIR)/%.pdf) $(DISTRIBUTIONPDF:$(DISTRIBUTIONDIR)/%.pdf=$(SUBMISSIONDIR)/%.pdf) | $(SUBMISSIONDIR)

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
