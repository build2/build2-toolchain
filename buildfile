# file      : buildfile
# license   : MIT; see accompanying LICENSE file

# Note that the project directories order is important (prerequisites go
# first).
#
d = libpkgconf/ libbutl/ build2/ \
libsqlite3/ libodb/ libodb-sqlite/ libbpkg/ bpkg/ bdep/ doc/

i =                     \
INSTALL                 \
UPGRADE                 \
BOOTSTRAP-UNIX          \
BOOTSTRAP-MACOSX        \
BOOTSTRAP-WINDOWS       \
BOOTSTRAP-WINDOWS-MSVC  \
BOOTSTRAP-WINDOWS-CLANG \
BOOTSTRAP-WINDOWS-MINGW

./: $d                     \
    doc{$i README}         \
    legal{LICENSE AUTHORS} \
    cli{$i}                \
    file{build.sh build-*} \
    manifest

# Don't install the BOOTSTRAP/INSTALL files. But UPGRADE could be useful.
#
doc{INSTALL}@./:  install = false
doc{BOOTSTRAP-*}: install = false
