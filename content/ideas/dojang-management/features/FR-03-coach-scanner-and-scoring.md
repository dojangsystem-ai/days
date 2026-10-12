---
title: "FR-03: Scanner Absensi QR, Kesiapan Atlet & Digital Scoring Pelatih"
slug: "dojang-management-fr-03"
date: "2026-10-12"
author: "System Architect Agent"
tags: ["coach", "qr-scanner", "scoring", "readiness", "days"]
category: "Product Spec"
status: "draft"
priority: "P0"
complexity: "High"
estimated_effort: "2-3 weeks"
---

# FR-03: Scanner Absensi QR, Kesiapan Atlet & Digital Scoring Pelatih

> **Sistem:** DAYS ([dojang.warsootech.com](https://dojang.warsootech.com))

## 1. User Story

- **As a** Pelatih Lapangan (Coach / Sabeum),
- **I want to** memindai QR code murid untuk absensi cepat, melihat status kesiapan atlet (*Squad Readiness Board*) sebelum memulai latihan, dan menggunakan terminal penilaian digital untuk Kyorugi/Poomsae,
- **So that** waktu melatih tidak terbuang untuk administrasi manual, risiko cedera atlet dapat dicegah lebih awal, dan perkembangan teknik murid tercatat secara kuantitatif.

---

## 2. Acceptance Criteria (Gherkin)

```gherkin
Feature: Coach Scanner, Squad Readiness and Digital Scoring

  Scenario: Pemindaian QR Code kehadiran murid pada jadwal latihan
    Given pelatih membuka tab scanner "/scan" pada jadwal kelas aktif "Sabtu Pagi - Kyorugi"
    When pelatih memindai QR code dari kartu atau aplikasi Member murid
    Then sistem memvalidasi QR hash murid dan mencocokkan jadwal kelas
    And sistem mencatat kehadiran murid dengan status "PRESENT" dalam waktu < 1 detik
    And menampilkan umpan balik visual hijau dengan nama murid, sabuk, dan foto profil

  Scenario: Tinjauan kesiapan atlet pada Squad Readiness Board
    Given pelatih membuka menu "/readiness" sebelum sesi sparring
    When sistem memuat skor kesiapan harian atlet
    Then atlet dengan skor >= 80% ditandai indikator hijau (prima untuk sparring keras)
    And atlet dengan skor 60-79% ditandai indikator kuning (hanya latihan teknik/drill)
    And atlet dengan skor < 60% atau memiliki catatan nyeri berat ditandai indikator merah (istirahatkan atau latihan alternatif)

  Scenario: Penilaian digital pertandingan tanding Kyorugi (Chung vs Hong)
    Given pelatih memilih dua atlet pada menu "/scoring/match/:chungId/:hongId"
    When pelatih menekan tombol poin pukulan (+1) atau tendangan kepala (+3) untuk sudut Chung
    Then poin bertambah seketika pada layar pertandingan
    And saat ronde berakhir, data skor tersimpan permanen di riwayat penilaian atlet
```

---

## 3. Spesifikasi Endpoint API

### `POST /api/v1/coach/attendance/scan`

- **Deskripsi:** Memproses pemindaian QR code kehadiran anggota oleh pelatih.
- **Headers:**
  - `Authorization: Bearer <jwt_access_token>`
  - `Content-Type: application/json`

#### Request Payload:
```json
{
  "schedule_id": "4b684cb3-5591-4cf4-9189-bc8b209d1712",
  "qr_payload": "DAYS:MBR:f51b6e82-3511-4fa2-bfda-90d5bc8ea013:HASH98234",
  "location_coords": {
    "latitude": -6.2088,
    "longitude": 106.8456
  }
}
```

#### Response Payloads:

##### `200 OK` (Presensi Sukses):
```json
{
  "status": "success",
  "message": "Presensi berhasil dicatat.",
  "data": {
    "attendance_id": "99f8d93c-23a9-4672-8822-458110992a71",
    "member": {
      "id": "f51b6e82-3511-4fa2-bfda-90d5bc8ea013",
      "name": "Bima Arya Putra",
      "belt": "Geup 4 (Sabuk Biru)",
      "photo_url": "https://storage.dojang.warsootech.com/members/bima.jpg"
    },
    "checked_in_at": "2026-10-12T16:02:14Z",
    "status": "PRESENT"
  }
}
```

##### `400 Bad Request` (Jadwal Tidak Sesuai):
```json
{
  "status": "error",
  "code": "INVALID_SCHEDULE",
  "message": "Murid tidak terdaftar pada sesi jadwal kelas ini."
}
```

##### `401 Unauthorized`:
```json
{
  "status": "error",
  "code": "UNAUTHORIZED",
  "message": "Lisensi pelatih tidak valid atau tidak memiliki akses ke dojang ini."
}
```

##### `500 Internal Server Error`:
```json
{
  "status": "error",
  "code": "INTERNAL_SERVER_ERROR",
  "message": "Gagal mencatat log kehadiran. Silakan ulangi pemindaian."
}
```

---

## 4. Edge Cases & Failure Modes

1. **Pemindaian Ganda (Double Scan):** Jika pelatih memindai QR murid yang sama dalam rentang 5 menit pada jadwal yang sama, sistem tidak membuat record baru melainkan mengembalikan pesan "Murid telah tercatat hadir pada 16:02 WIB".
2. **Kamera Tidak Mendukung / Rusak:** Tersedia tombol input manual cepat (*quick search by name/member number*) agar presensi tetap berjalan tanpa hambatan.
3. **Koneksi Seluler Putus di Basemen Gedung:** Aplikasi Coach menyimpan antrean check-in di IndexedDB (*offline storage*) dan secara otomatis melakukan sinkronisasi massal saat perangkat kembali online.

---

## Navigasi Modul & Fitur

[← Fitur Sebelumnya](FR-02-dojang-operational-management.md) | [Ikhtisar Sistem](../00-overview.md) | [Fitur Selanjutnya →](FR-04-athlete-readiness-and-member-hub.md)
