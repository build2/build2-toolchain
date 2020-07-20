#!/bin/sh

# file      : build.sh
# license   : MIT; see accompanying LICENSE file

usage="Usage: $0 [-h|--help] [<options>] <c++-compiler> [<compile-options>]"

# Package repository URL (or path).
#
if test -z "$BUILD2_REPO"; then
# BUILD2_REPO="https://stage.build2.org/1"
# BUILD2_REPO="https://pkg.cppget.org/1/queue/alpha"
  BUILD2_REPO="https://pkg.cppget.org/1/alpha"
fi

# The bpkg configuration directory.
#
cver="0.13"
cdir="build2-toolchain-$cver"

diag ()
{
  echo "$*" 1>&2
}

# Note that this function will execute a command with arguments that contain
# spaces but it will not print them as quoted (and neither does set -x).
#
run ()
{
  diag "+ $@"
  "$@"
  if test "$?" -ne "0"; then
    exit 1
  fi
}

owd="$(pwd)"

local=
private=
idir=
jobs=
sudo=
trust=
timeout=
make=
make_options=
verbose=

cxx=

while test $# -ne 0; do
  case "$1" in
    -h|--help)
      diag
      diag "$usage"
      diag "Options:"
      diag "  --local              Don't build from packages, only from local source."
      diag "  --install-dir <dir>  Alternative installation directory."
      diag "  --sudo <prog>        Optional sudo program to use (pass false to disable)."
      diag "  --private            Install shared libraries into private subdirectory."
      diag "  --jobs|-j <num>      Number of jobs to perform in parallel."
      diag "  --repo <loc>         Alternative package repository location."
      diag "  --trust <fp>         Repository certificate fingerprint to trust."
      diag "  --timeout <sec>      Network operations timeout in seconds."
      diag "  --make <arg>         Bootstrap using GNU make instead of script."
      diag "  --verbose <level>    Diagnostics verbosity level between 0 and 6."
      diag
      diag "By default the script will install into /usr/local with private"
      diag "library subdirectories and using sudo(1). To enable private"
      diag "subdirectories and/or use sudo for a custom installation location,"
      diag "you need to specify --private and/or --sudo explicitly, for example:"
      diag
      diag "$0 --install-dir /opt/build2 --sudo sudo g++"
      diag
      diag "If --jobs|-j is unspecified, then the bootstrap step is performed"
      diag "serially with the rest of the process using the number of available"
      diag "hardware threads."
      diag
      diag "The --trust option recognizes two special values: 'yes' (trust"
      diag "everything) and 'no' (trust nothing)."
      diag
      diag "The --make option can be used to bootstrap using GNU make. The"
      diag "first --make value should specify the make executable optionally"
      diag "followed by additional make options, for example:"
      diag
      diag "$0 --make make --make -j8 g++"
      diag
      diag "If --jobs|-j is specified, then its value is passed to make before"
      diag "any additional options."
      diag
      diag "If specified, <compile-options> override the default (-O3) compile"
      diag "options (config.cc.coptions) in the bpkg configuration used to build"
      diag "and install the final toolchain. For example, to build with the debug"
      diag "information (and without optimization):"
      diag
      diag "$0 g++ -g"
      diag
      diag "See the BOOTSTRAP-UNIX file for details."
      diag
      exit 0
      ;;
    --local)
      local=true
      shift
      ;;
    --private)
      private=config.install.private=build2
      shift
      ;;
    --install-dir)
      shift
      if test $# -eq 0; then
	diag "error: installation directory expected after --install-dir"
	diag "$usage"
	exit 1
      fi
      idir="$1"
      shift
      ;;
    -j|--jobs)
      shift
      if test $# -eq 0; then
	diag "error: number of jobs expected after --jobs|-j"
	diag "$usage"
	exit 1
      fi
      jobs="-j $1"
      shift
      ;;
    --sudo)
      shift
      if test $# -eq 0; then
	diag "error: sudo program expected after --sudo"
	diag "$usage"
	exit 1
      fi
      sudo="$1"
      shift
      ;;
    --repo)
      shift
      if test $# -eq 0; then
	diag "error: repository location expected after --repo"
	diag "$usage"
	exit 1
      fi
      BUILD2_REPO="$1"
      shift
      ;;
    --trust)
      shift
      if test $# -eq 0; then
	diag "error: certificate fingerprint expected after --trust"
	diag "$usage"
	exit 1
      fi
      trust="$1"
      shift
      ;;
    --timeout)
      shift
      if test $# -eq 0; then
	diag "error: value in seconds expected after --timeout"
	diag "$usage"
	exit 1
      fi
      timeout="$1"
      shift
      ;;
    --make)
      shift
      if test $# -eq 0; then
	diag "error: argument expected after --make"
	diag "$usage"
	exit 1
      fi
      if test -z "$make"; then
        make="$1"
      else
	make_options="$make_options $1"
      fi
      shift
      ;;
    --verbose)
      shift
      if test $# -eq 0; then
	diag "error: diagnostics level between 0 and 6 expected after --verbose"
	diag "$usage"
	exit 1
      fi
      verbose="$1"
      shift
      ;;
    *)
      cxx="$1"
      shift
      break
      ;;
  esac
done

if test -z "$cxx"; then
  diag "error: compiler executable expected"
  diag "$usage"
  exit 1
fi

# Place default <compile-options> into the $@ array.
#
if test $# -eq 0; then
  set -- -O3
fi

# Merge jobs and make_options into make.
#
if test -n "$make"; then
  if test -n "$jobs"; then
    make="$make $jobs"
  fi

  if test -n "$make_options"; then
    make="$make$make_options" # Already has leading space.
  fi
fi

if test -z "$idir"; then
  idir=/usr/local
  private=config.install.private=build2

  # Only use default sudo for the default installation directory and only if
  # it wasn't specified by the user.
  #
  if test -z "$sudo"; then
    sudo="sudo"
  fi
fi

if test "$sudo" = false; then
  sudo=
fi

if test -f build/config.build; then
  diag "error: current directory already configured, start with clean source"
  exit 1
fi

if test -z "$local" -a -d "../$cdir"; then
  diag "error: ../$cdir/ bpkg configuration directory already exists, remove it"
  exit 1
fi

# Add $idir/bin to PATH in case it is not already there.
#
PATH="$idir/bin:$PATH"
export PATH

sys="$(build2/config.guess | sed -n 's/^[^-]*-[^-]*-\(.*\)$/\1/p')"

case "$sys" in
  mingw32 | mingw64 | msys | msys2 | cygwin)
    conf_rpath="[null]"
    conf_rpath_stage="[null]"
    conf_sudo="[null]"
    ;;
  *)
    if test -n "$private"; then
      conf_rpath="$idir/lib/build2"
    else
      conf_rpath="$idir/lib"
    fi

    conf_rpath_stage="$idir/lib"

    if test -n "$sudo"; then
      conf_sudo="$sudo"
    else
      conf_sudo="[null]"
    fi
    ;;
esac

# We don't have arrays in POSIX shell but we should be ok as long as none of
# the option values contain spaces. Note also that the expansion must be
# unquoted.
#
bpkg_fetch_ops=
bpkg_build_ops=

if test -n "$timeout"; then
  bpkg_fetch_ops="--fetch-timeout $timeout"
  bpkg_build_ops="--fetch-timeout $timeout"
fi

if test "$trust" = "yes"; then
  bpkg_fetch_ops="$bpkg_fetch_ops --trust-yes"
elif test "$trust" = "no"; then
  bpkg_fetch_ops="$bpkg_fetch_ops --trust-no"
elif test -n "$trust"; then
  bpkg_fetch_ops="$bpkg_fetch_ops --trust $trust"
fi

if test -n "$verbose"; then
  verbose="--verbose $verbose"
fi

# Bootstrap, stage 1.
#
run cd build2
if test -z "$make"; then
  run ./bootstrap.sh "$cxx"
else
  run $make -f ./bootstrap.gmake "CXX=$cxx"
fi
run build2/b-boot --version

# Bootstrap, stage 2.
#
run build2/b-boot $verbose $jobs config.cxx="$cxx" config.bin.lib=static build2/exe{b}
mv build2/b build2/b-boot
run build2/b-boot --version

run cd ..

# Local installation early return.
#
if test "$local" = true; then

  run build2/build2/b-boot $verbose configure \
config.cxx="$cxx" \
config.cc.coptions="$*" \
config.bin.lib=shared \
config.bin.rpath="$conf_rpath" \
config.install.root="$idir" \
config.install.sudo="$conf_sudo" \
$private

  run build2/build2/b-boot $verbose $jobs install: build2/ bpkg/ bdep/

  run command -v b
  run command -v bpkg
  run command -v bdep

  run b --version
  run bpkg --version
  run bdep --version

  diag
  diag "Toolchain installation: $idir/bin"
  diag "Build configuration:    $owd"
  diag

  exit 0
fi

# Build and stage the build system and the package manager.
#
run build2/build2/b-boot $verbose configure \
config.cxx="$cxx" \
config.bin.lib=shared \
config.bin.suffix=-stage \
config.bin.rpath="$conf_rpath_stage" \
config.install.root="$idir" \
config.install.data_root=root/stage \
config.install.sudo="$conf_sudo"

run build2/build2/b-boot $verbose $jobs install: build2/ bpkg/

run command -v b-stage
run command -v bpkg-stage

run b-stage --version
run bpkg-stage --version

# Build the entire toolchain from packages.
#
run cd ..
run mkdir "$cdir"
run cd "$cdir"
cdir="$(pwd)" # Save full path for later.

run bpkg-stage $verbose create \
cc \
config.cxx="$cxx" \
config.cc.coptions="$*" \
config.bin.lib=shared \
config.bin.rpath="$conf_rpath" \
config.install.root="$idir" \
config.install.sudo="$conf_sudo" \
$private

run bpkg-stage $verbose add "$BUILD2_REPO"
run bpkg-stage $verbose $bpkg_fetch_ops fetch
run bpkg-stage $verbose $jobs $bpkg_build_ops build --for install --yes --plan= build2 bpkg bdep
run bpkg-stage $verbose $jobs install build2 bpkg bdep

run command -v b
run command -v bpkg
run command -v bdep

run b --version
run bpkg --version
run bdep --version

# Clean up stage.
#
run cd "$owd"
run b $verbose $jobs uninstall: build2/ bpkg/

diag
diag "Toolchain installation: $idir/bin"
diag "Build configuration:    $cdir"
diag
