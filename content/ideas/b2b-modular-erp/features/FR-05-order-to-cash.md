---
title: "FR-05: Order-to-Cash (Penjualan Grosir, Surat Jalan & Penagihan)"
slug: "b2b-modular-erp"
date: "2026-10-11"
author: "System Architect Agent"
tags: ["prd", "erp", "sales", "o2c", "sales-order", "delivery-order", "invoicing", "credit-limit", "accounts-receivable"]
category: "Product Spec"
status: "draft"
priority: "P0"
complexity: "High"
estimated_effort: "2 weeks"
---

# Feature Specification: Order-to-Cash / O2C (FR-05)

## 1. User Story

**As a** B2B Sales Representative & Billing Specialist,  
**I want to** membuat pesanan penjualan (*Sales Order* / SO) dengan pengecekan batas kredit dan reservasi stok otomatis, menerbitkan Surat Jalan (*Delivery Order* / DO) saat barang dikirim dari gudang, serta mencetak Faktur Penjualan (*Customer Invoice*) dengan pelacakan piutang dagang (*Accounts Receivable*),  
**So that** proses pengiriman barang ke pelanggan terkontrol ketat, risiko piutang macet dicegah sejak awal, dan penagihan tercatat rapi sesuai syarat termin pembayaran.

![Ilustrasi Kasir Grosir & Penjualan Order-to-Cash](../assets/sales-o2c-illust.jpg)
*Gambar 5.1: Ilustrasi Transaksi Penjualan & Kasir Grosir (O2C) — Staf Kasir Memindai Dus Barang dan Pelanggan Melakukan Pembayaran QRIS.*

---

## 2. Acceptance Criteria (Gherkin Format)

### Scenario 1: Pembuatan Sales Order Berhasil dengan Pengecekan Kredit & Reservasi Stok
```gherkin
Given a Customer "Toko Berkah Abadi" with available credit "IDR 50.000.000"
And available stock of "SKU-MYK-001" is 100 Karton in "Gudang Utama"
When the sales representative submits a Sales Order for 20 Karton with total value "IDR 3.840.000"
Then the system verifies the total does not exceed available credit (3.840.000 <= 50.000.000)
And locks and reserves 20 Karton (240 PCS) in "Gudang Utama"
And assigns sequential document number "SO/2026/10/00088"
And transitions SO status to "CONFIRMED"
```

### Scenario 2: Penolakan Sales Order Akibat Batas Kredit Terlampaui (Credit Limit Exceeded)
```gherkin
Given a Customer with remaining available credit "IDR 2.000.000"
When the sales representative attempts to submit a Sales Order with total "IDR 5.000.000"
Then the system blocks the confirmation
And flags the order with status "CREDIT_HOLD"
And notifies the Finance Manager for credit limit override or prepayment requirement
```

### Scenario 3: Pengiriman Barang (DO) Mengurangi Stok Fisik & Menerbitkan Invoice
```gherkin
Given a confirmed Sales Order "SO/2026/10/00088"
When the warehouse officer validates the Delivery Order "DO/2026/10/00054" for 20 Karton
Then the system creates a completed stock-out movement
And decrements both "quantity_on_hand" and "quantity_reserved" by 240 PCS
And transitions Delivery Order to "SHIPPED"
And triggers automatic draft Customer Invoice "INV/2026/10/00062" with due date 30 days from dispatch
```

---

## 3. API Endpoint Specifications

### 3.1 Create Sales Order Endpoint
- **HTTP Method:** `POST`
- **Endpoint URI:** `/api/v1/sales/orders`
- **Headers:**
  - `Authorization: Bearer <tenant_jwt_token>`
  - `Content-Type: application/json`
  - `X-Idempotency-Key: <uuid-v4>`

#### Request Body Schema:
```json
{
  "customer_id": "f8016b4a-0a2c-48c9-9407-3dcf2d13b4c1",
  "warehouse_id": "wh-01-cikarang",
  "order_date": "2026-10-11",
  "payment_term_days": 30,
  "shipping_address": "Gudang TBA, Jl. Lenteng Agung No. 12, Jakarta Selatan",
  "lines": [
    {
      "product_id": "c1f24d1a-8bb7-49f3-8b7c-33e144a10e82",
      "quantity": 20.0,
      "uom_code": "KARTON",
      "unit_price": 192000.0,
      "discount_percent": 0.0,
      "tax_percent": 11.0
    }
  ],
  "sales_person_id": "usr-sales-01"
}
```

#### Response Body Schema (201 Created):
```json
{
  "success": true,
  "data": {
    "sales_order_id": "5e114092-a1b2-4d3e-9081-30491823bc81",
    "order_number": "SO/2026/10/00088",
    "status": "CONFIRMED",
    "customer_id": "f8016b4a-0a2c-48c9-9407-3dcf2d13b4c1",
    "subtotal": 3840000.0,
    "tax_amount": 422400.0,
    "total_amount": 4262400.0,
    "stock_reservation_status": "FULLY_RESERVED",
    "created_at": "2026-10-11T09:00:00Z"
  }
}
```

### 3.2 Validate Delivery Order (Dispatch Barang) Endpoint
- **HTTP Method:** `POST`
- **Endpoint URI:** `/api/v1/sales/delivery-orders/{do_id}/validate`
- **Headers:**
  - `Authorization: Bearer <tenant_jwt_token>`
  - `Content-Type: application/json`

#### Request Body Schema:
```json
{
  "actual_dispatch_date": "2026-10-11T09:30:00Z",
  "driver_name": "Agus Salim",
  "vehicle_plate_number": "B 9182 KDA",
  "driver_phone": "+6281311223344"
}
```

#### Response Body Schema (200 OK):
```json
{
  "success": true,
  "data": {
    "delivery_order_id": "do-2026-10-00054",
    "delivery_number": "DO/2026/10/00054",
    "status": "SHIPPED",
    "stock_moves_executed": 1,
    "generated_invoice_id": "inv-2026-10-00062",
    "generated_invoice_number": "INV/2026/10/00062",
    "dispatched_at": "2026-10-11T09:30:00Z"
  }
}
```

---

## 4. Edge Cases & Failure Modes

- **Partial Delivery (Pengiriman Bertahap):** Jika armada truk tidak muat mengangkut seluruh pesanan sekaligus, sistem memungkinkan penerbitan beberapa Delivery Order (DO) berurutan dari 1 Sales Order yang sama hingga total kuantitas terpenuhi.
- **Order Cancellation Post-Reservation:** Jika pelanggan membatalkan pesanan berstatus `CONFIRMED`, sistem secara atomik melepaskan kuantitas cadangan (`quantity_reserved = quantity_reserved - order_qty`) dan memulihkan sisa limit kredit pelanggan.
- **Credit Limit Bypass with Management Override:** Dalam kondisi tertentu (misal: pesanan mendesak dari pelanggan strategis), Sales Order berstatus `CREDIT_HOLD` dapat disetujui hanya dengan token otorisasi khusus dari Direktur / CFO via endpoint override (`POST /api/v1/sales/orders/{id}/override-credit`).

---

## 5. Security & Data Privacy Review

- **Credit Data Integrity:** Perhitungan total piutang berjalan dihitung secara *server-side* langsung dari subledger piutang (`SUM(balance_due)`), mencegah manipulasi nilai kredit dari sisi client.
- **Delivery Sign-Off:** Surat Jalan digital mendukung penangkapan tanda tangan penerima (*digital signature / photo POD*) saat barang diserahterimakan untuk validitas hukum.

---

## Navigasi Modul & Fitur

| Navigasi | Tautan Dokumen |
| :--- | :--- |
| **← Fitur Sebelumnya** | [FR-04: Procure-to-Pay / P2P](FR-04-procure-to-pay.md) |
| **Katalog Fitur (Index)** | [features/README.md](README.md) |
| **Ikhtisar Ide (Overview)** | [00-overview.md](../00-overview.md) |
| **Roadmap Implementasi →** | [roadmap.md (Tahapan Eksekusi) →](../roadmap.md) |

