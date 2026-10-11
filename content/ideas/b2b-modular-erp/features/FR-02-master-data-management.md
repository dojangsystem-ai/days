---
title: "FR-02: Master Data Management (Produk, Multi-UoM & Mitra Bisnis)"
slug: "b2b-modular-erp"
date: "2026-10-11"
author: "System Architect Agent"
tags: ["prd", "erp", "mdm", "products", "uom", "customers", "vendors", "credit-limit"]
category: "Product Spec"
status: "draft"
priority: "P0"
complexity: "Medium"
estimated_effort: "1-2 weeks"
---

# Feature Specification: Master Data Management (FR-02)

## 1. User Story

**As a** Master Data Administrator / Operations Supervisor,  
**I want to** mengelola katalog produk (SKU, barcode, satuan bertingkat / multi-UoM), serta master data mitra bisnis (Pelanggan dan Pemasok) beserta plafon kredit (*credit limit*) dan termin pembayaran (*payment terms*),  
**So that** transaksi pembelian, penjualan, dan mutasi persediaan memiliki referensi data yang valid, akurat, dan mencegah kesalahan konversi satuan barang di gudang.

---

## 2. Acceptance Criteria (Gherkin Format)

### Scenario 1: Penambahan Produk dengan Satuan Bertingkat (Multi-UoM Conversion)
```gherkin
Given a Master Data Admin authenticated in tenant "TNT-MD-001"
When the admin creates a product "Minyak Goreng Sawit 1L" with base unit "PCS"
And defines UoM conversions: 1 "KARTON" = 12 "PCS" and 1 "PALLET" = 40 "KARTON"
Then the system stores the base unit and conversion ratios
And makes the product available for selection in purchase and sales orders with any configured UoM
And calculates standard stock valuation based on the base unit "PCS"
```

### Scenario 2: Registrasi Mitra Bisnis dengan Plafon Kredit & Termin Pembayaran
```gherkin
Given a Sales Supervisor creating a new customer "Toko Berkah Abadi"
When the user submits credit limit "IDR 50.000.000", payment terms "TOP 30 Days", and NPWP details
Then the system creates the business partner profile with type "CUSTOMER"
And activates automated credit monitoring for subsequent sales transactions
And sets customer status to "ACTIVE"
```

### Scenario 3: Validasi Duplikasi Barcode atau SKU Produk
```gherkin
Given an existing active product with barcode "8992761102918"
When a user attempts to create or update another product with the same barcode in the same tenant
Then the system aborts the operation
And returns HTTP status code 409 Conflict with message "Barcode already registered to another SKU"
```

---

## 3. API Endpoint Specifications

### 3.1 Create Product with Multi-UoM Endpoint
- **HTTP Method:** `POST`
- **Endpoint URI:** `/api/v1/mdm/products`
- **Headers:**
  - `Authorization: Bearer <tenant_jwt_token>`
  - `Content-Type: application/json`

#### Request Body Schema:
```json
{
  "sku": "SKU-MYK-001",
  "barcode": "8992761102918",
  "name": "Minyak Goreng Sawit 1 Liter",
  "category_id": "cat-fnb-edible-oil",
  "base_uom": "PCS",
  "standard_cost": 14000.00,
  "base_sales_price": 16500.00,
  "min_stock_level": 240,
  "uom_conversions": [
    {
      "uom_code": "KARTON",
      "conversion_factor": 12.0,
      "sales_price": 192000.00,
      "is_purchase_default": true,
      "is_sales_default": true
    }
  ]
}
```

#### Response Body Schema (201 Created):
```json
{
  "success": true,
  "data": {
    "product_id": "c1f24d1a-8bb7-49f3-8b7c-33e144a10e82",
    "sku": "SKU-MYK-001",
    "barcode": "8992761102918",
    "name": "Minyak Goreng Sawit 1 Liter",
    "base_uom": "PCS",
    "uom_conversions_count": 1,
    "is_active": true,
    "created_at": "2026-10-11T07:55:00Z"
  }
}
```

### 3.2 Create Business Partner (Customer / Vendor) Endpoint
- **HTTP Method:** `POST`
- **Endpoint URI:** `/api/v1/mdm/partners`
- **Headers:**
  - `Authorization: Bearer <tenant_jwt_token>`
  - `Content-Type: application/json`

#### Request Body Schema:
```json
{
  "code": "CUST-TBA-001",
  "partner_type": "CUSTOMER",
  "name": "Toko Berkah Abadi",
  "tax_id": "01.234.567.8-012.000",
  "billing_address": "Jl. Raya Pasar Minggu No. 45, Jakarta Selatan",
  "shipping_address": "Gudang TBA, Jl. Lenteng Agung No. 12, Jakarta Selatan",
  "contact_person": "Haji Mansyur",
  "contact_phone": "+6281198765432",
  "credit_limit": 50000000.00,
  "payment_term_days": 30,
  "tax_inclusive": false
}
```

#### Response Body Schema (201 Created):
```json
{
  "success": true,
  "data": {
    "partner_id": "f8016b4a-0a2c-48c9-9407-3dcf2d13b4c1",
    "code": "CUST-TBA-001",
    "partner_type": "CUSTOMER",
    "name": "Toko Berkah Abadi",
    "credit_limit": 50000000.00,
    "current_receivable_balance": 0.00,
    "available_credit": 50000000.00,
    "is_active": true
  }
}
```

---

## 4. Edge Cases & Failure Modes

- **Non-Integer Unit Conversions:** Untuk produk yang memiliki satuan pecahan (seperti Kg ke Gram atau Meter ke Centimeter), sistem menyimpan `conversion_factor` dalam tipe data `DECIMAL(14, 4)` untuk mencegah kehilangan presisi desimal.
- **Circular Conversion Reference:** Sistem mencegah definisi konversi siklik (misal A -> B dan B -> A dengan rasio berbeda) dengan validasi graph hierarki satuan hanya menuju satu `base_uom` absolut.
- **Deaktivasi Master Data Terikat Transaksi:** Produk atau mitra bisnis yang telah memiliki histori transaksi aktif tidak dapat dihapus permanen (*hard delete*), melainkan hanya dapat diubah statusnya menjadi `is_active = false` (*soft archive*).

---

## 5. Security & Data Privacy Review

- **Tenant Isolation:** Pemeriksaan keunikan SKU dan kode Mitra Bisnis dibatasi per tenant (`UNIQUE(tenant_id, sku)` dan `UNIQUE(tenant_id, code)`).
- **Sensitive Financial Data Masking:** Informasi batas kredit dan NPWP hanya dapat dilihat oleh user dengan permission `mdm.partners:view_financial`.

---

## Navigasi Modul & Fitur

| Navigasi | Tautan Dokumen |
| :--- | :--- |
| **← Fitur Sebelumnya** | [FR-01: Multi-Tenant Core & RBAC](FR-01-multi-tenant-core-and-rbac.md) |
| **Katalog Fitur (Index)** | [features/README.md](README.md) |
| **Ikhtisar Ide (Overview)** | [00-overview.md](../00-overview.md) |
| **Fitur Selanjutnya →** | [FR-03: Inventory & Warehouse Control →](FR-03-inventory-and-warehouse.md) |
| **Roadmap Implementasi** | [roadmap.md](../roadmap.md) |

