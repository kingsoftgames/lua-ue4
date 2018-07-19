@echo off

@if "%LUA_UE4_VERSION%"=="" (
    echo LUA_UE4_VERSION is not set, exit.
    exit /b 1
) else (
    echo LUA_UE4_VERSION: %LUA_UE4_VERSION%
)

@if "%LUA_UE4_PREFIX%"=="" (
    echo LUA_UE4_PREFIX is not set, exit.
    exit /b 1
) else (
    echo LUA_UE4_PREFIX: %LUA_UE4_PREFIX%
)

set CURRENT_DIR=%cd%
set LUA_UE4_DIR=lua-%LUA_UE4_VERSION%
set LUA_UE4_TAR=lua_%LUA_UE4_DIR%.tar
set LUA_UE4_TAR_GZ=%LUA_UE4_TAR%.gz
set LUA_UE4_URI="http://www.lua.org/ftp/lua-%LUA_UE4_VERSION%.tar.gz"

@REM down source
powershell -Command Invoke-WebRequest -Uri %LUA_UE4_URI% -OutFile %LUA_UE4_TAR_GZ%

set POWERSHELL_NUGET=C:\Program Files\WindowsPowerShell\Modules\PowerShellGet
if not exist "%POWERSHELL_NUGET%" (
    powershell -Command Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
)

set POWERSHELL_7ZIP=C:\Program Files\WindowsPowerShell\Modules\7Zip4Powershell
if not exist "%POWERSHELL_7ZIP%" (
    powershell -Command Install-Module -Name 7Zip4Powershell -Force
)


powershell -Command Expand-7Zip %LUA_UE4_TAR_GZ% .
powershell -Command Expand-7Zip %LUA_UE4_TAR% .

move %LUA_UE4_DIR%\src .
move %LUA_UE4_DIR%\Makefile .
rd /s /q %LUA_UE4_DIR%

@REM change source
cd src
powershell -Command "(type 'luaconf.h') -replace ('define LUA_IDSIZE','define LUA_IDSIZE    256  // ')|out-file luaconf.h"

cd ..

@REM build lua-ue4 on windows
rd %LUA_UE4_PREFIX%
mkdir %LUA_UE4_PREFIX%

cmake -DCMAKE_INSTALL_PREFIX=%LUA_UE4_PREFIX%/windows . -G "Visual Studio 15 2017 Win64"
set VS2017DEVCMD=C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\Common7\IDE\devenv.com
if exist "%VS2017DEVCMD%" (
    "%VS2017DEVCMD%" ALL_BUILD.vcxproj /rebuild "Release|x64"  
    
) else (
    echo "error: no exist %VS2017DEVCMD%"
    exit
)
