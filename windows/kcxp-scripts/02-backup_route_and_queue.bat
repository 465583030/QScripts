@ echo off
@ rem color F0
@ cls
@ title backup kcxp routes

set CWD=%~dp0
set PATH=%PATH%;D:\kcxp;D:\kcxp11;E:\kcxp;E:\kcxp11

@ rem KCXP IP/�˿�/�û���/������Ϣ/������Ϣ
set KCXP_HOSTS="127.0.0.1;127.0.0.2"
set KCXP_PORT=5000
set USERNAME=sys
set PASSWORD=passwd
set QUEUE_NAME=queue


@ rem ʱ��
set year=%date:~0,4%
set month=%date:~5,2%
set day=%date:~8,2%
set hour=%time:~0,2%
set minute=%time:~3,2%
set second=%time:~6,2%
set ms=%time:~9,2%

@ rem if %hour:~1,1% LSS 10 set hour=0%hour:~1,1%
if "%hour:~0,1%"==" " set hour=0%hour:~1,1%

set today=%year%%month%%day%
set now_time=%hour%%minute%%second%
set now_dt=%today%%now_time%
set now_dt_ms=%today%%now_time%%ms%

set now_dt_str=%today%_%now_time%%ms%



set backup_routes_dir=%CWD%\backup\routes
if not exist %backup_routes_dir% md %backup_routes_dir%
set backup_queues_dir=%CWD%\backup\queues
if not exist %backup_queues_dir% md %backup_queues_dir%

set /p flag=�Ƿ񱸷ݶ��м�·����Ϣ:%QUEUE_NAME% (Y/N)?

if /i "%flag%"=="Y" (

	@rem �����ӳ���չ
	setlocal EnableDelayedExpansion
	:GOON_CLEAR
	for /f "delims=;, tokens=1,*" %%i in (%KCXP_HOSTS%) do (
		
		set XPHOST=%%i
		
		set backup_route_file=%backup_routes_dir%\!XPHOST!_%now_dt_str%.txt
		set backup_queue_file=%backup_queues_dir%\!XPHOST!_%now_dt_str%.txt
		
		echo ==== !XPHOST!  =====
		
		@rem ע��XPHOST���������÷�ʽΪ��!XPHOST!
		@rem ����·����Ϣ
		set CMDSTR=disproute
		echo [INFO]
		echo Event: backup routes
		echo   Cmd: !CMDSTR!
		xpcc -a !XPHOST! -o %KCXP_PORT% -u %USERNAME% -p %PASSWORD% -c !CMDSTR! >!backup_route_file!
		
		@ rem ���ݶ�����Ϣ
		set CMDSTR=dispqd -a
		echo [INFO]
		echo Event: backup queues
		echo   Cmd: !CMDSTR!
		xpcc -a !XPHOST! -o %KCXP_PORT% -u %USERNAME% -p %PASSWORD% -c !CMDSTR! >!backup_queue_file!
		
		echo DONE
		echo.
		
		set KCXP_HOSTS="%%j"
		goto GOON_CLEAR
	)
	endlocal
)



echo �����������ִ��...

pause > nul