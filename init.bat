@ECHO OFF
setlocal

REM Set to your PULL-SECRET file location and admin password.
REM set SECRET_PATH=

REM OpenShift client details.
set OC_MAJOR_VER=4
set OC_MINOR_VER=6
set OC_MINI_VER=3
set OCP_VERSION=%OC_MAJOR_VER%.%OC_MINOR_VER%
set OC_URL="https://mirror.openshift.com/pub/openshift-v4/clients/ocp/4.6.3/"

REM CodeReady Containers details.
set VIRT_DRIVER=hyperv
set CRC_WINDOWS="https://mirror.openshift.com/pub/openshift-v4/clients/crc/latest/crc-windows-amd64.zip"
set CRC_CPU=6

REM Memory allocation options (14GB or 16GB).
set CRC_MEMORY=14336     
REM set CRC_MEMORY=16384     

REM Config files.
set ADMINPASS="%USERPROFIL%\.crc\cache\crc_hyperkit_4.2.0\kubeadmin-password"
set KUBECONFIG="%USERPROFIL%\.crc\cache\crc_hyperkit_4.2.0\kubeconfig"

REM wipe screen.
cls

echo.
echo ####################################################################
echo ##                                                                ##   
echo ##  Setting up OpenShift Container Plaform locally with:          ##
echo ##                                                                ##   
echo ##                                                                ##   
echo ##    ####  ###  ####  #####     ##### #####  ###  ####  #   #    ##
echo ##   #     #   # #   # #         #   # #     #   # #   # #   #    ##
echo ##   #     #   # #   # ###       ##### ###   ##### #   #  ###     ##
echo ##   #     #   # #   # #         #  #  #     #   # #   #   #      ##
echo ##    ####  ###  ####  #####     #   # ##### #   # ####    #      ##
echo ##                                                                ##   
echo ##                                                                ##   
echo ##    ####  ###  #   # #####  ###  ##### #   # ##### ##### #####  ##
echo ##   #     #   # ##  #   #   #   #   #   ##  # #     #   # #      ##
echo ##   #     #   # # # #   #   #####   #   # # # ###   #####  ###   ##
echo ##   #     #   # #  ##   #   #   #   #   #  ## #     #  #      #  ##
echo ##    ####  ###  #   #   #   #   # ##### #   # ##### #   # #####  ##
echo ##                                                                ##   
echo ##                                                                ##   
echo ##  https://gitlab.com/redhatdemocentral/ocp-install-demo         ##
echo ##                                                                ##   
echo ####################################################################
echo.

REM Check virtualization.
REM
echo Make sure you have HyperV installed...
echo.

REM Ensure OpenShift client tool available.
REM
call oc version --client >nul 2>&1

if %ERRORLEVEL% NEQ 0 (
  echo OpenShift CLI tooling is required but not installed yet... download %OCP_VERSION% here, unzip and install on your path: %OC_URL%
  GOTO :EOF
) else (
  echo OpenShift command line tools installed... checking for valid version...
  echo.
)

REM Validate version OpenShfit client tool.
REM
for /f "delims=;" %%i in ('call oc version --client') do set verFull=%%i


if "%verFull%" EQU "Client Version: %OC_MAJOR_VER%.%OC_MINOR_VER%.%OC_MINI_VER%" (
 echo Version of installed OpenShift command line tools correct... %verFull%
 echo.
 GOTO :passOcTestContinue
)

echo Version of installed OpenShift command line tools is %verFull%, must be %OC_MAJOR_VER%.%OC_MINOR_VER%.%OC_MINI_VER%
echo.
echo Download for Windows here: %OC_URL%
GOTO :EOF

:passOcTestContinue

REM Check on Code Ready Containers availability.
REM
call crc version >nul 2>&1

if %ERRORLEVEL% NEQ 0 (
  echo.
  echo Code Ready Containers is not yet installed... download here, unzip and install on your path: %CRC_WINDOWS%
  echo.
  GOTO :EOF
) else (
  echo.
  echo Code Ready Container is installed on your Windows machine..
  echo.
)

echo Running Code Ready Containers setup on this machine, even if done before...
echo
call crc setup

if %ERRORLEVEL% NEQ 0 (
  echo.
  echo Error occurred during 'crc setup' command...
  echo.
  GOTO :EOF
)

echo.
echo Before starting, setting up pull secret file location...
echo.
 
if %SECRET_PATH% == [] (
  REM Empty file variable.
  GOTO :printSecrets
)

if not exist "%SECRET_PATH%" (
  REM Not a file.
  GOTO :printSecrets
)

REM Secret path set, so commit to configuration.
REM
echo.
echo Setting pull-secret-file in cofiguration to: %SECRET_PATH%
echo.
call crc config set pull-secret-file %SECRET_PATH%

if %ERRORLEVEL% NEQ 0 (
  echo.
  echo Error occurred during 'crc config set pull-secret-file' command...
  echo.
  GOTO :EOF
)

REM Setting CPU count in cofiguration...
REM
echo.
echo Setting cpu count in cofiguration to: %CRC_CPU%
echo.
call crc config set cpus %CRC_CPU%

if %ERRORLEVEL% NEQ 0 (
  echo.
  echo Error occurred during 'crc config set cpus' command...
  echo.
  GOTO :EOF
)

REM Setting memory in configuration...
REM
echo.
echo Setting memory in cofiguration to: %CRC_MEMORY%
echo.
call crc config set memory  %CRC_MEMORY%

if %ERRORLEVEL% NEQ 0 (
  echo.
  echo Error occurred during 'crc config set memory' command...
  echo.
  GOTO :EOF
)

echo.
echo Starting Code Ready Containers platform...
echo.
echo This can take some time, so feel free to grab a coffee...
echo.
echo #####################################################################
echo ##                                                                 ##   
echo ##   ####  ###  ##### ##### ##### #####   ##### ##### #   # #####  ##
echo ##  #     #   # #     #     #     #         #     #   ## ## #      ##
echo ##  #     #   # ####  ####  ###   ###       #     #   # # # ###    ##
echo ##  #     #   # #     #     #     #         #     #   #   # #      ##
echo ##   ####  ###  #     #     ##### #####     #   ##### #   # #####  ##
echo ##                                                                 ##   
echo #####################################################################
echo.
echo.
call crc start

if %ERRORLEVEL% NEQ 0 (
  echo.
  echo Error occurred during 'crc start' command...
  echo.
	echo Try running 'crc -f delete' to remove existing cluster and the run init script again... 
	echo
  GOTO :EOF
)

echo.
echo Retrieving the admin password...
echo.
set KUBE_PASS=('call type %ADMINPASS%')

echo Retrieving oc client host login from kubeconfig file...
echo.
REM OCP_HOST=$(cat ${KUBECONFIG} | grep server | awk -F'[:]' '{print $2":"$3":"$4}')     TODO: fix for windowns
set OCP_HOST=('type %KUBECONFIG% | call findstr server')

echo.
echo Logging in as admin user...
echo.
call oc login %OCP_HOST% -u developer -p developer

if %ERRORLEVEL% NEQ 0 (
  echo.
  echo Error occurred during 'oc login' command...
  echo.
  GOTO :EOF
)

REM Detect console url.
REM
REM OCP_CONSOLE=$(crc console --url)              TODO: fix or validate for windows
set OCP_CONSOLE=('call crc console --url')  

echo.
echo ====================================================
echo =                                                  =
echo =  Install complete, get ready to rock.            =
echo =                                                  =
echo =  The server is accessible via web console at:    =
echo =                                                  =
echo =	%OCP_CONSOLE% =
echo =                                                  =
echo =  Log in admin:: kubeadmin                        =
echo =       password: %KUBE_PASS%    =
echo =                                                  =
echo =     Log in dev: developer                        =
echo =       password: developer                        =
echo =                                                  =
echo =  Now get your Red Hat Demo Central example       =
echo =  projects here:                                  =
echo =                                                  =
echo =     https://github.com/redhatdemocentral         =
echo =                                                  =
echo =  To stop, start, or delete your OCP cluster:     =
echo =                                                  =
echo =     $ crc {stop, start, delete}                  =
echo =                                                  =
echo ====================================================
echo.

:printSecrets

	echo
  echo Missing Pull Secret file for starting this Code Ready Containers platform,
  echo please download from:
  echo.
  echo      https://cloud.redhat.com/openshift/install/crc/installer-provisioned
  echo. 
  echo Then update the variable 'SECRET_PATH' at top of this file to point to the
  echo downlaoded file.        i.e. SECRET_PATH='some-dir\pull-secret'
  echo.

