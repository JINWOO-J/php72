#!/bin/bash
export DEBUG=${DEBUG:-"no"}  #error log for php_flag[display_errors]
export USE_DOCKERIZE=${USE_DOCKERIZE:-"yes"}
export USE_FPM_SOCKET=${USE_FPM_SOCKET:-"no"}
export FPM_LISTEN=${FPM_LISTEN:-"0.0.0.0:9000"}
export FPM_USER=${FPM_USER:-"www-data"}
export FPM_GROUP=${FPM_GROUP:-"www-data"}
export FPM_STATUS_PATH=${FPM_STATUS_PATH:-"/php_status"}
export FPM_MAX_CHILDREN=${FPM_MAX_CHILDREN:-"10"}
export FPM_MAX_REQUESTS=${FPM_MAX_REQUESTS:-"500"}
export FPM_PROCESS_IDLE_TIMEOUT=${FPM_PROCESS_IDLE_TIMEOUT:-"60"}
export REQUEST_TERMINATE_TIMEOUT=${REQUEST_TERMINATE_TIMEOUT:-"60"}
export MAX_EXECUTION_TIME=${MAX_EXECUTION_TIME:-"60"}
export MAX_INPUT_VARS=${MAX_INPUT_VARS:-"1000"}
export SHORT_OPEN_TAG=${SHORT_OPEN_TAG:-"On"}
export CLEAR_ENV=${CLEAR_ENV:-"no"}

export XDEBUG_REMOTE_ENABLE=${XDEBUG_REMOTE_ENABLE:-0}
export XDEBUG_REMOTE_HOST=${XDEBUG_REMOTE_HOST:-""}
export XDEBUG_REMOTE_PORT=${XDEBUG_REMOTE_PORT:-9000}
export XDEBUG_REMOTE_HANDLER=${XDEBUG_REMOTE_HANDLER:-""}
export XDEBUG_IDEKEY=${XDEBUG_IDEKEY:-"INTELLIJ_IDEA"}

export PHP_INI_DIR=${PHP_INI_DIR:-"/etc/php"}
export PHP_EXTRACONF=${PHP_EXTRACONF:-";"}

export TZ=${TZ:-"Asia/Seoul"}

export PHP_ACCESS_LOG=${PHP_ACCESS_LOG:-"no"}
export PHP_LOG_FORMAT=${PHP_LOG_FORMAT:-"main"}
export PHP_LOG_OUTPUT=${PHP_LOG_OUTPUT:-"file"} # stdout or file

export PHP_UPLOAD_MAX_FILESIZE=${PHP_UPLOAD_MAX_FILESIZE:-"30M"}
export PHP_POST_MAX_SIZE=${PHP_POST_MAX_SIZE:-"30M"}
export PHP_MEMORY_LIMIT=${PHP_MEMORY_LIMIT:-"128M"}
export PHP_SLOWLOG_TIMEOUT=${PHP_SLOWLOG_TIMEOUT:-"0"}
export PHP_OPCACHE_ENABLE=${PHP_OPCACHE_ENABLE-"Off"}
export PHP_OPCACHE_MEMORY_CONSUMPTION=${PHP_OPCACHE_MEMORY_CONSUMPTION:-256}
export PHP_OPCACHE_MAX_ACCELERATED_FILES=${PHP_OPCACHE_MAX_ACCELERATED_FILES:-12000}
export PHP_OPCACHE_MAX_WASTED_PERCENTAGE=${PHP_OPCACHE_MAX_WASTED_PERCENTAGE:-10}
export PHP_OPCACHE_INTERNED_STRINGS_BUFFER=${PHP_OPCACHE_INTERNED_STRINGS_BUFFER:-16}
export PHP_OPCACHE_VALIDATE_TIMESTAMPS=${PHP_OPCACHE_VALIDATE_TIMESTAMPS:-1}
export PHP_OPCACHE_REVALIDATE_FREQ=${PHP_OPCACHE_REVALIDATE_FREQ:-60}
export PHP_SO_DISABLES=${PHP_SO_DISABLES:-""}
export PHP_DISABLE_FUNCTIONS=${PHP_DISABLE_FUNCTIONS:-""}
export PHP_INI_EXTRA=${PHP_INI_EXTRA:-""}

for module in $PHP_SO_DISABLES
do
    echo "disabled $module"
    rm -f /etc/php/conf.d/${module}.ini
done

mkdir -p /tmp/xdebug
chmod 777 /tmp/xdebug

RESET='\e[0m'  # RESET
BWHITE='\e[7m';    # backgroud White
IRED='\e[0;91m'         # Rosso
IGREEN='\e[0;92m'       # Verde
RESET='\e[0m'  # RESET
function print_w(){
    printf "${BWHITE} ${1} ${RESET}\n";
}
function print_g(){
    printf "${IGREEN} ${1} ${RESET}\n";
}

# 환경파일 수정
#.env.development  .env.local  .env.production
export STAGE_NAME=${STAGE_NAME:-""}
ENVFILE="/var/www/.env.${STAGE_NAME}"
if [ -e $ENVFILE ]; then
    echo "STAGE_NAME =  ${STAGE_NAME} , ENVFILE = \'${ENVFILE}\'"
    cp -rf $ENVFILE /var/www/.env
fi

if [ ! -z "$TZ" ] ; then
    sed -i -e "s~.*date.timezone.*~date.timezone = ${TZ}~g" ${PHP_INI_DIR}/php.ini
fi


if [ "$PHP_OPCACHE_ENABLE" == "On" ]; then
    OPCACHE_CONF=${PHP_INI_DIR}/conf.d/opcache.ini
    echo "zend_extension=opcache.so" > $OPCACHE_CONF
    echo "opcache.enable=On" >> $OPCACHE_CONF
    echo "opcache.validate_timestamps=0" >> $OPCACHE_CONF
    echo "opcache.memory_consumption      = $PHP_OPCACHE_MEMORY_CONSUMPTION"  >> $OPCACHE_CONF ### 캐시 메모리 크기
    echo "opcache.max_accelerated_files   = ${PHP_OPCACHE_MAX_ACCELERATED_FILES}" >> $OPCACHE_CONF ## 파일 키 갯수
    echo "opcache.max_wasted_percentage   = $PHP_OPCACHE_MAX_WASTED_PERCENTAGE " >> $OPCACHE_CONF  #만료된 캐시 저장 공간 비율
    echo "opcache.interned_strings_buffer = $PHP_OPCACHE_INTERNED_STRINGS_BUFFER" >> $OPCACHE_CONF #문자열 버퍼 크기 (MB)
    echo "opcache.validate_timestamps     = $PHP_OPCACHE_VALIDATE_TIMESTAMPS " >> $OPCACHE_CONF # 파일과 캐시 변경점 체크 여부 (0=off, 1=on)
    echo "opcache.revalidate_freq         = $PHP_OPCACHE_REVALIDATE_FREQ" >> $OPCACHE_CONF # 변경점 체크 시간 (초)

fi



if [ "$XDEBUG_REMOTE_ENABLE" == 1 ]; then
    echo "xdebug.remote_enable=$XDEBUG_REMOTE_ENABLE" >> ${PHP_INI_DIR}/conf.d/xdebug.ini
    echo "xdebug.remote_host=$XDEBUG_REMOTE_HOST" >> ${PHP_INI_DIR}/conf.d/xdebug.ini
    echo "xdebug.remote_port=$XDEBUG_REMOTE_PORT" >> ${PHP_INI_DIR}/conf.d/xdebug.ini
    echo "xdebug.idekey=$XDEBUG_IDEKEY" >> ${PHP_INI_DIR}/conf.d/xdebug.ini

    if [ "x${XDEBUG_REMOTE_HANDLER}" != "x" ];then
        echo "xdebug.remote_handler=$XDEBUG_REMOTE_HANDLER" >> ${PHP_INI_DIR}/conf.d/xdebug.ini
    fi 

fi

if [ "x${PHP_DISABLE_FUNCTIONS}" != "x" ];then
    sed -i -e "s/.*disable_functions\s*=\s*.*/disable_functions = ${PHP_DISABLE_FUNCTIONS}/g" ${PHP_INI_DIR}/php.ini
fi

if [ "$STAGE_NAME" == "production" ] ; then
    sed -i -e "s/.*error_reporting\s*=\s*.*/error_reporting = E_ALL/g" ${PHP_INI_DIR}/php.ini
else
    sed -i -e "s/.*error_reporting\s*=\s*.*/error_reporting = E_ALL \& ~E_DEPRECATED \& ~E_STRICT/g" ${PHP_INI_DIR}/php.ini
fi

# change  short_open_tag option
if [ ! -z "$SHORT_OPEN_TAG" ] ; then
    sed -i -e "s/.*short_open_tag\s*=\s*.*/short_open_tag = ${SHORT_OPEN_TAG}/g" ${PHP_INI_DIR}/php.ini
fi

#Increase the  MAX_INPUT_VARS
if [ ! -z "$MAX_INPUT_VARS" ] ; then
    sed -i -e "s/.*max_input_vars\s*=\s*.*/max_input_vars = ${MAX_INPUT_VARS}/g" ${PHP_INI_DIR}/php.ini
fi

#Increase the  max_execution_time
if [ ! -z "$MAX_EXECUTION_TIME" ] ; then
    sed -i -e "s/.*max_execution_time\s*=\s*.*/max_execution_time = ${MAX_EXECUTION_TIME}/g" ${PHP_INI_DIR}/php.ini
fi

# Increase the memory_limit
if [ ! -z "$PHP_MEMORY_LIMIT" ] ; then
    sed -i -e "s/.*memory_limit\s*=\s*.*/memory_limit = ${PHP_MEMORY_LIMIT}/g" ${PHP_INI_DIR}/php.ini
fi
# Increase the post_max_size
if [ ! -z "$PHP_POST_MAX_SIZE" ] ; then
    sed -i -e "s/.*post_max_size\s*=\s*.*/post_max_size = ${PHP_POST_MAX_SIZE}/g" ${PHP_INI_DIR}/php.ini
fi
# Increase the upload_max_filesize
if [ ! -z "$PHP_UPLOAD_MAX_FILESIZE" ] ; then
    sed -i -e "s/.*upload_max_filesize\s*=\s*.*/upload_max_filesize = ${PHP_UPLOAD_MAX_FILESIZE}/g" ${PHP_INI_DIR}/php.ini
fi

for INI_SET in ${PHP_INI_EXTRA[@]} ; do
    KEY="${INI_SET%%:*}";
    VALUE="${INI_SET##*:}";
    sed -i -e "s/.*${KEY}\s*=\s*.*/${KEY} = ${VALUE}/g" ${PHP_INI_DIR}/php.ini
    print_w "Change php.ini => $KEY = $VALUE";
done


# cgi.fix_pathinfo off
# sed -i -e "s/.*cgi.fix_pathinfo\s*=\s*.*/cgi.fix_pathinfo = 0/g" ${PHP_INI_DIR}/php.ini
if [ $USE_DOCKERIZE == "yes" ];
then
    echo "USE the dockerize template";
    dockerize -template /etc/php/php-fpm.tmpl | grep -ve '^ *$'  > /etc/php/php-fpm.conf
fi

/usr/local/sbin/php-fpm -c ${PHP_INI_DIR} --nodaemonize --allow-to-run-as-root
