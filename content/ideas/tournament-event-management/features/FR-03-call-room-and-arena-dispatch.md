---
title: "FR-03: Call Room Management & Arena Dispatch"
slug: "tournament-event-management"
date: "2026-10-10"
author: "System Architect Agent"
tags: ["prd", "call-room", "arena-dispatch", "realtime", "websockets"]
category: "Product Spec"
status: "draft"
priority: "P0"
complexity: "High"
estimated_effort: "1-2 weeks"
---

# Feature Specification: Call Room Management & Arena Dispatch (FR-03)

## 1. User Story

**As a** Call Room Officer & Contingent Coach,  
**I want to** mengelola status kesiapan atlet secara realtime (Panggilan 1, Panggilan 2, Check-in, Inspeksi Proteksi, Dispatch Arena), serta melihat urutan antrean partai di layar monitor Call Room dan aplikasi mobile Coach,  
**So that** atlet hadir tepat waktu di arena pertandingan, meminimalkan durasi mat ras mati (*arena idle time*), dan menghilangkan insiden *walkover* tidak sengaja.

---

## 2. Acceptance Criteria (Gherkin Format)

### Scenario 1: Pemanggilan Atlet Ronde Berikutnya ke Call Room
```gherkin
Given Match 105 is currently running on Matras 1
When Call Room Officer triggers "CALL_STAGE_1" for Match 108 scheduled on Matras 1
Then the system updates the match call status to "CALLED_STAGE_1"
And broadcasts a WebSocket event to the Call Room Display monitor and Coach Mobile App
And sends an automated WhatsApp alert to the respective Contingent Managers
And returns HTTP status code 200 OK
```

### Scenario 2: Atlet Check-in & Inspeksi Perlengkapan di Call Room
```gherkin
Given a match in status "CALLED_STAGE_1"
When the Call Room Officer scans the athlete's ID-Card QR Code at the Call Room desk
Then the system verifies the athlete's identity, category, and equipment compliance
And transitions the match call status to "CHECKED_IN_READY"
And assigns the match to the Arena Waiting Queue
```

---

## 3. API Endpoint Specifications

### 3.1 Update Match Call Room Stage
- **HTTP Method:** `PATCH`
- **Endpoint URI:** `/api/v1/tournaments/{tournament_id}/matches/{match_id}/call-status`
- **Headers:**
  - `Authorization: Bearer <jwt_access_token>`
  - `Content-Type: application/json`

#### Request Body Schema:
```json
{
  "stage": "CHECKED_IN_READY",
  "arena_id": "arena-mat-1",
  "blue_corner_checked": true,
  "red_corner_checked": true,
  "officer_notes": "Equipment verified, dobok & protector compliance passed."
}
```

#### Response Payload (200 OK):
```json
{
  "status": "success",
  "data": {
    "match_id": "mat-u68m-r1-m2",
    "match_number": 102,
    "arena_name": "Matras 1",
    "call_stage": "CHECKED_IN_READY",
    "updated_at": "2026-10-10T14:30:00Z",
    "blue_athlete": {
      "name": "Deni",
      "contingent": "Klub B",
      "status": "READY"
    },
    "red_athlete": {
      "name": "Eko",
      "contingent": "Klub C",
      "status": "READY"
    }
  }
}
```

---

## 4. Realtime WebSocket Events Specification

- **Channel:** `ws://tms-realtime/tournaments/{tournament_id}/call-room`
- **Event:** `MATCH_CALL_STAGE_UPDATED`
```json
{
  "event": "MATCH_CALL_STAGE_UPDATED",
  "payload": {
    "match_id": "mat-u68m-r1-m2",
    "match_number": 102,
    "arena_number": 1,
    "call_stage": "DISPATCHED_TO_ARENA",
    "timestamp": "2026-10-10T14:32:00Z"
  }
}
```

---

## 5. Edge Cases & Failure Modes

1. **Atlet Tidak Hadir Setelah Panggilan 3 (Potential WO):** Jika atlet tidak check-in dalam batas waktu 5 menit setelah Panggilan 3, sistem menandai match status sebagai `WO_WARNING`. Keputusan akhir Walkover dikonfirmasi oleh Technical Delegate via Admin Panel.
2. **Koneksi Internet Terputus di Venue:** Aplikasi Call Room menjalankan Service Worker PWA dengan dukungan *offline queue*. Data check-in disimpan sementara di IndexedDB dan disinkronisasi otomatis saat koneksi terhubung kembali.
