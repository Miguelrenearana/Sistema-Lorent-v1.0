FROM php:8.2-apache

# 1. Instalamos librerías del sistema y extensiones de PHP para Postgre
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libpq-dev \
    zip \
    git \
    unzip \
    && docker-php-ext-install pdo pdo_pgsql gd

# 2. CONFIGURACIÓN CRUCIAL: Apuntar Apache a la carpeta /public de Laravel
ENV APACHE_DOCUMENT_ROOT /var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# 3. Activamos el módulo rewrite para que las rutas de Laravel funcionen
RUN a2enmod rewrite

# 4. Copiamos los archivos y entramos a la carpeta
COPY . /var/www/html
WORKDIR /var/www/html

# 5. Instalamos Composer y las dependencias de PHP
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
RUN composer install --no-dev --optimize-autoloader

# 6. Damos permisos correctos a Laravel
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

EXPOSE 80
CMD ["apache2-foreground"]

# 7. Instalamos dependencias de CSS/JS y compilamos (NPM)
RUN npm install && npm run build

# 8. Permisos para Laravel
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

# --- ESTA ES LA PARTE QUE CAMBIA ---
# Usamos una cadena de comandos: primero migra y luego arranca el servidor
CMD sh -c "php artisan migrate --force && apache2-foreground"