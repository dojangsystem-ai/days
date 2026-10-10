---
title: "FR-01: User Authentication & RBAC Management"
slug: "ojk-credit-scoring"
date: "2026-10-10"
author: "System Architect Agent"
tags: ["auth", "rbac", "security", "jwt", "oauth2"]
category: "Product Spec"
status: "draft"
priority: "P0"
complexity: "High"
estimated_effort: "1-2 weeks"
---

# Feature Specification: FR-01 User Authentication & RBAC Management

## 1. User Story
- **As a** Client Financial Institution (B2B Partner) or Internal Auditor,
- **I want to** authenticate securely using mTLS and OAuth2 JWT with strict Role-Based Access Control (RBAC),
- **So that** only authorized services and personnel can access sensitive credit scoring APIs and regulatory audit trails.

---

## 2. Acceptance Criteria (Gherkin Format)

### Scenario 1: Successful B2B Client Credentials Token Generation
```gherkin
Given a registered tenant with valid client_id and valid mTLS client certificate
When they send a POST request to "/api/v1/auth/token" with grant_type "client_credentials"
Then the system authenticates the certificate fingerprint and client secret
And returns HTTP status code 200 OK with an RS256-signed JWT Access Token valid for 3600 seconds
```

### Scenario 2: Access Denied Due to Invalid Client Credentials or Revoked Certificate
```gherkin
Given an unregistered tenant or invalid client_secret
When they send a POST request to "/api/v1/auth/token"
Then the system rejects the authentication request
And returns HTTP status code 401 Unauthorized with error code "AUTH_INVALID_CREDENTIALS"
```

### Scenario 3: Unauthorized Access to Auditor Endpoint by Underwriter Role
```gherkin
Given an authenticated user with role "UNDERWRITER"
When they attempt to access GET "/api/v1/audit/logs/export" requiring "AUDITOR_OJK" role
Then the system blocks the request
And returns HTTP status code 403 Forbidden with error code "AUTH_INSUFFICIENT_PERMISSIONS"
```

---

## 3. API Endpoint Specification

### 3.1 Token Generation Endpoint
- **HTTP Method:** `POST`
- **Path:** `/api/v1/auth/token`
- **Headers:**
  - `Content-Type: application/x-www-form-urlencoded`
  - `X-Client-Cert-SHA256: <cert_fingerprint>` (Injected by Gateway mTLS)

#### Request Body (URL Encoded):
```text
grant_type=client_credentials&client_id=tenant_8f9a2b1c&client_secret=sec_99x88y77z66
```

#### Response Payload (200 OK):
```json
{
  "status": "success",
  "data": {
    "access_token": "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9...",
    "token_type": "Bearer",
    "expires_in": 3600,
    "scope": "scoring:read scoring:write consent:verify"
  },
  "timestamp": "2026-10-10T14:30:00Z"
}
```

#### Response Payload (401 Unauthorized):
```json
{
  "status": "error",
  "error": {
    "code": "AUTH_INVALID_CREDENTIALS",
    "message": "Invalid client_id or client_secret provided.",
    "details": []
  },
  "timestamp": "2026-10-10T14:30:00Z"
}
```

#### Response Payload (403 Forbidden):
```json
{
  "status": "error",
  "error": {
    "code": "AUTH_INSUFFICIENT_PERMISSIONS",
    "message": "Role 'UNDERWRITER' is not permitted to access this resource.",
    "details": [
      {
        "required_role": "AUDITOR_OJK",
        "provided_role": "UNDERWRITER"
      }
    ]
  },
  "timestamp": "2026-10-10T14:30:00Z"
}
```

#### Response Payload (500 Internal Server Error):
```json
{
  "status": "error",
  "error": {
    "code": "INTERNAL_SERVER_ERROR",
    "message": "An unexpected authentication service error occurred.",
    "details": []
  },
  "timestamp": "2026-10-10T14:30:00Z"
}
```

---

## 4. Edge Cases & Failure Modes

1. **Client Certificate Revocation (CRL/OCSP Stale):** Jika mTLS Gateway gagal memverifikasi CRL/OCSP server, koneksi diblokir di tingkat API Gateway sebelum mencapai Auth Service.
2. **Brute Force Protection:** Percobaan autentikasi gagal > 5 kali dalam 1 menit dari IP yang sama akan memicu IP blocking selama 15 menit melalui Redis Rate Limiter.
3. **Clock Skew Tolerance:** Toleransi perbedaan waktu (skew) JWT validation diatur maksimal $\le 5\text{ detik}$.

---

## 5. Security & Data Privacy Review
- **Token Signing:** Menggunakan RS256 Asymmetric Key (2048-bit Private Key disimpan di AWS KMS).
- **No PII in JWT Payload:** JWT Claims hanya memuat `sub` (tenant_id), `role`, `scopes`, dan `exp`. Dilarang memasukkan Nama, Email, atau NIK ke dalam JWT body.
