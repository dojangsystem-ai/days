---
title: "FR-01: Autentikasi Cerdas Berbasis Peran & Single Sign-On"
slug: "dojang-management-fr-01"
date: "2026-10-12"
author: "System Architect Agent"
tags: ["auth", "sso", "jwt", "rbac", "security"]
category: "Product Spec"
status: "draft"
priority: "P0"
complexity: "High"
estimated_effort: "1-2 weeks"
---

# FR-01: Autentikasi Cerdas Berbasis Peran & Single Sign-On (Smart Role SSO)

## 1. User Story

- **As a** pengguna terdaftar (Pemilik Dojang, Pelatih, Atlet, Wali Murid, atau Pengurus Federasi),
- **I want to** melakukan login dari satu pintu masuk utama (`/login`) dan secara otomatis dialihkan ke antarmuka aplikasi yang sesuai dengan peran dan lisensi saya,
- **So that** saya tidak perlu menghafal banyak alamat URL terpisah atau mengalami kegagalan akses akibat salah memilih portal.

---

## 2. Acceptance Criteria (Gherkin)

```gherkin
Feature: Smart Role Authentication and Redirection

  Scenario: Berhasil login sebagai Admin Dojang reguler
    Given pengguna berada di halaman login "/login"
    When pengguna memasukkan email "admin@tigers.dojang.id" dan password valid
    Then sistem mengautentikasi kredensial dan menerbitkan access token JWT serta refresh token HttpOnly
    And sistem mengembalikan metadata peran "DojangAdmin" dan status tipe dojang "regular"
    And pengguna secara otomatis diarahkan ke URL "/admin/dashboard"

  Scenario: Berhasil login sebagai Pelatih (Coach/Sabeum)
    Given pengguna berada di halaman login "/login"
    When pengguna memasukkan kredensial nomor ponsel atau email pelatih yang valid
    Then sistem memverifikasi lisensi instruktur aktif
    And pengguna secara otomatis diarahkan ke URL "/coach/dashboard"

  Scenario: Berhasil login sebagai Pengurus Federasi / Executive
    Given pengguna berada di halaman login "/login"
    When pengguna memasukkan kredensial Pengcab atau Pengprov yang sah
    Then sistem mendeteksi peran yurisdiksi federasi
    And pengguna secara otomatis diarahkan ke URL "/executive/select-module"

  Scenario: Gagal login karena kredensial tidak valid
    Given pengguna memasukkan email yang terdaftar namun password keliru
    When request login dikirim ke sistem
    Then sistem menolak autentikasi dan merespons dengan HTTP status 401 Unauthorized
    And menampilkan pesan error yang aman tanpa mengekspos eksistensi user

  Scenario: Rate limiting proteksi Brute Force
    Given sebuah IP client melakukan percobaan login gagal sebanyak 5 kali berturut-turut dalam kurun 1 menit
    When request login ke-6 dikirim
    Then sistem menolak permintaan dengan HTTP status 429 Too Many Requests
    And mengembalikan header "Retry-After" sebesar 60 detik
```

---

## 3. Spesifikasi Endpoint API

### `POST /api/v1/auth/login`

- **Deskripsi:** Mengautentikasi pengguna dan mengembalikan token serta rute target redirect otomatis.
- **Headers:**
  - `Content-Type: application/json`
  - `X-Client-Device: web | mobile_pwa`

#### Request Payload:
```json
{
  "identifier": "sabeum.hendra@tigers.dojang.id",
  "password": "PasswordRahasia#2026",
  "remember_me": true
}
```

#### Response Payloads:

##### `200 OK` (Autentikasi Berhasil):
```json
{
  "status": "success",
  "data": {
    "user": {
      "id": "c7a840e1-4b13-41ef-8fa6-5e0031899a11",
      "email": "sabeum.hendra@tigers.dojang.id",
      "full_name": "Hendra Prasetya",
      "phone": "+6281234567890",
      "roles": ["instructor", "coach"],
      "primary_dojang": {
        "id": "d03e913a-7d4e-4f28-b80c-7b0b6cf517e4",
        "name": "Tigers Taekwondo Club",
        "is_federation_hub": false
      }
    },
    "token": {
      "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
      "token_type": "Bearer",
      "expires_in": 900
    },
    "redirect_url": "/coach/dashboard"
  }
}
```

##### `400 Bad Request` (Validasi Gagal):
```json
{
  "status": "error",
  "code": "VALIDATION_FAILED",
  "message": "Field 'identifier' dan 'password' wajib diisi dengan benar."
}
```

##### `401 Unauthorized` (Kredensial Keliru):
```json
{
  "status": "error",
  "code": "INVALID_CREDENTIALS",
  "message": "Email/Nomor telepon atau kata sandi yang Anda masukkan salah."
}
```

##### `500 Internal Server Error`:
```json
{
  "status": "error",
  "code": "INTERNAL_SERVER_ERROR",
  "message": "Terjadi gangguan pada auth cluster. Silakan hubungi dukungan teknis."
}
```

---

## 4. Edge Cases & Failure Modes

1. **Akun Multi-Peran:** Jika seorang pengguna memiliki peran ganda (misal: merangkap Pemilik Dojang sekaligus Pengurus Pengcab), sistem menyediakan selector modal transisi peran setelah login tanpa perlu relogin.
2. **Sesi Kadaluarsa saat Pertandingan:** Pada terminal scoring arena dan tablet penguji, jika access token kadaluarsa (15 menit), sistem melakukan *silent refresh token* di background tanpa menginterupsi jalannya pertandingan.
3. **PWA Offline Recovery:** Saat koneksi ponsel pelatih terputus di dalam gedung olahraga, kredensial lokal yang telah terenkripsi di IndexedDB mempertahankan sesi hingga konektivitas pulih.

---

## Navigasi Modul & Fitur

[← Dokumen Sebelumnya](../02-value-system-and-monetization.md) | [Ikhtisar Sistem](../00-overview.md) | [Fitur Selanjutnya →](FR-02-dojang-operational-management.md)
