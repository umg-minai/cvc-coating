GUIX:=/usr/local/bin/guix
GUIXTM:=${GUIX} time-machine --channels=guix/channels.pinned.scm -- \
		shell --manifest=guix/manifest.scm
GUIXTME:=${GUIX} time-machine --channels=guix/channels.pinned.scm -- \
		shell --manifest=guix/manifest-ethics.scm
DATE=$(shell date +'%Y%m%d')
GITHEAD=$(shell git rev-parse --short HEAD)
GITHEADL=$(shell git rev-parse HEAD)

.DELETE_ON_ERROR:

.PHONEY: \
	clean \
	guix-pin-channels

## pinning guix channels to latest commits
guix-pin-channels: guix/channels.pinned.scm

guix/channels.pinned.scm: guix/channels.scm FORCE
	${GUIX} time-machine --channels=guix/channels.scm -- \
		describe -f channels > guix/channels.pinned.scm

.PHONEY:
shell:
	${GUIX} time-machine --channels=guix/channels.pinned.scm -- \
		shell --manifest=guix/manifest.scm

.PHONEY:
pilot-rewrite-dicom-ids:
	${GUIX} time-machine --channels=guix/channels.pinned.scm -- \
		shell --manifest=guix/manifest-dcm.scm -- \
		bash bin/rewrite-dicom-ids.bash images/ultrasound/pilot/dicom

.PHONEY:
randomise:
	${GUIXTME} -- Rscript --vanilla ethics/randomisation/blockrand.R

FORCE:

clean:
