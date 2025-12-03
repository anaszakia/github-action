#!/bin/bash

# ===================================================================
# Script Setup Awal Server untuk Laravel Project
# Jalankan script ini SEKALI SAJA saat pertama kali setup server
# ===================================================================

echo "🚀 Starting Server Setup..."

# ===================================================================
# KONFIGURASI - SESUAIKAN DENGAN SERVER ANDA
# ===================================================================

# Path tempat project akan di-install
PROJECT_PATH="/var/www/html/myapp"

# GitHub repository URL
GITHUB_REPO="https://github.com/username/repository.git"

# Branch yang akan di-clone
BRANCH="main"

# Database configuration
DB_NAME="laravel_db"
DB_USER="laravel_user"
DB_PASSWORD="password_anda_yang_kuat"

# ===================================================================
# 1. UPDATE SYSTEM
# ===================================================================
echo "📦 Updating system packages..."
sudo apt update && sudo apt upgrade -y

# ===================================================================
# 2. INSTALL PHP DAN EXTENSIONS
# ===================================================================
echo "🐘 Installing PHP and extensions..."
sudo apt install -y php8.2 php8.2-fpm php8.2-mysql php8.2-mbstring php8.2-xml \
    php8.2-curl php8.2-zip php8.2-gd php8.2-bcmath php8.2-intl php8.2-redis \
    php8.2-cli unzip git curl

# ===================================================================
# 3. INSTALL COMPOSER
# ===================================================================
if ! command -v composer &> /dev/null; then
    echo "📥 Installing Composer..."
    curl -sS https://getcomposer.org/installer | php
    sudo mv composer.phar /usr/local/bin/composer
    sudo chmod +x /usr/local/bin/composer
else
    echo "✅ Composer already installed"
fi

# ===================================================================
# 4. INSTALL & SETUP MYSQL
# ===================================================================
echo "🗄️ Installing MySQL..."
sudo apt install -y mysql-server

# Start MySQL service
sudo systemctl start mysql
sudo systemctl enable mysql

# Create database and user
echo "📝 Creating database and user..."
sudo mysql <<MYSQL_SCRIPT
CREATE DATABASE IF NOT EXISTS ${DB_NAME};
CREATE USER IF NOT EXISTS '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASSWORD}';
GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'localhost';
FLUSH PRIVILEGES;
MYSQL_SCRIPT

echo "✅ Database '${DB_NAME}' and user '${DB_USER}' created"

# ===================================================================
# 5. INSTALL NGINX (Web Server)
# ===================================================================
echo "🌐 Installing Nginx..."
sudo apt install -y nginx

# ===================================================================
# 6. CLONE PROJECT DARI GITHUB
# ===================================================================
echo "📂 Cloning project from GitHub..."

# Create directory jika belum ada
sudo mkdir -p $(dirname "$PROJECT_PATH")

# Clone repository
sudo git clone -b $BRANCH $GITHUB_REPO $PROJECT_PATH

# Masuk ke directory project
cd $PROJECT_PATH

# ===================================================================
# 7. SETUP PROJECT
# ===================================================================
echo "⚙️ Setting up Laravel project..."

# Install dependencies
sudo composer install --no-interaction --prefer-dist --optimize-autoloader

# Copy .env file
if [ ! -f .env ]; then
    sudo cp .env.example .env
    echo "✅ .env file created"
fi

# Generate application key
sudo php artisan key:generate

# Update .env dengan konfigurasi database
sudo sed -i "s/DB_DATABASE=.*/DB_DATABASE=${DB_NAME}/" .env
sudo sed -i "s/DB_USERNAME=.*/DB_USERNAME=${DB_USER}/" .env
sudo sed -i "s/DB_PASSWORD=.*/DB_PASSWORD=${DB_PASSWORD}/" .env

# Create storage link
sudo php artisan storage:link

# Run migrations
sudo php artisan migrate --force

# Set permissions
echo "🔐 Setting permissions..."
sudo chown -R www-data:www-data $PROJECT_PATH
sudo chmod -R 775 $PROJECT_PATH/storage
sudo chmod -R 775 $PROJECT_PATH/bootstrap/cache

# ===================================================================
# 8. CONFIGURE NGINX
# ===================================================================
echo "⚙️ Configuring Nginx..."

NGINX_CONFIG="/etc/nginx/sites-available/laravel"

sudo tee $NGINX_CONFIG > /dev/null <<EOF
server {
    listen 80;
    server_name your-domain.com www.your-domain.com;
    root $PROJECT_PATH/public;

    add_header X-Frame-Options "SAMEORIGIN";
    add_header X-Content-Type-Options "nosniff";

    index index.php;

    charset utf-8;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt  { access_log off; log_not_found off; }

    error_page 404 /index.php;

    location ~ \.php$ {
        fastcgi_pass unix:/var/run/php/php8.2-fpm.sock;
        fastcgi_param SCRIPT_FILENAME \$realpath_root\$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\.(?!well-known).* {
        deny all;
    }
}
EOF

# Enable site
sudo ln -sf $NGINX_CONFIG /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default

# Test nginx configuration
sudo nginx -t

# Restart nginx
sudo systemctl restart nginx
sudo systemctl enable nginx

# ===================================================================
# 9. SETUP SSH KEY UNTUK GITHUB ACTIONS
# ===================================================================
echo "🔑 Setting up SSH key for GitHub Actions..."

# Generate SSH key jika belum ada
if [ ! -f ~/.ssh/id_ed25519 ]; then
    ssh-keygen -t ed25519 -C "github-actions" -f ~/.ssh/id_ed25519 -N ""
    cat ~/.ssh/id_ed25519.pub >> ~/.ssh/authorized_keys
    chmod 600 ~/.ssh/authorized_keys
    echo "✅ SSH key generated"
fi

echo ""
echo "🔐 PRIVATE SSH KEY - Copy this to GitHub Secrets (SERVER_SSH_KEY):"
echo "=================================================================="
cat ~/.ssh/id_ed25519
echo "=================================================================="
echo ""

# ===================================================================
# 10. SETUP GIT CONFIG
# ===================================================================
echo "⚙️ Configuring Git..."
cd $PROJECT_PATH
sudo git config --local pull.rebase false
sudo git config --local core.fileMode false

# ===================================================================
# SELESAI!
# ===================================================================
echo ""
echo "✅ =========================================="
echo "✅  SERVER SETUP COMPLETED!"
echo "✅ =========================================="
echo ""
echo "📝 INFORMASI PENTING:"
echo "   - Project Path: $PROJECT_PATH"
echo "   - Database Name: $DB_NAME"
echo "   - Database User: $DB_USER"
echo "   - Database Password: $DB_PASSWORD"
echo ""
echo "🔐 LANGKAH SELANJUTNYA:"
echo "   1. Copy PRIVATE SSH KEY di atas ke GitHub Secrets"
echo "   2. Setup GitHub Secrets berikut:"
echo "      - SERVER_HOST: $(curl -s ifconfig.me)"
echo "      - SERVER_USERNAME: $(whoami)"
echo "      - SERVER_SSH_KEY: (private key di atas)"
echo "      - SERVER_PORT: 22"
echo "      - SERVER_PATH: $PROJECT_PATH"
echo ""
echo "   3. Edit Nginx config untuk domain Anda:"
echo "      sudo nano /etc/nginx/sites-available/laravel"
echo "      (Ganti 'your-domain.com' dengan domain Anda)"
echo ""
echo "   4. Restart Nginx:"
echo "      sudo systemctl restart nginx"
echo ""
echo "   5. Test deployment dengan push ke GitHub!"
echo ""
echo "🌐 IP Server Anda: $(curl -s ifconfig.me)"
echo ""
