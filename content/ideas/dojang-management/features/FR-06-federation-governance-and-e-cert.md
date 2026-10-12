---
title: "FR-06: Tata Kelola Federasi, Mutasi Atlet & Otomasi E-Sertifikat"
slug: "dojang-management-fr-06"
date: "2026-10-12"
author: "System Architect Agent"
tags: ["federation", "governance", "mutation", "e-certificate", "days"]
category: "Product Spec"
status: "draft"
priority: "P0"
complexity: "High"
estimated_effort: "2-3 weeks"
---

# FR-06: Tata Kelola Federasi, Mutasi Atlet & Otomasi E-Sertifikat

> **Sistem:** DAYS ([dojang.warsootech.com](https://dojang.warsootech.com))

## 1. User Story

- **As a** Pengurus Federasi Olahraga Beladiri (Pengcab/Pengprov) atau Komite UKT,
- **I want to** mengawasi peta sebaran dojang wilayah, memvalidasi permohonan mutasi atlet antar-klub secara transparan, serta menerbitkan ratusan e-sertifikat ber-QR yang dapat diverifikasi publik dalam 1 kali klik,
- **So that** pemalsuan sertifikat sabuk dapat dihentikan, sengketa atlet jelang Porprov/PON tereliminasi, dan tata kelola organisasi cabang berjalan akuntabel.

---

## 2. Acceptance Criteria (Gherkin)

```gherkin
Feature: Federation Governance, Member Mutation and E-Certificate Automation

  Scenario: Pengajuan dan persetujuan mutasi atlet antar-dojang
    Given seorang atlet mengajukan perpindahan dari "Dojang Singa" ke "Dojang Garuda"
    When atlet mengunggah surat pelepasan resmi dan bukti bebas kewajiban administrasi
    Then status mutasi masuk antrean verifikasi Pengcab
    When admin Pengcab menyetujui mutasi
    Then afiliasi dojang atlet terbarui secara otomatis tanpa menghapus riwayat medali atau sabuk terdahulu
    And audit trail perpindahan tercatat permanen di paspor digital atlet

  Scenario: Otomasi penerbitan e-sertifikat kelulusan UKT secara massal
    Given penguji UKT telah memfinalisasi penilaian kelulusan 250 peserta ujian
    When panitia UKT menekan tombol "Terbitkan E-Sertifikat Massal"
    Then sistem mengenerate 250 berkas PDF e-sertifikat dengan template resmi, nomor registrasi unik, dan QR code keabsahan
    And proses selesai dalam waktu < 30 detik
    And setiap e-sertifikat langsung dapat dicek keabsahannya di portal publik "/e-certs/:registrationNumber"

  Scenario: Verifikasi e-sertifikat oleh publik tanpa perlu login
    Given pihak ketiga (sponsor, sekolah, atau instansi) memindai QR code pada sertifikat sabuk
    When browser membuka URL "https://dojang.warsootech.com/e-certs/CERT-2026-UKT-0891"
    Then portal publik menampilkan status "VALID & RESMI"
    And menyajikan informasi nama atlet, tingkat sabuk yang disahkan, nama penguji, dojang asal, dan tanggal penerbitan
```

---

## 3. Spesifikasi Endpoint API

### `POST /api/v1/certificates/batch-issue`

- **Deskripsi:** Menerbitkan e-sertifikat massal ber-QR untuk peserta yang lulus event/UKT.
- **Headers:**
  - `Authorization: Bearer <jwt_access_token>`
  - `Content-Type: application/json`

#### Request Payload:
```json
{
  "event_id": "993a401b-c74b-4a51-92ea-2024bc681023",
  "certificate_type": "BELT_PROMOTION_UKT",
  "signer_name": "Grandmaster Sukarno (DAN IX)",
  "template_id": "tpl-geup-taekwondo-2026",
  "auto_promote_belt": true
}
```

#### Response Payloads:

##### `200 OK` (Penerbitan Sukses):
```json
{
  "status": "success",
  "message": "250 E-sertifikat berhasil diterbitkan.",
  "data": {
    "total_issued": 250,
    "event_id": "993a401b-c74b-4a51-92ea-2024bc681023",
    "verification_base_url": "https://dojang.warsootech.com/e-certs",
    "zip_download_url": "https://storage.dojang.warsootech.com/batches/ukt-2026-certificates.zip",
    "processing_time_seconds": 12.4
  }
}
```

##### `400 Bad Request` (Peserta Belum Lengkap Dinilai):
```json
{
  "status": "error",
  "code": "UNFINALIZED_GRADES",
  "message": "Terdapat 14 peserta yang belum memiliki nilai akhir dari penguji."
}
```

##### `401 Unauthorized`:
```json
{
  "status": "error",
  "code": "UNAUTHORIZED",
  "message": "Anda tidak memiliki wewenang menerbitkan sertifikat resmi federasi."
}
```

##### `500 Internal Server Error`:
```json
{
  "status": "error",
  "code": "PDF_RENDER_TIMEOUT",
  "message": "Terjadi antrean rendering worker PDF. Job dialihkan ke asynchronous worker."
}
```

---

## 4. Edge Cases & Failure Modes

1. **Pemalsuan Sertifikat / Nomor Registrasi Tidak Terdaftar:** Jika publik memasukkan nomor sertifikat fiktif di portal publik, sistem menampilkan peringatan merah "Sertifikat Tidak Ditemukan atau Tidak Sah Terdaftar di Sistem DAYS".
2. **Atlet Memiliki Tunggakan Iuran Saat Mutasi:** Sistem memvalidasi status `monthly_dues` atlet di dojang asal; jika masih ada tunggakan, sistem menampilkan notifikasi peringatan kewajiban finansial yang belum diselesaikan.
3. **Penyimpanan Sertifikat Skala Besar:** Seluruh PDF e-sertifikat disimpan di Object Storage S3 dengan *immutable retention* dan dilindungi hash SHA-256 untuk menjamin integritas dokumen digital.

---

## Navigasi Modul & Fitur

[← Fitur Sebelumnya](FR-05-tournament-bracket-and-live-scoring.md) | [Ikhtisar Sistem](../00-overview.md) | [Roadmap Produk →](../03-roadmap.md)
