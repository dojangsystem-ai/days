---
title: "FR-02: Manajemen Operasional Dojang, Iuran & Multi-Cabang"
slug: "dojang-management-fr-02"
date: "2026-10-12"
author: "System Architect Agent"
tags: ["admin", "billing", "members", "multi-branch", "cms"]
category: "Product Spec"
status: "draft"
priority: "P0"
complexity: "High"
estimated_effort: "2-3 weeks"
---

# FR-02: Manajemen Operasional Dojang, Iuran Bulanan & Multi-Cabang

## 1. User Story

- **As a** Pemilik atau Pengurus Dojang (Admin Dojang),
- **I want to** mengelola database atlet secara terpusat, memantau penagihan dan pelunasan iuran bulanan, menjadwalkan kelas lintas lokasi cabang, serta mengelola website profil dojang saya,
- **So that** saya terbebas dari rekap spreadsheet manual, meminimalkan tunggakan kas, dan mempermudah akuisisi murid baru secara profesional.

---

## 2. Acceptance Criteria (Gherkin)

```gherkin
Feature: Dojang Operational and Billing Management

  Scenario: Pencatatan dan konfirmasi pembayaran iuran bulanan murid
    Given admin dojang berada di layar konfirmasi iuran "/payments"
    When wali murid mengunggah bukti transfer iuran sebesar Rp 250.000 untuk bulan Oktober 2026
    Then status tagihan berubah dari "UNPAID" menjadi "WAITING_VERIFICATION"
    When admin mengklik tombol "Verifikasi & Terbitkan Kwitansi"
    Then status tagihan berubah menjadi "PAID"
    And kwitansi digital ber-QR terbit otomatis dan tersinkronisasi ke aplikasi Member wali murid
    And saldo kas dojang terupdate secara real-time

  Scenario: Deteksi dan rekapitulasi tunggakan iuran otomatis
    Given tanggal sistem melewati batas tempo iuran bulanan (tanggal 10 setiap bulan)
    When cron job penagihan berjalan
    Then sistem menandai seluruh murid yang belum melunasi iuran sebagai "OVERDUE"
    And dasbor analitik menampilkan metrik "Total Piutang Tertunggak" secara akurat

  Scenario: Penjadwalan latihan multi-lokasi tanpa konflik ruangan
    Given dojang memiliki 2 cabang latihan: "GOR Cempaka" dan "Sekolah Harapan"
    When admin menambahkan jadwal kelas Kyorugi Prestasi di "GOR Cempaka" pada hari Sabtu pukul 16:00
    Then sistem memeriksa ketersediaan pelatih dan tempat latihan
    And jika tidak ada jadwal yang bentrok, jadwal berhasil disimpan dan dipublikasikan ke aplikasi Coach dan Member
```

---

## 3. Spesifikasi Endpoint API

### `POST /api/v1/dojang/dues/confirm`

- **Deskripsi:** Memverifikasi pembayaran iuran bulanan murid dan menerbitkan kwitansi digital.
- **Headers:**
  - `Authorization: Bearer <jwt_access_token>`
  - `Content-Type: application/json`

#### Request Payload:
```json
{
  "dues_id": "8fa16e2b-2a91-4965-b1a3-2391ce4a8990",
  "action": "APPROVE",
  "payment_method": "BANK_TRANSFER",
  "verified_amount": 250000,
  "admin_notes": "Pembayaran iuran Oktober 2026 lunas via BCA."
}
```

#### Response Payloads:

##### `200 OK` (Verifikasi Berhasil):
```json
{
  "status": "success",
  "message": "Pembayaran berhasil diverifikasi.",
  "data": {
    "dues_id": "8fa16e2b-2a91-4965-b1a3-2391ce4a8990",
    "member_id": "f51b6e82-3511-4fa2-bfda-90d5bc8ea013",
    "receipt_number": "KW-TGR-202610-0042",
    "status": "PAID",
    "receipt_pdf_url": "https://storage.dojang.id/receipts/KW-TGR-202610-0042.pdf",
    "paid_at": "2026-10-12T20:45:00Z"
  }
}
```

##### `400 Bad Request` (Status Tidak Valid):
```json
{
  "status": "error",
  "code": "ALREADY_PROCESSED",
  "message": "Tagihan iuran ini telah berstatus PAID sebelumnya."
}
```

##### `401 Unauthorized` (Token Tidak Valid / Kedaluwarsa):
```json
{
  "status": "error",
  "code": "UNAUTHORIZED",
  "message": "Sesi autentikasi tidak valid atau telah berakhir."
}
```

##### `500 Internal Server Error`:
```json
{
  "status": "error",
  "code": "DB_TRANSACTION_FAILED",
  "message": "Gagal membukukan transaksi kas dojang. Transaksi di-rollback."
}
```

---

## 4. Edge Cases & Failure Modes

1. **Pembayaran Parsial / Kurang Bayar:** Jika wali murid mentransfer nominal yang kurang dari tarif kelas, admin dapat menandai status `PARTIAL_PAID` beserta sisa tagihan yang harus dibayar.
2. **Koneksi Terputus Saat Upload Bukti Transfer:** Gambar bukti transfer di-compress di sisi klien sebelum upload dan menggunakan *resumable upload* ke object storage S3 guna mencegah kegagalan unggah di sinyal lemah.
3. **Konflik Jadwal Pelatih:** Jika pelatih yang sama dijadwalkan di dua cabang berbeda dalam selang waktu kurang dari waktu tempuh perjalanan (travel buffer), sistem menampilkan peringatan tabrakan jadwal (*schedule collision warning*).

---

## Navigasi Modul & Fitur

[← Fitur Sebelumnya](FR-01-user-authentication.md) | [Ikhtisar Sistem](../00-overview.md) | [Fitur Selanjutnya →](FR-03-coach-scanner-and-scoring.md)
