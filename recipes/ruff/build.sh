set -ex

# Set conda CC as custom CC in Rust
export CARGO_TARGET_X86_64_UNKNOWN_LINUX_GNU_LINKER=$CC

# Print Rust version
rustc --version

# Install cargo-bundle-licenses
export CARGO_HOME="$BUILD_PREFIX/cargo"
mkdir $CARGO_HOME
cargo install cargo-bundle-licenses

# Bundle all downstream library licenses
cargo-bundle-licenses \
  --format yaml \
  --output ${SRC_DIR}/THIRDPARTY.yml

# Apply PEP517 to install the package
maturin build --release -i $PYTHON

cd target/wheels

# Install wheel manually
$PYTHON -m pip install *.whl
