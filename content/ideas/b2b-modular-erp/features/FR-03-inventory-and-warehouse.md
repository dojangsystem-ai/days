---
title: "FR-03: Inventory & Multi-Warehouse Stock Control"
slug: "b2b-modular-erp"
date: "2026-10-11"
author: "System Architect Agent"
tags: ["prd", "erp", "inventory", "warehouse", "stock-quants", "distributed-lock", "stock-moves"]
category: "Product Spec"
status: "draft"
priority: "P0"
complexity: "High"
estimated_effort: "2 weeks"
---

# Feature Specification: Inventory & Multi-Warehouse Stock Control (FR-03)

## 1. User Story

**As a** Warehouse Manager / Staf Logistik,  
**I want to** memantau posisi stok per gudang dan lokasi rak secara *real-time*, mengelola pergerakan barang (masuk, keluar, transfer antar-gudang, dan penyesuaian stok opname), serta melakukan reservasi stok secara otomatis saat pesanan penjualan dibuat,  
**So that** tidak terjadi *overselling*, barang yang ada di gudang selalu akurat dengan catatan sistem, dan riwayat mutasi barang dapat ditelusuri (*fully traceable*).

![Ilustrasi Operasional Gudang & Pemindaian Barcode](../assets/warehouse-stock-illust.jpg)
*Gambar 3.1: Ilustrasi Aktivitas Gudang — Staf Memindai Barcode Barang Masuk (GRN) dan Penataan Stok Pallet ke Rak Penyimpanan.*

---

## 2. Acceptance Criteria (Gherkin Format)

### Scenario 1: Reservasi Stok Otomatis Saat Sales Order Dikonfirmasi
```gherkin
Given a product "SKU-MYK-001" with "quantity_on_hand" 100 PCS and "quantity_reserved" 20 PCS in "Gudang Utama"
When a Sales Order requests reservation for 30 PCS
Then the system acquires a distributed Redis lock on the product location key
And verifies available quantity (100 - 20 = 80 >= 30)
And increments "quantity_reserved" to 50 PCS
And releases the lock
And returns HTTP status code 200 OK with reserved quant snapshot
```

### Scenario 2: Penolakan Reservasi Akibat Stok Tersedia Tidak Mencukupi (Insufficient Stock)
```gherkin
Given a product "SKU-MYK-001" with available quantity 10 PCS in "Gudang Utama"
When a user attempts to reserve 15 PCS for a Sales Order
Then the system rejects the reservation attempt
And rolls back any intermediate state
And returns HTTP status code 422 Unprocessable Entity with error code "INSUFFICIENT_STOCK_AVAILABLE"
```

### Scenario 3: Mutasi Stok Fisik Keluar Saat Validasi Surat Jalan (Stock Out Move)
```gherkin
Given a Delivery Order confirmed for shipment with 30 PCS reserved of "SKU-MYK-001"
When the warehouse officer validates the dispatch operation
Then the system creates a completed "STOCK_MOVE" record from location "Gudang Utama/Rack-A" to "Customer/External"
And decrements "quantity_on_hand" by 30 PCS
And decrements "quantity_reserved" by 30 PCS
And publishes the domain event "StockMoveCompleted"
```

---

## 3. API Endpoint Specifications

### 3.1 Get Stock Quant per Warehouse / Location Endpoint
- **HTTP Method:** `GET`
- **Endpoint URI:** `/api/v1/inventory/quants`
- **Headers:**
  - `Authorization: Bearer <tenant_jwt_token>`
- **Query Parameters:**
  - `warehouse_id` (UUID, optional)
  - `product_id` (UUID, optional)
  - `sku` (string, optional)

#### Response Body Schema (200 OK):
```json
{
  "success": true,
  "data": [
    {
      "quant_id": "7d9b23f1-0a41-45c2-b5e1-881c03e84012",
      "warehouse_id": "wh-01-cikarang",
      "warehouse_name": "Gudang Pusat Cikarang",
      "location_id": "loc-rack-a1",
      "location_code": "RACK-A1",
      "product_id": "c1f24d1a-8bb7-49f3-8b7c-33e144a10e82",
      "sku": "SKU-MYK-001",
      "product_name": "Minyak Goreng Sawit 1 Liter",
      "base_uom": "PCS",
      "quantity_on_hand": 1200.0,
      "quantity_reserved": 350.0,
      "quantity_available": 850.0,
      "last_moved_at": "2026-10-11T06:30:00Z"
    }
  ],
  "meta": {
    "total_records": 1,
    "page": 1,
    "limit": 20
  }
}
```

### 3.2 Create Stock Transfer / Movement Endpoint
- **HTTP Method:** `POST`
- **Endpoint URI:** `/api/v1/inventory/moves`
- **Headers:**
  - `Authorization: Bearer <tenant_jwt_token>`
  - `Content-Type: application/json`
  - `X-Idempotency-Key: <uuid-v4>`

#### Request Body Schema:
```json
{
  "move_type": "INTERNAL_TRANSFER",
  "source_location_id": "loc-rack-a1",
  "destination_location_id": "loc-staging-b2",
  "reference_document": "TRF/2026/10/00012",
  "lines": [
    {
      "product_id": "c1f24d1a-8bb7-49f3-8b7c-33e144a10e82",
      "quantity": 120.0,
      "uom_code": "PCS"
    }
  ],
  "notes": "Relokasi stok fast-moving ke rak staging depan"
}
```

#### Response Body Schema (201 Created):
```json
{
  "success": true,
  "data": {
    "move_id": "8b9e4a31-6e12-42da-91ef-00192eab5581",
    "move_number": "SM/2026/10/00045",
    "status": "COMPLETED",
    "source_location_id": "loc-rack-a1",
    "destination_location_id": "loc-staging-b2",
    "executed_at": "2026-10-11T08:00:00Z"
  }
}
```

---

## 4. Edge Cases & Failure Modes

- **High-Velocity Race Condition:** Ketika ada 100 pesanan masuk bersamaan merebut 10 sisa stok:
  - Backend menggunakan Redis Lock `lock:inventory:product:{id}:loc:{id}` dengan timeout 2000ms.
  - Jika akuisisi kunci gagal/timeout, request menerima respon HTTP 409 Conflict dengan instruksi *retry with exponential backoff*.
- **Negative Stock Prevention:** Database constraint `CHECK (quantity_on_hand >= 0)` dan `CHECK (quantity_on_hand >= quantity_reserved)` diterapkan pada tabel `stock_quants` untuk mencegah stok minus akibat anomali mutasi concurrent.
- **Stock Opname Discrepancy:** Selisih stok opname tidak langsung menimpa data kuantitas, melainkan mewajibkan pembuatan dokumen `STOCK_ADJUSTMENT` yang memerlukan persetujuan Supervisor Gudang sebelum memutasi `stock_quants` dan mencatat selisih ke akun kerugian selisih persediaan.

---

## 5. Security & Data Privacy Review

- **Warehouse Location Access Scope:** Staf gudang dibatasi hanya dapat mengonfirmasi mutasi stok untuk gudang yang didelegasikan padanya (diperiksa via `user_warehouse_assignments`).
- **Immutable Stock Ledger:** Tabel `stock_moves` bersifat *append-only*. Tidak ada operasi UPDATE atau DELETE yang diizinkan terhadap mutasi yang telah berstatus `COMPLETED`. Jika terjadi pembatalan, sistem menerbitkan mutasi pembalik (*reversing movement*).

---

## Navigasi Modul & Fitur

| Navigasi | Tautan Dokumen |
| :--- | :--- |
| **← Fitur Sebelumnya** | [FR-02: Master Data Management](FR-02-master-data-management.md) |
| **Katalog Fitur (Index)** | [features/README.md](README.md) |
| **Ikhtisar Ide (Overview)** | [00-overview.md](../00-overview.md) |
| **Fitur Selanjutnya →** | [FR-04: Procure-to-Pay / P2P →](FR-04-procure-to-pay.md) |
| **Roadmap Implementasi** | [roadmap.md](../roadmap.md) |

