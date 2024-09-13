#!/bin/sh

cd /var/www/html/app

composer create-project laravel/laravel .
composer require laravel/jetstream
php ./artisan jetstream:install livewire --teams --dark
npm install
