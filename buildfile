# file      : buildfile
# copyright : Copyright (c) 2014-2016 Code Synthesis Ltd
# license   : MIT; see accompanying LICENSE file

d = libbutl/ build2/ libbpkg/ bpkg/
./: $d doc{INSTALL version}
include $d

$src_base/doc{INSTALL}: install = false
