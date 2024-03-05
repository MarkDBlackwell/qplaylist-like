#/bin/sh set -x
# Copyright (C) 2024 Mark D. Blackwell. All rights reserved. This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# Versions:
#  Elm 0.19.1
#  elm-format 0.8.7
DIRECTORY_BUILD=build
DIRECTORY_SOURCE_ELM=src-elm
DIRECTORY_SOURCE_JAVASCRIPT=src
DIRECTORY_NODE_BIN=../qplaylist-remember/node_modules/.bin
(
export PATH="$DIRECTORY_NODE_BIN:$PATH" && \

echo "Checking elm-format version" && \
elm-format | head -n 1 | diff - .elm-format-version && \

echo "Searching $DIRECTORY_SOURCE_JAVASCRIPT for trailing blanks" && \
(grep -nrIE '[[:space:]]$' $DIRECTORY_SOURCE_JAVASCRIPT; STATUS="$?"; NO_LINES_SELECTED="1"; [ "$STATUS" -eq "$NO_LINES_SELECTED" ]) && \

NAME=SetUp && \
echo "Copying $NAME.js" && \
cp --preserve=all $DIRECTORY_SOURCE_JAVASCRIPT/$NAME.js $DIRECTORY_BUILD/$NAME.js && \

echo "Formatting $DIRECTORY_SOURCE_ELM" && \
elm-format --yes $DIRECTORY_SOURCE_ELM && \

NAME=Main && \
echo "Compiling $NAME.elm" && \
elm make $DIRECTORY_SOURCE_ELM/$NAME.elm --output=$DIRECTORY_BUILD/$NAME.js && \

ls -l build && \

:) || \

echo "Failed to complete"
