@ECHO OFF
setlocal

set PROJECT_HOME=%~dp0
set DOCKER_MAJOR_VER=17
set DOCKER_MINOR_VER=06
set OC_MAJOR_VER=v3
set OC_MINOR_VER=9
set OC_MINI_VER=14
set OCP_VERSION=%OC_MAJOR_VER%.%OC_MINOR_VER%
set STREAM_BRMS_63="https://raw.githubusercontent.com/openshift/openshift-ansible/master/roles/openshift_examples/files/examples/latest/xpaas-streams/decisionserver63-image-stream.json"
set STREAM_BRMS_64="https://raw.githubusercontent.com/openshift/openshift-ansible/master/roles/openshift_examples/files/examples/latest/xpaas-streams/decisionserver64-image-stream.json"
set STREAM_RHDM_71="https://raw.githubusercontent.com/jboss-container-images/rhdm-7-openshift-image/7.1.0.GA/rhdm71-image-streams.yaml"
set STREAM_EAP_64="https://raw.githubusercontent.com/openshift/openshift-ansible/master/roles/openshift_examples/files/examples/latest/xpaas-streams/eap64-image-stream.json"
set STREAM_EAP_71="https://raw.githubusercontent.com/openshift/openshift-ansible/master/roles/openshift_examples/files/examples/latest/xpaas-streams/eap71-image-stream.json"
set STREAM_FUSE="https://raw.githubusercontent.com/openshift/openshift-ansible/master/roles/openshift_examples/files/examples/latest/xpaas-streams/fis-image-streams.json"
set STREAM_OPENJDK18="https://raw.githubusercontent.com/openshift/openshift-ansible/master/roles/openshift_examples/files/examples/latest/xpaas-streams/openjdk18-image-stream.json"
set STREAM_BPMS_63="https://raw.githubusercontent.com/openshift/openshift-ansible/master/roles/openshift_examples/files/examples/latest/xpaas-streams/processserver63-image-stream.json"
set STREAM_BPMS_64="https://raw.githubusercontent.com/openshift/openshift-ansible/master/roles/openshift_examples/files/examples/latest/xpaas-streams/processserver64-image-stream.json"
set STREAM_RHPAM_71="https://raw.githubusercontent.com/jboss-container-images/rhpam-7-openshift-image/7.1.0.GA/rhpam71-image-streams.yaml"
set STREAM_DOTNET="https://raw.githubusercontent.com/openshift/openshift-ansible/master/roles/openshift_examples/files/examples/latest/image-streams/dotnet_imagestreams.json"
set STREAM_RHEL="https://raw.githubusercontent.com/openshift/openshift-ansible/master/roles/openshift_examples/files/examples/latest/image-streams/image-streams-rhel7.json"
set TEMPLATE_EAP71="https://raw.githubusercontent.com/openshift/openshift-ansible/master/roles/openshift_examples/files/examples/latest/xpaas-templates/eap71-basic-s2i.json"
set TEMPLATE_BRMS_64="https://raw.githubusercontent.com/openshift/openshift-ansible/master/roles/openshift_examples/files/examples/latest/xpaas-templates/decisionserver64-basic-s2i.json"
set TEMPLATE_RHDM_71="https://raw.githubusercontent.com/jboss-container-images/rhdm-7-openshift-image/7.1.0.GA/templates/rhdm71-authoring.yaml"
set TEMPLATE_RHPAM_71="https://raw.githubusercontent.com/jboss-container-images/rhpam-7-openshift-image/7.1.0.GA/templates/rhpam71-authoring.yaml"
set TEMPLATE_BPM_64="https://raw.githubusercontent.com/openshift/openshift-ansible/master/roles/openshift_examples/files/examples/latest/xpaas-templates/processserver64-postgresql-s2i.json"
set TEMPLATE_BPM_DB_64="https://raw.githubusercontent.com/openshift/openshift-ansible/master/roles/openshift_examples/files/examples/latest/xpaas-templates/processserver64-postgresql-persistent-s2i.json"


REM uncomment amount memory needed, sets RAM usage limit for OCP, default 6 GB.
REM set VM_MEMORY=10240
REM set VM_MEMORY=8192  
set VM_MEMORY=6144 

REM wipe screen.
cls

echo.
echo ##############################################################
echo ##                                                          ##   
echo ##  Setting up your very own                                ##
echo ##                                                          ##   
echo ##    ###  ####  ##### #   #  #### #   # ##### ##### #####  ##
echo ##   #   # #   # #     ##  # #     #   #   #   #       #    ##
echo ##   #   # ####  ###   # # #  ###  #####   #   ####    #    ##
echo ##   #   # #     #     #  ##     # #   #   #   #       #    ##
echo ##    ###  #     ##### #   # ####  #   # ##### #       #    ##
echo ##                                                          ##   
echo ##    ####  ###  #   # #####  ###  ##### #   # ##### #####  ##
echo ##   #     #   # ##  #   #   #   #   #   ##  # #     #   #  ##
echo ##   #     #   # # # #   #   #####   #   # # # ###   #####  ##
echo ##   #     #   # #  ##   #   #   #   #   #  ## #     #  #   ##
echo ##    ####  ###  #   #   #   #   # ##### #   # ##### #   #  ##
echo ##                                                          ##   
echo ##      ####  #      ###  ##### #####  ###  ##### #   #     ##   
echo ##      #   # #     #   #   #   #     #   # #   # ## ##     ##   
echo ##      ####  #     #####   #   ####  #   # ##### # # #     ##   
echo ##      #     #     #   #   #   #     #   # #  #  #   #     ##   
echo ##      #     ##### #   #   #   #      ###  #   # #   #     ##   
echo ##                                                          ##   
echo ##  https://gitlab.com/redhatdemocentral/ocp-install-demo   ##
echo ##                                                          ##   
echo ##############################################################
echo.

REM Ensure OpenShift command line tools available.
call oc help >nul 2>&1

if %ERRORLEVEL% NEQ 0 (
  echo OpenShift CLI tooling is required but not installed yet... download %OCP_VERSION% here: https://access.redhat.com/downloads/content/290
  GOTO :EOF
) else (
  echo OpenShift command line tools installed... checking for valid version...
  echo.
)

REM Ensure docker-machine tool available.
call docker-machine -v >nul 2>&1

if %ERRORLEVEL% NEQ 0 (
  echo Docker-machine tooling is required but not installed yet... instructions here: https://docs.docker.com/machine/install-machine/#install-machine-directly
  GOTO :EOF
) else (
  echo Docker-machine command line tools installed...
  echo.
)

for /f "delims=*" %%i in ('oc version ^| findstr -i oc') do (
  for /F "tokens=2 delims= " %%A in ('echo %%i') do ( 
	set verFull=%%A	
  )
)

for /F "tokens=1,2,3 delims=." %%a in ('echo %verFull%') do (
  set verone=%%a
  set vertwo=%%b
  set verthree=%%c
)

if %OC_MAJOR_VER% EQU %verone% if %OC_MINOR_VER% EQU %vertwo% if %OC_MINI_VER% EQU %verthree% (
 echo Version of installed OpenShift command line tools correct... %verfull%
 echo.
 GOTO :passOcTestContinue
)

echo Version of installed OpenShift command line tools is %verone%.%vertwo%.%verthree%, must be %OC_MAJOR_VER%.%OC_MINOR_VER%.%OC_MINI_VER%...
echo.
echo Download for Windows here: https://access.redhat.com/downloads/content/290
GOTO :EOF

:passOcTestContinue

echo Setting up OpenShift docker machine...
echo.
call docker-machine create --driver virtualbox --virtualbox-cpu-count "2" --virtualbox-memory "%VBOX_MEMORY%" --engine-insecure-registry 172.30.0.0/16 --virtualbox-boot2docker-url https://github.com/boot2docker/boot2docker/releases/download/v1.13.1/boot2docker.iso openshift

if %ERRORLEVEL% NEQ 0 (
 echo.
 echo Error occurred during openshift docker machine creation...
 echo.
 echo Cleaning out existing 'openshift' machine...
 echo.
 call docker-machine rm -f openshift
 
 echo Setting up new OpenShift docker machine...
 echo.
 call docker-machine create --driver virtualbox --virtualbox-cpu-count "2" --virtualbox-memory "%VBOX_MEMORY%" --engine-insecure-registry 172.30.0.0/16 --virtualbox-boot2docker-url https://github.com/boot2docker/boot2docker/releases/download/v1.13.1/boot2docker.iso openshift

 if %ERRORLEVEL% NEQ 0 (
  echo.
  echo Problem with docker machine creation that I can't resolve, please raise an issue and add error output:
  echo.
  echo    https://github.com/redhatdemocentral/ocp-install-demo/issues/new
  echo.
  GOTO :EOF
 )
)

echo Installing OCP with cluster up...
echo.

call oc cluster up --image=registry.access.redhat.com/openshift3/ose --host-data-dir=/var/lib/boot2docker/ocp-data  --docker-machine=openshift --host-config-dir=/var/lib/boot2docker/ocp-config --use-existing-config=true --host-pv-dir=/var/lib/boot2docker/ocp-pv

if %ERRORLEVEL% NEQ 0 (
  echo.
  echo There was an issue starting OCP. If you feel the need, raise an issue and add error output:
  echo.
  echo    https://github.com/redhatdemocentral/ocp-install-demo/issues/new
  echo.
  GOTO :EOF
)

echo.
echo Logging in as admin user...
echo.
oc login -u system:admin

for /f "delims=" %%i in ('oc status ^| findstr -i -c:"My Project"') do (
  for /F "tokens=8 delims= " %%A in ('echo %%i') do ( 
    set OCP_IP=%%A	
  )
)

echo Granting admin user full cluster-admin rights...
echo.
call oc adm policy add-cluster-role-to-user cluster-admin admin

if %ERRORLEVEL% NEQ 0 (
	echo.
	echo Problem granting admin user full cluster-admin rights.
	echo.
	GOTO :EOF
)

echo.
echo Granting rights to service catalog access...
echo.
oc adm policy add-cluster-role-to-group system:openshift:templateservicebroker-client system:unauthenticated system:authenticated

if %ERRORLEVEL% NEQ 0 (
	echo.
	echo Problem granting service catalog rights.
	echo.
	GOTO :EOF
)

echo.
echo Updating JBoss image streams...

REM Updating JBoss BRMS 6.3 image stream.
call oc delete -n openshift -f %STREAM_BRMS_63%
call oc create -n openshift -f %STREAM_BRMS_63%

if %ERRORLEVEL% NEQ 0 (
	echo.
	echo Problem with accessing JBoss BRMS 63 stream for OCP.
	echo.
  echo Trying again.
	echo.
  call oc delete -n openshift -f %STREAM_BRMS_63%
  call oc create -n openshift -f %STREAM_BRMS_63%
	
	if %ERRORLEVELS% NEQ 0 (
		echo Failed again, exiting, check output messages and network connectivity before running install again.
		echo.
    call docker-machine rm -f openshift
		GOTO :EOF
  )
)

REM Updating JBoss BPMS 6.3 image stream.
call oc delete -n openshift -f %STREAM_BPMS_63%
call oc create -n openshift -f %STREAM_BPMS_63%

if %ERRORLEVEL% NEQ 0 (
	echo.
	echo Problem with accessing JBoss BPMS 63 stream for OCP.
	echo.
  echo Trying again.
	echo.
  call oc delete -n openshift -f %STREAM_BPMS_63%
  call oc create -n openshift -f %STREAM_BPMS_63%
	
	if %ERRORLEVELS% NEQ 0 (
		echo Failed again, exiting, check output messages and network connectivity before running install again.
		echo.
    call docker-machine rm -f openshift
		GOTO :EOF
  )
)

REM Updating JBoss BRMS 6.4 image stream.
call oc delete -n openshift -f %STREAM_BRMS_64%
call oc create -n openshift -f %STREAM_BRMS_64%

if %ERRORLEVEL% NEQ 0 (
	echo.
	echo Problem with accessing JBoss BRMS 64 stream for OCP.
	echo.
  echo Trying again.
	echo.
  call oc delete -n openshift -f %STREAM_BRMS_64%
  call oc create -n openshift -f %STREAM_BRMS_64%
	
	if %ERRORLEVELS% NEQ 0 (
		echo Failed again, exiting, check output messages and network connectivity before running install again.
		echo.
    call docker-machine rm -f openshift
		GOTO :EOF
  )
)

REM Updating Red Hat Decision Manager 7.1 image stream.
call oc delete -n openshift -f %STREAM_RHDM_71%
call oc create -n openshift -f %STREAM_RHDM_71%

if %ERRORLEVEL% NEQ 0 (
	echo.
	echo Problem with accessing Red Hat Decision Manager 7.1 stream for OCP.
	echo.
  echo Trying again.
	echo.
  call oc delete -n openshift -f %STREAM_RHDM_71%
  call oc create -n openshift -f %STREAM_RHDM_71%
	
	if %ERRORLEVELS% NEQ 0 (
		echo Failed again, exiting, check output messages and network connectivity before running install again.
		echo.
    call docker-machine rm -f openshift
		GOTO :EOF
  )
)

REM Updating JBoss BPMS 6.4 image stream.
call oc delete -n openshift -f %STREAM_BPMS_64%
call oc create -n openshift -f %STREAM_BPMS_64%

if %ERRORLEVEL% NEQ 0 (
	echo.
	echo Problem with accessing JBoss BPMS 64 stream for OCP.
	echo.
  echo Trying again.
	echo.
  call oc delete -n openshift -f %STREAM_BPMS_64%
  call oc create -n openshift -f %STREAM_BPMS_64%
	
	if %ERRORLEVELS% NEQ 0 (
		echo Failed again, exiting, check output messages and network connectivity before running install again.
		echo.
    call docker-machine rm -f openshift
		GOTO :EOF
  )
)

REM Updating Red Hat Process Automation Manager image stream.
call oc delete -n openshift -f %STREAM_RHPAM_71%
call oc create -n openshift -f %STREAM_RHPAM_71%

if %ERRORLEVEL% NEQ 0 (
	echo.
	echo Problem with accessing Red Hat Process Automation Manager 7.1 stream for OCP.
	echo.
  echo Trying again.
	echo.
  call oc delete -n openshift -f %STREAM_RHPAM_71%
  call oc create -n openshift -f %STREAM_RHPAM_71%
	
	if %ERRORLEVELS% NEQ 0 (
		echo Failed again, exiting, check output messages and network connectivity before running install again.
		echo.
    call docker-machine rm -f openshift
		GOTO :EOF
  )
)

REM Updating JBoss EAP 7.0 image stream.
call oc delete -n openshift -f %STREAM_EAP_70%
call oc create -n openshift -f %STREAM_EAP_70%

if %ERRORLEVEL% NEQ 0 (
	echo.
	echo Problem with accessing JBoss EAP 70 stream for OCP.
	echo.
  echo Trying again.
	echo.
  call oc delete -n openshift -f %STREAM_EAP_70%
  call oc create -n openshift -f %STREAM_EAP_70%
	
	if %ERRORLEVELS% NEQ 0 (
		echo Failed again, exiting, check output messages and network connectivity before running install again.
		echo.
    call docker-machine rm -f openshift
		GOTO :EOF
  )
)

REM Updating JBoss EAP 7.1 image stream.
call oc delete -n openshift -f %STREAM_EAP_71%
call oc create -n openshift -f %STREAM_EAP_71%

if %ERRORLEVEL% NEQ 0 (
	echo.
	echo Problem with accessing JBoss EAP 71 stream for OCP.
	echo.
  echo Trying again.
	echo.
  call oc delete -n openshift -f %STREAM_EAP_71%
  call oc create -n openshift -f %STREAM_EAP_71%
	
	if %ERRORLEVELS% NEQ 0 (
		echo Failed again, exiting, check output messages and network connectivity before running install again.
		echo.
    call docker-machine rm -f openshift
		GOTO :EOF
  )
)

REM Updating Fuse image streams.
call oc delete -n openshift -f %STREAM_FUSE%
call oc create -n openshift -f %STREAM_FUSE%

if %ERRORLEVEL% NEQ 0 (
	echo.
	echo Problem with accessing Fuse Integration product streams for OCP.
	echo.
  echo Trying again.
	echo.
  call oc delete -n openshift -f %STREAM_FUSE%
  call oc create -n openshift -f %STREAM_FUSE%
	
	if %ERRORLEVELS% NEQ 0 (
		echo Failed again, exiting, check output messages and network connectivity before running install again.
		echo.
    call docker-machine rm -f openshift
		GOTO :EOF
  )
)

REM Updating OPENJDK18 image stream.
call oc delete -n openshift -f %STREAM_OPENJDK18%
call oc create -n openshift -f %STREAM_OPENJDK18%

if %ERRORLEVEL% NEQ 0 (
	echo.
	echo Problem with accessing OPENJDK18 stream for OCP.
	echo.
  echo Trying again.
	echo.
  call oc delete -n openshift -f %STREAM_OPENJDK18%
  call oc create -n openshift -f %STREAM_OPENJDK18%
	
	if %ERRORLEVELS% NEQ 0 (
		echo Failed again, exiting, check output messages and network connectivity before running install again.
		echo.
    call docker-machine rm -f openshift
		GOTO :EOF
  )
)

REM Updating EAP 7.1 template.
call oc delete -n openshift -f %TEMPLATE_EAP71%
call oc create -n openshift -f %TEMPLATE_EAP71%

if %ERRORLEVEL% NEQ 0 (
	echo.
	echo Problem with accessing JBoss EAP 71 stream for OCP.
	echo.
  echo Trying again.
	echo.
  call oc delete -n openshift -f %TEMPLATE_EAP71%
  call oc create -n openshift -f %TEMPLATE_EAP71%
	
	if %ERRORLEVELS% NEQ 0 (
		echo Failed again, exiting, check output messages and network connectivity before running install again.
		echo.
    call docker-machine rm -f openshift
		GOTO :EOF
  )
)

REM Updating Decision Server 6.4 template.
call oc delete -n openshift -f %TEMPLATE_BRMS_64%
call oc create -n openshift -f %TEMPLATE_BRMS_64%

if %ERRORLEVEL% NEQ 0 (
	echo.
	echo Problem with accessing JBoss BRMS 64 stream for OCP.
	echo.
  echo Trying again.
	echo.
  call oc delete -n openshift -f %TEMPLATE_BRMS_64%
  call oc create -n openshift -f %TEMPLATE_BRMS_64%
	
	if %ERRORLEVELS% NEQ 0 (
		echo Failed again, exiting, check output messages and network connectivity before running install again.
		echo.
    call docker-machine rm -f openshift
		GOTO :EOF
  )
)

REM Updating Red Hat Decision Manager 7.1 template.
call oc delete -n openshift -f %TEMPLATE_RHDM_71%
call oc create -n openshift -f %TEMPLATE_RHDM_71%

if %ERRORLEVEL% NEQ 0 (
	echo.
	echo Problem with accessing Red Hat Decision Manager 7.1 template for OCP.
	echo.
  echo Trying again.
	echo.
  call oc delete -n openshift -f %TEMPLATE_RHDM_71%
  call oc create -n openshift -f %TEMPLATE_RHDM_71%
	
	if %ERRORLEVELS% NEQ 0 (
		echo Failed again, exiting, check output messages and network connectivity before running install again.
		echo.
    call docker-machine rm -f openshift
		GOTO :EOF
  )
)

REM Updating Process Server 6.4 template.
call oc delete -n openshift -f %TEMPLATE_BPM_64%
call oc create -n openshift -f %TEMPLATE_BPM_64%

if %ERRORLEVEL% NEQ 0 (
	echo.
	echo Problem with accessing JBoss BPM Suite 64 template for OCP.
	echo.
  echo Trying again.
	echo.
  call oc delete -n openshift -f %TEMPLATE_BPM_64%
  call oc create -n openshift -f %TEMPLATE_BPM_64%
	
	if %ERRORLEVELS% NEQ 0 (
		echo Failed again, exiting, check output messages and network connectivity before running install again.
		echo.
    call docker-machine rm -f openshift
		GOTO :EOF
  )
)

REM Updating Process Server DB 6.4 template.
call oc delete -n openshift -f %TEMPLATE_BPM_DB_64%
call oc create -n openshift -f %TEMPLATE_BPM_DB_64%

if %ERRORLEVEL% NEQ 0 (
	echo.
	echo Problem with accessing JBoss BPM Suite DB 64 template for OCP.
	echo.
  echo Trying again.
	echo.
  call oc delete -n openshift -f %TEMPLATE_BPM_DB_64%
  call oc create -n openshift -f %TEMPLATE_BPM_DB_64%
	
	if %ERRORLEVELS% NEQ 0 (
		echo Failed again, exiting, check output messages and network connectivity before running install again.
		echo.
    call docker-machine rm -f openshift
		GOTO :EOF
  )
)

REM Updating Red Hat Process Automation Manager Server 7.1 template.
call oc delete -n openshift -f %TEMPLATE_RHPAM_71%
call oc create -n openshift -f %TEMPLATE_RHPAM_71%

if %ERRORLEVEL% NEQ 0 (
	echo.
	echo Problem with accessing Red Hat Process Automation Manager Server 7.1 template for OCP.
	echo.
  echo Trying again.
	echo.
  call oc delete -n openshift -f %TEMPLATE_RHPAM_71%
  call oc create -n openshift -f %TEMPLATE_RHPAM_71%
	
	if %ERRORLEVELS% NEQ 0 (
		echo Failed again, exiting, check output messages and network connectivity before running install again.
		echo.
    call docker-machine rm -f openshift
		GOTO :EOF
  )
)

echo.
echo Updating RHEL 7 image streams...
call oc delete -n openshift -f %STREAM_RHEL%
call oc create -n openshift -f %STREAM_RHEL%

if %ERRORLEVEL% NEQ 0 (
	echo.
	echo Problem with accessing RHEL product streams for OCP.
	echo.
  echo Trying again.
	echo.
  call oc delete -n openshift -f %STREAM_RHEL%
  call oc create -n openshift -f %STREAM_RHEL%
	
	if %ERRORLEVELS% NEQ 0 (
		echo Failed again, exiting, check output messages and network connectivity before running install again.
		echo.
    call docker-machine rm -f openshift
		GOTO :EOF
  )
)

echo.
echo Update .Net image streams...
call oc delete -n openshift -f %STREAM_DOTNET%
call oc create -n openshift -f %STREAM_DOTNET%

if %ERRORLEVEL% NEQ 0 (
	echo.
	echo Problem with accessing .Net image streams for OCP.
	echo.
  echo Trying again.
	echo.
  call oc delete -n openshift -f %STREAM_DOTNET%
  call oc create -n openshift -f %STREAM_DOTNET%
	
	if %ERRORLEVELS% NEQ 0 (
		echo Failed again, exiting, check output messages and network connectivity before running install again.
		echo.
    call docker-machine rm -f openshift
		GOTO :EOF
  )
)

echo.
echo ====================================================
echo =                                                  =
echo = Install complete, get ready to rock your Cloud.  =
echo = Look for information at end of OSE install.      =
echo =                                                  =
echo =  The server is accessible via web console at:    =
echo =                                                  =
echo =	  %OCP_IP%               =
echo =                                                  =
echo =  Log in as user: openshift-dev                   =
echo =        password: devel                           =
echo =                                                  =
echo =  Admin log in as: admin                          =
echo =         password: admin                          =
echo =                                                  =
echo =  Now get your Red Hat Demo Central example       =
echo =  projects here:                                  =
echo =                                                  =
echo =     https://github.com/redhatdemocentral         =
echo =                                                  =
echo =  To stop and restart your OCP cluster with       =
echo =  installed containers, see Readme.md in the      =
echo =  NOTES section for details.                      =
echo =                                                  =
echo =  When finished, clean up your demo with:         =
echo =                                                  =
echo =     $ docker-machine rm -f openshift             =
echo =                                                  =
echo ====================================================
echo.
