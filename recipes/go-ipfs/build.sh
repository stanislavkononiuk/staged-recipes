#!/usr/bin/env bash
set -eux

export GOPATH="$( pwd )"
export CGO_ENABLED=1

module='github.com/ipfs/go-ipfs'

make -C "src/${module}" \
  install \
  GOTAGS=openssl

gather_licenses() {
  # shellcheck disable=SC2039  # Allow widely supported non-POSIX local keyword.
  local module output tmp_dir acc_dir
  output="${1}"
  shift
  tmp_dir="$(pwd)/gather-licenses-tmp"
  acc_dir="$(pwd)/gather-licenses-acc"
  mkdir "${acc_dir}"
  cat > "${output}" <<'EOF'
--------------------------------------------------------------------------------
The output below is generated with `go-licenses csv` and `go-licenses save`.
================================================================================
EOF
  for module ; do
    cat >> "${output}" <<EOF
go-licenses csv ${module}
================================================================================
EOF
    go get -d "${module}"
    chmod -R +rw "$( go env GOPATH )"
    go-licenses csv "${module}" | sort >> "${output}"
    go-licenses save "${module}" --force --save_path="${tmp_dir}"
    cp -r "${tmp_dir}"/* "${acc_dir}"/
  done
  # shellcheck disable=SC2016  # Not expanding $ in single quotes intentional.
  find "${acc_dir}" -type f | sort | xargs -L1 sh -c '
cat <<EOF
--------------------------------------------------------------------------------
${2#${1%/}/}
================================================================================
EOF
cat "${2}"
' -- "${acc_dir}" >> "${output}"
  rm -r "${acc_dir}" "${tmp_dir}"
}

# gather_licenses ./third-party-licenses.txt "${module}/cmd/ipfs"
