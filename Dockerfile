#
# - Base nginx
#
FROM ubuntu:18.04
MAINTAINER JINWOO <jinwoo@theloop.co.kr>
#
# Prepare the container
#
RUN sed -i 's/archive.ubuntu.com/ftp.daum.net/g' /etc/apt/sources.list
ENV TZ "Asia/Seoul"
RUN echo $TZ > /etc/timezone && \
    apt-get update > dev/null && apt-get install -y tzdata >/dev/null && \
    rm /etc/localtime && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata && \
    apt-get clean > /dev/null

ENV DOCKERIZE_VERSION v0.6.1
ARG PHP_VERSION
ENV PHP_VERSION $PHP_VERSION
ARG DEBUG_BUILD
ENV DEBUG_BUILD $DEBUG_BUILD
RUN echo "PHP version = ${PHP_VERSION}"
# ENV PHP_LIB redis-3.1.2 yaml-2.0.0RC8 amqp-1.9.0 memcached-3.1.4 apcu-5.1.18 xdebug-2.8.0
ENV PHP_LIB xdebug-2.8.0
ENV PHALCON_INSTALL "disable"
ENV PHALCON_VER 3.0.0

ENV TERM "xterm"
ENV RED "\\\033[1;31m"
ENV NORMAL "\\\033[0;39m"
ENV BLUE "\\\033[1;34m"
ENV USERID 24988

COPY src/* /usr/src/php/
ENV PHP_INI_DIR /etc/php

ENV PHP_EXTRA_CONFIGURE_ARGS --enable-fpm --with-fpm-user=www-data --with-fpm-group=www-data \
                         --with-iconv \
						 --with-php-config \
                         --with-libdir=lib64 --with-openssl --enable-opcache \
                         --with-mysql \
                         --with-mysqli \
                         --with-pdo-mysql \
                         --enable-sockets  \
                   	 	 --disable-cgi \
						 --enable-mysqlnd \
						 --enable-bcmath \
						 --with-bz2 \
						 --enable-calendar \
						 --with-curl \
						 --with-gd \
						 --with-jpeg-dir \
						 --enable-gd-native-ttf \
						 --enable-mbstring \
						 --with-mcrypt \
						 --with-pdo-mysql \
						 --enable-pcntl \
						 --with-openssl \
						 --with-xsl \
						 --with-readline \
						 --with-zlib \
						 --enable-intl \
						 --enable-zip \
                         --enable-calendar \
                         --enable-ctype \
                         --enable-dom \
                         --enable-exif \
                         --enable-fileinfo \
                         --with-gettext=shared \
                         --enable-gmp \
                         --enable-imap \
                         --enable-json \
                         --enable-shmop \
                         --enable-soap \
                         --enable-sysvmsg \
                         --enable-sysvsem \
                         --with-xml \
                         --with-xmlreader \
                         --with-xmlwriter \
                         --with-xsl \
                         --with-zip \
                         --with-bz2 \
                         --enable-wddx \
                         --with-mysqli=mysqlnd

ENV PHP_BUILD_DEPS bzip2 \
		re2c \
		file \
		mysql-client \
        software-properties-common \
        libmysqlclient-dev\
        libyaml-dev \
        librabbitmq-dev \
        libsasl2-dev \
        libbz2-dev \
		libcurl4-openssl-dev \
		libjpeg-dev \
		libmcrypt-dev \
        libpng-dev\
		libreadline6-dev \
		libssl-dev \
        libxslt-dev \
        libxml2 \
        wget \
        libc-dev \
        libxml2-dev \
        libicu-dev \
	    ca-certificates \
		curl \
        libzip-dev \
        vim

    #     flex \
    # libtool libssl-dev libcurl4-openssl-dev libxml2-dev libreadline7 \
   
    # pkg-config re2c sqlite3 zlib1g-dev


ENV PHP_BUILD_DEPS_EXTRA    autoconf \
                            gcc make pkg-config  \
                            runit nano less tmux git \
                            apt-utils \
                            g++




RUN userdel www-data && groupadd -r www-data -g ${USERID} && \
    mkdir /home/www-data && \
    mkdir -p /var/www && \
    useradd -u ${USERID} -r -g www-data -d /home/www-data -s /sbin/nologin -c "Docker image user for web application" www-data && \
    chown -R www-data:www-data /home/www-data /var/www && \
    chmod 700 /home/www-data && \
    chmod 711 /var/www


ENV PHP71_KEY "A917B1ECDA84AEC2B568FED6F50ABC807BD5DCD0 528995BFEDFBA7191D46839EF9BA0ADA31CBD89E"
ENV PHP7_KEY "1A4E8B7277C42E53DBA9C7B9BCAA30EA9C0D5763 6E4F6AB321FDC07F2C332E3AC2BF0BC433CFC8B3"
ENV PHP5_KEY "6E4F6AB321FDC07F2C332E3AC2BF0BC433CFC8B3 0BD78B5F97500D450838F95DFE857D9A90D90EC1"


RUN echo 'export PS1=" \[\e[00;32m\]php-${PHP_VERSION}\[\e[0m\]\[\e[00;37m\]@\[\e[0m\]\[\e[00;31m\]\H :\\$\[\e[0m\] "' >> /root/.bashrc

# COPY configuration files
COPY files /

RUN "/usr/src/php_compile.sh"



#RUN bash -c "git clone https://github.com/rlerdorf/php-memcached" && cd php-memcached && phpize &&./configure && make && make install

#
# Docker properties
#
#RUN sh -c "echo 'source /usr/local/bin/remove_newline.sh' >> /root/.bashrc"

VOLUME [ "/var/www" , "/var/log/nginx" ]

EXPOSE 9000
EXPOSE 443
EXPOSE 80



CMD ["/run.sh"]
# CMD ["/usr/local/sbin/runsvdir-init"]
