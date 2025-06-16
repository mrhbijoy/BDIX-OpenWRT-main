@echo off
echo Building BDIX LuCI IPK Package...
echo.

REM Set package details
set PACKAGE_NAME=luci-app-bdix
set VERSION=1.0.0-1
set ARCH=all

REM Create build directory
set BUILD_DIR=build-%PACKAGE_NAME%
if exist %BUILD_DIR% rmdir /s /q %BUILD_DIR%
mkdir %BUILD_DIR%

echo Created build directory: %BUILD_DIR%

REM Copy CONTROL files
mkdir %BUILD_DIR%\CONTROL
copy CONTROL\* %BUILD_DIR%\CONTROL\

REM Create data directory structure
mkdir %BUILD_DIR%\data\usr\lib\lua\luci\controller
mkdir %BUILD_DIR%\data\usr\lib\lua\luci\model\cbi
mkdir %BUILD_DIR%\data\usr\lib\lua\luci\view\bdix
mkdir %BUILD_DIR%\data\etc\init.d
mkdir %BUILD_DIR%\data\etc\config

REM Copy data files
copy data\usr\lib\lua\luci\controller\bdix.lua %BUILD_DIR%\data\usr\lib\lua\luci\controller\
copy data\usr\lib\lua\luci\model\cbi\bdix.lua %BUILD_DIR%\data\usr\lib\lua\luci\model\cbi\
copy data\usr\lib\lua\luci\view\bdix\status.htm %BUILD_DIR%\data\usr\lib\lua\luci\view\bdix\
copy data\etc\init.d\bdix %BUILD_DIR%\data\etc\init.d\
copy data\etc\config\bdix %BUILD_DIR%\data\etc\config\

echo Copied all files

REM Create debian-binary
echo 2.0 > %BUILD_DIR%\debian-binary

echo.
echo Package structure created in %BUILD_DIR%
echo.
echo To complete the IPK package:
echo 1. Install 7-Zip or similar archive tool
echo 2. Create control.tar.gz from CONTROL folder
echo 3. Create data.tar.gz from data folder  
echo 4. Combine debian-binary, control.tar.gz, data.tar.gz into IPK
echo.
echo Or upload the entire %BUILD_DIR% folder contents to your OpenWRT router
echo.

pause
