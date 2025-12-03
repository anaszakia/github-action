#!/bin/bash

# ===================================================================
# Quick Setup Script untuk Shared Hosting
# Jalankan script ini di server shared hosting Anda
# ===================================================================

echo "🚀 Starting Shared Hosting Setup..."

# ===================================================================
# Auto-detect informasi server
# ===================================================================

CURRENT_USER=$(whoami)
CURRENT_HOME=$HOME
PROJECT_DIR=$(pwd)

echo ""
echo "📋 Informasi Server:"
echo "   Username: $CURRENT_USER"
echo "   Home Directory: $CURRENT_HOME"
echo "   Project Directory: $PROJECT_DIR"
echo ""

# ===================================================================
# 1. GENERATE SSH KEY
# ===================================================================

echo "🔑 Setting up SSH key for GitHub Actions..."

if [ ! -f ~/.ssh/id_ed25519 ]; then
    ssh-keygen -t ed25519 -C "github-actions" -f ~/.ssh/id_ed25519 -N ""
    echo "✅ SSH key generated"
else
    echo "✅ SSH key already exists"
fi

# Add to authorized_keys
cat ~/.ssh/id_ed25519.pub >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
chmod 700 ~/.ssh

echo ""
echo "🔐 COPY PRIVATE KEY INI KE GITHUB SECRETS (SERVER_SSH_KEY):"
echo "=================================================================="
cat ~/.ssh/id_ed25519
echo "=================================================================="
echo ""

# ===================================================================
# 2. SETUP .ENV FILE
# ===================================================================

echo "📝 Setting up .env file..."

if [ ! -f .env ]; then
    if [ -f .env.example ]; then
        cp .env.example .env
        echo "✅ .env file created from .env.example"
        
        # Generate app key
        php artisan key:generate
        echo "✅ Application key generated"
    else
        echo "⚠️  .env.example not found. Please create .env manually."
    fi
else
    echo "✅ .env file already exists"
fi

# ===================================================================
# 3. INSTALL COMPOSER DEPENDENCIES
# ===================================================================

echo "📦 Installing Composer dependencies..."

# Check if composer exists
if command -v composer &> /dev/null; then
    COMPOSER_CMD="composer"
elif [ -f ~/composer.phar ]; then
    COMPOSER_CMD="php ~/composer.phar"
elif [ -f composer.phar ]; then
    COMPOSER_CMD="php composer.phar"
else
    echo "⚠️  Composer not found. Installing composer..."
    curl -sS https://getcomposer.org/installer | php
    COMPOSER_CMD="php composer.phar"
fi

$COMPOSER_CMD install --no-interaction --prefer-dist --optimize-autoloader

echo "✅ Composer dependencies installed"

# ===================================================================
# 4. SETUP LARAVEL
# ===================================================================

echo "⚙️ Setting up Laravel..."

# Create storage link
if [ ! -L public/storage ]; then
    php artisan storage:link
    echo "✅ Storage link created"
else
    echo "✅ Storage link already exists"
fi

# Set permissions
chmod -R 755 storage bootstrap/cache
echo "✅ Permissions set"

# ===================================================================
# 5. SETUP GIT CONFIG
# ===================================================================

echo "⚙️ Configuring Git..."

git config --local pull.rebase false
git config --local core.fileMode false

echo "✅ Git configured"

# ===================================================================
# 6. CHECK DATABASE (OPTIONAL - COMMENTED)
# ===================================================================

# Uncomment jika ingin auto-run migration
# echo "🗄️ Running migrations..."
# php artisan migrate --force
# echo "✅ Migrations completed"

# ===================================================================
# INFO UNTUK GITHUB SECRETS
# ===================================================================

# Get server hostname
if command -v hostname &> /dev/null; then
    SERVER_HOST=$(hostname -f)
else
    SERVER_HOST=$(cat /etc/hostname 2>/dev/null || echo "your-server-hostname")
fi

echo ""
echo "✅ =========================================="
echo "✅  SETUP COMPLETED!"
echo "✅ =========================================="
echo ""
echo "📝 COPY INFORMASI INI KE GITHUB SECRETS:"
echo ""
echo "1. SERVER_HOST"
echo "   Nilai: $SERVER_HOST"
echo "   (atau gunakan domain/IP yang Anda gunakan untuk SSH)"
echo ""
echo "2. SERVER_USERNAME"
echo "   Nilai: $CURRENT_USER"
echo ""
echo "3. SERVER_SSH_KEY"
echo "   Nilai: (Private key yang ditampilkan di atas)"
echo "   Copy dari -----BEGIN sampai -----END"
echo ""
echo "4. SERVER_PORT"
echo "   Nilai: 22"
echo ""
echo "5. SERVER_PATH"
echo "   Nilai: $PROJECT_DIR"
echo ""
echo "📋 LANGKAH SELANJUTNYA:"
echo ""
echo "1. Edit .env file untuk database:"
echo "   nano .env"
echo "   (Set DB_DATABASE, DB_USERNAME, DB_PASSWORD)"
echo ""
echo "2. Run migrations (jika sudah setup database):"
echo "   php artisan migrate"
echo ""
echo "3. Tambahkan 5 GitHub Secrets di:"
echo "   GitHub Repository → Settings → Secrets and variables → Actions"
echo ""
echo "4. Test deployment dengan push ke GitHub!"
echo "   git push origin main"
echo ""
echo "🎉 Setelah itu, setiap push akan otomatis deploy ke server!"
echo ""
