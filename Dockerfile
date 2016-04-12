FROM ubuntu:14.04

ENV GITHUB_TOKEN=fc1541eddbd36e61f631327ed59a85a6d76a6002
ENV ENVIRONMENT=docker

#RUN echo "deb http://archive.ubuntu.com/ubuntu precise main universe" > /etc/apt/sources.list

#Mongo PHP driver version

ENV MONGO_VERSION 2.2.7
ENV MONGO_PGP 2.2
ENV MONGO_PHP_VERSION 1.5.5

#Install php and dependenceis
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && \
    apt-get -yq install \
        curl \
        git \
        make \
        apache2 \
        libapache2-mod-php5 \
        php5 \
        php5-dev \
        php5-gd \
        php5-curl \
        php5-mcrypt \
        php-pear \
        php-apc && \
    rm -rf /var/lib/apt/lists/*

RUN sed -i "s/variables_order.*/variables_order = \"EGPCS\"/g" /etc/php5/apache2/php.ini
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer


RUN curl -SL "https://fastdl.mongodb.org/linux/mongodb-linux-x86_64-$MONGO_VERSION.tgz" -o mongo.tgz \
  && curl -SL "https://fastdl.mongodb.org/linux/mongodb-linux-x86_64-$MONGO_VERSION.tgz.sig" -o mongo.tgz.sig \
  && curl -SL "https://www.mongodb.org/static/pgp/server-$MONGO_PGP.asc" -o server-$MONGO_PGP.asc \
  && gpg --import server-$MONGO_PGP.asc \
  && gpg --verify mongo.tgz.sig \
  && tar -xvf mongo.tgz -C /usr/local --strip-components=1 \
  && rm mongo.tgz*

RUN pecl install mongo-$MONGO_PHP_VERSION && \
    mkdir -p /etc/php5/mods-available && \
    echo "extension=mongo.so" > /etc/php5/mods-available/mongo.ini && \
    ln -s /etc/php5/mods-available/mongo.ini /etc/php5/cli/conf.d/mongo.ini && \
    ln -s /etc/php5/mods-available/mongo.ini /etc/php5/apache2/conf.d/mongo.ini && \
    ln -s /etc/php5/mods-available/mcrypt.ini /etc/php5/cli/conf.d/mcrypt.ini && \
    ln -s /etc/php5/mods-available/mcrypt.ini /etc/php5/apache2/conf.d/mcrypt.ini

#RUN apt-get install -y gearman php5-gearman

RUN a2enmod headers php5 rewrite ssl vhost_alias
RUN rm -f /etc/apache2/sites-enabled/000-default.conf

# Add apache default vhost configuration
#COPY ["sites-enabled/vhost.conf", "/etc/apache2/sites-enabled/"]
ADD sites-enabled/vhost.conf /etc/apache2/sites-enabled/

ADD run.sh /run.sh

#VOLUME ["/var/log/apache2"]

EXPOSE 80 443

CMD ["/run.sh"]

################################


COPY ["start_script.sh", "/"]

RUN chmod +x /start_script.sh
RUN mkdir /log-dev-docker.dev
RUN chmod 777 /log-dev-docker.dev

RUN mkdir -p /data/log/iotalk-admin.dev/

WORKDIR /var/www/html

CMD composer self-update
CMD composer update
CMD /start_script.sh

