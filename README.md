# Mini E-Wallet

Mini E-Wallet adalah implementasi take-home test Fullstack Developer yang mencakup:

- backend API
- database
- web frontend
- mobile frontend (nilai tambah)
- integrasi antar komponen
- keamanan dasar aplikasi
- konsistensi data transfer

Project ini terdiri dari dua aplikasi:

- `web/mini-e-wallet` → Laravel + Inertia React (web + API)
- `mobile/mini_e_wallet` → Flutter (mobile)

## Fitur

### Web

- Login menggunakan email dan password
- Redirect root `/` ke `/login` jika guest, atau ke `/dashboard` jika sudah login
- Dashboard menampilkan nama user dan saldo aktif
- Transfer dana ke user lain
- Riwayat transaksi dengan sorting dan pagination
- Error handling dan loading state pada form transfer

### API

- Login berbasis bearer token menggunakan Laravel Sanctum
- Dashboard summary untuk mobile
- Daftar penerima transfer
- Submit transfer
- Riwayat transaksi dengan sorting dan pagination
- Logout API

### Mobile

- Login ke API `POST /api/v1/auth/login`
- Dashboard mobile yang menampilkan nama dan saldo dari backend
- Transfer page dengan daftar penerima, nominal, quick amount, dan submit transfer
- History page dengan default sorting terbaru dan pagination 10 item per halaman
- Popup profile + logout

## Stack Teknologi

### Backend / Web

- PHP 8.3+
- Laravel 13
- Laravel Fortify
- Laravel Sanctum
- Inertia.js
- React + TypeScript
- Tailwind CSS
- MySQL / MariaDB

### Mobile

- Flutter
- Dart
- `http`
- `shared_preferences`

## Struktur Project

```text
mini_e_wallet/
├── README.md
├── mobile/
│   └── mini_e_wallet/
└── web/
    └── mini-e-wallet/
```

### Struktur Web

```text
web/mini-e-wallet/
├── app/
│   ├── Http/Controllers/
│   ├── Http/Requests/
│   ├── Http/Resources/Api/V1/
│   ├── Models/
│   └── Providers/
├── bootstrap/
├── config/
├── database/
│   ├── migrations/
│   └── seeders/
├── resources/
│   └── js/
├── routes/
│   ├── api.php
│   ├── settings.php
│   └── web.php
└── tests/
```

### Struktur Mobile

```text
mobile/mini_e_wallet/lib/src/
├── core/
│   └── config/
├── pages/
│   ├── auth/
│   ├── history/
│   ├── home/
│   └── transfer/
└── widgets/
```

## Cara Menjalankan Aplikasi

## 1) Menjalankan Web + API

Masuk ke folder project web:

```bash
cd web/mini-e-wallet
```

### Instalasi dependency

```bash
composer install
npm install
```

### Konfigurasi environment

Copy file environment:

```bash
cp .env.example .env
```

Generate app key:

```bash
php artisan key:generate
```

Atur koneksi database di `.env`, contoh:

```env
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=mini_e_wallet
DB_USERNAME=root
DB_PASSWORD=
```

### Migration dan seeding

```bash
php artisan migrate:fresh --seed
```

Seeder akan membuat 3 user awal dengan wallet saldo `100000` masing-masing.

### Menjalankan web

Terminal 1:

```bash
php artisan serve
```

Terminal 2:

```bash
npm run dev
```

Akses aplikasi web di:

```text
http://127.0.0.1:8000
```

## 2) Menjalankan Mobile Flutter

Masuk ke folder project mobile:

```bash
cd mobile/mini_e_wallet
```

Install dependency Flutter:

```bash
flutter pub get
```

### Base URL API

Secara default aplikasi mobile menggunakan:

```text
http://10.0.2.2:8000/api/v1
```

Nilai tersebut cocok untuk **Android emulator** jika Laravel dijalankan di laptop lokal pada port `8000`.

Kalau ingin override manual:

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000/api/v1
```

Contoh lain:

- iOS Simulator: `http://127.0.0.1:8000/api/v1`
- Real device: `http://<IP-LAPTOP-ANDA>:8000/api/v1`

### Menjalankan mobile

```bash
flutter run
```

## Akun Awal

Seeder menyediakan akun berikut:

- `usera@example.com`
- `userb@example.com`
- `userc@example.com`

Password untuk semua akun:

```text
password
```

Saldo awal masing-masing user:

```text
Rp 100.000
```

## API Endpoint

Base path:

```text
/api/v1
```

### Auth

- `POST /api/v1/auth/login`
- `POST /api/v1/auth/logout`

### Dashboard

- `GET /api/v1/dashboard`

### Transfer

- `GET /api/v1/recipients`
- `POST /api/v1/transfers`

### History

- `GET /api/v1/transactions?sort=desc&per_page=10&page=1`

## Cara Test API via Postman

### Login

Request:

```http
POST /api/v1/auth/login
Accept: application/json
Content-Type: application/json
```

Body:

```json
{
  "email": "usera@example.com",
  "password": "password"
}
```

Response sukses akan mengembalikan:

- `token`
- `token_type`
- `user`

Gunakan token tersebut pada header berikut:

```http
Authorization: Bearer <token>
```

### Dashboard

```http
GET /api/v1/dashboard
```

### Recipients

```http
GET /api/v1/recipients
```

### Transfer

```http
POST /api/v1/transfers
Content-Type: application/json
Authorization: Bearer <token>
```

Body contoh:

```json
{
  "recipient_user_id": 2,
  "amount": 25000
}
```

### Transactions

```http
GET /api/v1/transactions?sort=desc&per_page=10&page=1
```

## Penjelasan Teknis

## Desain Data

### `users`

Menyimpan data autentikasi user.

### `wallets`

Saldo dipisahkan dari tabel `users` agar domain wallet lebih eksplisit dan lebih mudah dikembangkan.

Kolom penting:

- `uuid`
- `user_id`
- `balance`

### `transfers`

Menyimpan histori perpindahan dana.

Kolom penting:

- `uuid`
- `reference_id`
- `sender_user_id`
- `sender_wallet_id`
- `recipient_user_id`
- `recipient_wallet_id`
- `amount`
- `transferred_at`

### `personal_access_tokens`

Dipakai Sanctum untuk autentikasi API mobile.

## Keputusan Desain

### 1. Wallet dipisah dari `users`

Alasan:

- domain saldo lebih jelas
- lebih mudah jika nanti ada multi-wallet atau ledger lain
- menghindari tabel `users` menjadi terlalu gemuk

### 2. Transfer memakai database transaction + `lockForUpdate`

Transfer adalah operasi sensitif yang harus konsisten.

Pendekatan ini dipakai agar:

- debit dan kredit terjadi atomik
- race condition pada saldo berkurang
- aman untuk fondasi sistem yang akan diakses banyak user secara bersamaan

### 3. UUID pada tabel domain

UUID ditambahkan pada entitas utama agar lebih aman dan lebih nyaman jika nanti resource diekspos lintas platform.

### 4. `reference_id` unik pada transfer

Setiap transfer punya identifier unik untuk membedakan transaksi satu dengan lainnya, sekaligus bisa ditampilkan di UI web dan mobile.

### 5. API mobile dipisahkan di `/api/v1`

API dibuat terpisah dari flow web Inertia agar:

- mudah dikonsumsi Flutter
- kontrak JSON lebih stabil
- evolusi API lebih aman dengan versioning

### 6. Sanctum untuk mobile token auth

Sanctum dipilih karena sederhana, native untuk Laravel, dan cukup untuk kebutuhan token bearer pada aplikasi mobile ini.

### 7. Shared shell pada mobile

Mobile memakai top nav dan bottom nav reusable supaya page dashboard, transfer, dan history punya struktur tampilan yang konsisten.

## Validasi Bisnis Transfer

Aturan yang diterapkan:

- tidak boleh transfer ke akun sendiri
- nominal harus lebih besar dari nol
- saldo pengirim harus mencukupi
- wallet pengirim dan penerima harus tersedia

## Konsistensi UI/UX

Baik di web maupun mobile, saya menjaga beberapa prinsip berikut:

- error message dibuat spesifik
- loading state tampil saat request diproses
- saldo dan riwayat diperbarui setelah transfer berhasil
- desain tidak berlebihan, fokus pada keterbacaan dan kejelasan flow

## Asumsi yang Digunakan

- Aplikasi ini menggunakan satu mata uang rupiah (`IDR`)
- Semua nominal disimpan sebagai integer
- Transfer dianggap selalu berhasil jika transaction commit selesai
- Tidak ada fitur top up / withdraw pada scope saat ini
- Satu user memiliki satu wallet
- Mobile saat ini menggunakan bearer token yang disimpan lokal menggunakan `SharedPreferences`
- Mobile belum mengimplementasikan auto-login saat app dibuka ulang; token sudah disimpan dan siap dipakai untuk pengembangan tahap berikutnya

## Fitur yang Sudah Tercakup vs Brief

Sesuai brief, implementasi ini sudah mencakup:

- login
- dashboard nama + saldo
- transfer dana
- riwayat transaksi
- pagination
- sorting tanggal
- initial seed data
- loading state
- form validation
- informative error message
- update saldo/riwayat setelah transfer
- identifier unik transaksi
- web frontend
- backend API
- mobile frontend sebagai nilai tambah

## Pengumpulan

Dokumen pengumpulan yang diminta brief dapat diambil dari project ini:

- repository source code
- `README.md` ini
- migration database di `web/mini-e-wallet/database/migrations`
- implementasi web dan mobile
