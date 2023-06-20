FROM php:apache

RUN docker-php-ext-install pdo pdo_mysql
RUN apt-get update && apt-get install -y \
    libzip-dev \
    zip
#Installé pour régler bug d'installation lors de l'installation de composer

RUN docker-php-ext-install zip
#Installé pour régler bug d'installation lors de l'installation de composer

RUN apt-get update && apt-get install -y git
#Installé pour régler bug d'installation lors de l'installation de composer

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

# Copy the rest of the application files
COPY . .

# Enable Apache modules and start the server
RUN a2enmod rewrite

CMD ["apache2-foreground"]
