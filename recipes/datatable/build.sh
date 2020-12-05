#!/bin/bash

set -euo pipefail

{

cat >fake-git <<'EOF'
#!/bin/bash

if [ "$1" == "show" ]; then
  date +%s
else
  echo "FAKE_BUILD_INFO_FOR_CONDA"
fi
EOF

chmod +x fake-git
mv fake-git git
echo 0.11.0 >VERSION.txt
env PATH=.:"$PATH" "$PYTHON" ci/ext.py build
env PATH=.:"$PATH" "$PYTHON" -m pip install . -vv
mv git fake-git
}
