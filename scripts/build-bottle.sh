#!/bin/bash
set -euo pipefail

ARCHIVE_PATH="$1"
VERSION="$2"
FORMULA_NAME="$3"

STAGING_ROOT="$(mktemp -d)"
STAGING_DIR="${STAGING_ROOT}/${FORMULA_NAME}/${VERSION}"
mkdir -p "${STAGING_DIR}/bin"

echo "Extracting binaries from xcarchive..."
cp "${ARCHIVE_PATH}/Products/usr/local/bin/spice-vdagentd" "${STAGING_DIR}/bin/"
cp "${ARCHIVE_PATH}/Products/usr/local/bin/spice-vdagent" "${STAGING_DIR}/bin/"

echo "Clearing extended attributes..."
xattr -c "${STAGING_DIR}/bin/spice-vdagentd"
xattr -c "${STAGING_DIR}/bin/spice-vdagent"

echo "Ad-hoc code signing (no Developer ID required)..."
codesign --force --sign - \
  --identifier com.redhat.spice.vdagentd \
  "${STAGING_DIR}/bin/spice-vdagentd"
codesign --force --sign - \
  --identifier com.redhat.spice.vdagent \
  "${STAGING_DIR}/bin/spice-vdagent"

OS_TAG="sequoia"
BOTTLE_FILENAME="${FORMULA_NAME}--${VERSION}.${OS_TAG}.bottle.tar.gz"

echo "Creating bottle tarball: ${BOTTLE_FILENAME}"
echo "Staging dir: ${STAGING_DIR}"
ls -laR "${STAGING_ROOT}"
tar -czf "${BOTTLE_FILENAME}" -C "${STAGING_ROOT}" \
  "${FORMULA_NAME}/${VERSION}"

echo "Bottle created: ${BOTTLE_FILENAME}"
ls -lh "${BOTTLE_FILENAME}"

rm -rf "${STAGING_ROOT}"
