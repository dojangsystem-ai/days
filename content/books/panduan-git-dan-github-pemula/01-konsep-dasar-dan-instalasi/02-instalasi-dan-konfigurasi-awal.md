---
title: "Bab 1.2: Instalasi & Konfigurasi Awal Lingkungan Kerja"
slug: "02-instalasi-dan-konfigurasi-awal"
date: "2026-10-10"
author: "System Architect & Content Engineering Agent"
tags: ["git", "installation", "git-config", "setup"]
category: "Technical Books"
status: "published"
---

# Bab 1.2: Instalasi & Konfigurasi Awal Lingkungan Kerja

Sebelum mulai mengendalikan versi kode, kita perlu menginstal perangkat lunak Git di komputer lokal dan mengonfigurasi identitas pengembang. Identitas ini sangat penting karena setiap *commit* yang Anda buat akan mencantumkan nama dan email sebagai tanda tangan permanen.

---

## 1. Panduan Instalasi Git

### Windows
1. Unduh installer resmi dari situs web [git-scm.com](https://git-scm.com/download/win).
2. Jalankan berkas `.exe` yang diunduh.
3. Pada opsi instalasi, disarankan untuk memilih pengaturan standar (*default*), dan pastikan opsi **Git Bash** tercentang.
4. Selesaikan proses instalasi hingga tombol *Finish*.

### macOS
Jika Anda menggunakan macOS dan sudah memiliki Xcode Command Line Tools, Git mungkin sudah terpasang. Untuk menginstalnya secara manual via Homebrew:
```bash
brew install git
```

### Linux (Ubuntu / Debian)
Jalankan perintah berikut di terminal Linux:
```bash
sudo apt update
sudo apt install git -y
```

### Verifikasi Instalasi
Buka Terminal (atau Git Bash di Windows), lalu ketikkan perintah berikut untuk memastikan Git sudah terpasang dengan benar:

```bash
git --version
```

**Contoh Output:**
```text
git version 2.43.0
```

---

## 2. Konfigurasi Identitas Pengembang (`git config`)

Saat Anda melakukan simpanan (*commit*), Git akan mencatat **siapa** yang melakukan perubahan tersebut. Konfigurasi ini cukup dilakukan **satu kali** saat pertama kali menggunakan Git di komputer Anda.

### A. Mengatur Nama dan Email Global
Jalankan dua perintah berikut di Terminal / Git Bash (ganti teks di dalam tanda kutip dengan nama dan email akun GitHub Anda):

```bash
git config --global user.name "Nama Lengkap Anda"
git config --global user.email "email-anda@example.com"
```

> [!IMPORTANT]
> Pastikan alamat email yang Anda masukkan di `user.email` sama persis dengan email yang terdaftar di akun **GitHub** Anda. Ini bertujuan agar commit dari komputer lokal secara otomatis terhubung dengan profil GitHub Anda.

### B. Mengatur Nama Branch Utama ke `main`
Secara historis, nama branch bawaan Git adalah `master`. Industri software standar saat ini menggunakan `main`. Atur default branch dengan perintah:

```bash
git config --global init.defaultBranch main
```

### C. Memeriksa Konfigurasi yang Tersimpan
Untuk melihat seluruh daftar konfigurasi Git yang sedang aktif:

```bash
git config --list
```

**Output Contoh:**
```text
user.name=Budi Pratama
user.email=budi.pratama@example.com
init.defaultbranch=main
```

---

## 3. Otentikasi GitHub: Personal Access Token & SSH Key

Saat melakukan integrasi ke GitHub di masa mendatang, GitHub tidak lagi menerima password akun biasa demi alasan keamanan. Terdapat dua pilihan metode otentikasi utama:

1. **HTTPS dengan Personal Access Token (PAT):**
   - Dibuat via menu **Settings > Developer Settings > Personal Access Tokens** di GitHub.
   - Digunakan sebagai pengganti kata sandi saat Terminal meminta otentikasi.
2. **SSH Key (Rekomendasi Terbaik):**
   - Menggunakan pasangan kunci kriptografi publik dan privat.
   - Sekali diatur, Anda tidak perlu lagi memasukkan token atau kredensial saat melakukan upload/download kode.

### Cara Cepat Membuat SSH Key:
```bash
ssh-keygen -t ed25519 -C "email-anda@example.com"
```
Tekan `Enter` untuk menyetujui lokasi penyimpan standar, lalu salin isi dari berkas publik (`~/.ssh/id_ed25519.pub`) dan tempelkan pada menu **GitHub Settings > SSH and GPG keys**.

---

## Ringkasan Bab

- Perintah `git --version` digunakan untuk memverifikasi pemasangan Git.
- Perintah `git config --global user.name` dan `user.email` wajib diisi sebagai identitas pembuat commit.
- Inisialisasi default branch sebaiknya diset ke `main`.
- Otentikasi ke GitHub paling aman dan nyaman menggunakan **SSH Key**.

---

[← Subbab Sebelumnya](01-apa-itu-git-dan-github.md) | [Daftar Isi](../_index.md) | [Subbab Selanjutnya →](../02-lifecycle-git-lokal/01-empat-area-utama-git.md)
