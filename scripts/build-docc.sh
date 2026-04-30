#!/usr/bin/env bash
set -eux

TEMP_DIR="$(pwd)/temp"
TEMPLATE_VERSION="release/6.3"

cleanup()
{
    if [ -n "$TEMP_DIR" ]; then
        rm -rf "${TEMP_DIR:?}"
    fi
}
trap cleanup exit $?

DOCC=${DOCC:-}
if [[ -z "$DOCC" ]]; then
    if [[ "$(uname)" == "Darwin" ]]; then
        DOCC=$(xcrun --find docc)
    else
        DOCC=$(which docc)
    fi
fi
echo "Found docc here ${DOCC}"

HUMMINGBIRD_VERSION=${HUMMINGBIRD_VERSION:-""}
SG_FOLDER=.build/symbol-graphs
HB_SG_FOLDER=.build/hummingbird-symbol-graphs
BASE_OUTPUT_PATH=docs
OUTPUT_PATH=$BASE_OUTPUT_PATH/$HUMMINGBIRD_VERSION

BUILD_SYMBOLS=1
WARNINGS_AS_ERRORS=""
while getopts 'se' option
do
    case $option in
        s) BUILD_SYMBOLS=0;;
        e) WARNINGS_AS_ERRORS="--warnings-as-errors";;
        *) echo "Usage build-docc.sh [-s]"; exit 1;
    esac
done

if [ -z "${DOCC_HTML_DIR:-}" ]; then
    git submodule update --init --recursive
    pushd scripts/swift-docc-render-artifact
    git fetch
    git checkout "$TEMPLATE_VERSION"
    export DOCC_HTML_DIR="./scripts/swift-docc-render-artifact/dist"
    popd
fi

# Build documentation
mkdir -p "$OUTPUT_PATH"
rm -rf "${OUTPUT_PATH:?}"/*
swift package --allow-writing-to-directory "$OUTPUT_PATH" \
    generate-documentation \
    --transform-for-static-hosting \
    --hosting-base-path /"$HUMMINGBIRD_VERSION" \
    --output-path "$OUTPUT_PATH" \
    $WARNINGS_AS_ERRORS \
    --hosting-base-path /"$HUMMINGBIRD_VERSION" \
    --enable-experimental-combined-documentation \
    --target HummingbirdDocs --target Hummingbird --target HummingbirdCore --target HummingbirdTLS --target HummingbirdHTTP2 --target HummingbirdTesting \
    --target HummingbirdAuth --target HummingbirdBasicAuth --target HummingbirdBcrypt --target HummingbirdOTP \
    --target HummingbirdWebSocket --target WSClient --target WSCore --target WSCompression \
    --target HummingbirdCompression \
    --target Mustache \
    --target Jobs --target JobsPostgres --target JobsValkey

# copy root files template to docs file
rsync -trv scripts/docsTemplate/* $BASE_OUTPUT_PATH