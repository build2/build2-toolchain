@echo off

rem file      : build-mingw.bat
rem copyright : Copyright (c) 2014-2017 Code Synthesis Ltd
rem license   : MIT; see accompanying LICENSE file

setlocal EnableDelayedExpansion
goto start

:usage
echo.
echo Usage: %0 [/?] ^<cxx^> [^<install-dir^>] [^<trust^>]
echo.
echo By default the batch file will install into C:\build2. It also expects
echo to find the base utilities in the bin\ subdirectory of the installation
echo directory (C:\build2\bin\ by default).
echo.
echo The ^<trust^> argument can be used to specify the repository certificate
echo fingerprint to trust. Two special values are also recognized: 'yes'
echo (trust everything) and 'no' (trust nothing).
echo.
echo Example usage:
echo.
echo %0 C:\mingw\bin\g++ D:\build2
echo.
echo See the BOOTSTRAP-MINGW file for details.
echo.
goto end

:start

set "owd=%CD%"

if "_%1_" == "_/?_" goto usage

rem Package repository URL (or path).
rem
if "_%BUILD2_REPO%_" == "__" (
    set "BUILD2_REPO=https://stage.build2.org/1"
rem set "BUILD2_REPO=https://pkg.cppget.org/1/queue"
rem set "BUILD2_REPO=https://pkg.cppget.org/1/alpha"
)

rem Bpkg configuration directory.
rem
set "cver=0.7-a.0"
set "cdir=build2-toolchain-%cver%"

rem Compiler.
rem
if "_%1_" == "__" (
  echo error: compiler executable expected, run %0 /? for details
  goto error
) else (
  set "cxx=%1"
)

rem Installation directory.
rem
if "_%2_" == "__" (
  set "idir=C:\build2"
) else (
  set "idir=%2"
)

rem Certificate to trust.
rem
if "_%3_" == "__" (
  set "trust="
) else (
  if "_%3_" == "_yes_" (
    set "trust=--trust-yes"
  ) else (
    if "_%3_" == "_no_" (
      set "trust=--trust-no"
    ) else (
      set "trust=--trust %3"
    )
  )
)

if not exist %idir%\bin\ (
  echo error: %idir%\bin\ does not exist
  goto error
)

if exist build\config.build (
  echo error: current directory already configured, start with clean source
  goto error
)

if exist ..\%cdir%\ (
  echo error: ..\%cdir%\ bpkg configuration directory already exists
  goto error
)

set "PATH=%idir%\bin;%PATH%"

rem Show the steps we are performing.
rem
@echo on

@rem Verify the compiler works.
@rem
%cxx% --version
@if errorlevel 1 goto error

@rem Bootstrap.
@rem
cd build2

@rem Execute in a separate cmd.exe to preserve the echo mode.
@rem
cmd /C bootstrap-mingw.bat %cxx% -static
@if errorlevel 1 goto error

build2\b-boot --version
@if errorlevel 1 goto error

build2\b-boot config.cxx=%cxx% config.bin.lib=static
@if errorlevel 1 goto error

move /y build2\b.exe build2\b-boot.exe
@if errorlevel 1 goto error

build2\b-boot --version
@if errorlevel 1 goto error

@rem Build and stage the toolchain.
@rem
cd ..

build2\build2\b-boot configure^
 config.cxx=%cxx%^
 config.bin.suffix=-stage^
 config.install.root=%idir%^
 config.install.data_root=root\stage
@if errorlevel 1 goto error

build2\build2\b-boot install
@if errorlevel 1 goto error

@rem The where command is not available on XP without the resource kit.
@rem
where b-stage
@rem @if errorlevel 1 goto error

where bpkg-stage
@rem @if errorlevel 1 goto error

b-stage --version
@if errorlevel 1 goto error

bpkg-stage --version
@if errorlevel 1 goto error

@rem Rebuild via package manager.
@rem
cd ..

md %cdir%
@if errorlevel 1 goto error

cd %cdir%

@rem Save full path for later.
@rem
@set "cdir=%CD%"

bpkg-stage create^
 cc^
 config.cxx=%cxx%^
 config.cc.coptions=-O3^
 config.install.root=%idir%
@if errorlevel 1 goto error

bpkg-stage add %BUILD2_REPO%
@if errorlevel 1 goto error

bpkg-stage fetch %trust%
@if errorlevel 1 goto error

bpkg-stage build --yes build2 bpkg
@if errorlevel 1 goto error

bpkg-stage install build2 bpkg
@if errorlevel 1 goto error

where b
@rem @if errorlevel 1 goto error

where bpkg
@rem @if errorlevel 1 goto error

b --version
@if errorlevel 1 goto error

bpkg --version
@if errorlevel 1 goto error

@rem Clean up stage.
@rem
cd %owd%
b uninstall
@if errorlevel 1 goto error

@echo off

echo.
echo Toolchain installation: %idir%\bin
echo Upgrade configuration:  %cdir%
echo.

goto end

:error
@echo off
cd %owd%
endlocal
exit /b 1

:end
endlocal
