# 🚀 Setup GitHub Actions untuk Shared Hosting

## ✅ Yang Sudah Dilakukan

Anda sudah clone project di: `ga.anaszakiaar.dhan.my.id`

## 📝 Langkah Setup (Ikuti Step-by-Step)

### Step 1: Setup SSH Key di Server

SSH ke server Anda dan generate SSH key:

```bash
ssh u364194548@id-dci-web1409.ga.anaszakiaardhan.my.id

# Generate SSH key
ssh-keygen -t ed25519 -C "github-actions" -f ~/.ssh/id_ed25519 -N ""

# Tambahkan public key ke authorized_keys
cat ~/.ssh/id_ed25519.pub >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
chmod 700 ~/.ssh

# Tampilkan private key (COPY INI untuk GitHub Secrets)
cat ~/.ssh/id_ed25519
```

**📋 COPY SEMUA ISI FILE** dari `-----BEGIN` sampai `-----END` (termasuk header/footer).

---

### Step 2: Setup Environment (.env) di Server

```bash
# Masuk ke directory project
cd ~/ga.anaszakiaar.dhan.my.id

# Copy .env
cp .env.example .env

# Generate application key
php artisan key:generate

# Edit .env untuk database
nano .env
```

Edit bagian database di `.env`:

```env
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=u364194548_nama_database_anda
DB_USERNAME=u364194548_db_user
DB_PASSWORD=password_database_anda
```

**Ganti dengan kredensial database dari cPanel Anda!**

Save file (Ctrl+X, Y, Enter).

---

### Step 3: Install Dependencies & Setup Laravel

```bash
# Masuk ke directory project
cd ~/ga.anaszakiaar.dhan.my.id

# Install composer dependencies
composer install --no-interaction --prefer-dist --optimize-autoloader

# Create storage link
php artisan storage:link

# Run migrations
php artisan migrate

# Set permissions
chmod -R 755 storage bootstrap/cache
```

---

### Step 4: Setup GitHub Secrets

1. Buka repository GitHub: https://github.com/anaszakia/github-action
2. Klik **Settings** (tab atas)
3. Klik **Secrets and variables** → **Actions** (sidebar kiri)
4. Klik tombol **New repository secret**

Tambahkan **5 secrets** berikut:

#### Secret 1: SERVER_HOST
```
Nilai: id-dci-web1409.ga.anaszakiaardhan.my.id
```

#### Secret 2: SERVER_USERNAME
```
Nilai: u364194548
```

#### Secret 3: SERVER_SSH_KEY
```
Nilai: (Paste PRIVATE KEY dari Step 1)
Paste seluruh isi dari cat ~/.ssh/id_ed25519
Termasuk:
-----BEGIN OPENSSH PRIVATE KEY-----
...
-----END OPENSSH PRIVATE KEY-----
```

#### Secret 4: SERVER_PORT
```
Nilai: 22
```

#### Secret 5: SERVER_PATH
```
Nilai: /home/u364194548/ga.anaszakiaar.dhan.my.id
```

**Screenshot setiap secret setelah dibuat untuk memastikan benar!**

---

### Step 5: Update Git Config di Server

```bash
# Masuk ke directory project
cd ~/ga.anaszakiaar.dhan.my.id

# Setup git config
git config --local pull.rebase false
git config --local core.fileMode false

# Cek remote
git remote -v
```

Pastikan remote sudah mengarah ke repository GitHub yang benar.

---

### Step 6: Test Deployment!

Sekarang test apakah GitHub Actions berjalan:

#### Di Local (Windows):

```powershell
# Buat perubahan kecil
# Edit file README.md atau buat file test.txt

git add .
git commit -m "test: deployment to shared hosting"
git push origin main
```

#### Monitor Deployment:

1. **Di GitHub**: 
   - Buka https://github.com/anaszakia/github-action/actions
   - Lihat workflow yang berjalan
   - Tunggu sampai selesai (ada tanda ✅ hijau)

2. **Di Server** (SSH):
   ```bash
   # Cek apakah perubahan masuk
   cd ~/ga.anaszakiaar.dhan.my.id
   git log -1
   
   # Lihat file terakhir yang berubah
   ls -lt | head
   ```

---

## 🎯 Checklist Final

Sebelum test deployment, pastikan:

- [ ] SSH key sudah digenerate dan ditambahkan
- [ ] File `.env` sudah ada dan database sudah dikonfigurasi
- [ ] `composer install` sudah dijalankan
- [ ] `php artisan storage:link` sudah dijalankan
- [ ] Migrations sudah dijalankan
- [ ] 5 GitHub Secrets sudah ditambahkan semua
- [ ] Git config sudah disetup di server
- [ ] Branch `main` di server sudah up-to-date

---

## 🐛 Troubleshooting

### Error: Permission denied (publickey)

**Penyebab**: Private key tidak valid atau authorized_keys salah

**Solusi**:
```bash
# Cek authorized_keys
cat ~/.ssh/authorized_keys

# Cek permissions
ls -la ~/.ssh/
# Harus:
# drwx------ untuk .ssh/ (700)
# -rw------- untuk authorized_keys (600)

# Fix permissions jika perlu
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
```

### Error: composer: command not found

**Penyebab**: Composer tidak ada di PATH atau belum terinstall

**Solusi**:
```bash
# Cek apakah composer terinstall
which composer
composer --version

# Jika tidak ada, cek di home directory
ls -la ~/composer.phar

# Buat alias (tambahkan ke ~/.bashrc)
echo 'alias composer="php ~/composer.phar"' >> ~/.bashrc
source ~/.bashrc
```

Atau ubah workflow file untuk menggunakan `php ~/composer.phar` instead of `composer`.

### Error: php artisan command failed

**Penyebab**: Database tidak terkoneksi atau .env salah

**Solusi**:
```bash
cd ~/ga.anaszakiaar.dhan.my.id

# Test koneksi database
php artisan tinker
>>> DB::connection()->getPdo();
>>> exit

# Jika error, cek .env
cat .env | grep DB_

# Cek kredensial database di cPanel
```

### Deployment Success tapi Website Error 500

**Solusi**:
```bash
# Lihat error log Laravel
cd ~/ga.anaszakiaar.dhan.my.id
tail -50 storage/logs/laravel.log

# Clear cache
php artisan config:clear
php artisan cache:clear
php artisan route:clear
php artisan view:clear

# Re-cache
php artisan config:cache
php artisan route:cache
php artisan view:cache
```

---

## 📊 Command Berguna

### Cek Status Deployment

```bash
# Lihat commit terakhir
cd ~/ga.anaszakiaar.dhan.my.id
git log -1 --oneline

# Lihat status git
git status

# Lihat branch
git branch
```

### Manual Pull (Jika Perlu)

```bash
cd ~/ga.anaszakiaar.dhan.my.id

# Pull perubahan
git pull origin main

# Install dependencies
composer install --no-dev

# Run migrations
php artisan migrate --force

# Clear & cache
php artisan config:cache
php artisan route:cache
php artisan view:cache
```

### Rollback ke Commit Sebelumnya

```bash
cd ~/ga.anaszakiaar.dhan.my.id

# Lihat history
git log --oneline -10

# Reset ke commit tertentu (HATI-HATI!)
git reset --hard COMMIT_HASH

# Atau rollback 1 commit
git reset --hard HEAD~1
```

---

## 🎉 Setelah Setup Berhasil

Setelah test deployment berhasil, setiap kali Anda:

1. ✏️ Edit code di local
2. 💾 Commit & push ke GitHub
3. 🚀 GitHub Actions otomatis:
   - Pull code ke server
   - Install dependencies
   - Run migrations
   - Clear & optimize cache
   - **Website langsung update!**

**Anda tidak perlu SSH ke server lagi untuk deployment!** 🎊

---

## 📞 Info Penting

**Server Details:**
- Host: `id-dci-web1409.ga.anaszakiaardhan.my.id`
- User: `u364194548`
- Project Path: `/home/u364194548/ga.anaszakiaar.dhan.my.id`
- Port: `22`

**GitHub Repository:**
- URL: `https://github.com/anaszakia/github-action`
- Branch: `main`

**Lokasi File Workflow:**
- `.github/workflows/deploy.yml`

---

**Happy Auto-Deploying! 🚀**
