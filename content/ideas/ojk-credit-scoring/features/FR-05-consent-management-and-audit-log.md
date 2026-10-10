---
title: "FR-05: Consent Management & Cryptographic Audit Log Engine"
slug: "ojk-credit-scoring"
date: "2026-10-10"
author: "System Architect Agent"
tags: ["consent", "audit-log", "pdp-compliance", "cryptography", "ojk"]
category: "Product Spec"
status: "draft"
priority: "P0"
complexity: "High"
estimated_effort: "2 weeks"
---

# Feature Specification: FR-05 Consent Management & Cryptographic Audit Log Engine

## 1. User Story
- **As a** Compliance Officer or OJK External Auditor,
- **I want to** verify explicit user consents, consent revocations, and cryptographically signed action audit logs,
- **So that** every credit scoring request can be independently audited and proven to comply with UU PDP and SEOJK regulations.

---

## 2. Acceptance Criteria (Gherkin Format)

### Scenario 1: Record Explicit User Consent with Digital Signature
```gherkin
Given a debitur consenting to credit data processing with a digital signature payload
When the client calls POST "/api/v1/consent/record"
Then the system creates a consent record with SHA-256 digital signature digest
And returns HTTP status code 201 Created with a valid "consent_id" and expiration timestamp
```

### Scenario 2: Revoke Debitur Consent (Right to be Forgotten)
```gherkin
Given an active consent record ID
When the debitur or client calls POST "/api/v1/consent/revoke"
Then the system sets "is_revoked": true and triggers feature store data shredding
And returns HTTP status code 200 OK confirming revocation
```

### Scenario 3: Verify Audit Log Cryptographic Integrity
```gherkin
Given an auditor requesting log verification for a specific date range
When they call GET "/api/v1/audit/verify-chain"
Then the system recalculates SHA-256 HMAC hash chain over TimescaleDB log entries
And returns HTTP status code 200 OK with "integrity_status": "VALID"
```

---

## 3. API Endpoint Specification

### 3.1 Record Consent Endpoint
- **HTTP Method:** `POST`
- **Path:** `/api/v1/consent/record`
- **Headers:**
  - `Authorization: Bearer <jwt_access_token>`
  - `Content-Type: application/json`

#### Request Body JSON Schema:
```json
{
  "applicant_nik": "3171012304950001",
  "consent_scope": ["SLIK_CHECK", "ALTERNATIVE_TELCO", "ALTERNATIVE_EWALLET"],
  "consent_term_version": "v2026.1",
  "digital_signature_base64": "MEUCIQD...==",
  "ip_address": "202.158.10.45",
  "user_agent": "Mozilla/5.0 (iPhone; CPU iPhone OS 17_4 like Mac OS X)"
}
```

#### Response Payload (201 Created):
```json
{
  "status": "success",
  "data": {
    "consent_id": "c7a8b9d0-1234-5678-9abc-def012345678",
    "applicant_id": "a-11223344-5566-7788",
    "consent_scope": ["SLIK_CHECK", "ALTERNATIVE_TELCO", "ALTERNATIVE_EWALLET"],
    "granted_at": "2026-10-10T14:00:00Z",
    "expires_at": "2026-11-09T14:00:00Z",
    "signature_hash": "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
  },
  "timestamp": "2026-10-10T14:00:00Z"
}
```

#### Response Payload (400 Bad Request):
```json
{
  "status": "error",
  "error": {
    "code": "CONSENT_INVALID_SIGNATURE",
    "message": "Digital signature payload verification failed.",
    "details": []
  },
  "timestamp": "2026-10-10T14:00:00Z"
}
```

#### Response Payload (401 Unauthorized):
```json
{
  "status": "error",
  "error": {
    "code": "AUTH_INVALID_TOKEN",
    "message": "Bearer token invalid.",
    "details": []
  },
  "timestamp": "2026-10-10T14:00:00Z"
}
```

#### Response Payload (500 Internal Server Error):
```json
{
  "status": "error",
  "error": {
    "code": "AUDIT_STORAGE_FAILURE",
    "message": "Failed to write audit log entry to TimescaleDB.",
    "details": []
  },
  "timestamp": "2026-10-10T14:00:00Z"
}
```

---

## 4. Edge Cases & Failure Modes

1. **Audit Chain Tampering Detection:** Jika seseorang mengubah atau menghapus satu baris log di TimescaleDB secara manual, hash HMAC berikutnya tidak akan cocok. API `/api/v1/audit/verify-chain` memicu alarm *SECURITY_ALERT_LOG_TAMPERED* secara otomatis.
2. **Expired Consent Access:** Semua request scoring yang dikirim setelah `expires_at` akan langsung ditolak di level Consent Microservice.

---

## 5. Security & Data Privacy Review
- **Immutable Log Storage:** Table log di database menggunakan hak akses `INSERT-ONLY` (DML `UPDATE` dan `DELETE` dicabut dari semua database user, termasuk admin application user).
- **Cryptographic Hash Chaining:** Setiap log entry memuat `hash = SHA256(previous_hash + current_entry_data)`.
