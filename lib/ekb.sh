#!/bin/bash

ekb_recreate_dir() {
  rm -rf $1
  mkdir -p $1
}

# Work around transient failures
ekb_retry() {
  local subcommand=${1:?No subcommand supplied to ${FUNCNAME}}
  local i=0
  local max_retries=10

  while ! "$@" && (( ++i < max_retries )) ; do
    echo "$@ failed; retrying..."
    sleep 1
  done

  if (( i >= max_retries )); then
    echo "$@ failed ${max_retries} times; giving up"
    exit 1
  fi
}

ekb_download_file() {
  local url=${1:?No url supplied to ${FUNCNAME}}
  local output=${2:?No output supplied to ${FUNCNAME}}

  local curl_args=(--retry-connrefused --retry 10 -L --output "${output}")

  if [ -e "${output}" ]; then
    ekb_retry curl "${curl_args[@]}" --time-cond "${output}" "${url}"
  else
    ekb_retry curl "${curl_args[@]}" "${url}"
  fi
}

# Compress a directory according to the configured compression type.
ekb_compress_dir() {
  pushd "${1}"
  case "${EKB_COMPRESSION}" in
    zip)
      zip --recurse-paths "${2}" .
      ;;
    *)
      echo "Unrecognized image compression ${EKB_COMPRESSION}" >&2
      return 1
      ;;
  esac
  popd
}

# Create a detached checksum with sha256sum. By default the target in
# the checksum file is the basename of the file being checksummed.
ekb_checksum() {
  local file=${1:?No file supplied to ${FUNCNAME}}
  local outfile=${2:-${file}.sha256}
  local target=${3:-${file##*/}}
  local checksum

  checksum=$(sha256sum "${file}" | cut -d' ' -f1)
  echo "${checksum}  ${target}" > "${outfile}"
}
