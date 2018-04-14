# file      : buildfile
# copyright : Copyright (c) 2014-2017 Code Synthesis Ltd
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

./: $d doc{$i README version} cli{$i} file{build.sh build-*} file{manifest}

# The version file is auto-generated (by the version module) from manifest.
# Include it in distribution and don't remove when cleaning in src (so that
# clean results in a state identical to distributed).
#
doc{version}: file{manifest}
doc{version}: dist  = true
doc{version}: clean = ($src_root != $out_root)

# Don't install the BOOTSTRAP/INSTALL files. But UPGRADE could be useful.
#
doc{INSTALL}@./:  install = false
doc{BOOTSTRAP-*}: install = false
