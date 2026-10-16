---
title: "FR-07: Manajemen Pelatih Tetap, Pelatih Lepas & Honorarium Sesi"
slug: "dojang-management-fr-07"
date: "2026-10-13"
author: "System Architect Agent"
tags: ["admin", "coaches", "freelance", "payroll", "scheduling"]
category: "Product Spec"
status: "draft"
priority: "P1"
complexity: "Medium"
estimated_effort: "2-3 weeks"
---

# FR-07: Manajemen Pelatih Tetap, Pelatih Lepas & Honorarium Sesi

## 1. User Story

- **As a** Pemilik atau Pengurus Dojang (Admin Dojang / Head Coach),
- **I want to** mendaftarkan dan mengelola direktori pelatih tetap maupun pelatih lepas (*freelance / guest coach*), menetapkan skema honor per sesi (*pay-per-session*), menugaskan pelatih pengganti (*substitute coach*) pada jadwal latihan, serta mengontrol hak akses aplikasi pelatih,
- **So that** jadwal latihan tetap berjalan lancar tanpa pembatalan kelas saat sabeum utama berhalangan, pengeluaran honorarium pelatih lepas terhitung transparan dan otomatis, serta kerahasiaan data finansial dojang tetap terjaga.

---

## 2. Acceptance Criteria (Gherkin)

```gherkin
Feature: Coach and Freelance Instructor Management

  Scenario: Admin menambahkan data pelatih lepas baru dengan skema tarif per sesi
    Given admin dojang berada di halaman direktori pelatih "/instructors"
    When admin menekan tombol "+ Tambah Pelatih"
    And memilih tipe kepegawaian "FREELANCE"
    And mengisi nama "Sabeum Budi Santoso", nomor HP, lisensi Dan Kukkiwon "DAN-4-10294", dan tarif per sesi Rp 150.000
    And memilih opsi hak akses aplikasi "RESTRICTED_APP_ACCESS"
    Then sistem membuat profil pelatih lepas baru
    And sistem mengirimkan tautan aktivasi login aplikasi DAYS Coach via WhatsApp/Email
    And pelatih lepas muncul di daftar tab "Pelatih Lepas / Freelance" dengan status aktif

  Scenario: Penugasan pelatih pengganti (substitute) pada tanggal sesi latihan spesifik
    Given pelatih tetap kelas "Sabtu 16:00 - Kyorugi Prestasi" berhalangan hadir pada tanggal 17 Oktober 2026
    When admin membuka jadwal tersebut di kalender "/schedules" dan memilih aksi "Tunjuk Pelatih Pengganti"
    And admin memilih pelatih lepas "Sabeum Budi Santoso" untuk sesi 17 Oktober 2026 saja
    Then sistem memperbarui pelatih pengampu sesi tersebut tanpa mengubah master jadwal mingguan
    And jadwal sesi tersebut muncul di aplikasi DAYS Coach milik Sabeum Budi Santoso
    And notifikasi penugasan terkirim ke ponsel pelatih lepas

  Scenario: Rekapitulasi dan kalkulasi otomatis honor pelatih lepas berbasis presensi
    Given pelatih lepas telah menyelesaikan 4 sesi latihan pengganti dalam periode bulan berjalan
    And seluruh 4 sesi telah terverifikasi presensi mengajar pada "/instructor-attendance"
    When admin membuka menu laporan honorarium pelatih lepas
    Then sistem menghitung total kewajiban bayar: 4 sesi x Rp 150.000 = Rp 600.000
    And admin dapat mengklik "Terbitkan Voucher Pembayaran Honor" untuk dibukukan ke pengeluaran kas dojang

  Scenario: Pembatasan hak akses data untuk pelatih lepas
    Given pelatih berstatus "FREELANCE" dengan hak akses "RESTRICTED_APP_ACCESS" login ke aplikasi DAYS Coach
    When pelatih membuka dashboard aplikasi
    Then pelatih hanya dapat melihat daftar murid dan QR scanner pada sesi kelas yang ditugaskan kepadanya
    And pelatih tidak dapat melihat data keuangan dojang, riwayat iuran murid, maupun daftar kelas cabang lain
```

---

## 3. Spesifikasi Endpoint API

### 3.1 `POST /api/v1/dojang/instructors`

- **Deskripsi:** Mendaftarkan pelatih baru (tetap, freelance, tamu, atau asisten) ke dalam basis data dojang.
- **Headers:**
  - `Authorization: Bearer <jwt_access_token>`
  - `Content-Type: application/json`

#### Request Payload:
```json
{
  "full_name": "Budi Santoso",
  "phone": "+6281234567890",
  "email": "budi.sabeum@example.com",
  "employment_type": "FREELANCE",
  "origin_dojang": "Dojang Garuda Jaya",
  "dan_rank": "DAN 4",
  "kukkiwon_number": "KUK-2018-88392",
  "pbti_license_level": "WASIT_DAERAH",
  "specializations": ["KYORUGI", "PHYSICAL_CONDITIONING"],
  "compensation_model": "PER_SESSION",
  "fee_per_session": 150000,
  "bank_account": {
    "bank_name": "BCA",
    "account_number": "8720192831",
    "account_holder": "Budi Santoso"
  },
  "app_access_level": "RESTRICTED"
}
```

#### Response Payloads:

##### `201 Created` (Pendaftaran Berhasil):
```json
{
  "status": "success",
  "message": "Data pelatih berhasil ditambahkan.",
  "data": {
    "instructor_id": "e3a89e17-48b2-4d22-9214-a95786fce810",
    "full_name": "Budi Santoso",
    "employment_type": "FREELANCE",
    "compensation_model": "PER_SESSION",
    "fee_per_session": 150000,
    "app_access_level": "RESTRICTED",
    "invitation_status": "INVITED",
    "created_at": "2026-10-13T08:00:00Z"
  }
}
```

##### `400 Bad Request` (Validasi Gagal):
```json
{
  "status": "error",
  "code": "VALIDATION_ERROR",
  "message": "Tarif per sesi (fee_per_session) wajib diisi untuk pelatih bertipe FREELANCE."
}
```

##### `401 Unauthorized`:
```json
{
  "status": "error",
  "code": "UNAUTHORIZED",
  "message": "Sesi autentikasi tidak valid atau tidak memiliki peran Admin Dojang."
}
```

##### `500 Internal Server Error`:
```json
{
  "status": "error",
  "code": "INTERNAL_SERVER_ERROR",
  "message": "Gagal menyimpan data instruktur ke database."
}
```

---

### 3.2 `POST /api/v1/dojang/schedules/substitute`

- **Deskripsi:** Menugaskan pelatih pengganti (*substitute/freelance coach*) untuk sesi tanggal tertentu pada jadwal reguler.
- **Headers:**
  - `Authorization: Bearer <jwt_access_token>`
  - `Content-Type: application/json`

#### Request Payload:
```json
{
  "schedule_id": "4b684cb3-5591-4cf4-9189-bc8b209d1712",
  "session_date": "2026-10-17",
  "substitute_instructor_id": "e3a89e17-48b2-4d22-9214-a95786fce810",
  "reason": "Sabeum utama dinas luar kota / pendampingan kejuaraan Porprov",
  "agreed_fee": 150000
}
```

#### Response Payload (`200 OK`):
```json
{
  "status": "success",
  "message": "Pelatih pengganti berhasil ditugaskan untuk sesi 2026-10-17.",
  "data": {
    "assignment_id": "b7194f4a-91d4-4e3a-9654-82a9db41b9c1",
    "schedule_id": "4b684cb3-5591-4cf4-9189-bc8b209d1712",
    "session_date": "2026-10-17",
    "substitute_instructor_name": "Budi Santoso",
    "status": "CONFIRMED"
  }
}
```

---

### 3.3 `GET /api/v1/dojang/instructors/payroll/summary`

- **Deskripsi:** Mengambil rekapitulasi sesi mengajar dan akumulasi honor pelatih lepas pada rentang periode tanggal.
- **Headers:**
  - `Authorization: Bearer <jwt_access_token>`
- **Query Params:** `?month=2026-10&type=FREELANCE`

#### Response Payload (`200 OK`):
```json
{
  "status": "success",
  "data": {
    "period": "2026-10",
    "total_freelance_expense": 1850000,
    "instructors": [
      {
        "instructor_id": "e3a89e17-48b2-4d22-9214-a95786fce810",
        "name": "Budi Santoso",
        "employment_type": "FREELANCE",
        "total_sessions_completed": 4,
        "fee_per_session": 150000,
        "total_payout": 600000,
        "payment_status": "PENDING"
      }
    ]
  }
}
```

---

## 4. Edge Cases & Failure Modes

1. **Tabrakan Jadwal Pelatih Lepas (*Double Booking*):** Jika seorang pelatih lepas ditugaskan di dua sesi cabang dojang yang berbeda pada rentang jam yang sama atau memiliki selisih waktu kurang dari buffer perpindahan lokasi (minimal 60 menit), sistem menampilkan *Warning Modal* bentrok waktu.
2. **Pelatih Tamu Tanpa Smartphone / Tanpa Akun (*Shadow Profile*):** Dojang dapat mendaftarkan pelatih tamu murni untuk pencatatan internal tanpa mengaktifkan login aplikasi (`app_access_level = NONE`). Presensi dan pencatatan kehadiran sesi dilakukan langsung oleh asisten admin dojang di lokasi.
3. **Pembatalan Kelas Mendadak Setelah Pelatih Hadir (*Late Cancellation Policy*):** Jika sesi dibatalkan < 2 jam sebelum jadwal latihan sementara pelatih lepas telah tiba di lokasi, sistem menyediakan opsi *Disbursement Flag: COMPENSATED_HALF* atau *COMPENSATED_FULL* sesuai kesepakatan dojang.

---

[← Fitur Sebelumnya](FR-06-federation-governance-and-e-cert.md) | [Ikhtisar Sistem](../00-overview.md) | [Roadmap Produk →](../03-roadmap.md) | [Fitur Selanjutnya (FR-08) →](FR-08-payment-gateway-and-commerce-engine.md)
