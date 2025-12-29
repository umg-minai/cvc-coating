# CVC-Coating: Catheter-related thrombosis in central venous catheter coated with/without chlorhexidine

[![Project Status: WIP – Initial development is in progress, but there has not yet been a stable, usable release suitable for the public.](https://www.repostatus.org/badges/latest/wip.svg)](https://www.repostatus.org/#wip)

We use [guix](https://guix.gnu.org) to ensure an reproducible computing environment.

## Bootstrap

### Guix on debian

```bash
sudo apt install make git git-annex guix
```

### Fetch sources

```bash
git clone git@github.com:umg-minai/crt-chx.git
```

### Build manuscript

Running `make` the first time will take some time because
`guix` hast to download the given state and build the image.

```bash
make
```

### Modify the manuscript

All the work has to be done in the `sections/*.Rmd` files.

### Make targets

- `make shell` create reproducible environment (`guix shell` with specific
  parameters).
- `make clean` removes all generated files.


## Initial setup

### Init git-annex

https://git-annex.branchable.com/

```bash
WEBDAV_USERNAME=xxx WEBDAV_PASSWORD=xxx git annex initremote uni-greifswald-nextcloud type=webdav url=https://nextcloud.uni-greifswald.de/remote.php/dav/files/gibbs/9726.crt-chx/git-annex chunk=10mb encryption=none

git annex initremote ant type=rsync rsyncurl=antl:/media/wd/cvc-coating/git-annex chunk=10mb encryption=none
```

### Install DICOM viewer

https://weasis.org

```bash
wget https://github.com/nroduit/Weasis/releases/download/v4.6.6/weasis_4.6.6-1_amd64.deb
wget https://github.com/nroduit/Weasis/releases/download/v4.6.6/weasis_4.6.6-1_amd64.deb.sha256
sha256sum -c weasis_4.6.6-1_amd64.deb.sha256
sudo dpkg -i weasis_4.6.6-1_amd64.deb
```

## Usage

### Update DICOMDIR files

Fix different named IDs and update DICOMDIR file.

```bash
make rewrite-dicom-ids
```

#### Troubleshooting

Sometimes duplicated SOPInstanceUIDs appear:

```
W: file GEMS_IMG/2025_OCT/18/__19116/PAIJ2DG6: directory record for this SOP instance already exists
```

Find duplicated files:

```bash
bin/dcmdup.sh GEMS_IMG/2025_OCT/18/__19116/PAIJ2DG6
```

Compare the duplicated files:

```bash
bin/dcmdiff.sh GEMS_IMG/2025_OCT/18/JD190116/PAIJ2BO2 GEMS_IMG/2025_OCT/18/__19116/PAIJ2DG6
```

### Use git annex

```bash
git annex add largefiles
git commit -m "what was done"
git annex sync --content # to publish the files on the remotes
```

## Predecessor study

https://umg-minai.github.io/crt/

## Contact/Contribution

You are welcome to:

- submit suggestions and bug-reports at: <https://github.com/umg-minai/cvc-coating/issues>
- send a pull request on: <https://github.com/umg-minai/cvc-coating/>
- compose an e-mail to: <mail@sebastiangibb.de>

We try to follow:

- [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/)
- [Semantic Line Breaks](https://sembr.org/)