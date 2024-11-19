#!/usr/bin/env bash
set -eux

TEMP_DIR="$(pwd)/temp"

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
    git clone https://github.com/apple/swift-docc-render-artifact "$TEMP_DIR"/swift-docc-render-artifact
     export DOCC_HTML_DIR="$TEMP_DIR/swift-docc-render-artifact/dist"
fi

if test "$BUILD_SYMBOLS" == 1; then
    # build symbol graphs
    mkdir -p $SG_FOLDER
    swift build \
        -Xswiftc -emit-symbol-graph \
        -Xswiftc -emit-symbol-graph-dir -Xswiftc $SG_FOLDER
    # Copy Hummingbird symbol graph into separate folder
    mkdir -p $HB_SG_FOLDER
    cp $SG_FOLDER/Hummingbird* $HB_SG_FOLDER
    cp $SG_FOLDER/Mustache* $HB_SG_FOLDER
    cp $SG_FOLDER/Jobs* $HB_SG_FOLDER
    cp $SG_FOLDER/PostgresMigrations* $HB_SG_FOLDER
    #rm $HB_SG_FOLDER/*@*
fi

# Build documentation
mkdir -p "$OUTPUT_PATH"
rm -rf "${OUTPUT_PATH:?}"/*
$DOCC convert Hummingbird.docc \
    --transform-for-static-hosting \
    --hosting-base-path /"$HUMMINGBIRD_VERSION" \
    --fallback-display-name Hummingbird \
    --fallback-bundle-identifier com.opticalaberration.hummingbird \
    --fallback-bundle-version 1 \
    --additional-symbol-graph-dir $HB_SG_FOLDER \
    --output-path "$OUTPUT_PATH" \
    $WARNINGS_AS_ERRORS \
    --hosting-base-path /"$HUMMINGBIRD_VERSION"
# copy root files template to docs file
rsync -trv scripts/docsTemplate/* $BASE_OUTPUT_PATH