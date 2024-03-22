#!/usr/bin/env bash
set -eu

function text.count() {
    grep -o "$1" | wc -l
}

URL_PREFIX=https://docs.hummingbird.codes
HUMMINGBIRD_VERSION=${HUMMINGBIRD_VERSION:-""}
if [[ -z $HUMMINGBIRD_VERSION ]]; then
    DOCUMENTATION_PATH="documentation"
else
    DOCUMENTATION_PATH="$HUMMINGBIRD_VERSION/documentation"
fi
BASE_PATH=docs/

pushd "$BASE_PATH"

FILES=$(find "$DOCUMENTATION_PATH" -name 'index.html' -print)

cat > sitemap.xml << EOF
<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
EOF

slashCount=$(echo "$DOCUMENTATION_PATH" | text.count "/")
minSlashes=$(($slashCount + 2))

for FILE in $FILES; do
    URL=$(echo "${FILE%index.html}" | sed 's/:/%3A/g')
    # work out priority, by counting slashes in filename, subtract the minimum
    # number of slashes, calculate 2 to the power of the resulting number and
    # invert it
    slashCount=$(echo "$FILE" | text.count "/")
    slashCount=$(($slashCount - $minSlashes))
    slashCount=$(($slashCount>0 ? $slashCount : 0))
    # only include pages which are modules or top level types
    if [ "$slashCount" -lt 2 ]; then
        # Give Hummingbird page higher priority than anything else
        if [[ "$URL" == */hummingbird/ ]]; then
            priority=1.0
        else
            inv_priority=$((2 ** $slashCount))
            priority=$(bc <<< "scale=2; 0.8/$inv_priority" )
        fi
        DATE=$(date -r "$FILE" "+%Y-%m-%d")
        cat >> sitemap.xml << EOF
  <url>
    <loc>$URL_PREFIX/$URL</loc>
    <lastmod>$DATE</lastmod>
    <priority>$priority</priority>
  </url>
EOF
    fi
done   
cat >> sitemap.xml << EOF
</urlset>
EOF
popd