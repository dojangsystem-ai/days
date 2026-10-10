---
title: "FR-02: e-KYC & Identity Verification Service"
slug: "ojk-credit-scoring"
date: "2026-10-10"
author: "System Architect Agent"
tags: ["ekyc", "dukcapil", "identity", "biometric", "privacy"]
category: "Product Spec"
status: "draft"
priority: "P0"
complexity: "High"
estimated_effort: "2 weeks"
---

# Feature Specification: FR-02 e-KYC & Identity Verification Service

## 1. User Story
- **As a** Credit Scoring System,
- **I want to** verify applicant identity (NIK, Full Name, Date of Birth, Selfie Face Match) against Dukcapil e-KYC,
- **So that** fraud, synthetic identity creation, and identity theft are prevented before credit scoring execution.

---

## 2. Acceptance Criteria (Gherkin Format)

### Scenario 1: Successful Identity Verification & High Biometric Match
```gherkin
Given a credit applicant with a valid 16-digit NIK and liveness selfie image
When the system executes POST "/api/v1/identity/verify" with encrypted applicant details
Then the system matches demographic data against Dukcapil database
And returns HTTP status code 200 OK with "verification_status": "VERIFIED" and "biometric_match_score": 0.96
```

### Scenario 2: Identity Verification Failure Due to Mismatched Demographic Data
```gherkin
Given an applicant NIK that does not match the provided Full Name or Date of Birth
When the system executes POST "/api/v1/identity/verify"
Then the system marks verification as failed
And returns HTTP status code 400 Bad Request with error code "EKYC_DEMOGRAPHIC_MISMATCH"
```

### Scenario 3: Dukcapil API Gateway Timeout Handling
```gherkin
Given Dukcapil external service is unreachable or responds > 5000ms
When the system executes POST "/api/v1/identity/verify"
Then the system activates Circuit Breaker fallback
And returns HTTP status code 504 Gateway Timeout with error code "EKYC_THIRD_PARTY_TIMEOUT"
```

---

## 3. API Endpoint Specification

### 3.1 Verification Endpoint
- **HTTP Method:** `POST`
- **Path:** `/api/v1/identity/verify`
- **Headers:**
  - `Authorization: Bearer <jwt_access_token>`
  - `Content-Type: application/json`

#### Request Body JSON Schema:
```json
{
  "nik": "3171012304950001",
  "full_name": "BUDI SANTOSO",
  "dob": "1995-04-23",
  "selfie_base64": "data:image/jpeg;base64,/9j/4AAQSkZJRgABAQ...",
  "consent_id": "c7a8b9d0-1234-5678-9abc-def012345678"
}
```

#### Response Payload (200 OK):
```json
{
  "status": "success",
  "data": {
    "verification_id": "v-99887766-5544-3322",
    "applicant_id": "a-11223344-5566-7788",
    "verification_status": "VERIFIED",
    "demographic_match": {
      "nik_match": true,
      "name_match": true,
      "dob_match": true
    },
    "biometric_match_score": 0.96,
    "is_fraud_flagged": false
  },
  "timestamp": "2026-10-10T14:35:00Z"
}
```

#### Response Payload (400 Bad Request):
```json
{
  "status": "error",
  "error": {
    "code": "EKYC_DEMOGRAPHIC_MISMATCH",
    "message": "Full Name or Date of Birth does not match Dukcapil record.",
    "details": [
      {
        "field": "full_name",
        "issue": "Similarity score below threshold (0.62 < 0.85)"
      }
    ]
  },
  "timestamp": "2026-10-10T14:35:00Z"
}
```

#### Response Payload (401 Unauthorized):
```json
{
  "status": "error",
  "error": {
    "code": "AUTH_INVALID_TOKEN",
    "message": "Access token expired or malformed.",
    "details": []
  },
  "timestamp": "2026-10-10T14:35:00Z"
}
```

#### Response Payload (504 Gateway Timeout):
```json
{
  "status": "error",
  "error": {
    "code": "EKYC_THIRD_PARTY_TIMEOUT",
    "message": "Dukcapil e-KYC upstream server timed out after 5000ms.",
    "details": []
  },
  "timestamp": "2026-10-10T14:35:00Z"
}
```

---

## 4. Edge Cases & Failure Modes

1. **Liveness Detection Failure (Photo of Photo):** Algoritma Liveness Detection menolak selfie jika terdeteksi manipulasi layar/topeng (Passive Liveness Threshold < 0.90).
2. **Partial Dukcapil Outage:** Jika Dukcapil error 5xx, request masuk ke antrean retry Kafka dengan Exponential Backoff (maksimal 3 kali retry dalam 30 detik).

---

## 5. Security & Data Privacy Review
- **No Raw Image Storage:** Gambar `selfie_base64` hanya diproses di volatile RAM untuk ekstraksi biometric feature vector (128-d embeddings). Gambar mentah SEGERA dihapus dari RAM setelah ekstraksi.
- **NIK Hash:** Disimpan dalam database sebagai `HMAC-SHA256` untuk mencegah reverse lookup jika database bocor.
