# file      : buildfile
# license   : MIT; see accompanying LICENSE file

# NOTE: This buildfile is only meant to be used to prepare the distribution.
#       If you need to build the toolchain manually, follow the local
#       installation instructions in the BOOTSTRAP-* file corresponding to
#       your platform/compiler.
#
assert ($build.meta_operation == 'dist'      || \
        $build.meta_operation == 'configure' || \
        $build.meta_operation == 'disfigure') 'only dist and configure supported'

# Package repository URL (or path).
#
#build2_repo="https://stage.build2.org/1"
#build2_repo="https://pkg.cppget.org/1/queue/alpha"
build2_repo="https://pkg.cppget.org/1/alpha"

# @@ Note that the project directories order is important (prerequisites go
#    first).
#
# NOTE: see also subprojects in bootstrap.build if changing anything here.
#
d = libbutl/ build2/ libbpkg/ bpkg/ bdep/ doc/ libbuild2-*/

if ($build.meta_operation == 'dist')
  d += tests/*/

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

# Obtain the toolchain and standard build system modules versions.
#
bp = $recall($build.path)
pt = '^version: (.+)$'

# When adding a new standard build system module, these are the places where
# you will need to make changes (igrep for the name of one of the existing
# modules to locate all the places):
#
# - this buildfile
# - build/bootstrap.build (submodules; should be handled automatically)
# - build scripts: build.sh.in and build-*.bat.in
# - documentation: BOOTSTRAP-*.cli and UPGRADE.cli (multiple places)
# - install scripts: prepare, build2-install.sh, and build2-install-*.bat
# - build2.org/www/ (module docs symlinks for both public and stage, etc)
# - make sure the module has `builds: all` in its manifest
# - make sure just `b noop: libbuild2-<mod>-tests/` works and loads the module
#   (not that noop does not do implicit directory buildfile loading)
# - make sure the module is listed in the mod array in etc/bootstrap
#
ver          = $process.run_regex($bp 'info:' $src_root/,                    "$pt", '\1')
build2_ver   = $process.run_regex($bp 'info:' $src_root/build2/,             "$pt", '\1')
bpkg_ver     = $process.run_regex($bp 'info:' $src_root/bpkg/,               "$pt", '\1')
bdep_ver     = $process.run_regex($bp 'info:' $src_root/bdep/,               "$pt", '\1')
autoconf_ver = $process.run_regex($bp 'info:' $src_root/libbuild2-autoconf/, "$pt", '\1')
kconfig_ver  = $process.run_regex($bp 'info:' $src_root/libbuild2-kconfig/,  "$pt", '\1')

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

    sed -e 's%@BUILD2_REPO@%'$build2_repo'%'      $p >$t
    sed -e 's/@CONFIG_VER@/'$cver'/'               -i $t
    sed -e 's/@BUILD2_VERSION@/'$build2_ver'/'     -i $t
    sed -e 's/@BPKG_VERSION@/'$bpkg_ver'/'         -i $t
    sed -e 's/@BDEP_VERSION@/'$bdep_ver'/'         -i $t
    sed -e 's/@AUTOCONF_VERSION@/'$autoconf_ver'/' -i $t
    sed -e 's/@KCONFIG_VERSION@/'$kconfig_ver'/'   -i $t
  }}
}

# Don't install the BOOTSTRAP/INSTALL files. But UPGRADE could be useful.
#
doc{INSTALL}@./:  install = false
doc{BOOTSTRAP-*}: install = false
