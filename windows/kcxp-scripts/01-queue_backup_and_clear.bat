@ echo off
@ title backup kcxp queue and clear


set CWD=%~dp0
set PATH=%PATH%;D:\kcxp;D:\kcxp11;E:\kcxp;E:\kcxp11


@ rem KCXP IP/�˿�/�û���/������Ϣ/������Ϣ
set KCXP_HOSTS="127.0.0.1;127.0.0.2"
set KCXP_PORT=5000
set USERNAME=sys
set PASSWORD=passwd
set QUEUE_NAME=queue

@ rem ������ʱ��
set year=%date:~0,4%
set month=%date:~5,2%
set day=%date:~8,2%
set hour=%time:~0,2%
set minute=%time:~3,2%
set second=%time:~6,2%
set ms=%time:~9,2%

@ rem if %hour:~1,1% LSS 10 set hour=0%hour:~1,1%
if "%hour:~0,1%"==" " set "hour=0%hour:~1,1%"

set today=%year%%month%%day%
set now_time=%hour%%minute%%second%
set now_dt=%today%%now_time%
set now_dt_ms=%today%%now_time%%ms%

set now_dt_str=%today%_%now_time%%ms%

set backup_dir=%CWD%\backup
if not exist %backup_dir% md %backup_dir%

@rem ִ�е�������б���
rem set backup_file=%backup_dir%\%QUEUE_NAME%_%now_dt_str%.txt

set /p export_flag=�Ƿ񵼳�����:%QUEUE_NAME% (Y/N)?
set CMDSTR=dispqu -n %QUEUE_NAME% -a

if /i "%export_flag%"=="Y" (
	@rem �����ӳ���չ
	setlocal EnableDelayedExpansion
	:GOON_EXPORT
	for /f "delims=;, tokens=1,*" %%i in (%KCXP_HOSTS%) do (
		
		set XPHOST=%%i
		@rem ע��XPHOST���������÷�ʽΪ��!XPHOST!
		set backup_file=%backup_dir%\!XPHOST!_%QUEUE_NAME%_%now_dt_str%.txt
		
		echo [INFO] ==== !XPHOST! =====
		echo    Event: export queue message
		echo      Cmd: %CMDSTR%
		echo    Queue: %QUEUE_NAME%
		echo Location: !backup_file!
		
		@rem ע��backup_file���������÷�ʽΪ��!backup_file!
		xpcc -a !XPHOST! -o %KCXP_PORT% -u %USERNAME% -p %PASSWORD% -c %CMDSTR%>!backup_file!
		echo DONE

		set KCXP_HOSTS="%%j"
		goto GOON_EXPORT
	)
	endlocal
)

@rem ִ�е������ն���
set /p flag=�Ƿ���ն���:%QUEUE_NAME% (Y/N)?
set CMDSTR_CLEAR=emptyq -n %QUEUE_NAME%

if /i "%flag%"=="Y" (

	@rem �����ӳ���չ
	setlocal EnableDelayedExpansion
	:GOON_CLEAR
	for /f "delims=;, tokens=1,*" %%i in (%KCXP_HOSTS%) do (
		
		set XPHOST=%%i
		
		echo [INFO] ==== !XPHOST!  =====
		echo Event: empty queue
		echo   Cmd: %CMDSTR_CLEAR%
		echo Queue: %QUEUE_NAME%
		
		@rem ע��XPHOST���������÷�ʽΪ��!XPHOST!
		xpcc -a !XPHOST! -o %KCXP_PORT% -u %USERNAME% -p %PASSWORD% -c %CMDSTR_CLEAR%
		echo DONE
		set KCXP_HOSTS="%%j"
		goto GOON_CLEAR
	)
	endlocal
)


:eof
pause