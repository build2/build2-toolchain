#! /usr/bin/env bash

version=0.17.0

trap 'exit 1' ERR
set -o errtrace # Trap in functions.

function info () { echo "$*" 1>&2; }
function error () { info "$*"; exit 1; }

date="$(date +"%B %Y")"
copyright="$(sed -n -re 's%^Copyright \(c\) (.+) \(see the AUTHORS file\)\.$%\1%p' ../LICENSE)"

while [ $# -gt 0 ]; do
  case $1 in
    --clean)
      rm -f build2-toolchain-intro.xhtml build2-toolchain-intro*.ps \
build2-toolchain-intro*.pdf
      rm -f build2-packaging-guide.xhtml build2-packaging-guide*.ps \
build2-packaging-guide*.pdf
      rm -f build2-toolchain-install.xhtml build2-toolchain-install*.ps \
build2-toolchain-install*.pdf
      exit 0
      ;;
    *)
      error "unexpected $1"
      ;;
  esac
done

function xhtml_to_ps () # <from> <to> [<html2ps-options>]
{
  local from="$1"
  shift
  local to="$1"
  shift

  sed -e 's/├/|/g' -e 's/│/|/g' -e 's/─/-/g' -e 's/└/\xb7/g' "$from" | \
  html2ps "${@}" -o "$to"
}

function gen () # <name>
{
  local n="$1"
  shift
  cli -I .. \
-v version="$(echo "$version" | sed -e 's/^\([^.]*\.[^.]*\).*/\1/')" \
-v date="$date" \
-v copyright="$copyright" \
--generate-html --html-suffix .xhtml \
--html-prologue-file doc-prologue.xhtml \
--html-epilogue-file doc-epilogue.xhtml \
--link-regex '%intro(#.+)?%build2-toolchain-intro.xhtml$1%' \
--link-regex '%b([-.].+)%../../build2/doc/b$1%' \
--link-regex '%bpkg([-.].+)%../../bpkg/doc/bpkg$1%' \
--link-regex '%bdep([-.].+)%../../bdep/doc/bdep$1%' \
--link-regex '%b(#.+)?%../../build2/doc/build2-build-system-manual.xhtml$1%' \
--link-regex '%bpkg(#.+)?%../../bpkg/doc/build2-package-manager-manual.xhtml$1%' \
--link-regex '%bbot(#.+)?%../../bbot/doc/build2-build-bot-manual.xhtml$1%' \
--link-regex '%testscript(#.+)?%../../build2/doc/build2-testscript-manual.xhtml$1%' \
--output-prefix build2-toolchain- "${@}" $n.cli

  xhtml_to_ps build2-toolchain-$n.xhtml build2-toolchain-$n-a4.ps -f doc.html2ps:a4.html2ps
  ps2pdf14 -sPAPERSIZE=a4 -dOptimize=true -dEmbedAllFonts=true build2-toolchain-$n-a4.ps build2-toolchain-$n-a4.pdf

  xhtml_to_ps build2-toolchain-$n.xhtml build2-toolchain-$n-letter.ps -f doc.html2ps:letter.html2ps
  ps2pdf14 -sPAPERSIZE=letter -dOptimize=true -dEmbedAllFonts=true build2-toolchain-$n-letter.ps build2-toolchain-$n-letter.pdf
}

gen packaging
gen intro
#gen intro1

# Auto-heading doesn't work since it is broken into multiple doc strings.
#
gen install --html-heading-map 2=h2

# Generate INSTALL/BOOTSTRAP/UPGRADE file in ../
#
function gen_txt () # <name>
{
  cli --generate-txt --omit-link-check --link-regex '%#(.*)%\U\1\E file%' \
-o .. --txt-suffix "" ../$1.cli
}

gen_txt INSTALL
gen_txt UPGRADE
gen_txt BOOTSTRAP-UNIX
gen_txt BOOTSTRAP-MACOSX
gen_txt BOOTSTRAP-WINDOWS
gen_txt BOOTSTRAP-WINDOWS-MSVC
gen_txt BOOTSTRAP-WINDOWS-CLANG
gen_txt BOOTSTRAP-WINDOWS-MINGW
