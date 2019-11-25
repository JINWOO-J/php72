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

export PHP_SO_DISABLES=${PHP_SO_DISABLES:-""}

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


if [ "$XDEBUG_REMOTE_ENABLE" == 1 ]; then
    echo "xdebug.remote_enable=$XDEBUG_REMOTE_ENABLE" >> ${PHP_INI_DIR}/conf.d/xdebug.ini
    echo "xdebug.remote_host=$XDEBUG_REMOTE_HOST" >> ${PHP_INI_DIR}/conf.d/xdebug.ini
    echo "xdebug.remote_port=$XDEBUG_REMOTE_PORT" >> ${PHP_INI_DIR}/conf.d/xdebug.ini
    echo "xdebug.idekey=$XDEBUG_IDEKEY" >> ${PHP_INI_DIR}/conf.d/xdebug.ini

    if [ "x${XDEBUG_REMOTE_HANDLER}" != "x" ];then
        echo "xdebug.remote_handler=$XDEBUG_REMOTE_HANDLER" >> ${PHP_INI_DIR}/conf.d/xdebug.ini
    fi 

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
