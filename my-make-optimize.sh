#/bin/sh set -x
# Copyright (C) 2024 Mark D. Blackwell. All rights reserved. This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# Versions:
#  Elm 0.19.1
#  uglify-js 3.17.4
DIRECTORY_BUILD=build
DIRECTORY_SOURCE_ELM=src-elm
DIRECTORY_SOURCE_JAVASCRIPT=src
DIRECTORY_NODE_BIN=../qplaylist-remember/node_modules/.bin
DIRECTORY_TEMP=tmp
(
export PATH="$DIRECTORY_NODE_BIN:$PATH" && \

echo "Checking uglify-js version" && \
uglifyjs -v | diff - .uglify-js-version && \

NAME=SetUp && \
echo "Minifying $NAME.js" && \
uglifyjs --compress --mangle --warn \
-- $DIRECTORY_SOURCE_JAVASCRIPT/$NAME.js > \
$DIRECTORY_BUILD/$NAME.js && \

NAME=Main && \
echo "Compiling and optimizing $NAME.elm" && \
elm make $DIRECTORY_SOURCE_ELM/$NAME.elm --output=$DIRECTORY_TEMP/$NAME-optimized.js --optimize && \

echo "Minifying $NAME.js" && \
uglifyjs --compress "pure_funcs=[F2,F3,F4,F5,F6,F7,F8,F9,A2,A3,A4,A5,A6,A7,A8,A9],pure_getters,keep_fargs=false,unsafe_comps,unsafe" \
-- $DIRECTORY_TEMP/$NAME-optimized.js | \
uglifyjs --mangle --warn > \
$DIRECTORY_BUILD/$NAME.js && \

ls -l build && \

:) || \

echo "Failed to complete"
