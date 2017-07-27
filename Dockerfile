FROM php:5.6.31-apache

COPY assets/* /tmp/

# Install bcmath
RUN docker-php-ext-install bcmath

# Install pdo
RUN docker-php-ext-install pdo_mysql 

# Enable mod_rewrite
RUN a2enmod rewrite && \
    a2enmod proxy_http && \
    a2enmod proxy_wstunnel

# Install xdebug
RUN pecl install xdebug && \
    docker-php-ext-enable xdebug && \
 	mv /tmp/xdebug.ini /usr/local/etc/php/conf.d/

# Install wkhtmltopodf
RUN apt-get update && \
    apt-get install -y \
        libxext6 \
        libfontconfig1 \
        libxrender1 && \
    cd /tmp && \
    curl https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.4/wkhtmltox-0.12.4_linux-generic-amd64.tar.xz -LO && \
    tar xf wkhtmltox-0.12.4_linux-generic-amd64.tar.xz && \
    mv wkhtmltox/bin/wkhtmltopdf /usr/local/bin/ && \
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

# Cleanup
RUN rm -r /tmp/*

CMD confd -onetime -backend env && apache2-foreground