FROM centos:7
MAINTAINER relotalent
ENV PHALCON_VERSION=3.4.0

# Install PHP 7.1

RUN yum install epel-release -y
RUN yum install http://rpms.remirepo.net/enterprise/remi-release-7.rpm -y
RUN yum-config-manager --enable remi-php71
RUN yum install php php-common php-opcache php-mcrypt php-cli php-gd php-curl php-mysql php-mbstring php-pecl-zip php-imap php-fpm php-intl -y

RUN mkdir /run/php-fpm
# Install Nginx

RUN yum install nginx -y
# Install composer

RUN yum -y update
RUN cd /tmp && curl -sS https://getcomposer.org/installer | php
RUN cd /tmp && mv composer.phar /usr/local/bin/composer

# Install Phalcon3.4
RUN yum install php-devel pcre-devel gcc make -y
# Compile Phalcon
RUN set -xe && \
        # Add virtual packages. It will remove when done. 
        curl -LO https://github.com/phalcon/cphalcon/archive/v${PHALCON_VERSION}.tar.gz && \
        tar xzf v${PHALCON_VERSION}.tar.gz && cd cphalcon-${PHALCON_VERSION}/build && sh install && \
        echo "extension=phalcon.so" > /etc/php.d/phalcon.ini && \
        cd ../.. && rm -rf v${PHALCON_VERSION}.tar.gz cphalcon-${PHALCON_VERSION}


# Install Imagick

RUN yum install ImageMagick ImageMagick-devel php-pear -y
RUN pecl install imagick
RUN echo "extension=imagick.so" > /etc/php.d/imagick.ini

# Install wkhtmltopdf

RUN curl -LO https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.4/wkhtmltox-0.12.4_linux-generic-amd64.tar.xz
RUN yum -y install xz
RUN unxz wkhtmltox-0.12.4_linux-generic-amd64.tar.xz
RUN tar -xvf wkhtmltox-0.12.4_linux-generic-amd64.tar
RUN mv wkhtmltox/bin/* /usr/local/bin/
RUN rm -rf wkhtmltox
RUN rm -f wkhtmltox-0.12.4_linux-generic-amd64.tar
RUN yum install libXrender fontconfig urw-fonts libXext -y

# Install nodejs
RUN curl --silent --location https://rpm.nodesource.com/setup_10.x | bash -
RUN yum install -y nodejs
RUN npm install -g gulp-cli bower bower-npm-resolver

# Install php redis
RUN yum install redis php-pecl-redis -y

# Install Phalcon development tool
RUN yum install -y git
RUN git clone git://github.com/phalcon/phalcon-devtools.git
RUN ln -s /phalcon-devtools/phalcon /usr/bin/phalcon

# Start bash

ADD start.sh /start.sh

EXPOSE 80

CMD bash /start.sh && tail -f /dev/null

#CMD ["php-fpm", "-D", nginx", "-g", "daemon off;"]
