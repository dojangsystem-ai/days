---
title: "FR-01: Multi-Tenant Core, RBAC & Sequence Engine"
slug: "b2b-modular-erp"
date: "2026-10-11"
author: "System Architect Agent"
tags: ["prd", "erp", "core", "multi-tenant", "rbac", "sequence-engine"]
category: "Product Spec"
status: "draft"
priority: "P0"
complexity: "High"
estimated_effort: "1-2 weeks"
---

# Feature Specification: Multi-Tenant Core, RBAC & Sequence Engine (FR-01)

## 1. User Story

**As a** System Administrator / Company Owner,  
**I want to** mengelola pendaftaran tenant perusahaan, hierarki peran pengguna (*roles & permissions*), serta format penomoran dokumen otomatis (seperti format nomor SO, PO, DO, dan Invoice),  
**So that** seluruh data operasional bisnis terisolasi secara aman antar-entitas, akses staf dibatasi sesuai tanggung jawab kerja, dan dokumen memiliki nomor seri berurutan tanpa celah (*gapless audit trail*).

---

## 2. Acceptance Criteria (Gherkin Format)

### Scenario 1: Registrasi Tenant Baru dan Inisialisasi Role Default
```gherkin
Given a platform superadmin with valid master authentication credentials
When the superadmin submits a POST request to "/api/v1/core/tenants" with company name "PT Maju Distribusi" and base currency "IDR"
Then the system creates a new isolated tenant entity with unique code "TNT-MD-001"
And generates standard system roles ("Owner", "WarehouseManager", "SalesOfficer", "PurchasingOfficer", "FinanceAdmin")
And provisions the default document numbering sequence profiles
And returns HTTP status code 201 Created with tenant details
```

### Scenario 2: Alokasi Nomor Seri Dokumen Unik & Thread-Safe
```gherkin
Given an authenticated user under tenant "TNT-MD-001" creating a Sales Order in month "2026-10"
When the system requests next sequence for document type "SALES_ORDER"
Then the sequence engine acquires atomic increment on the database sequence
And formats the generated serial number according to template "SO/{YYYY}/{MM}/{SEQ:5}"
And returns the assigned document number "SO/2026/10/00001"
And ensures no duplicate number can be generated under concurrent requests
```

### Scenario 3: Penolakan Akses Pengguna Tanpa Hak Akses (RBAC Failure)
```gherkin
Given a user with role "WarehouseOfficer" having only "inventory:*" permissions
When the user attempts to send a POST request to "/api/v1/sales/orders" to create a sales transaction
Then the system evaluates the RBAC permission policy
And intercepts the request with HTTP status code 403 Forbidden
And logs the unauthorized attempt into the audit log
```

---

## 3. API Endpoint Specifications

### 3.1 Tenant Registration Endpoint
- **HTTP Method:** `POST`
- **Endpoint URI:** `/api/v1/core/tenants`
- **Headers:**
  - `Authorization: Bearer <master_jwt_token>`
  - `Content-Type: application/json`

#### Request Body Schema:
```json
{
  "company_code": "MD-DIST",
  "company_name": "PT Maju Distribusi Makmur",
  "timezone": "Asia/Jakarta",
  "base_currency": "IDR",
  "fiscal_year_start_month": 1,
  "admin_user": {
    "full_name": "Hendro Wijaya",
    "email": "owner@majudistribusi.co.id",
    "password": "SecurePassword123!"
  }
}
```

#### Response Body Schema (201 Created):
```json
{
  "success": true,
  "message": "Tenant successfully registered and initialized",
  "data": {
    "tenant_id": "a91e52db-5c54-4c6e-826f-d12975878345",
    "company_code": "MD-DIST",
    "company_name": "PT Maju Distribusi Makmur",
    "base_currency": "IDR",
    "created_at": "2026-10-11T07:50:00Z",
    "admin_user_id": "3b6807f4-839e-4c7b-99d8-8ec1cf736c1e"
  }
}
```

### 3.2 Generate Next Document Sequence Number
- **HTTP Method:** `POST`
- **Endpoint URI:** `/api/v1/core/sequences/next`
- **Headers:**
  - `Authorization: Bearer <tenant_jwt_token>`
  - `Content-Type: application/json`

#### Request Body Schema:
```json
{
  "document_type": "SALES_ORDER",
  "reference_date": "2026-10-11"
}
```

#### Response Body Schema (200 OK):
```json
{
  "success": true,
  "data": {
    "sequence_id": "e826b6f7-b76b-4eef-bbf3-dca017c62bb1",
    "document_type": "SALES_ORDER",
    "generated_number": "SO/2026/10/00001",
    "counter": 1
  }
}
```

---

## 4. Edge Cases & Failure Modes

- **High-Concurrency Numbering Collision:** Apabila 50 sales order disimpan bersamaan dalam waktu 100ms, sistem menggunakan klausa `SELECT ... FOR UPDATE` pada tabel `document_sequences` atau native database sequences PostgreSQL per tenant untuk menggaransi angka berurutan tanpa duplikasi.
- **Tenant Context Bleeding:** Middleware memvalidasi bahwa klausa `tenant_id` dari JWT token identik dengan parameter path atau query yang diproses. Jika terdeteksi mismatch, request digugurkan dengan status `401 Unauthorized`.
- **Clock Drift & Year Rolling:** Ketika pergantian tahun/bulan terjadi, sistem secara otomatis mereset counter sequence sesuai konfigurasi template (`reset_frequency: MONTHLY | YEARLY | NEVER`).

---

## 5. Security & Data Privacy Review

- **Tenant Isolation Enforcement:** Penggunaan PostgreSQL Row-Level Security (RLS) dengan variable `app.current_tenant_id` yang diinjeksi pada setiap koneksi pool transaksi.
- **Password Hashing:** Menggunakan algoritma Argon2id / bcrypt (work factor 12) untuk penyimpanan kredensial user.
- **Audit Logging:** Seluruh mutasi konfigurasi tenant dan permission dicatat dalam tabel `audit_logs` yang bersifat append-only (*immutable*).

---

## Navigasi Modul & Fitur

| Navigasi | Tautan Dokumen |
| :--- | :--- |
| **← Dokumen Sebelumnya** | [01-architecture-and-techstack.md (Arsitektur Sistem)](../01-architecture-and-techstack.md) |
| **Katalog Fitur (Index)** | [features/README.md](README.md) |
| **Ikhtisar Ide (Overview)** | [00-overview.md](../00-overview.md) |
| **Fitur Selanjutnya →** | [FR-02: Master Data Management →](FR-02-master-data-management.md) |
| **Roadmap Implementasi** | [roadmap.md](../roadmap.md) |

