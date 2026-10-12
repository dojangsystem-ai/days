---
title: "FR-02: Drawing Bagan Kejuaraan & Seeding"
slug: "tournament-event-management"
date: "2026-10-10"
author: "System Architect Agent"
tags: ["prd", "bracket", "drawing", "seeding", "single-elimination"]
category: "Product Spec"
status: "draft"
priority: "P0"
complexity: "High"
estimated_effort: "1-2 weeks"
---

# Feature Specification: Drawing Bagan Kejuaraan & Seeding (FR-02)

## 1. User Story

**As a** Technical Delegate / Admin Kejuaraan,  
**I want to** menjalankan algoritma pembuatan bagan (*drawing bracket*) otomatis berdasarkan parameter tipe pertandingan (*Single Elimination*, *Double Elimination*, *Round Robin*) dengan constraint *Same-Contingent Separation*,  
**So that** bagan pertandingan dapat dibuat dalam hitungan detik secara adil, transparan, dan tidak ada atlet dari kontingen yang sama saling berhadapan pada babak pertama.

---

## 2. Acceptance Criteria (Gherkin Format)

### Scenario 1: Pembuatan Bagan Single Elimination dengan Automatic Seeding dan Same-Contingent Constraint
```gherkin
Given a verified list of 13 athletes in category "Senior Male Under 68kg" from 5 different contingents
When the Technical Delegate executes POST request to "/api/v1/tournaments/{id}/categories/{cat_id}/draw-bracket" with method "SINGLE_ELIMINATION"
Then the system generates a 16-slot binary tree bracket with 3 Bye slots
And places seeded top-ranked athletes at opposing ends of the bracket tree
And ensures no two athletes from the same contingent meet in Round 1
And returns HTTP status code 201 Created with complete bracket structure JSON
```

### Scenario 2: Regenerasi Bagan Setelah Timbang Badan (Redraw / Manual Adjust)
```gherkin
Given an existing generated bracket for category "Junior Female Under 44kg"
When an athlete is disqualified during weigh-in and the admin triggers a bracket redraw with "REPLACE_WITH_BYE" strategy
Then the system updates the match tree, converting affected match slots into Bye advances
And re-indexes all match numbers without altering unaffected match assignments
```

---

## 3. API Endpoint Specifications

### 3.1 Draw Bracket Endpoint
- **HTTP Method:** `POST`
- **Endpoint URI:** `/api/v1/tournaments/{tournament_id}/categories/{category_id}/draw-bracket`
- **Headers:**
  - `Authorization: Bearer <jwt_access_token>`
  - `Content-Type: application/json`

#### Request Body Schema:
```json
{
  "bracket_type": "SINGLE_ELIMINATION",
  "seeding_strategy": "RANKING_AND_CONTINGENT_SPLIT",
  "seeded_athlete_ids": [
    "ath-001-rank1",
    "ath-002-rank2"
  ],
  "random_seed": 409281
}
```

#### Response Payload (201 Created):
```json
{
  "status": "success",
  "data": {
    "bracket_id": "brk-cat-u68m-001",
    "category_id": "cat-u68m",
    "total_participants": 13,
    "bracket_size": 16,
    "total_rounds": 4,
    "total_matches": 12,
    "rounds": [
      {
        "round_number": 1,
        "round_name": "Babak 16 Besar",
        "matches": [
          {
            "match_id": "mat-u68m-r1-m1",
            "match_number": 101,
            "blue_corner": { "athlete_id": "ath-001-rank1", "name": "Budi", "contingent": "Klub A" },
            "red_corner": { "athlete_id": null, "name": "BYE", "contingent": null },
            "winner_id": "ath-001-rank1",
            "status": "COMPLETED"
          },
          {
            "match_id": "mat-u68m-r1-m2",
            "match_number": 102,
            "blue_corner": { "athlete_id": "ath-005", "name": "Deni", "contingent": "Klub B" },
            "red_corner": { "athlete_id": "ath-009", "name": "Eko", "contingent": "Klub C" },
            "winner_id": null,
            "status": "SCHEDULED"
          }
        ]
      }
    ]
  }
}
```

---

## 4. Edge Cases & Failure Modes

1. **Peserta Ganjil / Kurang dari 2:** Jika kategori hanya memiliki 1 peserta, sistem memberikan notifikasi *Direct Gold Medalist* tanpa membuat bagan pertandingan. Jika 0 peserta, sistem menolak pembuatan bagan (`400 Bad Request`).
2. **Dominasi 1 Kontingen (>50% Peserta):** Jika dalam 1 kategori terdapat 6 atlet dari Kontingen A dan 2 atlet dari Kontingen B, constraint *no same contingent in round 1* tidak mungkin dipenuhi 100%. Algoritma secara aman melakukan *relaxation constraint*, meminimalkan pertemuan se-kontingen di ronde 1 dan mencatat log peringatan.

---

## 5. Security & Data Privacy Review

- Only users with `SUPER_ADMIN`, `EVENT_ORGANIZER`, or `TECHNICAL_DELEGATE` roles can execute or redraw brackets.
- Once a category bracket is marked as `PUBLISHED`, drawing status becomes immutable unless explicitly unlocked with audit logging.
