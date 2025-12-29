#!/bin/sh
# take from https://support.dcmtk.org/redmine/projects/dcmtk/wiki/Howto_CompareFiles

SCRIPT=$(readlink -f "${0}")
PROJECTDIR="$(dirname ${SCRIPT})/.."
GUIXTM="/usr/local/bin/guix time-machine --channels=${PROJECTDIR}/guix/channels.pinned.scm -- shell --manifest=${PROJECTDIR}/guix/manifest-dcm.scm -- "

if [ $# != 2 ]
then
  echo "usage: `basename $0` file1 file2"
  exit 1
fi

TMPFILE1=/tmp/`basename $0`.$$.`basename "$1"`
TMPFILE2=/tmp/`basename $0`.$$.`basename "$2"`

${GUIXTM} dcmdump -q -dc "$1" >"$TMPFILE1" 2>&1
${GUIXTM} dcmdump -q -dc "$2" >"$TMPFILE2" 2>&1
colordiff -au "$TMPFILE1" "$TMPFILE2"

rm "$TMPFILE1" "$TMPFILE2"

exit 0