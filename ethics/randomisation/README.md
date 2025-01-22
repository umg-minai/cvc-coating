# Randomisation for CVC-Coating

## Boostrap on debian

```sh
sudo apt install make git guix
```

## Clone git repositories and create branch

```sh
git clone https://github.com/umg-minai/cvc-coating.git
cd cvc-coating/
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
git add --force ethics/randomisation/*.csv
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

## Codebook

### `ethics/randomisation/randomisation_table_groups.csv`

Used for blinded *per-protocol* analysis after finishing the data collection.

- id: randomisation/patient id.
- group: group/treatment identifier, "A" or "B".

### `ethics/randomisation/randomisation_table_unblinded.csv`

Used for final conclusion and unblinding.

- id: randomisation/patient id.
- stratum: selected stratum (sex and surgery/organ).
- block.id: id of the randomisation block.
- block.size: size of the current randomisation block.
- treatment: randomised treatment.
- group: group/treatment identifier, "A" or "B", same as in
  `randomisation_table_unblinded.csv`.
