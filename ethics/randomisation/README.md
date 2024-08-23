# Randomisation for CRT-CHX

## Boostrap on debian

```sh
sudo apt install make git guix
```

## Clone git repositories and create branch

```sh
git clone https://github.com/umg-minai/crt-chx.git
cd crt-chx/
git checkout -b randomisation
```

## Randomisation

**IMPORTANT:** Edit *seed* in `ethics/randomisation/blockrand.R` or use the
following command (please replace `SEED_TO_BE_CHANGED` with your chosen seed).

```sh
export SEEDCRT=SEED_TO_BE_CHANGED
sed -i 's#set\.seed(20240220)$#set.seed('${SEEDCRT}')#' ethics/randomisation/blockrand.R
```

Add change to *randomisation* branch.

```sh
git add ethics/randomisation/blockrand.R
git commit -m "feat: set seed for randomisation"
```

Actually run the randomisation:

```sh
make randomise
```

Add randomisation tables to *randomisation* branch.

```sh
git add ethics/randomisation/*.csv
git commit -m "feat: add randomisation tables"
```

Print and backup the `ethics/randomisation/*.csv` files at a save place.

Please also backup the chosen *seed*.

Send the `ethics/randomisation/randomisation_cards.pdf` file for printing and
enveloping.

Go back to the *main* branch:

```sh
git checkout main
```

**IMPORTANT:** Don't push the *randomisation* branch to the origin (github) now.

**REMINDER:** For reproducibility please push the *randomisation* branch and
create a pull request after the analysis finished.
