#!/bin/bash
DEBUG_BUILD=${DEBUG_BUILD:-"no"}

function print_w(){
    RESET='\e[0m'  # RESET
    BWhite='\e[7m';    # backgroud White
    printf "${BWhite} ${1} ${RESET}\n";
}

function PrintOK() {
    IRed='\e[0;91m'         # Rosso
    IGreen='\e[0;92m'       # Verde
    RESET='\e[0m'  # RESET
    MSG=${1}
    CHECK=${2:-0}

    if [ ${CHECK} == 0 ];
    then
        printf "${IGreen} [OK] ${CHECK}  ${MSG} ${RESET} \n"
    else
        printf "${IRed} [FAIL] ${CHECK}  ${MSG} ${RESET} \n"
        printf "${IRed} [FAIL] Stopped script ${RESET} \n"
        exit 0;
    fi
}


if [ $DEBUG_BUILD == "yes" ];
then
    set -x
fi

mkdir -p /usr/src/php
cd /usr/src/php

print_w "Start compile to php "
print_w "PHP_VERSION = ${PHP_VERSION}"
apt-get update  > /dev/null
apt-get install -y $PHP_BUILD_DEPS $PHP_BUILD_DEPS_EXTRA  --no-install-recommends > /dev/null

# apt-add-repository ppa:pinepain/libv8-5.2 -y  > /dev/null
# apt-get update > /dev/null
# apt-get install libv8-5.2-dev -y --allow-unauthenticated > /dev/null
PrintOK "apt package install" $?

#####  gpg --keyserver pool.sks-keyservers.net --recv-keys $PHP7_KEY  > /dev/null 2>&1

mkdir -p $PHP_INI_DIR/conf.d

if [ ! -f "dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz" ]; then
    curl -SL --silent -f -O https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz
fi

tar -C /usr/local/bin -xzvf dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz
rm -f /dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz
PrintOK "Dockerize install" $?

if [ ! -f "php-$PHP_VERSION.tar.bz2" ]; then
    curl  -SL --silent -f "http://jp2.php.net/get/php-$PHP_VERSION.tar.bz2/from/this/mirror" -o php.tar.bz2
fi

mv php-$PHP_VERSION.tar.bz2 php.tar.bz2
PrintOK "Download $PHP_VERSION.tar.bz2 " $?

# curl  -SL --silent -f "http://jp2.php.net/get/php-$PHP_VERSION.tar.bz2.asc/from/this/mirror" -o php.tar.bz2.asc
# PrintOK "Download $PHP_VERSION.tar.bz2.asc" $?

##### gpg --verify php.tar.bz2.asc > /dev/null 2>&1

tar -xof php.tar.bz2 -C /usr/src/php --strip-components=1


 ./configure \
	--sysconfdir="$PHP_INI_DIR" \
	--with-config-file-path="$PHP_INI_DIR" \
	--with-config-file-scan-dir="$PHP_INI_DIR/conf.d" \
	$PHP_EXTRA_CONFIGURE_ARGS  >/dev/null
PrintOK "PHP ./confiure " $?

make -j"$(nproc)" -s > /dev/null 2>&1
PrintOK "PHP make " $?

make install -s > /dev/null
PrintOK "PHP make install " $?

cp /usr/src/php/php.ini-production ${PHP_INI_DIR}/php.ini
sed -i 's/short_open_tag = Off/short_open_tag = On/g' ${PHP_INI_DIR}/php.ini

if [ "${PHALCON_INSTALL}" = "enable" ] ; \
    then print_w "INSTALL PHALCON" \
    && mkdir -p /usr/src/pecl && cd /usr/src/pecl  \
	&& wget https://github.com/phalcon/cphalcon/archive/v${PHALCON_VER}.tar.gz  \
	&& tar zxf v${PHALCON_VER}.tar.gz && cd /usr/src/pecl/cphalcon-${PHALCON_VER}/build \
	&& ./install \
    && echo "extension=phalcon.so" > $PHP_INI_DIR/conf.d/phalcon.ini \
    ; else print_w "PASS PHALCON";
fi

mkdir -p /usr/src/pecl && cd /usr/src/pecl
# curl -SL --silent -f -O https://launchpad.net/libmemcached/1.0/1.0.18/+download/libmemcached-1.0.18.tar.gz
# PrintOK "Download  libmemcached-1.0.18.tar.gz " $?
# tar xzf libmemcached-1.0.18.tar.gz
# cd libmemcached-1.0.18
# ./configure --enable-sasl  >/dev/null
# PrintOK "./configure " $?
# make -j"$(nproc)" -s > /dev/null 2>&1
# PrintOK "make " $?
# make install -s > /dev/null
# PrintOK "make install" $?

# curl -SL --silent -f -O http://nz.archive.ubuntu.com/ubuntu/pool/universe/libr/librabbitmq/librabbitmq4_0.7.1-1_amd64.deb
# dpkg -i librabbitmq4_0.7.1-1_amd64.deb
# PrintOK "Install librabbitmq4_0.7.1-1_amd64 " $?

# curl -SL --silent -f -O http://nz.archive.ubuntu.com/ubuntu/pool/universe/libr/librabbitmq/librabbitmq-dev_0.7.1-1_amd64.deb
# dpkg -i librabbitmq-dev_0.7.1-1_amd64.deb
# PrintOK "Install librabbitmq-dev_0.7.1-1_amd64 " $?

# rm -rf *.deb libmemcached-1.0.18*
/usr/local/bin/docker-pecl-install ${PHP_LIB}

# Install composer
wget --no-check-certificate http://getcomposer.org/composer.phar && chmod +x composer.phar && mv composer.phar /usr/local/bin/composer
# Install PHPUnit
wget --no-check-certificate https://phar.phpunit.de/phpunit.phar && chmod +x phpunit.phar && mv phpunit.phar /usr/local/bin/phpunit

composer global require hirak/prestissimo


rm -r /var/lib/apt/lists/*
rm -rf /usr/src/php
rm -rf /usr/src/pecl
if [ $DEBUG_BUILD == "no" ];
then
    # apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false -o APT::AutoRemove::SuggestsImportant=false $PHP_BUILD_DEPS_EXTRA > /dev/null    
fi
