# file      : buildfile
# copyright : Copyright (c) 2014-2016 Code Synthesis Ltd
# license   : MIT; see accompanying LICENSE file

d = libbutl/ build2/ libbpkg/ bpkg/ doc/
./: $d doc{INSTALL README version} file{INSTALL.cli}
include $d

doc{INSTALL*}: install = false
