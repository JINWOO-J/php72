#!/bin/bash
PHP_PROC_MEM=`ps --no-headers -o "rss,cmd" -C php-fpm | awk '{ sum+=$1 } END { printf ("%d%s %d%s\n", sum/NR/1024, "Mb / ",sum/NR," byte") }'`
PHP_PROC_MEM_BYTE=`echo ${PHP_PROC_MEM}  | cut -d "/" -f 2 | grep -o '[0-9]*'`
PHP_PROC_MEM_MB=`echo ${PHP_PROC_MEM}  | cut -d "/" -f 1 | grep -o '[0-9]*'`
TOTAL_MEM_MB=`free -m  | grep Mem | awk '{print $2}'`

let AVAILABLE=${TOTAL_MEM_MB}/${PHP_PROC_MEM_MB}
echo "Total memmory : ${TOTAL_MEM_MB} Mb "
echo "PHP Process memmory : ${PHP_PROC_MEM} "
echo "max_children=$AVAILABLE "
