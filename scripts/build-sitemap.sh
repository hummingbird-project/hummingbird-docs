#!/usr/bin/env bash
set -eu

function text.count() {
    grep -o "$1" | wc -l
}

URL_PREFIX=https://hummingbird-project.github.io/hummingbird-docs
HUMMINGBIRD_VERSION=${HUMMINGBIRD_VERSION:-""}
if [[ -z $HUMMINGBIRD_VERSION ]]; then
    DOCUMENTATION_PATH="documentation"
else
    DOCUMENTATION_PATH="$HUMMINGBIRD_VERSION/documentation"
fi
BASE_PATH=docs/hummingbird-docs/

pushd "$BASE_PATH"

FILES=$(find $DOCUMENTATION_PATH -name '*.html' -print)

cat > sitemap.xml << EOF
<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
EOF

# Calculate the minimum number of slashes in a file
minSlashes=100
for f in $FILES; do
    slashCount=$(echo $f | text.count "/")
    minSlashes=$(($minSlashes>$slashCount ? $slashCount : $minSlashes))
done

for f in $FILES; do
    # work out priority, by counting slashes in filename, subtract the minimum
    # number of slashes, calculate 2 to the power of the resulting number and
    # invert it
    slashCount=$(echo $f | text.count "/")
    slashCount=$(($slashCount - $minSlashes))
    slashCount=$(($slashCount>0 ? $slashCount : 0))
    inv_priority=$((2 ** $slashCount))
    priority=$(bc <<< "scale=2; 1/$inv_priority" )

    DATE=$(date -r $f "+%Y-%m-%d")
    cat >> sitemap.xml << EOF
    <url>
      <loc>$URL_PREFIX/$f</loc>
      <lastmod>$DATE</lastmod>
      <priority>$priority</priority>
    </url>
EOF
done   
cat >> sitemap.xml << EOF
</urlset>
EOF
popd