# file      : buildfile
# copyright : Copyright (c) 2014-2018 Code Synthesis Ltd
# license   : MIT; see accompanying LICENSE file

# Note that the project directories order is important (prerequisites go
# first).
#
d = libpkgconf/ libbutl/ build2/ \
libsqlite3/ libodb/ libodb-sqlite/ libbpkg/ bpkg/ bdep/ doc/

i =               \
INSTALL           \
UPGRADE           \
BOOTSTRAP-MACOSX  \
BOOTSTRAP-MINGW   \
BOOTSTRAP-MSVC    \
BOOTSTRAP-UNIX    \
BOOTSTRAP-WINDOWS

./: $d doc{$i README} cli{$i} file{build.sh build-*} manifest

# Don't install the BOOTSTRAP/INSTALL files. But UPGRADE could be useful.
#
doc{INSTALL}@./:  install = false
doc{BOOTSTRAP-*}: install = false
