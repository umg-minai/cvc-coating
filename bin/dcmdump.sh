#!/bin/sh
# take from https://support.dcmtk.org/redmine/projects/dcmtk/wiki/Howto_CompareFiles

SCRIPT=$(readlink -f "${0}")
PROJECTDIR="$(dirname ${SCRIPT})/.."
GUIXTM="/usr/local/bin/guix time-machine --channels=${PROJECTDIR}/guix/channels.pinned.scm -- shell --manifest=${PROJECTDIR}/guix/manifest-dcm.scm -- "

if [ $# != 1 ]
then
  echo "usage: `basename $0` file1"
  exit 1
fi

${GUIXTM} dcmdump -q -dc "$1"