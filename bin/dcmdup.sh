#!/bin/bash
# take from https://support.dcmtk.org/redmine/projects/dcmtk/wiki/Howto_CompareFiles
set -o errexit -o pipefail

SCRIPT=$(readlink -f "${0}")
PROJECTDIR="$(dirname $(dirname ${SCRIPT}))"
GUIXTM="/usr/local/bin/guix time-machine --channels=${PROJECTDIR}/guix/channels.pinned.scm -- shell --manifest=${PROJECTDIR}/guix/manifest-dcm.scm -- "

if [ $# != 1 ]
then
  echo "usage: `basename $0`"
  exit 1
fi


SOPID=$(${GUIXTM} \
  dcmdump --load-short --read-file-only \
  --search SOPInstanceUID --search-first "$1" | sed 's#.*\[\([0-9.]\+\)\].*#\1#')

${GUIXTM} \
  dcmdump --load-short --read-file-only --print-file-search \
  --scan-directories --recurse $(dirname $(dirname $(dirname $(dirname "$1")))) \
  --search SOPInstanceUID --quiet | fgrep -B1 "${SOPID}"