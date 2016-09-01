# file      : buildfile
# copyright : Copyright (c) 2014-2016 Code Synthesis Ltd
# license   : MIT; see accompanying LICENSE file

d = libbutl/ build2/ libsqlite3/ libodb/ libodb-sqlite/ libbpkg/ bpkg/ doc/
./: $d doc{INSTALL README version} file{INSTALL.cli} \
file{build.sh build-msvc.bat build-mingw.bat}
include $d

# Don't install the INSTALL file.
#
doc{INSTALL}@./: install = false
