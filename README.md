# CRT-CHX: **C**atheter-**r**elated **t**hrombosis in central venous catheter coated with/without **ch**lorhe**x**idin.

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

https://git-annex.branchable.com/

### Init git-annex

```bash
WEBDAV_USERNAME=xxx WEBDAV_PASSWORD=xxx git annex initremote uni-greifswald-nextcloud type=webdav url=https://nextcloud.uni-greifswald.de/remote.php/dav/files/gibbs/9726.crt-chx/git-annex chunk=10mb encryption=none

git annex initremote ant type=rsync rsyncurl=rsync://antl/media/wd/crt-chx/git-annex chunk=10mb encryption=none
```

## Predecessor study

https://umg-minai.github.io/crt/

## Contact/Contribution

You are welcome to:

- submit suggestions and bug-reports at: <https://github.com/umg-minai/vct-or-mc/issues>
- send a pull request on: <https://github.com/umg-minai/vct-or-mc/>
- compose an e-mail to: <mail@sebastiangibb.de>

We try to follow:

- [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/)
- [Semantic Line Breaks](https://sembr.org/)