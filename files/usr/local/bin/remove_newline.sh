#!/bin/bash
ENVIROMENT=`printenv | awk -F "=" '{print $1}' |xargs `
for E in $ENVIROMENT
do
    if [ "${E}" != "PATH" ] && [ "${E}" != "LS_COLORS" ]
    then
        newVAR="$(eval echo \$${E} | tr  '\n' ' ')"
        #export "$(eval echo ${E}____ADD=\'\$${newVAR}\')";
        #export "$(eval echo \${E}____ADD=\'\$${newVAR}\')";
        #echo "$(eval echo \${E}=\"${newVAR}\")";
        export "$(eval echo \${E}=\"${newVAR}\")";
    fi
    #eval ${E}= ` echo \'\$$E\' \| \/usr\/bin\/tr  \'\\n\' \' \' `;
    #eval echo \$${E}____ADD
    #eval echo "sdsdsd\n" | tr "\n" " "
done
# source /root/.bashrc
# source /root/.profile
#/usr/bin/printenv
