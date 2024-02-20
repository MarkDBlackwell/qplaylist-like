#/bin/sh
# Copyright (C) 2024 Mark D. Blackwell.
#   All rights reserved.
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

# Versions:
#  Elm 0.19.1
#  elm-format 0.7.0-exp or 0.8.3

DIRECTORY_SOURCE_ELM=src-elm

DIRECTORY_TEMP=tmp

(
echo "Checking elm-format version" && \
elm-format | head -n 1 | diff - .elm-format-version && \

echo "Formatting $DIRECTORY_SOURCE_ELM:" && \
elm-format --yes $DIRECTORY_SOURCE_ELM && \

NAME=Main && \
#elm make $DIRECTORY_SOURCE_ELM/$NAME.elm --output=$DIRECTORY_TEMP/$NAME.js && \
 elm make $DIRECTORY_SOURCE_ELM/$NAME.elm --output=$DIRECTORY_TEMP/$NAME.js --optimize && \

#echo "Minifying $NAME.js to $NAME-min.js" && \

#uglifyjs --compress --mangle reserved=['Elm'] -- \
#  $DIRECTORY_TEMP/$NAME.js > \
#  build/$NAME-min.js && \

##uglifyjs $DIRECTORY_TEMP/$NAME.js \
##--compress "pure_funcs=[F2,F3,F4,F5,F6,F7,F8,F9,A2,A3,A4,A5,A6,A7,A8,A9],pure_getters,keep_fargs=false,unsafe_comps,unsafe" \
##| uglifyjs --mangle --output build/$NAME-min.js && \

:) || \

echo "Failed to complete"
