#!/bin/bash
set -o errexit -o pipefail

DICOMDIR=${1}
DICOMSUBDIR=GEMS_IMG
DCMDUMP="dcmdump --load-short --read-file-only"

if [ ! -d "${DICOMDIR}/${DICOMSUBDIR}" ] ; then
  echo "Directory ${DICOMDIR}/${DICOMSUBDIR} doesn't exist"
  exit 1
fi

extract_value() {
  # Extract content between [...] from dcmdump output line
  sed -n 's/^[^[]*\[\(.*\)\].*/\1/p' <<< "${1}"
}

cd "${DICOMDIR}"

for DICOMFILE in $(find ${DICOMSUBDIR} -type f,l | sort); do
  DUMP=$(${DCMDUMP} --search PatientID --search PatientName --search StudyID "${DICOMFILE}" 2>/dev/null || true)
  DUMP_LO=$(grep -m1 -F '(0010,0020)' <<< "${DUMP}" || true)
  DUMP_PN=$(grep -m1 -F '(0010,0010)' <<< "${DUMP}" || true)
  DUMP_SH=$(grep -m1 -F '(0020,0010)' <<< "${DUMP}" || true)

  LO=$(extract_value "${DUMP_LO}")
  PN=$(extract_value "${DUMP_PN}")
  SH=$(extract_value "${DUMP_SH}")

  if [[ "${LO}" == 0000* ]] && [[ "${PN}" == *^* ]] ; then
    echo "  $(dirname "${DICOMFILE}")  SH=[${SH}]  LO=[${LO}]  PN=[${PN}]"
  fi
done
