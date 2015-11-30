# file      : buildfile
# copyright : Copyright (c) 2014-2015 Code Synthesis Ltd
# license   : MIT; see accompanying LICENSE file

d = libbutl/ build2/ libbpkg/ bpkg/
./: $d file{version}
include $d
