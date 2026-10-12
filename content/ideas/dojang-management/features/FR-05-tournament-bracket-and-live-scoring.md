---
title: "FR-05: Tournament Bracket Auto-Drawing, Live Scoring & TV Display"
slug: "dojang-management-fr-05"
date: "2026-10-12"
author: "System Architect Agent"
tags: ["tournament", "brackets", "live-scoring", "scoreboard", "days"]
category: "Product Spec"
status: "draft"
priority: "P0"
complexity: "Critical"
estimated_effort: "3-4 weeks"
---

# FR-05: Tournament Bracket Auto-Drawing, Live Scoring & TV Display

> **Sistem:** DAYS ([dojang.warsootech.com](https://dojang.warsootech.com))

## 1. User Story

- **As a** Tournament Director / Panitia Kejuaraan Beladiri,
- **I want to** mengenerate bagan pertandingan sistem gugur secara otomatis dan adil, mengelola antrean call room atlet, menyiarkan live score ke TV arena via WebSocket, dan mencetak Result Book PDF instan,
- **So that** kejuaraan berlangsung tanpa tuduhan kecurangan drawing, tanpa penundaan partai (*zero arena downtime*), serta buku hasil resmi dapat langsung dibagikan saat upacara penutupan.

---

## 2. Acceptance Criteria (Gherkin)

```gherkin
Feature: Tournament Engine, Auto-Drawing and Live TV Scoreboard

  Scenario: Pembuatan bagan sistem gugur otomatis (Auto-Drawing Brackets)
    Given panitia telah memfinalisasi kategori tanding "Kyorugi Under 54kg Senior Putra" dengan 16 atlet
    When panitia menekan tombol "Generate Bagan Otomatis" dengan algoritma seeded kontingen
    Then sistem memisahkan atlet dari dojang/kontingen yang sama ke pool atas dan pool bawah
    And bagan 16 besar terbentuk dalam waktu < 2 detik
    And bagan interaktif langsung dapat dipublikasikan ke publik dan dicetak untuk papan venue

  Scenario: Penyiaran skor arena real-time ke Scoreboard TV
    Given pertandingan partai #102 di Arena 1 sedang berlangsung
    When operator terminal menekan tombol poin pukulan (+1) untuk sudut Hong
    Then terminal mengirim pesan mutasi skor via WebSocket lokal/cloud
    And layar TV Display publik memperbarui angka skor sudut Hong dalam waktu < 150 milidetik
    And tidak ada flicker pada tampilan antarmuka penonton

  Scenario: Ekspor 1-Click Official Result Book PDF saat penutupan acara
    Given seluruh partai kejuaraan telah selesai dan disahkan oleh Technical Delegate
    When panitia mengklik tombol "Generate Result Book PDF"
    Then sistem mengompilasi seluruh bagan juara, rekap perolehan medali, kontingen Juara Umum 1-2-3, dan Best Player
    And berkas PDF resmi terunduh lengkap dengan tanda tangan digital panitia dalam < 10 detik
```

---

## 3. Spesifikasi Endpoint API

### `POST /api/v1/tournaments/matches/:matchId/score`

- **Deskripsi:** Mengirim mutasi penambahan skor atau pelanggaran dari terminal operator arena.
- **Headers:**
  - `Authorization: Bearer <jwt_access_token>`
  - `Content-Type: application/json`

#### Request Payload:
```json
{
  "round_number": 2,
  "corner": "HONG",
  "score_type": "BODY_KICK",
  "points_delta": 2,
  "gamjeom_delta": 0,
  "time_remaining_seconds": 68
}
```

#### Response Payloads:

##### `200 OK` (Skor Berhasil Disinkronkan):
```json
{
  "status": "success",
  "data": {
    "match_id": "771b0299-4d61-419b-a010-ea9834120912",
    "arena_id": "arena-1",
    "current_round": 2,
    "scores": {
      "chung": { "points": 4, "gamjeom": 1 },
      "hong": { "points": 7, "gamjeom": 0 }
    },
    "event_broadcasted": true,
    "latency_ms": 18
  }
}
```

##### `400 Bad Request` (Partai Berstatus Selesai / Terkunci):
```json
{
  "status": "error",
  "code": "MATCH_LOCKED",
  "message": "Partai pertandingan ini telah dihentikan atau disahkan."
}
```

##### `401 Unauthorized`:
```json
{
  "status": "error",
  "code": "UNAUTHORIZED",
  "message": "Operator tidak memiliki wewenang mencatat skor di gelanggang ini."
}
```

##### `500 Internal Server Error`:
```json
{
  "status": "error",
  "code": "REDIS_PUBLISH_FAILED",
  "message": "Gagal menyiarkan update skor ke socket display venue."
}
```

---

## 4. Edge Cases & Failure Modes

1. **Jaringan Internet Venue Putus Total:** Terminal operator dan TV Scoreboard di arena dirancang dapat beroperasi via *Local Mesh Wi-Fi Network* (tanpa akses internet luar) menggunakan mini-server lokal / laptop operator. Saat koneksi internet kembali menyala, data hasil di-*sync* ke cloud server.
2. **Koreksi Skor Akibat Protes Wasit (Mitigasi Isu):** Technical Delegate memiliki kewenangan melakukan *rollback* atau koreksi poin manual melalui antarmuka khusus mitigasi protes, yang langsung mencatat audit trail alasan koreksi.
3. **Hasil Imbang (Golden Point / Superiority):** Sistem menyediakan antarmuka penentuan pemenang berdasarkan kriteria superioritas WT (*World Taekwondo*) saat ronde tambahan berakhir seri.

---

## Navigasi Modul & Fitur

[← Fitur Sebelumnya](FR-04-athlete-readiness-and-member-hub.md) | [Ikhtisar Sistem](../00-overview.md) | [Fitur Selanjutnya →](FR-06-federation-governance-and-e-cert.md)
