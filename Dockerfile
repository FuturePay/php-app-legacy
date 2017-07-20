FROM php:5.6.31-apache

COPY assets/* /tmp/

# Install pdo
RUN docker-php-ext-install pdo_mysql 

# Enable mod_rewrite
RUN a2enmod rewrite

# Install xdebug
RUN pecl install xdebug && \
    docker-php-ext-enable xdebug && \
 	mv /tmp/xdebug.ini /usr/local/etc/php/conf.d/

# Install wkhtmltopodf
RUN apt-get update && \
	apt-get install -y \
		wkhtmltopdf && \
	rm -r /var/lib/apt/lists/*

# Install mcrypt
RUN apt-get update && \
	apt-get install -y \
		libmcrypt-dev && \
	docker-php-ext-install mcrypt && \
	rm -r /var/lib/apt/lists/*

# Install confd
RUN curl -Lo /usr/local/bin/confd https://github.com/kelseyhightower/confd/releases/download/v0.11.0/confd-0.11.0-linux-amd64 && \
    chmod +x /usr/local/bin/confd && \
    mkdir -p /etc/confd/templates && \
    mkdir -p /etc/confd/conf.d

# Install phing
RUN pecl channel-discover pear.phing.info && \
    pecl install phing/phing

# Cleanup
RUN rm -r /tmp/*

CMD confd -onetime -backend env && apache2-foreground