---
title: "FR-04: Credit Scoring Engine & Explainable AI (XAI)"
slug: "ojk-credit-scoring"
date: "2026-10-10"
author: "System Architect Agent"
tags: ["ml", "xai", "credit-score", "shap", "xgboost", "ojk"]
category: "Product Spec"
status: "draft"
priority: "P0"
complexity: "Critical"
estimated_effort: "3-4 weeks"
---

# Feature Specification: FR-04 Credit Scoring Engine & Explainable AI (XAI)

## 1. User Story
- **As a** Risk Officer or OJK Auditor,
- **I want the system to** calculate a credit score (300-850), risk grade, default probability, and top SHAP factor drivers for every credit evaluation request,
- **So that** credit decisions are audit-transparent, mathematically justified, and compliant with OJK Explainability guidelines.

---

## 2. Acceptance Criteria (Gherkin Format)

### Scenario 1: Successful Credit Scoring Execution with Full XAI Breakdown
```gherkin
Given a valid request with an ingested feature vector and active consent
When the client calls POST "/api/v1/scoring/evaluate"
Then the ML Inference Engine computes credit score, probability of default (PD), and top 5 SHAP feature drivers
And returns HTTP status code 200 OK within 1200ms
```

### Scenario 2: Scoring Execution Failure Due to Feature Vector Incompleteness
```gherkin
Given a feature vector lacking mandatory identity or telco tenure features
When the client calls POST "/api/v1/scoring/evaluate"
Then the scoring engine rejects the execution
And returns HTTP status code 400 Bad Request with error code "SCORING_FEATURE_VECTOR_INCOMPLETE"
```

### Scenario 3: Model Invalidation Guard Triggered
```gherkin
Given an ML model artifact checksum mismatch or uncalibrated model version
When the client calls POST "/api/v1/scoring/evaluate"
Then the system halts inference and alerts system administrator
And returns HTTP status code 500 Internal Server Error with error code "MODEL_CHECKSUM_INVALID"
```

---

## 3. API Endpoint Specification

### 3.1 Scoring Evaluation Endpoint
- **HTTP Method:** `POST`
- **Path:** `/api/v1/scoring/evaluate`
- **Headers:**
  - `Authorization: Bearer <jwt_access_token>`
  - `Content-Type: application/json`

#### Request Body JSON Schema:
```json
{
  "applicant_id": "a-11223344-5566-7788",
  "consent_id": "c7a8b9d0-1234-5678-9abc-def012345678",
  "loan_amount_requested_idr": 15000000,
  "tenor_months": 12,
  "product_category": "PERSONAL_MICRO_LOAN"
}
```

#### Response Payload (200 OK):
```json
{
  "status": "success",
  "data": {
    "scoring_id": "sc-12345678-90ab-cdef",
    "applicant_id": "a-11223344-5566-7788",
    "credit_score": 742,
    "score_range": { "min": 300, "max": 850 },
    "risk_grade": "AA",
    "probability_of_default": 0.0215,
    "decision_recommendation": "APPROVE",
    "max_recommended_limit_idr": 20000000,
    "explainability_xai": {
      "base_value_score": 620,
      "top_factors": [
        {
          "rank": 1,
          "feature_key": "slik_collectibility_status",
          "display_name": "Riwayat Kolektibilitas SLIK",
          "impact": "POSITIVE",
          "shap_value": 65.4,
          "description": "Kolektibilitas Lancar (Kol-1) selama 24 bulan terakhir menambah skor."
        },
        {
          "rank": 2,
          "feature_key": "ewallet_net_cashflow_ratio",
          "display_name": "Rasio Arus Kas E-Wallet",
          "impact": "POSITIVE",
          "shap_value": 32.1,
          "description": "Surplus arus kas bulanan konsisten di atas 20%."
        },
        {
          "rank": 3,
          "feature_key": "telco_tenure_months",
          "display_name": "Masa Pakai Nomor Telco",
          "impact": "POSITIVE",
          "shap_value": 18.5,
          "description": "Nomor aktif > 36 bulan menunjukkan stabilitas identitas."
        },
        {
          "rank": 4,
          "feature_key": "credit_inquiry_count_30d",
          "display_name": "Jumlah Pengajuan Kredit (30 Hari)",
          "impact": "NEGATIVE",
          "shap_value": -12.3,
          "description": "Terdapat 3 pengajuan kredit dalam 30 hari terakhir."
        },
        {
          "rank": 5,
          "feature_key": "utility_bill_punctuality",
          "display_name": "Ketepatan Pembayaran Tagihan",
          "impact": "POSITIVE",
          "shap_value": 8.3,
          "description": "Pembayaran listrik/air selalu tepat waktu."
        }
      ]
    },
    "model_metadata": {
      "model_version": "v2.4.1-xgboost",
      "calculated_at": "2026-10-10T14:45:00Z"
    }
  },
  "timestamp": "2026-10-10T14:45:00Z"
}
```

#### Response Payload (400 Bad Request):
```json
{
  "status": "error",
  "error": {
    "code": "SCORING_FEATURE_VECTOR_INCOMPLETE",
    "message": "Missing required scoring features in feature store.",
    "details": [
      {
        "missing_feature": "telco_tenure_months",
        "action_required": "Run FR-03 Data Ingestion prior to scoring."
      }
    ]
  },
  "timestamp": "2026-10-10T14:45:00Z"
}
```

#### Response Payload (401 Unauthorized):
```json
{
  "status": "error",
  "error": {
    "code": "AUTH_EXPIRED_TOKEN",
    "message": "Authentication token has expired.",
    "details": []
  },
  "timestamp": "2026-10-10T14:45:00Z"
}
```

#### Response Payload (500 Internal Server Error):
```json
{
  "status": "error",
  "error": {
    "code": "MODEL_CHECKSUM_INVALID",
    "message": "Model artifact binary integrity check failed. Inference aborted.",
    "details": []
  },
  "timestamp": "2026-10-10T14:45:00Z"
}
```

---

## 4. Edge Cases & Failure Modes

1. **Extreme Score Degradation Alert:** Jika faktor negatif menurunkan skor > 200 poin secara tiba-tiba untuk debitur terverifikasi, sistem menandai skor sebagai `REFER` untuk peninjauan manual oleh Underwriter.
2. **Adverse Action Notice (Penolakan Kredit):** Jika rekomendasi `REJECT`, API secara otomatis memformat ringkasan top 3 faktor penolakan berdasar SHAP terendah untuk dikirimkan ke debitur sesuai regulasi OJK.

---

## 5. Security & Data Privacy Review
- **Model Governance:** Model ML yang terpasang wajib melalui audit berkala (Population Stability Index / PSI dan Characteristic Stability Index / CSI) setiap kuartal.
- **Model Artifact Protection:** File biner model ML di AWS S3 dienkripsi dengan KMS Key dan diverifikasi dengan checksum SHA-256 setiap kali container microservice Python di-spin up.
