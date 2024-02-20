#/bin/sh
# Copyright (C) 2024 Mark D. Blackwell.
#   All rights reserved.
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

# See:
# https://developers.google.com/speed/docs/insights/MinifyResources
# https://dimiterpetrov.com/blog/elm-single-page-application-setup/
# https://github.com/ben-eb/cssnano-cli
# https://github.com/kangax/html-minifier
# https://github.com/mishoo/UglifyJS2

# Versions:
#  html-minifier 3.5.6 or 4.0.0
#  cssnano 3.10.0
#  cssnano-cli 1.0.5

# Don't uglify (or compress) the PHP program on the server (append.php),
#   since browsers don't download it, and thus it doesn't involve slow
#   network traffic.

(
cd build && \

export PATH="../node_modules/.bin:$PATH" && \

DIRECTORY_SOURCE=../src/remember-source && \

echo "Searching for trailing blanks:" && \
(grep -nrIE '[[:space:]]$' $DIRECTORY_SOURCE; status=$?; [ $status -ne 0 ]) && \

echo "Minifying JavaScript:" && \

NAME=SetUp && \
echo "Minifying $NAME.js to $NAME-min.js" && \
uglifyjs --compress --mangle --warn -- \
  $DIRECTORY_SOURCE/$NAME.js > \
  $NAME-min.js && \

NAME=RememberSongs-windows-phone-8-viewport-fix && \
echo "Minifying $NAME.js to $NAME-min.js" && \
uglifyjs --compress --mangle --warn -- \
  $DIRECTORY_SOURCE/$NAME.js > \
  $NAME-min.js && \

echo "Minifying HTML:" && \

NAME=RememberSongs && \
echo "Minifying $NAME-src.html to $NAME.html" && \
html-minifier --config-file ../html-minifier-conf.json \
  $DIRECTORY_SOURCE/$NAME-src.html > \
  $NAME.html && \

NAME=RememberSongsDevelop && \
echo "Minifying $NAME-src.html to $NAME.html" && \
tr -d '\n' < \
  $DIRECTORY_SOURCE/$NAME-src.html > \
  $NAME.html && \

echo "Minifying CSS:" && \

NAME=RememberSongs && \
echo "Minifying $NAME.css to $NAME-min.css" && \
cssnano \
  $DIRECTORY_SOURCE/$NAME.css > \
  $NAME-min.css && \

NAME=RememberSongs-responsive && \
echo "Minifying $NAME.css to $NAME-min.css" && \
cssnano \
  $DIRECTORY_SOURCE/$NAME.css > \
  $NAME-min.css && \

:) || \

echo "Failed to complete"
