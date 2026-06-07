#!/bin/bash
set -o errexit -o pipefail

DICOMDIR=${1}
DICOMSUBDIR=GEMS_IMG

if [ ! -d "${DICOMDIR}/${DICOMSUBDIR}" ] ; then
  echo "Directory ${DICOMDIR}/${DICOMSUBDIR} doesn't exists"
  exit 1
fi

extract() {
  echo "${1}" | sed '/^.*\([[:alpha:]]\{2,3\}[0-9][0-9][-_.]\{1,2\}d\?[0-9]\{1,2\}[^]]*\)(\?.*$/!d; s//\1/'
}

normalize() {
  echo "${1}" | sed 's#[-_.]\+#-#; s#^\(.*\)$#\U\1#; s#-D#-#; s#-\([0-9]\)$#-0\1#; s#(.*$##'
}

# map a GEMS_IMG month abbreviation (APR, FEB, ...) to a sortable number
month_num() {
  case "${1}" in
    JAN) echo 01 ;; FEB) echo 02 ;; MAR) echo 03 ;; APR) echo 04 ;;
    MAY) echo 05 ;; JUN) echo 06 ;; JUL) echo 07 ;; AUG) echo 08 ;;
    SEP) echo 09 ;; OCT) echo 10 ;; NOV) echo 11 ;; DEC) echo 12 ;;
    *)   echo 00 ;;
  esac
}

# list files in chronological order based on the GEMS_IMG/<YYYY>_<MON>/<DD>/...
# directory layout (alphabetical sort would order APR before FEB)
sorted_files() {
  local f comps
  while IFS= read -r f; do
    IFS='/' read -r -a comps <<< "${f}"
    printf '%s%s%s\t%s\n' \
      "${comps[1]%_*}" "$(month_num "${comps[1]#*_}")" "${comps[2]}" "${f}"
  done < <(find "${DICOMSUBDIR}" -type f,l) | sort | cut -f2-
}

cd "${DICOMDIR}"

# Read PatientID/PatientName/StudyID for the whole tree in a single recursive
# dcmdump pass instead of spawning one dcmdump per file. --print-file-search
# emits a "# dcmdump (N): <path>" header before each matched file's tag lines;
# only the first occurrence of a repeated tag is kept (as grep -m1 did before).
declare -A ID_LINE PN_LINE SD_LINE
file=
while IFS= read -r line; do
  case "${line}" in
    '# dcmdump ('*'): '*) file="${line#*): }" ;;
    '(0010,0020)'*) [[ -n ${file} && -z ${ID_LINE[$file]+x} ]] && ID_LINE[$file]=${line} ;;
    '(0010,0010)'*) [[ -n ${file} && -z ${PN_LINE[$file]+x} ]] && PN_LINE[$file]=${line} ;;
    '(0020,0010)'*) [[ -n ${file} && -z ${SD_LINE[$file]+x} ]] && SD_LINE[$file]=${line} ;;
  esac
done < <(dcmdump --load-short --read-file-only --quiet \
    --scan-directories --recurse --print-file-search \
    --search PatientID --search PatientName --search StudyID \
    "${DICOMSUBDIR}" 2>/dev/null)

while IFS= read -r DICOMFILE; do
  DUMPID=${ID_LINE[$DICOMFILE]:-}
  DUMPPN=${PN_LINE[$DICOMFILE]:-}
  DUMPSD=${SD_LINE[$DICOMFILE]:-}

  OID=$(extract "${DUMPID}")
  OPN=$(extract "${DUMPPN}")
  OSD=$(extract "${DUMPSD}")
  ID=$(normalize "${OID}")
  PN=$(normalize "${OPN}")
  SD=$(normalize "${OSD}")

  if [ -z "${SD}" -a -z "${ID}" -a -z "${PN}" ] ; then
    echo "${DICOMFILE}: error - neither StudyID, PatientID nor PatientName valid"
    echo "${DICOMFILE}:"
    echo "SD: ${DUMPSD}"
    echo "ID: ${DUMPID}"
    echo "PN: ${DUMPPN}"
    exit 1
  elif [ -z "${PN}" -a -z "${SD}" ] ; then
    # ID valid
    SD=${ID}
  elif [ -z "${ID}" -a -z "${SD}" ] ; then
    # PN valid
    SD=${PN}
  fi

  ID="${SD%%-*}"

  if [ "${OSD}" = "${SD}" ] ; then
    echo "${DICOMFILE}: [ ] keep ${ID}/${SD}"
  else
    echo "${DICOMFILE}: [M] set ${ID}/${SD} (was ID:${OID}/PN:${OPN}/SD:${OSD})"
    dcmodify --erase-all PatientID --erase-all PatientName \
      --erase-all StudyID \
      --erase-private \
      --insert "(0010,0010)=${ID}" --insert "(0010,0020)=${ID}" \
      --insert "(0020,0010)=${SD}" \
      --no-backup ${DICOMFILE}
  fi
done < <(sorted_files)

echo "Rewrite ${DICOMDIR}/DICOMDIR"
dcmmkdir -Pum --keep-filenames --recurse --no-backup ${DICOMSUBDIR}
cd -
