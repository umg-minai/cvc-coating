#!/bin/bash
# Run through a checklist and ask yes/no questions
#
#
# argument: filename for checklist

# argument question
function yesno() {
  echo "${1}"
  select yn in "yes" "no"; do
    case $yn in
      yes ) break;;
      no ) exit 1;;
    esac
  done
  return 0
}

# argument filename
function read_checklist() {
  # select requires the stdin file descriptor (fd),
  # so we need to use another one
  # open fd
  exec {FD}<"${1}"
  while IFS= read -r -u "${FD}" line ; do yesno "${line}"; done
  # close fd
  exec {FD}<&-
}

read_checklist "${1}"
