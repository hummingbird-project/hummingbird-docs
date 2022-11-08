#!/usr/bin/env bash
# Old script you should use `build-docc.sh`
set -eux

mkdir -p .build/symbol-graphs

swift build \
    -Xswiftc -emit-symbol-graph \
    -Xswiftc -emit-symbol-graph-dir -Xswiftc .build/symbol-graphs

export DOCC_JSON_PRETTYPRINT=YES
if [ ! -d .build/swift-docc-render-artifact ]; then
    git clone --depth 1 https://github.com/apple/swift-docc-render-artifact .build/swift-docc-render-artifact
fi
export DOCC_HTML_DIR=$(pwd)/.build/swift-docc-render-artifact/dist

docc convert Hummingbird.docc \
    --output-path ./docs \
    --fallback-display-name Hummingbird \
    --fallback-bundle-identifier com.opticalaberration.hummingbird \
    --fallback-bundle-version 0.16.0 \
    --additional-symbol-graph-dir .build/symbol-graphs \
    --emit-digest \
    --transform-for-static-hosting

