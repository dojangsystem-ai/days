---
title: "FR-04: Procure-to-Pay (Pengadaan & Penerimaan Barang)"
slug: "b2b-modular-erp"
date: "2026-10-11"
author: "System Architect Agent"
tags: ["prd", "erp", "procurement", "p2p", "purchase-order", "goods-receipt", "vendor-bill", "3-way-matching"]
category: "Product Spec"
status: "draft"
priority: "P0"
complexity: "High"
estimated_effort: "2 weeks"
---

# Feature Specification: Procure-to-Pay / P2P (FR-04)

## 1. User Story

**As a** Purchasing Officer / Bagian Pengadaan,  
**I want to** membuat pesanan pembelian (*Purchase Order* / PO), memvalidasi penerimaan fisik barang dari pemasok (*Goods Receipt Note* / GRN) yang otomatis menambah stok gudang, serta mencatat tagihan pemasok (*Vendor Bill*) dengan verifikasi pencocokan 3 arah (*3-way matching*),  
**So that** pengadaan barang berjalan tertib, stok masuk tercatat tepat waktu dan kuantitas, serta pembayaran kepada vendor hanya dilakukan atas barang yang benar-benar diterima sesuai kesepakatan harga.

![Ilustrasi Kemitraan Pengadaan & Penerimaan Barang Pemasok](../assets/procure-p2p-illust.jpg)
*Gambar 4.1: Ilustrasi Pengadaan (P2P) — Staf Pembelian dan Supplier Menyepakati Penerimaan Barang Sesuai Checklist PO.*

---

## 2. Acceptance Criteria (Gherkin Format)

### Scenario 1: Pembuatan & Konfirmasi Purchase Order ke Vendor
```gherkin
Given an authenticated Purchasing Officer in tenant "TNT-MD-001"
When the officer creates a Purchase Order for Vendor "PT Sumber Pangan Sejahtera" containing 100 Karton "SKU-MYK-001" at unit price "IDR 180.000"
Then the system calculates subtotal "IDR 18.000.000", PPN 11% "IDR 1.980.000", total "IDR 19.980.000"
And assigns sequential document number "PO/2026/10/00021"
And transitions the order status to "CONFIRMED"
```

### Scenario 2: Penerimaan Barang Parsial via Goods Receipt (GRN)
```gherkin
Given a confirmed Purchase Order "PO/2026/10/00021" for 100 Karton
When the warehouse officer receives 60 Karton fisik di "Gudang Utama"
Then the system creates Goods Receipt "GRN/2026/10/00018" with status "RECEIVED"
And triggers stock-in mutation to increment "quantity_on_hand" by 720 PCS (60 Karton x 12 PCS)
And updates PO line received status to 60/100 Karton
And sets PO status to "PARTIALLY_RECEIVED"
```

### Scenario 3: Validasi Tagihan Vendor dengan 3-Way Matching
```gherkin
Given an approved GRN for 60 Karton at agreed PO price "IDR 180.000"
When Finance attempts to record a Vendor Bill claiming 70 Karton or price "IDR 190.000"
Then the system detects 3-way matching discrepancy (Quantity mismatch: Billed 70 > Received 60)
And flags the bill as "DISCREPANCY_HOLD"
And prevents bill approval until supervisor approval or credit note is attached
```

---

## 3. API Endpoint Specifications

### 3.1 Create Purchase Order Endpoint
- **HTTP Method:** `POST`
- **Endpoint URI:** `/api/v1/procurement/orders`
- **Headers:**
  - `Authorization: Bearer <tenant_jwt_token>`
  - `Content-Type: application/json`
  - `X-Idempotency-Key: <uuid-v4>`

#### Request Body Schema:
```json
{
  "vendor_id": "vend-sps-001",
  "warehouse_id": "wh-01-cikarang",
  "order_date": "2026-10-11",
  "expected_delivery_date": "2026-10-15",
  "payment_term_days": 30,
  "lines": [
    {
      "product_id": "c1f24d1a-8bb7-49f3-8b7c-33e144a10e82",
      "quantity": 100.0,
      "uom_code": "KARTON",
      "unit_price": 180000.0,
      "discount_percent": 0.0,
      "tax_percent": 11.0
    }
  ],
  "notes": "Pengiriman tahap 1 via truk ekspedisi vendor"
}
```

#### Response Body Schema (201 Created):
```json
{
  "success": true,
  "data": {
    "purchase_order_id": "9a12c401-4be1-4034-8c01-762bc1298a01",
    "order_number": "PO/2026/10/00021",
    "status": "CONFIRMED",
    "vendor_id": "vend-sps-001",
    "subtotal": 18000000.0,
    "tax_amount": 1980000.0,
    "total_amount": 19980000.0,
    "created_at": "2026-10-11T08:15:00Z"
  }
}
```

### 3.2 Create Goods Receipt Note (GRN) Endpoint
- **HTTP Method:** `POST`
- **Endpoint URI:** `/api/v1/procurement/goods-receipts`
- **Headers:**
  - `Authorization: Bearer <tenant_jwt_token>`
  - `Content-Type: application/json`

#### Request Body Schema:
```json
{
  "purchase_order_id": "9a12c401-4be1-4034-8c01-762bc1298a01",
  "vendor_delivery_note_ref": "SJ-VENDOR-9912",
  "receiving_warehouse_id": "wh-01-cikarang",
  "destination_location_id": "loc-rack-a1",
  "receipt_date": "2026-10-11",
  "lines": [
    {
      "po_line_id": "line-po-001",
      "product_id": "c1f24d1a-8bb7-49f3-8b7c-33e144a10e82",
      "quantity_received": 60.0,
      "uom_code": "KARTON"
    }
  ]
}
```

#### Response Body Schema (201 Created):
```json
{
  "success": true,
  "data": {
    "goods_receipt_id": "2d8f9021-99ab-48d1-8172-bbce091a12e3",
    "receipt_number": "GRN/2026/10/00018",
    "status": "RECEIVED",
    "purchase_order_number": "PO/2026/10/00021",
    "total_items_received": 1,
    "stock_move_id": "sm-grn-00018",
    "received_at": "2026-10-11T08:30:00Z"
  }
}
```

---

## 4. Edge Cases & Failure Modes

- **Over-Delivery Handling:** Jika vendor mengirimkan barang melebihi kuantitas PO (misal dipesan 100 tapi dikirim 110), sistem menerapkan konfigurasi *Tolerance Policy*:
  - Jika toleransi 0%: sistem memblokir penerimaan kelebihan barang (wajib buat addendum PO).
  - Jika toleransi diizinkan (misal max 10%): sistem menerima kelebihan dan memberi flag khusus pada GRN.
- **Damaged Goods on Arrival:** Staf gudang dapat mencatat kuantitas barang rusak (*rejected/damaged qty*). Kuantitas ini tidak dimasukkan ke stok siap jual (*sellable quants*), melainkan dipindahkan ke lokasi scrap atau retur vendor (*return-to-vendor / RTV*).
- **Early Vendor Billing:** Jika Vendor Bill diinput sebelum GRN terbit, tagihan tetap berstatus `UNMATCHED_PENDING_GRN` dan tidak dapat dibayarkan sampai barang diverifikasi tiba oleh gudang.

---

## 5. Security & Data Privacy Review

- **Segregation of Duties (SoD):** User yang membuat PO tidak diperkenankan memvalidasi GRN atau menyetujui Vendor Bill di atas nominal tertentu guna mencegah kecurangan (*fraud prevention*).
- **Pricing Visibility:** Harga beli unit hanya dapat diakses oleh role Purchasing dan Finance; staf gudang saat menerima barang fisik hanya melihat kuantitas dan satuan tanpa nilai harga beli.

---

## Navigasi Modul & Fitur

| Navigasi | Tautan Dokumen |
| :--- | :--- |
| **← Fitur Sebelumnya** | [FR-03: Inventory & Multi-Warehouse](FR-03-inventory-and-warehouse.md) |
| **Katalog Fitur (Index)** | [features/README.md](README.md) |
| **Ikhtisar Ide (Overview)** | [00-overview.md](../00-overview.md) |
| **Fitur Selanjutnya →** | [FR-05: Order-to-Cash / O2C →](FR-05-order-to-cash.md) |
| **Roadmap Implementasi** | [roadmap.md](../roadmap.md) |

