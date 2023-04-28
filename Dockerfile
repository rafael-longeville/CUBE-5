FROM nginx:latest

RUN rm -rf node-modules

# Copy Nginx configuration file
COPY nginx.conf /etc/nginx/conf.d/default.conf
RUN rm /etc/nginx/conf.d/default.conf

# Install PHP and related extensions
RUN apt-get update && \
    apt-get install -y \
    php7.4 \
    php7.4-fpm \
    php7.4-mysql \
    php7.4-gd \
    php7.4-curl \
    php7.4-mbstring \
    php7.4-xml \
    php7.4-zip \
    php7.4-intl

# Install Composer
COPY ./composer.json .
COPY ./composer.lock .
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
RUN composer install

# Install Node.js and NPM
COPY ./package.json .
COPY ./package-lock.json .
RUN curl -sL https://deb.nodesource.com/setup_14.x | bash -
RUN apt-get install -y nodejs
RUN npm install
RUN npm run watch


# Copy application files to container
COPY . /var/www/html

# Expose ports
EXPOSE 80

# Start Nginx and PHP-FPM
CMD service php7.4-fpm start && nginx -g "daemon off;"
