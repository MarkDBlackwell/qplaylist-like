#/bin/sh
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

echo "Formatting $DIRECTORY_SOURCE_ELM:" && \
elm-format --yes $DIRECTORY_SOURCE_ELM && \

NAME=Main && \
elm make $DIRECTORY_SOURCE_ELM/$NAME.elm --output=$DIRECTORY_BUILD/$NAME.js && \

NAME=SetUp && \
cp --preserve=all $DIRECTORY_SOURCE_JAVASCRIPT/$NAME.js $DIRECTORY_BUILD/$NAME.js && \

:) || \

echo "Failed to complete"
