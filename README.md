# docker-apache-php-mongo

- [Docker Hub](https://hub.docker.com/r/pitchanon/docker-apache-php-mongo/)

## Components

- Base: Ubuntu 14.04
- PHP: 5.5x
- Mongo PHP driver (PECL install): 1.5x
- PHP composer
- MongoDB 2.2x binaries 
- Apache 2.4 with mod_rewrite enabled

## Running & Building
### Using this container as a base
Use this container as a base for your application. Below is an example Dockerfile in which we add a VHost to the apache config:

    FROM pitchanon/apache-php-mongo:latest

    ...

    ADD vhost.conf /etc/apache2/sites-enabled/

    CMD ["/run.sh"]
    
### Running
    
    docker run -d -v /host/www:/app -p 80 pitchanon/apache-php-mongo:latest
