#!/bin/bash
set -o errexit -o pipefail

DICOMDIR=${1}
DICOMSUBDIR=GEMS_IMG

if [ ! -d "${DICOMDIR}/${DICOMSUBDIR}" ] ; then
  echo "Directory ${DICOMDIR}/${DICOMSUBDIR} doesn't exists"
  exit 1
fi

cd ${DICOMDIR}

for DICOMFILE in $(find ${DICOMSUBDIR} -type f); do
  DUMPID=$(dcmdump --search PatientID --search-first ${DICOMFILE})
  DUMPPN=$(dcmdump --search PatientName --search-first ${DICOMFILE})
  OID=$(echo "${DUMPID}" | sed '/^.*\([[:alpha:]]\{2,3\}[0-9][0-9][-_]\{1,2\}d\?[0-9]\{1,2\}[^]]*\).*$/!d; s//\1/')
  OPN=$(echo "${DUMPPN}" | sed '/^.*\([[:alpha:]]\{2,3\}[0-9][0-9][-_]\{1,2\}d\?[0-9]\{1,2\}[^]]*\).*$/!d; s//\1/')
  ID=$(echo ${OID} | sed 's#[-_]\+#-#; s#^\(.*\)$#\U\1#; s#-D#-#; s#-\([0-9]\)$#-0\1#')
  PN=$(echo ${OPN} | sed 's#[-_]\+#-#; s#^\(.*\)$#\U\1#; s#-D#-#; s#-\([0-9]\)$#-0\1#')

  if [ -z "${ID}" -a -z "${PN}" ] ; then
    echo "${DICOMFILE}: error - neither ID nor Name valid"; exit 1
  elif [ -z "${PN}" ] ; then
    # ID valid
    PN=${ID}
  else
    # PN valid
    ID=${PN}
  fi

  if [ "${OID}" = "${ID}" -a "${OPN}" = "${PN}" ] ; then
    echo "${DICOMFILE}: [ ] keep ${ID}"
  else
    echo "${DICOMFILE}: [M] set ${ID} (before ID:${OID}/PN:${OPN})"
    dcmodify --erase-all PatientID --erase-all PatientName --erase-private \
      --insert "(0010,0010)=${PN}" --insert "(0010,0020)=${PN}" \
      --no-backup ${DICOMFILE}
  fi
done

echo "Rewrite ${DICOMDIR}/DICOMDIR"
dcmmkdir -Pum --keep-filenames --recurse --no-backup ${DICOMSUBDIR}
cd -
