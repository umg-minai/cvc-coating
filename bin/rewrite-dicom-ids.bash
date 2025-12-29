#!/bin/bash
set -o errexit -o pipefail

DICOMDIR=${1}
DICOMSUBDIR=GEMS_IMG
DCMDUMP="dcmdump --load-short --read-file-only"

if [ ! -d "${DICOMDIR}/${DICOMSUBDIR}" ] ; then
  echo "Directory ${DICOMDIR}/${DICOMSUBDIR} doesn't exists"
  exit 1
fi

cd ${DICOMDIR}

for DICOMFILE in $(find ${DICOMSUBDIR} -type f,l); do
  DUMPID=$(${DCMDUMP} --search PatientID --search-first ${DICOMFILE})
  DUMPPN=$(${DCMDUMP} --search PatientName --search-first ${DICOMFILE})
  DUMPSD=$(${DCMDUMP} --search StudyID --search-first ${DICOMFILE})
  OID=$(echo "${DUMPID}" | sed '/^.*\([[:alpha:]]\{2,3\}[0-9][0-9][-_.]\{1,2\}d\?[0-9]\{1,2\}[^]]*\)(\?.*$/!d; s//\1/')
  OPN=$(echo "${DUMPPN}" | sed '/^.*\([[:alpha:]]\{2,3\}[0-9][0-9][-_.]\{1,2\}d\?[0-9]\{1,2\}[^]]*\)(\?.*$/!d; s//\1/')
  OSD=$(echo "${DUMPSD}" | sed '/^.*\([[:alpha:]]\{2,3\}[0-9][0-9][-_.]\{1,2\}d\?[0-9]\{1,2\}[^]]*\)(\?.*$/!d; s//\1/')
  ID=$(echo ${OID} | sed 's#[-_.]\+#-#; s#^\(.*\)$#\U\1#; s#-D#-#; s#-\([0-9]\)$#-0\1#')
  PN=$(echo ${OPN} | sed 's#[-_.]\+#-#; s#^\(.*\)$#\U\1#; s#-D#-#; s#-\([0-9]\)$#-0\1#')
  SD=$(echo ${OSD} | sed 's#[-_.]\+#-#; s#^\(.*\)$#\U\1#; s#-D#-#; s#-\([0-9]\)$#-0\1#')

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

  ID=$(echo ${SD} | cut -d- -f1)

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
done

echo "Rewrite ${DICOMDIR}/DICOMDIR"
dcmmkdir -Pum --keep-filenames --recurse --no-backup ${DICOMSUBDIR}
cd -