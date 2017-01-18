#!/bin/sh
## qjq@20170115
##
JDKPATH=/wls/apache/tomcat/jdk1.8.0_25
CURDIR=$(cd $(dirname ${BASH_SOURCE[0]});pwd)
CURR_DT=$(date +"%Y%m%d%H%M%S")
MAX_GET_CNT=5

#INSTANCE_NAME="tm_only_uniq_flag"
INSTANCE_NAME=$1
if [ "x${INSTANCE_NAME}" = "x" ];then
	echo "Usage: $0 \${instance_name_of_tomcat}"
	exit 1
fi

PGID=$(ps -ef | grep "DserverName=${INSTANCE_NAME}"| grep -v 'grep ' | awk '{print $2}')
if [ "x${PGID}" = "x" ];then
	echo "[ERROR] Pid of Instance:${INSTANCE_NAME} Not Found"
	exit 1
fi

LOG_DIRROOT=${CURDIR}/dumplog/${INSTANCE_NAME}/${CURR_DT}
ENV_LOGPATH=${LOG_DIRROOT}/${INSTANCE_NAME}.out
THREADDUMP_LOGPATH=${LOG_DIRROOT}/threaddump_${INSTANCE_NAME}.out
HEAPDUMP_LOGPATH=${LOG_DIRROOT}/heapdump_${INSTANCE_NAME}.hprof

mkdir -p ${LOG_DIRROOT}
for((i=1;i<=${MAX_GET_CNT};i++));do
	if [ $i -lt 10 ];then
		i="0${i}"
	fi
	echo "---�߳���Ϣ ${i}Start---" >>${ENV_LOGPATH}
	top -Hp ${PGID} -d 1 -n 3 >>${ENV_LOGPATH}
	echo "---�߳���Ϣ ${i}End---"  >>${ENV_LOGPATH}
	sleep 1
done

echo "---netstat��ϢStart---" >>${ENV_LOGPATH}
netstat -na >>${ENV_LOGPATH}
echo "---netstat��ϢStop---" >>${ENV_LOGPATH}
echo -e "\n\n" >>${ENV_LOGPATH}

echo "---���̴��ļ���ϢStart---" >>${ENV_LOGPATH}
ls -l /proc/${PGID}/fd >>${ENV_LOGPATH}
echo "---���̴��ļ���ϢEnd---" >>${ENV_LOGPATH}
echo -e "\n\n" >>${ENV_LOGPATH}

echo "---JVM����ϢStart---" >>${ENV_LOGPATH}
${JDKPATH}/bin/jmap -heap $PGID>> ${ENV_LOGPATH}
echo "---JVM����ϢEnd---" >>${ENV_LOGPATH}
echo -e "\n\n" >>${ENV_LOGPATH}

echo "---JVM THREAD DUMP ��ϢStart---"  >>${ENV_LOGPATH}
${JDKPATH}/bin/jstack -F ${PGID} >>${THREADDUMP_LOGPATH}
echo "Location:${THREADDUMP_LOGPATH}" >>${ENV_LOGPATH}
echo "---JVM THREAD DUMP ��ϢEnd---" >>${ENV_LOGPATH}
echo -e "\n\n" >>${ENV_LOGPATH}

echo "---JVM HEAP DUMP ��ϢStart---" >>${ENV_LOGPATH}
${JDKPATH}/bin/jmap -dump:format=b,file=${HEAPDUMP_LOGPATH} $PGID
echo "Location:${HEAPDUMP_LOGPATH}" >>${ENV_LOGPATH}
echo "---JVM HEAP DUMP ��ϢEnd---" >>${ENV_LOGPATH}
echo -e "\n\n" >>${ENV_LOGPATH}


echo "###################################################"
echo "[SUMMARY]:"
echo "###################################################"
echo "INSTANCE_NAME: ${INSTANCE_NAME}"
echo "PID: ${PGID}"
echo "DUMPDIR: ${LOG_DIRROOT}"
echo "RUN_ENV_LOG: ${ENV_LOGPATH}"
echo "THREAD_DUMP_LOG: ${THREADDUMP_LOGPATH}"
echo "HEAP_DUMP_LOG: ${HEAPDUMP_LOGPATH}"