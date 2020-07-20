@echo off

rem file      : build-msvc.bat
rem license   : MIT; see accompanying LICENSE file

setlocal EnableDelayedExpansion
goto start

:usage
echo.
echo Usage: %0 [/?] [^<options^>] [^<cl-compiler^>]
echo Options:
echo   --local              Don't build from packages, only from local source.
echo   --install-dir ^<dir^>  Alternative installation directory.
echo   --repo ^<loc^>         Alternative package repository location.
echo   --trust ^<fp^>         Repository certificate fingerprint to trust.
echo   --timeout ^<sec^>      Network operations timeout in seconds.
echo   --verbose ^<level^>    Diagnostics verbosity level between 0 and 6.
echo.
echo By default the batch file will use cl.exe as the C++ compiler and install
echo into C:\build2. It also expects to find the base utilities in the bin\
echo subdirectory of the installation directory ^(C:\build2\bin\ by default^).
echo.
echo The --trust option recognizes two special values: 'yes' ^(trust everything^)
echo and 'no' (trust nothing).
echo.
echo See the BOOTSTRAP-WINDOWS-MSVC file for details.
echo.
goto end

:start

set "owd=%CD%"

rem Package repository URL (or path).
rem
if "_%BUILD2_REPO%_" == "__" (
rem set "BUILD2_REPO=https://stage.build2.org/1"
rem set "BUILD2_REPO=https://pkg.cppget.org/1/queue/alpha"
    set "BUILD2_REPO=https://pkg.cppget.org/1/alpha"
)

rem The bpkg configuration directory.
rem
set "cver=0.13"
set "cdir=build2-toolchain-%cver%"

rem Parse options.
rem
set "local="
set "idir=C:\build2"
set "trust="
set "timeout="
set "verbose="

:options
if "_%~1_" == "_/?_"     goto usage
if "_%~1_" == "_-h_"     goto usage
if "_%~1_" == "_--help_" goto usage

if "_%~1_" == "_--local_" (
  set "local=true"
  shift
  goto options
)

if "_%~1_" == "_--install-dir_" (
  if "_%~2_" == "__" (
    echo error: installation directory expected after --install-dir
    goto error
  )
  set "idir=%~2"
  shift
  shift
  goto options
)

if "_%~1_" == "_--trust_" (
  if "_%~2_" == "__" (
    echo error: certificate fingerprint expected after --trust
    goto error
  )
  set "trust=%~2"
  shift
  shift
  goto options
)

if "_%~1_" == "_--repo_" (
  if "_%~2_" == "__" (
    echo error: repository location expected after --repo
    goto error
  )
  set "BUILD2_REPO=%~2"
  shift
  shift
  goto options
)

if "_%~1_" == "_--timeout_" (
  if "_%~2_" == "__" (
    echo error: value in seconds expected after --timeout
    goto error
  )
  set "timeout=%~2"
  shift
  shift
  goto options
)

if "_%~1_" == "_--verbose_" (
  if "_%~2_" == "__" (
    echo error: diagnostics level between 0 and 6 expected after --verbose
    goto error
  )
  set "verbose=%~2"
  shift
  shift
  goto options
)

if "_%~1_" == "_--_" shift

rem Validate options and arguments.
rem

rem @@ Temporarily retained for backwards compatibility.
rem
if not "_%1_" == "__" (
  set "idir=%1"
)
if not "_%2_" == "__" (
  set "trust=%2"
)
rem Compiler.
rem
rem if "_%1_" == "__" (
  set "cxx=cl"
rem ) else (
rem  set "cxx=%1"
rem )

rem Certificate to trust.
rem
if not "_%trust%_" == "__" (
  if "_%trust%_" == "_yes_" (
    set "trust=--trust-yes"
  ) else (
    if "_%trust%_" == "_no_" (
      set "trust=--trust-no"
    ) else (
      set "trust=--trust %trust%"
    )
  )
)

rem Network timeout.
rem
if not "_%timeout%_" == "__" (
  set "timeout=--fetch-timeout %timeout%"
)

rem Diagnostics verbosity.
rem
if not "_%verbose%_" == "__" (
  set "verbose=--verbose %verbose%"
)

if not exist %idir%\bin\ (
  echo error: %idir%\bin\ does not exist
  goto error
)

if exist build\config.build (
  echo error: current directory already configured, start with clean source
  goto error
)

if "_%local%_" == "__" (
  if exist ..\%cdir%\ (
    echo error: ..\%cdir%\ bpkg configuration directory already exists, remove it
    goto error
  )
)

set "PATH=%idir%\bin;%PATH%"

rem Show the steps we are performing.
rem
@echo on

@rem Verify the compiler works.
@rem
%cxx%
@if errorlevel 1 goto error

@rem Bootstrap.
@rem
cd build2

@rem Execute in a separate cmd.exe to preserve the echo mode.
@rem
cmd /C bootstrap-msvc.bat %cxx%
@if errorlevel 1 goto error

build2\b-boot --version
@if errorlevel 1 goto error

build2\b-boot %verbose% config.cxx=%cxx% config.bin.lib=static build2\exe{b}
@if errorlevel 1 goto error

move /y build2\b.exe build2\b-boot.exe
@if errorlevel 1 goto error

build2\b-boot --version
@if errorlevel 1 goto error

cd ..

@rem Local installation early return.
@rem
@if "_%local%_" == "__" goto stage

build2\build2\b-boot %verbose% configure^
 config.cxx=%cxx%^
 config.cc.coptions=/O2^
 config.bin.lib=shared^
 config.install.root=%idir%
@if errorlevel 1 goto error

build2\build2\b-boot %verbose% install: build2\ bpkg\ bdep\
@if errorlevel 1 goto error

where b
@if errorlevel 1 goto error

where bpkg
@if errorlevel 1 goto error

where bdep
@if errorlevel 1 goto error

b --version
@if errorlevel 1 goto error

bpkg --version
@if errorlevel 1 goto error

bdep --version
@if errorlevel 1 goto error

@echo off

echo.
echo Toolchain installation: %idir%\bin
echo Build configuration:    %owd%
echo.

goto end

@rem Build and stage the build system and the package manager.
@rem
:stage

build2\build2\b-boot %verbose% configure^
 config.cxx=%cxx%^
 config.bin.lib=shared^
 config.bin.suffix=-stage^
 config.install.root=%idir%^
 config.install.data_root=root\stage
@if errorlevel 1 goto error

build2\build2\b-boot %verbose% install: build2\ bpkg\
@if errorlevel 1 goto error

where b-stage
@if errorlevel 1 goto error

where bpkg-stage
@if errorlevel 1 goto error

b-stage --version
@if errorlevel 1 goto error

bpkg-stage --version
@if errorlevel 1 goto error

@rem Build the entire toolchain from packages.
@rem
cd ..

md %cdir%
@if errorlevel 1 goto error

cd %cdir%

@rem Save full path for later.
@rem
@set "cdir=%CD%"

bpkg-stage %verbose% create^
 cc^
 config.cxx=%cxx%^
 config.cc.coptions=/O2^
 config.bin.lib=shared^
 config.install.root=%idir%
@if errorlevel 1 goto error

bpkg-stage %verbose% add %BUILD2_REPO%
@if errorlevel 1 goto error

bpkg-stage %verbose% %timeout% %trust% fetch
@if errorlevel 1 goto error

bpkg-stage %verbose% %timeout% build --for install --yes --plan= build2 bpkg bdep
@if errorlevel 1 goto error

bpkg-stage %verbose% install build2 bpkg bdep
@if errorlevel 1 goto error

where b
@if errorlevel 1 goto error

where bpkg
@if errorlevel 1 goto error

where bdep
@if errorlevel 1 goto error

b --version
@if errorlevel 1 goto error

bpkg --version
@if errorlevel 1 goto error

bdep --version
@if errorlevel 1 goto error

@rem Clean up stage.
@rem
cd %owd%
b %verbose% uninstall: build2/ bpkg/
@if errorlevel 1 goto error

@echo off

echo.
echo Toolchain installation: %idir%\bin
echo Build configuration:    %cdir%
echo.

goto end

:error
@echo off
cd %owd%
endlocal
exit /b 1

:end
endlocal
