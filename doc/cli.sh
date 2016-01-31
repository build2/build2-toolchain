#! /usr/bin/env bash

version="0.2" # 0.2.0
date="January 2016"

trap 'exit 1' ERR
set -o errtrace # Trap in functions.

function info () { echo "$*" 1>&2; }
function error () { info "$*"; exit 1; }

while [ $# -gt 0 ]; do
  case $1 in
    --clean)
      rm -f build2-toolchain-intro.xhtml build2-toolchain-intro.ps \
build2-toolchain-intro.pdf
      exit 0
      ;;
    *)
      error "unexpected $1"
      ;;
  esac
done

cli -I .. -v version="$version" -v date="$date" \
--generate-html --html-suffix .xhtml \
--html-prologue-file intro-prologue.xhtml \
--html-epilogue-file intro-epilogue.xhtml \
--link-regex '%b([-.].+)%../../build2/doc/b$1%' \
--link-regex '%bpkg([-.].+)%../../bpkg/doc/bpkg$1%' \
--output-prefix build2-toolchain- intro.cli

#html2ps -f intro.html2ps -o build2-toolchain-intro.ps build2-toolchain-intro.xhtml
#ps2pdf14 build2-toolchain-intro.ps build2-toolchain-intro.pdf
