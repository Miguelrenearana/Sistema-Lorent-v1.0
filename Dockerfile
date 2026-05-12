# Usamos una imagen de PHP con Apache
FROM php:8.2-apache

# Instalamos extensiones necesarias para Laravel y PostgreSQL
# Hemos añadido 'libpq-dev' y cambiado 'pdo_mysql' por 'pdo_pgsql'
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libpq-dev \
    zip \
    git \
    unzip \
    && docker-php-ext-install pdo pdo_pgsql gd

# Activamos el módulo rewrite de Apache
RUN a2enmod rewrite

# Copiamos los archivos del proyecto
COPY . /var/www/html

# Establecemos el directorio de trabajo
WORKDIR /var/www/html

# Instalamos Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Instalamos las dependencias de PHP
RUN composer install --no-dev --optimize-autoloader

# Damos permisos a las carpetas de Laravel
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

# Exponemos el puerto
EXPOSE 80

# Comando para arrancar Apache
CMD ["apache2-foreground"]