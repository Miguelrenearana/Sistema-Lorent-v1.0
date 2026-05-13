# 1. Usamos la imagen base de PHP
FROM php:8.2-apache

# 2. INSTALAMOS NODE.JS (Actualizado a v22 para que Vite no se queje)
RUN curl -sL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y nodejs

# 3. Instalamos librerías del sistema y extensiones PHP para PostgreSQL
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libpq-dev \
    zip \
    git \
    unzip \
    && docker-php-ext-install pdo pdo_pgsql gd

# 4. Configuramos Apache para que apunte a la carpeta /public
ENV APACHE_DOCUMENT_ROOT /var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf
RUN a2enmod rewrite

# 5. Copiamos el código al servidor
COPY . /var/www/html
WORKDIR /var/www/html

# 6. Instalamos dependencias de PHP (Composer)
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
RUN composer install --no-dev --optimize-autoloader

# 7. Instalamos dependencias de JS/CSS y compilamos
# Ahora sí funcionará porque tenemos Node 22
RUN npm install
RUN npm run build

# 8. Damos permisos a las carpetas de Laravel
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

# 9. Comando de inicio: Migrar base de datos y arrancar Apache
EXPOSE 80
CMD sh -c "php artisan migrate:fresh --force && apache2-foreground"