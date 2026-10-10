---
title: "FR-01: Registrasi Atlet & Kontingen"
slug: "tournament-event-management"
date: "2026-10-10"
author: "System Architect Agent"
tags: ["prd", "registration", "athletes", "contingents", "payment"]
category: "Product Spec"
status: "draft"
priority: "P0"
complexity: "Medium"
estimated_effort: "1-2 weeks"
---

# Feature Specification: Registrasi Atlet & Kontingen (FR-01)

## 1. User Story

**As a** Contingent Manager (Manager Klub / Kontingen),  
**I want to** mengoperasikan portal pendaftaran mandiri untuk mendaftarkan atlet, mengunggah dokumen persyaratannya, memilih kelas tanding/kategori, serta melakukan pembayaran secara kolektif,  
**So that** proses pendaftaran kontingen saya cepat, transparan, terverifikasi otomatis, dan bebas dari antrean fisik sekretariat.

---

## 2. Acceptance Criteria (Gherkin Format)

### Scenario 1: Pendaftaran Atlet Berhasil dengan Pembayaran Virtual Account
```gherkin
Given a Contingent Manager with an authenticated session on tournament "TN-2026-BDG"
When the manager submits a POST request to "/api/v1/tournaments/TN-2026-BDG/registrations" with a list of valid athletes and selected categories
Then the system validates category constraints (age, gender, weight)
And creates pending registration records for each athlete
And generates a Payment Gateway Virtual Account invoice
And returns HTTP status code 201 Created with invoice details and expiration timestamp
```

### Scenario 2: Penolakan Pendaftaran Akibat Umur/Berat Badan Tidak Sesuai Kategori
```gherkin
Given an athlete whose birth date violates the age limit for "Kategori Remaja (14-16 Tahun)"
When the Contingent Manager attempts to register the athlete into that category
Then the system rejects the registration
And returns HTTP status code 400 Bad Request with error detail "Athlete age does not meet category criteria (Required: 14-16, Actual: 17)"
```

---

## 3. API Endpoint Specifications

### 3.1 Bulk Registration Endpoint
- **HTTP Method:** `POST`
- **Endpoint URI:** `/api/v1/tournaments/{tournament_id}/registrations`
- **Headers:**
  - `Authorization: Bearer <jwt_access_token>`
  - `Content-Type: application/json`

#### Request Body Schema:
```json
{
  "contingent_name": "Garuda Taekwondo Club",
  "manager_name": "Budi Santoso",
  "manager_phone": "+6281234567890",
  "athletes": [
    {
      "full_name": "Ahmad Rizky",
      "gender": "MALE",
      "birth_date": "2008-05-14",
      "weight_kg": 54.5,
      "category_id": "cat-u55-male-under-18",
      "identity_document_url": "https://s3.ap-southeast-1.amazonaws.com/tms-docs/id-12345.jpg"
    },
    {
      "full_name": "Siti Nurhaliza",
      "gender": "FEMALE",
      "birth_date": "2009-08-20",
      "weight_kg": 47.0,
      "category_id": "cat-u48-female-under-18",
      "identity_document_url": "https://s3.ap-southeast-1.amazonaws.com/tms-docs/id-67890.jpg"
    }
  ],
  "payment_method": "VIRTUAL_ACCOUNT",
  "bank_code": "BCA"
}
```

#### Response Payload (201 Created):
```json
{
  "status": "success",
  "data": {
    "registration_id": "reg-99201-bdg",
    "contingent_id": "cont-garuda-01",
    "total_athletes": 2,
    "total_amount": 700000,
    "currency": "IDR",
    "payment_details": {
      "payment_status": "PENDING",
      "payment_type": "VIRTUAL_ACCOUNT",
      "va_number": "88301928374192",
      "bank_code": "BCA",
      "expires_at": "2026-10-11T22:00:00Z"
    }
  }
}
```

#### Error Response Payload (400 Bad Request):
```json
{
  "status": "error",
  "code": "INVALID_CATEGORY_ELIGIBILITY",
  "message": "Validation failed for athlete Ahmad Rizky",
  "errors": [
    {
      "field": "weight_kg",
      "issue": "Weight 54.5kg exceeds max limit 51.0kg for category Under 51kg Male"
    }
  ]
}
```

---

## 4. Edge Cases & Failure Modes

1. **Kuota Kategori Penuh:** Jika suatu kategori memiliki limit maksimal peserta (misal: max 32 atlet), sistem mengunci opsi pendaftaran secara atomic di PostgreSQL transaction dan mengembalikan `409 Conflict`.
2. **Double Registration (Atlet Sama Terdaftar 2x):** Sistem melakukan pengecekan kombinasi `full_name` + `birth_date` + `gender` dalam 1 tournament. Jika terdeteksi duplikat, pendaftaran ditolak dengan notifikasi dialog konfirmasi.
3. **Kadaluarsa Pembayaran VA:** Jika VA tidak dibayar hingga `expires_at`, status pendaftaran otomatis berubah menjadi `EXPIRED` via background cron job, dan kuota slot kategori dikembalikan ke publik.

---

## 5. Security & Data Privacy Review

- **Dokumen Identitas:** Berkas akta/KTP diunggah ke private S3 bucket dengan Presigned URL (masa berlaku URL 15 menit).
- **Access Control:** Contingent Manager hanya dapat melihat dan menyunting data atlet di bawah kontingennya sendiri.
