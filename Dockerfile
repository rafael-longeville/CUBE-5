FROM php:apache

RUN docker-php-ext-install pdo pdo_mysql
RUN apt-get update && apt-get install -y \
    libzip-dev \
    zip

RUN docker-php-ext-install zip
RUN apt-get update && apt-get install -y git

# Set the document root to the desired folder
ENV APACHE_DOCUMENT_ROOT /var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

WORKDIR /var/www/html

# Install Composer & dependencies for backend
COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer
ENV COMPOSER_ALLOW_SUPERUSER=1
COPY composer.json .
RUN composer install    

COPY . .

# Enable Apache modules and start the server
RUN a2enmod rewrite

CMD ["apache2-foreground"]
