---
title: "FR-04: Plan Medali & Rekapitulasi Perolehan Juara"
slug: "tournament-event-management"
date: "2026-10-10"
author: "System Architect Agent"
tags: ["prd", "medal-tally", "winner-recap", "leaderboard", "points"]
category: "Product Spec"
status: "draft"
priority: "P0"
complexity: "Medium"
estimated_effort: "1 week"
---

# Feature Specification: Plan Medali & Rekapitulasi Perolehan Juara (FR-04)

## 1. User Story

**As a** Technical Delegate & Panitia Penyerahan Hadiah (UPP),  
**I want to** memantau perencanaaan alokasi medali (Plan Medali) sebelum event dan rekapitulasi klasemen perolehan juara kontingen (*Medal Tally Leaderboard*) secara *real-time* setelah tiap final selesai,  
**So that** jumlah fisik medali yang dipesan sesuai dengan total kategori, penentuan Juara Umum 1, 2, 3 terakumulasi otomatis tanpa kesalahan hitung, dan acara penyerahan hadiah berjalan lancar.

---

## 2. Acceptance Criteria (Gherkin Format)

### Scenario 1: Perencanaan Kebutuhan Medali (Plan Medali Engine)
```gherkin
Given a tournament with 40 approved categories across Kyorugi and Poomsae
When the Admin requests GET "/api/v1/tournaments/{id}/medal-plan"
Then the system calculates total gold (40), silver (40), and bronze medals (80 for 3rd place joint, or 40 for single 3rd)
And outputs a detailed procurement summary broken down by division and age group
```

### Scenario 2: Akumulasi Otomatis Poin Juara Umum Kontingen
```gherkin
Given a completed final match in category "Under 58kg Male" where Athlete A (Klub Garuda) wins Gold
When the referee submits the final score result
Then the system updates the Medal Tally table for "Klub Garuda" (+1 Gold, +7 Points)
And recalculates the overall Contingent Leaderboard in Redis
And updates the public live scoreboard via WebSockets
```

---

## 3. API Endpoint Specifications

### 3.1 Contingent Medal Leaderboard Endpoint
- **HTTP Method:** `GET`
- **Endpoint URI:** `/api/v1/tournaments/{tournament_id}/medal-tally`
- **Headers:** `Accept: application/json`

#### Response Payload (200 OK):
```json
{
  "status": "success",
  "data": {
    "tournament_name": "Kejuaraan Nasional Taekwondo 2026",
    "updated_at": "2026-10-10T16:45:00Z",
    "total_categories_finished": 32,
    "total_categories_remaining": 8,
    "leaderboard": [
      {
        "rank": 1,
        "contingent_id": "cont-garuda-01",
        "contingent_name": "Garuda Taekwondo Club Bandung",
        "gold": 8,
        "silver": 4,
        "bronze": 6,
        "total_medals": 18,
        "total_points": 74
      },
      {
        "rank": 2,
        "contingent_id": "cont-elang-02",
        "contingent_name": "Elang Muda Jakarta",
        "gold": 6,
        "silver": 5,
        "bronze": 4,
        "total_medals": 15,
        "total_points": 59
      }
    ]
  }
}
```

---

## 4. Edge Cases & Failure Modes

1. **Hasil Juara Bersama 3 (Joint Bronze):** Untuk cabang beladiri tertentu, Juara 3 diberikan kepada dua semifinalis yang kalah. Algoritma Plan Medali mendukung toggle setting `JOINT_BRONZE: true/false` per jenis kategori.
2. **Kriteria Tie-Breaker Juara Umum:** Jika dua kontingen memiliki jumlah Emas, Perak, dan Perunggu yang persis sama, sistem menggunakan hirarki *Tie-Breaker*: (1) Total Emas > (2) Total Perak > (3) Total Perunggu > (4) Jumlah Atlet Terdaftar > (5) Jumlah Partai Dimenangkan.

---

## 5. Security & Data Privacy Review

- Pembaruan status pemenang hanya dapat dipicu oleh hasil pertandingan yang telah diverifikasi oleh Wasit Utama / Technical Delegate dengan tanda tangan digital / OTP otorisasi.
