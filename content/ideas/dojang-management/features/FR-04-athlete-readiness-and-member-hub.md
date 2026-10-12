---
title: "FR-04: Athlete Readiness 5P, Pembayaran Iuran & Member Hub"
slug: "dojang-management-fr-04"
date: "2026-10-12"
author: "System Architect Agent"
tags: ["member", "readiness", "sports-science", "payments", "days"]
category: "Product Spec"
status: "draft"
priority: "P0"
complexity: "High"
estimated_effort: "2-3 weeks"
---

# FR-04: Athlete Readiness 5P, Pembayaran Iuran & Member Hub

> **Sistem:** DAYS ([dojang.warsootech.com](https://dojang.warsootech.com))

## 1. User Story

- **As a** Atlet, Murid, atau Orang Tua Murid (Member),
- **I want to** memantau jadwal latihan, menampilkan QR code kehadiran, mencatat skor kesiapan fisik 5P, melunasi tagihan iuran bulanan dengan kwitansi digital, dan mengakses kurikulum sabuk,
- **So that** saya selalu siap mengikuti latihan, terhindar dari cedera fatal, memiliki bukti pembayaran yang sah, dan memahami materi teknik beladiri saya.

---

## 2. Acceptance Criteria (Gherkin)

```gherkin
Feature: Member Hub, Athlete Readiness 5P and Digital Receipts

  Scenario: Pencatatan skor kesiapan harian atlet (Athlete Readiness 5P)
    Given atlet membuka menu kesiapan fisik "/readiness" di pagi hari sebelum latihan
    When atlet mengisi 5 indikator skala 1-5 (Kualitas Tidur, Tingkat Energi, Nyeri Otot, Stres, Kesiapan Mental) dan berat badan terkini
    Then sistem menghitung skor kesiapan agregat dalam persentase (0-100%)
    And sistem menampilkan indikator visual (Hijau / Biru / Merah)
    And data kesiapan tersinkronisasi seketika ke Squad Readiness Board pelatih

  Scenario: Menampilkan QR Code kehadiran dan mengajukan izin tidak hadir
    Given murid berhalangan hadir pada sesi latihan terjadwal
    When murid menekan tombol "Ajukan Izin" pada menu "/checkin" dan menyertakan alasan "Sakit demam"
    Then status kehadiran murid tercatat sebagai "PERMITTED"
    And pelatih menerima notifikasi di dasbor tanpa perlu chat personal

  Scenario: Unduh kwitansi digital pembayaran iuran yang telah terverifikasi
    Given orang tua murid telah melunasi tagihan iuran bulanan
    When orang tua membuka rincian tagihan berstatus "PAID" di "/payments"
    Then sistem menyediakan tombol "Unduh Kwitansi Digital (PDF)"
    And berkas PDF memuat nomor registrasi kwitansi, cap resmi dojang, dan QR verifikasi keabsahan
```

---

## 3. Spesifikasi Endpoint API

### `POST /api/v1/member/readiness`

- **Deskripsi:** Mengirim log kesiapan harian 5P dan data fisik atlet.
- **Headers:**
  - `Authorization: Bearer <jwt_access_token>`
  - `Content-Type: application/json`

#### Request Payload:
```json
{
  "log_date": "2026-10-12",
  "sleep_quality": 4,
  "energy_level": 4,
  "muscle_soreness": 2,
  "stress_level": 1,
  "mental_readiness": 5,
  "current_weight_kg": 57.4,
  "injury_notes": "Sedikit pegal di pergelangan kaki kanan pasca latihan kemarin.",
  "pain_scale": 2
}
```

#### Response Payloads:

##### `201 Created` (Kesiapan Tersimpan):
```json
{
  "status": "success",
  "message": "Data kesiapan fisik berhasil dicatat.",
  "data": {
    "readiness_id": "e491c107-740b-4eef-bce9-1f4a9b6c0291",
    "calculated_readiness_score": 84.0,
    "status_tier": "OPTIMAL",
    "recommendation": "Kondisi prima. Siap untuk sesi latihan intensitas penuh atau sparring.",
    "weight_diff_from_target_kg": -0.6
  }
}
```

##### `400 Bad Request` (Nilai di Luar Skala):
```json
{
  "status": "error",
  "code": "VALIDATION_FAILED",
  "message": "Nilai indikator 5P harus berada dalam rentang skala 1 hingga 5."
}
```

##### `401 Unauthorized`:
```json
{
  "status": "error",
  "code": "UNAUTHORIZED",
  "message": "Sesi autentikasi telah berakhir. Silakan login kembali."
}
```

##### `500 Internal Server Error`:
```json
{
  "status": "error",
  "code": "INTERNAL_SERVER_ERROR",
  "message": "Gagal menyimpan metrik kesiapan fisik atlet."
}
```

---

## 4. Edge Cases & Failure Modes

1. **Pengisian Ganda di Hari yang Sama:** Jika atlet mengirimkan kembali form kesiapan pada hari yang sama, sistem melakukan *update* pada log hari tersebut dan menyimpan timestamp pembaruan terakhir.
2. **Skor Kesiapan Kritis (< 50% atau Skala Nyeri >= 4):** Sistem secara otomatis mengirimkan notifikasi *alert* darurat ke akun pelatih agar atlet tidak dimasukkan ke dalam sesi latihan kontak keras.
3. **Penyimpanan Lokal Formulir Offline:** Jika form diisi saat perangkat tidak terhubung ke internet, form tersimpan di LocalStorage dan dikirim saat koneksi internet tersambung kembali.

---

## Navigasi Modul & Fitur

[← Fitur Sebelumnya](FR-03-coach-scanner-and-scoring.md) | [Ikhtisar Sistem](../00-overview.md) | [Fitur Selanjutnya →](FR-05-tournament-bracket-and-live-scoring.md)
