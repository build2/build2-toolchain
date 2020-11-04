# file      : buildfile
# license   : MIT; see accompanying LICENSE file

assert ($build.meta_operation == 'dist'      || \
        $build.meta_operation == 'configure' || \
        $build.meta_operation == 'disfigure') 'only dist and configure supported'

# Package repository URL (or path).
#
build2_repo="https://stage.build2.org/1"
# build2_repo="https://pkg.cppget.org/1/queue/alpha"
# build2_repo="https://pkg.cppget.org/1/alpha"

# @@ Note that the project directories order is important (prerequisites go
#    first).
#
# See also subprojects in bootstrap.build.
#
d = libpkgconf/ libbutl/ build2/ libsqlite3/ libodb/ libodb-sqlite/ \
libbpkg/ bpkg/ bdep/ doc/ libbuild2-*/ tests/*/

i =                     \
INSTALL                 \
UPGRADE                 \
BOOTSTRAP-UNIX          \
BOOTSTRAP-MACOSX        \
BOOTSTRAP-WINDOWS       \
BOOTSTRAP-WINDOWS-MSVC  \
BOOTSTRAP-WINDOWS-CLANG \
BOOTSTRAP-WINDOWS-MINGW

./: $d                          \
    doc{$i README tests/README} \
    legal{LICENSE AUTHORS}      \
    cli{$i}                     \
    manifest

# Obtain the build2, bpkg, bdep, and toolchain versions.
#
bp = $recall($build.path)
pt = '^version: (.+)$'

ver        = $process.run_regex($bp 'info:' $src_root/,        "$pt", '\1')
build2_ver = $process.run_regex($bp 'info:' $src_root/build2/, "$pt", '\1')
bpkg_ver   = $process.run_regex($bp 'info:' $src_root/bpkg/,   "$pt", '\1')
bdep_ver   = $process.run_regex($bp 'info:' $src_root/bdep/,   "$pt", '\1')

# Generate install scripts from templates and include them into the
# distribution.
#
# @@ Redo as ad hoc rule.
#
for s: exe{build.sh} file{build-msvc.bat build-clang.bat build-mingw.bat}
{
  ./: $s: file{$name($s).$extension($s).in}
  {
    dist = true
  }
  {{
    diag sed $<

    t = $path($>)
    p = $path($<)

    # Note: the same code as in the etc/version script.
    #
    sed    -e 's/([^.]+)\..*/\1/'                            <<<"$ver" | set mj
    sed    -e 's/[^.]+\.([^.]+)\..*/\1/'                     <<<"$ver" | set mn
    sed -n -e 's/[^.]+\.[^.]+\.[^.-]+-([ab]).*/\1/p'         <<<"$ver" | set ab
    sed -n -e 's/[^.]+\.[^.]+\.[^.-]+-[ab]\.([^.+]+).*/\1/p' <<<"$ver" | set pr

    # Version for configuration directory.
    #
    cver = "$mj.$mn"

    if ("$ab" != '')
      cver = "$cver-$ab.$pr"
    end

    sed -e 's%@BUILD2_REPO@%'$build2_repo'%'   $p >$t
    sed -e 's/@CONFIG_VER@/'$cver'/'            -i $t
    sed -e 's/@BUILD2_VERSION@/'$build2_ver'/'  -i $t
    sed -e 's/@BPKG_VERSION@/'$bpkg_ver'/'      -i $t
    sed -e 's/@BDEP_VERSION@/'$bdep_ver'/'      -i $t
  }}
}

# Don't install the BOOTSTRAP/INSTALL files. But UPGRADE could be useful.
#
doc{INSTALL}@./:  install = false
doc{BOOTSTRAP-*}: install = false
