---
title: "FR-03: Alternative Data Ingestion & SLIK Integrator Engine"
slug: "ojk-credit-scoring"
date: "2026-10-10"
author: "System Architect Agent"
tags: ["data-ingestion", "slik", "alternative-data", "etl", "feature-store"]
category: "Product Spec"
status: "draft"
priority: "P0"
complexity: "High"
estimated_effort: "2-3 weeks"
---

# Feature Specification: FR-03 Alternative Data Ingestion & SLIK Integrator Engine

## 1. User Story
- **As a** Credit Scoring Pipeline,
- **I want to** ingest and normalize financial data from SLIK OJK alongside alternative data (Telco ARPU, E-Wallet transaction velocity, E-Commerce order frequency),
- **So that** a comprehensive feature vector can be generated for unbanked and underbanked debiturs without storing raw data payload.

---

## 2. Acceptance Criteria (Gherkin Format)

### Scenario 1: Successful Data Ingestion and Feature Vector Extraction
```gherkin
Given a verified applicant with active user consent for SLIK and Telco alternative data
When the client calls POST "/api/v1/data/ingest" with payload references
Then the system ingests data asynchronously, normalizes variables, and computes 42 feature metrics
And returns HTTP status code 202 Accepted with a trackable "job_id"
```

### Scenario 2: Reject Ingestion Request Without Active Consent
```gherkin
Given an applicant whose consent has expired or was revoked by the user
When the client calls POST "/api/v1/data/ingest" with applicant ID
Then the ingestion pipeline halts execution immediately
And returns HTTP status code 403 Forbidden with error code "CONSENT_INVALID_OR_REVOKED"
```

### Scenario 3: Malformed Alternative Data Payload Validation
```gherkin
Given an e-wallet transaction JSON payload missing timestamp or negative amount values
When the client calls POST "/api/v1/data/ingest"
Then the system rejects the invalid payload
And returns HTTP status code 400 Bad Request with explicit field validation errors
```

---

## 3. API Endpoint Specification

### 3.1 Data Ingestion Trigger Endpoint
- **HTTP Method:** `POST`
- **Path:** `/api/v1/data/ingest`
- **Headers:**
  - `Authorization: Bearer <jwt_access_token>`
  - `Content-Type: application/json`

#### Request Body JSON Schema:
```json
{
  "applicant_id": "a-11223344-5566-7788",
  "consent_id": "c7a8b9d0-1234-5678-9abc-def012345678",
  "data_sources": ["SLIK_OJK", "TELCO_ARPU", "EWALLET_TRANSACTIONS"],
  "payload": {
    "telco_data": {
      "avg_monthly_recharge_idr": 150000,
      "tenure_months": 36,
      "late_payment_count_6m": 0
    },
    "ewallet_data": {
      "monthly_inflow_avg_idr": 4500000,
      "monthly_outflow_avg_idr": 4100000,
      "transaction_frequency_monthly": 48
    }
  }
}
```

#### Response Payload (202 Accepted):
```json
{
  "status": "success",
  "data": {
    "job_id": "job-77665544-3322-1100",
    "applicant_id": "a-11223344-5566-7788",
    "status": "PROCESSING",
    "features_extracted_count": 42,
    "estimated_completion_ms": 350
  },
  "timestamp": "2026-10-10T14:40:00Z"
}
```

#### Response Payload (400 Bad Request):
```json
{
  "status": "error",
  "error": {
    "code": "DATA_MALFORMED_PAYLOAD",
    "message": "Field 'avg_monthly_recharge_idr' must be a non-negative integer.",
    "details": [
      {
        "field": "payload.telco_data.avg_monthly_recharge_idr",
        "issue": "Value -50000 is invalid"
      }
    ]
  },
  "timestamp": "2026-10-10T14:40:00Z"
}
```

#### Response Payload (403 Forbidden):
```json
{
  "status": "error",
  "error": {
    "code": "CONSENT_INVALID_OR_REVOKED",
    "message": "Consent ID 'c7a8b9d0-1234-5678-9abc-def012345678' is revoked or expired.",
    "details": []
  },
  "timestamp": "2026-10-10T14:40:00Z"
}
```

#### Response Payload (500 Internal Server Error):
```json
{
  "status": "error",
  "error": {
    "code": "DATA_PIPELINE_ERROR",
    "message": "Failed to normalize feature metrics due to storage engine lock.",
    "details": []
  },
  "timestamp": "2026-10-10T14:40:00Z"
}
```

---

## 4. Edge Cases & Failure Modes

1. **SLIK Record Not Found (No Credit History):** Jika calon debitur belum memiliki catatan di SLIK OJK, pipeline beralih secara otomatis ke *Alternative-Data-Only Scoring Sub-Model* dengan bobot risiko disesuaikan.
2. **Data Outlier Filtering:** Transaksi e-wallet individual di atas Rp 500.000.000 yang bersifat anomalous di-winsorize / di-cap pada percentile 99th untuk mencegah manipulasi skor kredit.

---

## 5. Security & Data Privacy Review
- **Zero Raw Data Persistence Policy:** Payload data transaksi mentah dilarang disimpan secara permanen di database. Setelah kalkulasi feature vector (contoh: `avg_monthly_recharge`), payload mentah dibuang dari memory buffer.
- **Feature Store Encryption:** Metrik fitur yang dihasilkan disimpan di database dalam bentuk terenkripsi AES-256.
