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
DISTRIBUTIONODT=$(wildcard $(DISTRIBUTIONDIR)/*.odt)
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

$(DISTRIBUTIONDIR)/%.pdf: $(OUTPUTDIR)/%.pdf | $(OUTPUTDIR)
	cp $< $(DISTRIBUTIONDIR)/$(basename $(notdir $<))_$(DATE)_$(shell git log -n 1 --pretty=format:%h -- $(notdir $(<:%.pdf=%.*))).pdf

$(DISTRIBUTIONDIR)/%.odt: $(OUTPUTDIR)/%.odt | $(DISTRIBUTIONDIR)
	if [ -f "checklists/$(basename $(notdir $<))-pre-submission-checklist.txt" ] ; then \
		../bin/ask-checklist.sh checklists/$(basename $(notdir $<))-pre-submission-checklist.txt ; \
		fi && cp $< $(DISTRIBUTIONDIR)/$(basename $(notdir $<))_$(DATE)_$(shell git log -n 1 --pretty=format:%h -- $(notdir $(<:%.docx=%.Rmd))).odt

$(SUBMISSIONDIR)/%.pdf: $(DISTRIBUTIONDIR)/%.pdf | $(SUBMISSIONDIR)
	cp $< $(SUBMISSIONDIR)/

$(SUBMISSIONDIR)/%.pdf: $(DISTRIBUTIONDIR)/%.odt | $(SUBMISSIONDIR)
	${GUIXTME} libreoffice --headless --convert-to pdf $< --outdir $(SUBMISSIONDIR)

.PHONEY:
dist: $(patsubst $(OUTPUTDIR)/%,$(DISTRIBUTIONDIR)/%,$(ODT)) $(patsubst $(OUTPUTDIR)/%,$(DISTRIBUTIONDIR)/%,$(PDF)) | $(DISTRIBUTIONDIR)

.PHONEY:
submit: $(patsubst $(DISTRIBUTIONDIR)/%,$(SUBMISSIONDIR)/%,$(DISTRIBUTIONODT)) $(patsubst $(DISTRIBUTIONDIR)/%,$(SUBMISSIONDIR)/%,$(DISTRIBUTIONPDF)) | $(SUBMISSIONDIR)

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
