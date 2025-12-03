# 📦 Panduan Deployment dengan GitHub Actions

Proyek ini sudah dikonfigurasi untuk **otomatis deploy ke server** setiap kali ada push ke branch `main`.

## 🎯 Apa yang Akan Terjadi?

Setiap kali Anda **push code dari local ke GitHub**, GitHub Actions akan:
1. ✅ Otomatis pull code terbaru ke server
2. ✅ Install/update dependencies (composer)
3. ✅ Copy .env jika belum ada
4. ✅ Set permissions untuk storage
5. ✅ Create storage link
6. ✅ Clear semua cache
7. ✅ Run database migrations
8. ✅ Optimize aplikasi (cache config, routes, views)

**Anda TIDAK perlu SSH ke server dan menjalankan command manual lagi!** 🚀

---

## 🚀 Cara Setup (Pilih salah satu metode)

### Metode A: Setup Otomatis dengan Script (RECOMMENDED)

#### 1. Upload dan Jalankan Script di Server

```bash
# Di local, upload script ke server
scp setup-server.sh user@your-server-ip:/tmp/

# SSH ke server
ssh user@your-server-ip

# Jalankan script
cd /tmp
chmod +x setup-server.sh

# EDIT KONFIGURASI di dalam script terlebih dahulu!
nano setup-server.sh
# Edit bagian:
# - PROJECT_PATH="/var/www/html/myapp"
# - GITHUB_REPO="https://github.com/username/repository.git"
# - DB_NAME, DB_USER, DB_PASSWORD

# Jalankan script
sudo ./setup-server.sh
```

Script akan otomatis:
- Install PHP, Composer, MySQL, Nginx
- Create database dan user MySQL
- Clone project dari GitHub
- Setup Laravel (composer install, .env, migrations, dll)
- Configure Nginx
- Generate SSH key
- Tampilkan private key untuk GitHub Secrets

#### 2. Copy Private SSH Key

Setelah script selesai, akan muncul **PRIVATE SSH KEY**. Copy seluruh isinya (termasuk `-----BEGIN` dan `-----END`).

#### 3. Setup GitHub Secrets

Buka repository GitHub → **Settings** → **Secrets and variables** → **Actions** → **New repository secret**

Tambahkan 5 secrets berikut (informasi akan ditampilkan oleh script):

| Secret Name | Nilai dari Script |
|-------------|-------------------|
| `SERVER_HOST` | IP address server (ditampilkan di akhir script) |
| `SERVER_USERNAME` | Username SSH Anda (ditampilkan di akhir script) |
| `SERVER_SSH_KEY` | Private key yang muncul di output script | ssh-keygen -t ed25519 -C "your_email@example.com"
| `SERVER_PORT` | `22` |
| `SERVER_PATH` | Path project (sesuai PROJECT_PATH di script) |

#### 4. Edit Nginx Config untuk Domain

```bash
# Di server
sudo nano /etc/nginx/sites-available/laravel

# Ganti baris:
# server_name your-domain.com www.your-domain.com;
# Menjadi:
# server_name example.com www.example.com;

# Restart Nginx
sudo systemctl restart nginx
```

#### 5. Test Deployment!

```bash
# Di local
git add .
git commit -m "test: auto deployment"
git push origin main
```

Buka tab **Actions** di GitHub repository untuk melihat deployment berjalan!

---

### Metode B: Setup Manual Step-by-Step

Jika Anda ingin setup manual tanpa script:

#### 1. Install Requirements di Server

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install PHP 8.2 dan extensions
sudo apt install -y php8.2 php8.2-fpm php8.2-mysql php8.2-mbstring \
    php8.2-xml php8.2-curl php8.2-zip php8.2-gd php8.2-bcmath \
    php8.2-intl php8.2-cli unzip git curl

# Install Composer
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer
sudo chmod +x /usr/local/bin/composer

# Install MySQL
sudo apt install -y mysql-server
sudo systemctl start mysql
sudo systemctl enable mysql

# Install Nginx
sudo apt install -y nginx
```

#### 2. Create Database MySQL

```bash
# Login ke MySQL
sudo mysql

# Di MySQL prompt, jalankan:
CREATE DATABASE laravel_db;
CREATE USER 'laravel_user'@'localhost' IDENTIFIED BY 'password_kuat_anda';
GRANT ALL PRIVILEGES ON laravel_db.* TO 'laravel_user'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

#### 3. Clone Project dari GitHub

```bash
# Create directory
sudo mkdir -p /var/www/html

# Clone project
cd /var/www/html
sudo git clone https://github.com/username/repository.git myapp
cd myapp

# Setup git config
sudo git config --local pull.rebase false
sudo git config --local core.fileMode false
```

#### 4. Setup Laravel Project

```bash
cd /var/www/html/myapp

# Install dependencies
sudo composer install --no-interaction --prefer-dist --optimize-autoloader

# Copy .env
sudo cp .env.example .env

# Generate key
sudo php artisan key:generate

# Edit .env untuk database
sudo nano .env
# Edit baris berikut:
# DB_DATABASE=laravel_db
# DB_USERNAME=laravel_user
# DB_PASSWORD=password_kuat_anda

# Create storage link
sudo php artisan storage:link

# Run migrations
sudo php artisan migrate

# Set permissions
sudo chown -R www-data:www-data /var/www/html/myapp
sudo chmod -R 775 storage bootstrap/cache
```

#### 5. Configure Nginx

```bash
# Create config file
sudo nano /etc/nginx/sites-available/laravel
```

Paste konfigurasi berikut:

```nginx
server {
    listen 80;
    server_name your-domain.com www.your-domain.com;
    root /var/www/html/myapp/public;

    add_header X-Frame-Options "SAMEORIGIN";
    add_header X-Content-Type-Options "nosniff";

    index index.php;

    charset utf-8;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt  { access_log off; log_not_found off; }

    error_page 404 /index.php;

    location ~ \.php$ {
        fastcgi_pass unix:/var/run/php/php8.2-fpm.sock;
        fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\.(?!well-known).* {
        deny all;
    }
}
```

Enable site dan restart Nginx:

```bash
# Enable site
sudo ln -sf /etc/nginx/sites-available/laravel /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default

# Test config
sudo nginx -t

# Restart
sudo systemctl restart nginx
sudo systemctl enable nginx
```

#### 6. Generate SSH Key untuk GitHub Actions

```bash
# Generate key
ssh-keygen -t ed25519 -C "github-actions" -f ~/.ssh/id_ed25519 -N ""

# Add ke authorized_keys
cat ~/.ssh/id_ed25519.pub >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys

# Tampilkan private key (copy ini ke GitHub Secrets)
cat ~/.ssh/id_ed25519
```

#### 7. Setup GitHub Secrets

Copy private key di atas, lalu ke GitHub repository:

**Settings** → **Secrets and variables** → **Actions** → **New repository secret**

Tambahkan 5 secrets:

| Secret Name | Nilai |
|-------------|-------|
| `SERVER_HOST` | IP address server Anda (cek dengan: `curl ifconfig.me`) |
| `SERVER_USERNAME` | Username SSH Anda (cek dengan: `whoami`) |
| `SERVER_SSH_KEY` | Private key dari `cat ~/.ssh/id_ed25519` |
| `SERVER_PORT` | `22` |
| `SERVER_PATH` | `/var/www/html/myapp` |

#### 8. Test Deployment!

```bash
# Di local
git add .
git commit -m "test: auto deployment"
git push origin main
```

---

## 🔄 Cara Kerja GitHub Actions

File `.github/workflows/deploy.yml` sudah dikonfigurasi dengan script lengkap:

```yaml
script: |
  # Pull code terbaru
  cd /var/www/html/myapp
  git pull origin main
  
  # Copy .env jika belum ada
  if [ ! -f .env ]; then
      cp .env.example .env
      php artisan key:generate
  fi
  
  # Install dependencies
  composer install --no-dev
  
  # Set permissions
  chmod -R 775 storage bootstrap/cache
  chown -R www-data:www-data storage bootstrap/cache
  
  # Storage link
  php artisan storage:link
  
  # Clear cache
  php artisan cache:clear
  php artisan config:clear
  php artisan route:clear
  php artisan view:clear
  
  # Run migrations
  php artisan migrate --force
  
  # Optimize
  php artisan config:cache
  php artisan route:cache
  php artisan view:cache
  php artisan optimize
  
  # Restart queue
  php artisan queue:restart
```

**Semua ini berjalan OTOMATIS setiap push!** 🎉

## 📊 Monitoring Deployment

### Cara Cek Status Deployment:

1. **Di GitHub**:
   - Buka repository → Tab **Actions**
   - Lihat workflow yang sedang berjalan
   - Klik untuk lihat detail log
   - ✅ Hijau = Berhasil | ❌ Merah = Gagal

2. **Di Server**:
   ```bash
   # Cek git log terakhir
   cd /var/www/html/myapp
   git log -1
   
   # Cek Laravel logs
   tail -f storage/logs/laravel.log
   
   # Cek Nginx logs
   sudo tail -f /var/log/nginx/error.log
   ```

3. **Test di Browser**:
   - Akses http://your-server-ip atau http://your-domain.com
   - Pastikan aplikasi berjalan dengan baik

---

## ⚙️ Customisasi Deployment

### Mengubah Branch

Edit file `.github/workflows/deploy.yml`:

```yaml
on:
  push:
    branches:
      - main  # Ganti dengan branch Anda (master, production, dll)
```

### Menambah/Mengurangi Command Deployment

Edit bagian `script` di file `.github/workflows/deploy.yml`:

```yaml
script: |
  cd ${{ secrets.SERVER_PATH }}
  git pull origin main
  composer install --no-interaction --prefer-dist --optimize-autoloader --no-dev
  # Tambah command Anda di sini
  npm install  # Contoh: install npm packages
  npm run build  # Contoh: build assets
  php artisan config:cache
  php artisan route:cache
  php artisan view:cache
  php artisan migrate --force
  php artisan queue:restart
  php artisan optimize
```

### Menambah Command NPM (untuk build assets frontend)

Edit `.github/workflows/deploy.yml`, tambahkan setelah `composer install`:

```yaml
script: |
  cd ${{ secrets.SERVER_PATH }}
  git pull origin main
  
  # Install Composer dependencies
  composer install --no-interaction --prefer-dist --optimize-autoloader --no-dev
  
  # Install NPM dan build assets (TAMBAHKAN INI)
  npm install
  npm run build
  
  # Copy .env jika belum ada
  if [ ! -f .env ]; then
      cp .env.example .env
      php artisan key:generate
  fi
  
  # ... rest of the script
```

### Deploy ke Multiple Environments (Staging & Production)

### Deploy ke Multiple Environments (Staging & Production)

Buat 2 file workflow terpisah:

**`.github/workflows/deploy-staging.yml`** (trigger dari branch `develop`):
```yaml
on:
  push:
    branches:
      - develop
```

**`.github/workflows/deploy-production.yml`** (trigger dari branch `main`):
```yaml
on:
  push:
    branches:
      - main
```

Setup GitHub Secrets terpisah untuk masing-masing environment.

---

## 🐛 Troubleshooting

### ❌ Error: Permission Denied (publickey)

**Penyebab**: SSH key tidak valid atau belum ditambahkan

**Solusi**:
```bash
# Di server, cek authorized_keys
cat ~/.ssh/authorized_keys

# Pastikan public key ada di sana
cat ~/.ssh/id_ed25519.pub

# Jika belum ada, tambahkan:
cat ~/.ssh/id_ed25519.pub >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
```

Pastikan juga private key di GitHub Secrets lengkap (termasuk `-----BEGIN` dan `-----END`).

### ❌ Error: Could not resolve host

**Penyebab**: IP/Domain server salah di GitHub Secrets

**Solusi**:
```bash
# Cek IP server Anda
curl ifconfig.me

# Update SERVER_HOST di GitHub Secrets dengan IP yang benar
```

### ❌ Error: composer: command not found

**Penyebab**: Composer belum terinstall di server

**Solusi**:
```bash
# Install Composer di server
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer
sudo chmod +x /usr/local/bin/composer

# Verify
composer --version
```

### ❌ Error: php artisan migrate failed

**Penyebab**: Database tidak terkoneksi atau kredensial salah

**Solusi**:
```bash
# Di server, cek .env
cd /var/www/html/myapp
cat .env | grep DB_

# Test koneksi database
php artisan tinker
> DB::connection()->getPdo();

# Jika error, cek MySQL service
sudo systemctl status mysql

# Cek kredensial MySQL
sudo mysql
> SELECT User, Host FROM mysql.user;
```

### ❌ Error: Permission denied saat git pull

**Penyebab**: Permissions atau ownership salah

**Solusi**:
```bash
# Set ownership ke user yang menjalankan deployment
sudo chown -R $USER:$USER /var/www/html/myapp

# Atau jika menggunakan www-data:
sudo chown -R www-data:www-data /var/www/html/myapp

# Set permissions
chmod -R 775 /var/www/html/myapp
```

### ❌ Error: Local changes would be overwritten by merge

**Penyebab**: Ada perubahan lokal di server yang conflict dengan GitHub

**Solusi**:
```bash
# Di server, backup changes jika perlu
cd /var/www/html/myapp
git stash

# Atau reset ke commit terakhir (HATI-HATI: akan hapus perubahan lokal)
git reset --hard origin/main

# Pull lagi
git pull origin main
```

### ❌ Error: Storage not writable

**Penyebab**: Permissions storage salah

**Solusi**:
```bash
# Fix permissions
cd /var/www/html/myapp
sudo chmod -R 775 storage bootstrap/cache
sudo chown -R www-data:www-data storage bootstrap/cache

# Verify
ls -la storage/
```

### ⚠️ Deployment Success tapi Website Error 500

**Solusi**:
```bash
# Cek Laravel logs
tail -50 storage/logs/laravel.log

# Cek Nginx error logs
sudo tail -50 /var/log/nginx/error.log

# Clear all cache
php artisan cache:clear
php artisan config:clear
php artisan route:clear
php artisan view:clear

# Re-cache
php artisan config:cache
php artisan route:cache
php artisan view:cache
```

---

## 🎯 Checklist Sebelum First Deployment

Sebelum push pertama kali, pastikan:

- [ ] Server sudah setup (PHP, Composer, MySQL, Nginx)
- [ ] Database MySQL sudah dibuat
- [ ] Project sudah di-clone di server
- [ ] File `.env` sudah dikonfigurasi dengan benar
- [ ] SSH key sudah digenerate dan ditambahkan
- [ ] 5 GitHub Secrets sudah ditambahkan semua
- [ ] Nginx sudah dikonfigurasi dan running
- [ ] Permissions storage dan cache sudah benar
- [ ] Test SSH connection dari GitHub Actions (optional)

---

## 📞 Quick Reference

### Server Info yang Dibutuhkan:

```bash
# IP Address
curl ifconfig.me

# Username
whoami

# Project Path
pwd

# SSH Port (default)
22
```

### GitHub Secrets yang Harus Ditambahkan:

1. `SERVER_HOST` - IP server
2. `SERVER_USERNAME` - SSH username
3. `SERVER_SSH_KEY` - Private key dari `~/.ssh/id_ed25519`
4. `SERVER_PORT` - `22`
5. `SERVER_PATH` - `/var/www/html/myapp`

### Command Berguna di Server:

```bash
# Cek status deployment terakhir
cd /var/www/html/myapp
git log -1

# Lihat perubahan terbaru
git show

# Manual pull (jika perlu)
git pull origin main

# Restart services
sudo systemctl restart nginx
sudo systemctl restart php8.2-fpm

# Clear semua cache Laravel
php artisan optimize:clear
```

---

### Git Ignore Files yang Sensitif

Pastikan file berikut di-ignore (sudah ada di `.gitignore`):

- `.env` - Jangan commit file environment
- `vendor/` - Dependencies tidak perlu di-commit
- `node_modules/` - NPM packages tidak perlu di-commit
- `storage/` - File cache dan logs

### Setup Git Config di Server (Recommended)

Untuk menghindari conflict saat pull:

```bash
# Di server
cd /var/www/html/myapp
git config --local pull.rebase false
git config --local core.fileMode false
```

## 🐛 Troubleshooting

### Error: Permission Denied (publickey)

**Solusi**: Pastikan SSH key sudah ditambahkan dengan benar di GitHub Secrets dan authorized_keys di server.

### Error: Could not resolve host

**Solusi**: Cek `SERVER_HOST` di GitHub Secrets, pastikan IP/domain benar.

### Error: Permission denied saat composer install

**Solusi**: 
```bash
# Di server
sudo chown -R $USER:$USER /var/www/html/myapp
```

### Error: Please make sure you have the correct access rights

**Solusi**: Setup deploy key di server atau gunakan HTTPS dengan token untuk clone repository:

```bash
# Jika repository private, gunakan Personal Access Token
git remote set-url origin https://TOKEN@github.com/username/repo.git
```

### Git Pull Error: Local changes would be overwritten

**Solusi**: 
```bash
# Di server, stash atau reset local changes
git stash
# atau
git reset --hard origin/main
```

---

## 🔐 Tips Keamanan

### File yang Harus di-Ignore Git

Pastikan `.gitignore` mencakup:

```gitignore
.env
/vendor/
/node_modules/
/storage/*.key
/storage/logs/*.log
```

### Secure MySQL

```bash
# Run security script
sudo mysql_secure_installation

# Set strong password untuk database user
# Disable remote root access
```

### Setup Firewall (UFW)

```bash
# Enable firewall
sudo ufw enable

# Allow SSH, HTTP, HTTPS
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

# Check status
sudo ufw status
```

### Setup SSL/HTTPS (Optional tapi Recommended)

```bash
# Install Certbot
sudo apt install certbot python3-certbot-nginx

# Generate SSL certificate
sudo certbot --nginx -d your-domain.com -d www.your-domain.com

# Auto renewal
sudo systemctl enable certbot.timer
```

---

## ✅ Testing

Setelah setup, test deployment:

1. Buat perubahan kecil di local (misalnya edit README.md)
2. Commit dan push:
   ```bash
   git add .
   git commit -m "test: deployment automation"
   git push origin main
   ```
3. Buka GitHub Actions tab dan lihat workflow berjalan
4. Cek server untuk memastikan perubahan sudah masuk

## 🎯 Tips

- **Backup dulu**: Sebelum deploy pertama kali, backup database dan files di server
- **Test di staging dulu**: Setup environment staging untuk test deployment
- **Monitor logs**: Selalu cek logs di GitHub Actions dan server
- **Rollback plan**: Siapkan strategi rollback jika deployment bermasalah
- **Database backups**: Jalankan backup database sebelum migration

---

**Happy Deploying! 🚀**
