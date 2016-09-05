#! /usr/bin/env bash

version="0.4" # 0.4.0
date="September 2016"

trap 'exit 1' ERR
set -o errtrace # Trap in functions.

function info () { echo "$*" 1>&2; }
function error () { info "$*"; exit 1; }

while [ $# -gt 0 ]; do
  case $1 in
    --clean)
      rm -f build2-toolchain-intro.xhtml build2-toolchain-intro*.ps \
 build2-toolchain-intro*.pdf
      rm -f build2-toolchain-install.xhtml build2-toolchain-install*.ps \
build2-toolchain-install*.pdf
      exit 0
      ;;
    *)
      error "unexpected $1"
      ;;
  esac
done

function gen () # <name>
{
  local n="$1"
  shift
  cli -I .. -v version="$version" -v date="$date" \
--generate-html --html-suffix .xhtml \
--html-prologue-file doc-prologue.xhtml \
--html-epilogue-file doc-epilogue.xhtml \
--link-regex '%b([-.].+)%../../build2/doc/b$1%' \
--link-regex '%bpkg([-.].+)%../../bpkg/doc/bpkg$1%' \
--output-prefix build2-toolchain- "${@}" $n.cli

html2ps -f doc.html2ps:a4.html2ps -o build2-toolchain-$n-a4.ps build2-toolchain-$n.xhtml
ps2pdf14 -sPAPERSIZE=a4 -dOptimize=true -dEmbedAllFonts=true build2-toolchain-$n-a4.ps build2-toolchain-$n-a4.pdf

html2ps -f doc.html2ps:letter.html2ps -o build2-toolchain-$n-letter.ps build2-toolchain-$n.xhtml
ps2pdf14 -sPAPERSIZE=letter -dOptimize=true -dEmbedAllFonts=true build2-toolchain-$n-letter.ps build2-toolchain-$n-letter.pdf
}

# Auto-heading doesn't work since it is broken into multiple doc strings.
#
gen install --html-heading-map 2=h2
gen intro

# Generate INSTALL/BOOTSTRAP/UPGRADE file in ../
#
function gen_txt () # <name>
{
  cli --generate-txt --omit-link-check --link-regex '%#(.*)%\1 file%' \
-o .. --txt-suffix "" ../$1.cli
}

gen_txt INSTALL
gen_txt UPGRADE
gen_txt BOOTSTRAP-MACOSX
gen_txt BOOTSTRAP-MINGW
gen_txt BOOTSTRAP-MSVC
gen_txt BOOTSTRAP-UNIX
gen_txt BOOTSTRAP-WINDOWS
