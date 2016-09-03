#!/bin/sh

# file      : build.sh
# copyright : Copyright (c) 2014-2016 Code Synthesis Ltd
# license   : MIT; see accompanying LICENSE file

# @@ Should we add sys:sqlite by default? Or add option?
# @@ Need to note that script will ask for repository verification.
# @@ Perhaps a fingerprint to pass to fetch? Once repo is signed?
# @@ Option for alternative bpkg config dir?

usage="Usage: $0 [-h] [--install-dir <dir>] [--sudo <prog>] <cxx>"

# Package repository URL (or path).
#
if test -z "$BUILD2_REPO"; then
  BUILD2_REPO="https://stage.build2.org/1"
#  BUILD2_REPO="https://pkg.cppget.org/1/alpha"
fi

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
    exit 1;
  fi
}

owd="$(pwd)"

cxx=
idir=
sudo=
sudo_set=

while test $# -ne 0; do
  case $1 in
    -h|--help)
      diag
      diag "$usage"
      diag
      diag "By default the script will install into /usr/local using sudo (1)."
      diag "To use sudo for a custom installation directory you need to specify"
      diag "the sudo program explicitly, for example:"
      diag
      diag "$0 --install-dir /opt/build2 --sudo sudo g++"
      diag
      diag "See the INSTALL file for details."
      diag
      exit 0
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
    --sudo)
      shift
      if test $# -eq 0; then
	diag "error: sudo program expected after --sudo"
	diag "$usage"
	exit 1
      fi
      sudo="$1"
      sudo_set="y"
      shift
      ;;
    *)
      cxx="$1"
      break
      ;;
  esac
done

if test -z "$cxx"; then
  diag "error: compiler executable expected"
  diag "$usage"
  exit 1
fi

# Only use default sudo for the default installation directory and only if
# it wasn't specified by the user.
#
if test -z "$idir"; then
  idir="/usr/local"

  if test -z "$sudo_set"; then
    sudo="sudo"
  fi
fi

if test -f build/config.build; then
  diag "current directory already configured, start with clean source"
  exit 1
fi

if test -d ../build2-toolchain; then
  diag "../build2-toolchain/ bpkg configuration directory already exists"
  exit 1
fi

# Add $idir/bin to PATH in case it is not already there.
#
PATH="$idir/bin:$PATH"
export PATH

sys="$(build2/config.guess | sed -n 's/^[^-]*-[^-]*-\(.*\)$/\1/p')"

# Bootstrap, stage 1.
#
run cd build2
run ./bootstrap.sh "$cxx"
run build2/b-boot --version

# Bootstrap, stage 2.
#
run build2/b-boot config.cxx="$cxx" config.bin.lib=static
mv build2/b build2/b-boot
run build2/b-boot --version

case "$sys" in
  mingw32 | mingw64 | msys | msys2 | cygwin)
    conf_rpath="[null]"
    conf_sudo="[null]"
    ;;
  *)
    conf_rpath="$idir/lib"

    if test -n "$sudo"; then
      conf_sudo="$sudo"
    else
      conf_sudo="[null]"
    fi
    ;;
esac

# Stage.
#
run cd ..

run build2/build2/b-boot configure \
config.cxx="$cxx" \
config.bin.lib=shared \
config.bin.suffix=-stage \
config.bin.rpath="$conf_rpath" \
config.install.root="$idir" \
config.install.data_root=root/stage \
config.install.sudo="$conf_sudo"

run build2/build2/b-boot install

run b-stage --version
run bpkg-stage --version

# Install.
#
run cd ..
run mkdir build2-toolchain
run cd build2-toolchain
cdir="$(pwd)"

run bpkg-stage create \
cc \
config.cxx="$cxx" \
config.cc.coptions=-O3 \
config.bin.lib=shared \
config.bin.rpath="$conf_rpath" \
config.install.root="$idir" \
config.install.sudo="$conf_sudo"

run bpkg-stage add "$BUILD2_REPO"
run bpkg-stage fetch
run bpkg-stage build --yes build2 bpkg
run bpkg-stage install build2 bpkg

run b --version
run bpkg --version

# Clean up.
#
run cd "$owd"
run b uninstall

diag
diag "Toolchain installation: $idir/bin"
diag "Upgrade configuration:  $cdir"
diag
