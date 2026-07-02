#!/bin/bash
set -o errexit -o pipefail

DICOMSUBDIR=GEMS_IMG

usage() {
  echo "usage: $(basename "${0}") [--delete] <dicomdir>"
  echo "  lists non-study DICOM directories under <dicomdir>/${DICOMSUBDIR}"
  echo "  --delete  remove the listed directories after printing them"
}

DELETE=0
DICOMDIR=

while [ $# -gt 0 ]; do
  case "${1}" in
    --delete) DELETE=1 ;;
    -h|--help) usage; exit 0 ;;
    *) DICOMDIR=${1} ;;
  esac
  shift
done

# mislabeled exports that have been re-exported under the correct ID
BLACKLIST=(
  "GEMS_IMG/2026_APR/23/_W162021" # was incorrectly labelled as WP07-02; is ML07-02
)

if [ ! -d "${DICOMDIR}/${DICOMSUBDIR}" ] ; then
  echo "Directory ${DICOMDIR}/${DICOMSUBDIR} doesn't exist"
  exit 1
fi

is_blacklisted() {
  local file="${1}"
  for entry in "${BLACKLIST[@]}"; do
    [[ "${file}" == "${entry}"* ]] && return 0
  done
  return 1
}

extract_value() {
  # content between the first [ and the last ], via parameter expansion only
  local v="${1#*[}"
  printf '%s' "${v%]*}"
}

cd "${DICOMDIR}"

# seen maps a matched directory to its formatted report line; it doubles as the
# dedup set (one entry per directory rather than one per file).
declare -A seen
file= lo= pn= sh=

emit() {
  [[ -z "${file}" ]] && return
  local dir="${file%/*}"
  local reason=
  if [[ "${lo}" == 0000* ]] && [[ "${pn}" == *^* ]]; then
    reason=id-mismatch
  fi
  if is_blacklisted "${file}"; then
    reason=${reason:+${reason},}blacklisted
  fi
  if [[ -n "${reason}" ]] && [[ -z "${seen["${dir}"]:-}" ]]; then
    seen["${dir}"]=$(printf '  %s  [%s]  SH=[%s]  LO=[%s]  PN=[%s]' \
      "${dir}" "${reason}" "${sh}" "${lo}" "${pn}")
  fi
}

# A single recursive dcmdump processes the whole tree in one process instead of
# spawning one dcmdump per file. --print-file-search prefixes every matched file
# with a "# dcmdump (N): <path>" header, which the loop uses to group tag values.
while IFS= read -r line; do
  case "${line}" in
    '# dcmdump ('*'): '*)
      emit
      file="${line#*): }"
      lo= pn= sh= ;;
    '(0010,0020)'*) [[ -z "${lo}" ]] && lo=$(extract_value "${line}") ;;
    '(0010,0010)'*) [[ -z "${pn}" ]] && pn=$(extract_value "${line}") ;;
    '(0020,0010)'*) [[ -z "${sh}" ]] && sh=$(extract_value "${line}") ;;
  esac
done < <(dcmdump --load-short --read-file-only --quiet \
    --scan-directories --recurse --print-file-search \
    --search PatientID --search PatientName --search StudyID \
    "${DICOMSUBDIR}" 2>/dev/null)
emit

# sorted list of matched directories for stable output and deletion order
dirs=()
if [ "${#seen[@]}" -gt 0 ]; then
  mapfile -t dirs < <(printf '%s\n' "${!seen[@]}" | sort)
fi

for dir in "${dirs[@]}"; do
  printf '%s\n' "${seen["${dir}"]}"
done

if [ "${DELETE}" -eq 1 ]; then
  for dir in "${dirs[@]}"; do
    rm -rf -- "${dir}"
    echo "deleted ${dir}"
  done
fi
