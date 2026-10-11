---
title: "B2B Modular ERP - Architecture & Tech Stack"
slug: "b2b-modular-erp"
date: "2026-10-11"
author: "System Architect Agent"
tags: ["prd", "erp", "architecture", "mermaid", "erd", "tech-stack", "security"]
category: "Product Spec"
status: "draft"
priority: "P0"
complexity: "High"
estimated_effort: "8-10 weeks"
---

# B2B Modular ERP — System Architecture & Tech Stack

## 1. High-Level Modular Monolith Architecture

B2B Modular ERP mengadopsi pola **Modular Monolith** berbasis *Domain-Driven Design (DDD)* dan *Clean Architecture*. Pendekatan ini memberikan keunggulan kesederhanaan *deployment* dan performa *in-memory transaction* antar-modul, namun tetap memisahkan *domain boundary*, skema tabel, dan kontrak modul (*module public interfaces / domain events*) secara ketat agar siap diekstraksi menjadi microservices jika skala traffic menuntut di masa depan.

```mermaid
flowchart TD
    subgraph ClientLayer["Client & User Interface Tier"]
        AdminWeb["Admin Web Dashboard (Next.js / React SPA)"]
        MobileWarehouse["Warehouse Mobile PWA (Barcode / QR Scanner)"]
        CustomerPortal["B2B Customer Portal (PWA / Responsive)"]
    end

    subgraph GatewayTier["Edge & Gateway Tier"]
        ReverseProxy["Nginx / Cloudflare Edge (SSL & WAF)"]
        APIGateway["Modular API Gateway & Context Dispatcher"]
    end

    subgraph CoreEngine["Core Modular Monolith Engine"]
        subgraph Layer0["Layer 0: Core Foundation"]
            TenantContext["Tenant Context & Security Filter"]
            RBACModule["RBAC & Permission Evaluator"]
            SequenceEngine["Sequence Numbering Generator"]
            AuditDispatcher["Universal Audit Logger"]
        end

        subgraph Layer1["Layer 1: Master Data Management"]
            ProductCatalog["Product & Multi-UoM Module"]
            PartnerModule["Business Partner (Customer/Vendor) Module"]
            PriceEngine["Tiered Pricing & Price List Engine"]
        end

        subgraph Layer2["Layer 2: Operations & Supply Chain"]
            StockModule["Inventory & Multi-Warehouse Control"]
            P2PModule["Procure-to-Pay (P2P: PO -> GRN -> Bill)"]
            O2CModule["Order-to-Cash (O2C: SO -> DO -> Invoice)"]
        end

        subgraph Layer3["Layer 3: Financial & Sub-Ledger"]
            SubLedger["AP / AR Sub-Ledger & Aging Engine"]
            JournalDispatcher["Automated Journal Voucher Dispatcher"]
        end

        EventBus["Internal Domain Event Bus (In-Memory / Redis Streams)"]
    end

    subgraph DataStorage["Data Persistence & Caching Tier"]
        PostgresDB[("PostgreSQL 16 (Multi-Tenant RLS & Sub-Schemas)")]
        RedisCluster[("Redis 7 (Distributed Locking & Cache)")]
        DocStorage["Object Storage (S3 / MinIO - PDF & Barcode Docs)"]
    end

    AdminWeb --> ReverseProxy
    MobileWarehouse --> ReverseProxy
    CustomerPortal --> ReverseProxy

    ReverseProxy --> APIGateway
    APIGateway --> TenantContext

    TenantContext --> RBACModule
    RBACModule --> ProductCatalog
    RBACModule --> PartnerModule
    RBACModule --> StockModule
    RBACModule --> P2PModule
    RBACModule --> O2CModule

    O2CModule -->|Reserve Stock| StockModule
    O2CModule -->|Publish: OrderInvoiced| EventBus
    P2PModule -->|Receive Stock| StockModule
    P2PModule -->|Publish: BillApproved| EventBus

    EventBus --> SubLedger
    EventBus --> JournalDispatcher
    EventBus --> AuditDispatcher

    StockModule -.->|Pessimistic / Distributed Lock| RedisCluster
    CoreEngine --> PostgresDB
    CoreEngine --> DocStorage
```

---

## 2. Database Schema (Mermaid ERD)

Skema database diorganisasi secara modular dengan relasi berbasis kunci asing (*Foreign Keys*) dan `tenant_id` pada setiap tabel transaksional untuk memastikan isolasi data multi-tenant yang ketat.

```mermaid
erDiagram
    TENANTS ||--o{ USERS : "has"
    TENANTS ||--o{ PRODUCTS : "owns"
    TENANTS ||--o{ BUSINESS_PARTNERS : "manages"
    TENANTS ||--o{ WAREHOUSES : "operates"

    USERS ||--o{ USER_ROLES : "assigned"
    ROLES ||--o{ USER_ROLES : "contains"
    ROLES ||--o{ ROLE_PERMISSIONS : "defines"

    PRODUCTS ||--o{ PRODUCT_UOM_CONVERSIONS : "has"
    PRODUCTS ||--o{ STOCK_QUANTS : "tracked_in"
    WAREHOUSES ||--o{ STOCK_LOCATIONS : "contains"
    STOCK_LOCATIONS ||--o{ STOCK_QUANTS : "stores"

    BUSINESS_PARTNERS ||--o{ PURCHASE_ORDERS : "supplies"
    BUSINESS_PARTNERS ||--o{ SALES_ORDERS : "orders"

    PURCHASE_ORDERS ||--o{ PURCHASE_ORDER_LINES : "contains"
    PURCHASE_ORDERS ||--o{ GOODS_RECEIPTS : "fulfilled_by"
    GOODS_RECEIPTS ||--o{ GOODS_RECEIPT_LINES : "lists"

    SALES_ORDERS ||--o{ SALES_ORDER_LINES : "contains"
    SALES_ORDERS ||--o{ DELIVERY_ORDERS : "dispatched_by"
    DELIVERY_ORDERS ||--o{ DELIVERY_ORDER_LINES : "lists"

    DELIVERY_ORDERS ||--o{ CUSTOMER_INVOICES : "billed_by"
    CUSTOMER_INVOICES ||--o{ CUSTOMER_INVOICE_LINES : "items"

    TENANTS {
        uuid id PK
        string code UK
        string name
        string timezone
        string currency
        timestamp created_at
    }

    USERS {
        uuid id PK
        uuid tenant_id FK
        string email UK
        string password_hash
        string full_name
        boolean is_active
        timestamp created_at
    }

    BUSINESS_PARTNERS {
        uuid id PK
        uuid tenant_id FK
        string partner_type "CUSTOMER | VENDOR | BOTH"
        string code UK
        string name
        string tax_id
        decimal credit_limit
        int payment_term_days
        boolean is_active
    }

    PRODUCTS {
        uuid id PK
        uuid tenant_id FK
        string sku UK
        string barcode UK
        string name
        string base_uom
        decimal standard_cost
        decimal base_sales_price
        boolean is_active
    }

    WAREHOUSES {
        uuid id PK
        uuid tenant_id FK
        string code UK
        string name
        string address
        boolean is_active
    }

    STOCK_LOCATIONS {
        uuid id PK
        uuid warehouse_id FK
        string code
        string name
        string location_type "STORAGE | RECEIVING | DISPATCH | SCRAP"
    }

    STOCK_QUANTS {
        uuid id PK
        uuid tenant_id FK
        uuid product_id FK
        uuid location_id FK
        decimal quantity_on_hand
        decimal quantity_reserved
        decimal quantity_available
        timestamp updated_at
    }

    SALES_ORDERS {
        uuid id PK
        uuid tenant_id FK
        string order_number UK
        uuid customer_id FK
        date order_date
        string status "DRAFT | CONFIRMED | PROCESSING | DELIVERED | CANCELLED"
        decimal subtotal
        decimal tax_amount
        decimal total_amount
    }

    SALES_ORDER_LINES {
        uuid id PK
        uuid sales_order_id FK
        uuid product_id FK
        decimal quantity_ordered
        decimal quantity_delivered
        decimal unit_price
        decimal discount_amount
        decimal total_line_price
    }

    DELIVERY_ORDERS {
        uuid id PK
        uuid tenant_id FK
        string delivery_number UK
        uuid sales_order_id FK
        date dispatch_date
        string status "DRAFT | PACKED | SHIPPED | RECEIVED"
        uuid warehouse_id FK
    }

    CUSTOMER_INVOICES {
        uuid id PK
        uuid tenant_id FK
        string invoice_number UK
        uuid sales_order_id FK
        uuid customer_id FK
        date invoice_date
        date due_date
        string payment_status "UNPAID | PARTIAL | PAID | OVERDUE"
        decimal total_amount
        decimal balance_due
    }
```

---

## 3. Tech Stack & Infrastructure Specifications

| Komponen Arsitektur | Teknologi / Framework | Justifikasi Rekayasa (Engineering Rationale) |
| :--- | :--- | :--- |
| **Frontend Web Framework** | **Next.js 14+ (App Router, React 18/19, TypeScript)** | SSR untuk halaman portal & CSR cepat untuk SPA Admin Dashboard, modular routing, dan integrasi tipe end-to-end. |
| **UI Component Library** | **Tailwind CSS + Shadcn UI + Lucide Icons** | Desain clean, performa render tinggi tanpa CSS runtime overhead, mudah disesuaikan untuk tema multi-tenant. |
| **Client State & Cache** | **TanStack Query v5 + Zustand** | Optimistic UI updates, caching mutasi data operasional, dan manajemen state lokal yang ringan. |
| **Backend Runtime** | **Go 1.22+ (Fiber / Gin) ATAU Node.js (NestJS / Fastify)** | Kecepatan eksekusi tinggi, memory footprint rendah, konkurensi native via goroutine untuk menangani ribuan mutasi stok per detik. |
| **Database Utama** | **PostgreSQL 16** | Mendukung ACID transaksional ketat, skema relasional terstruktur, dan fitur *Row-Level Security (RLS)* bawaan untuk isolasi tenant. |
| **Distributed Cache & Locking**| **Redis 7 (Redis Cluster)** | Eksekusi *distributed lock* (`Redlock`) saat proses reservasi stok produk untuk mencegah *race condition* / *overselling*. |
| **Internal Domain Event Bus**| **Redis Streams / RabbitMQ** | Pengiriman event antar-modul tanpa kopling langsung (misal: saat Surat Jalan divalidasi, otomatis memicu mutasi stok dan jurnal akuntansi). |
| **Object & Document Storage** | **AWS S3 / Cloudflare R2 / MinIO** | Penyimpanan dokumen digital PDF (Surat Jalan, Faktur Penjualan, PO, label barcode). |
| **Container & Orchestration** | **Docker + Kubernetes (atau Docker Compose di VM Edge)** | Standardisasi environment, zero-downtime rolling deployment, dan portabilitas lokal. |

---

## 4. Security, Isolation, & Reliability Model

### 4.1 Multi-Tenant Data Isolation Strategy
- **Shared Database, Shared Schema dengan Row-Level Security (RLS):**
  - Setiap query transaksional secara wajib menyertakan filter `WHERE tenant_id = :current_tenant_id`.
  - Pada layer database, fungsi session context PostgreSQL (`SET LOCAL app.current_tenant_id = '...'`) diaktifkan via database connection middleware untuk menjamin tidak ada data tenant yang bocor antar-organisasi (*data leak immunity*).

### 4.2 Concurrency & Race-Condition Prevention (Stock Reservation)
- Untuk mencegah dua Sales Order memesan stok yang sama secara bersamaan:
  1. Backend mengakuisisi Redis Lock dengan kunci: `lock:stock:tenant:{tenant_id}:product:{product_id}:location:{location_id}` dengan TTL 3000ms.
  2. Eksekusi query verifikasi `quantity_available = (quantity_on_hand - quantity_reserved) >= requested_qty`.
  3. Update atomik `quantity_reserved = quantity_reserved + requested_qty`.
  4. Rilis Redis Lock.

### 4.3 Idempotency Key pada Endpoint Finansial
- Seluruh endpoint mutasi finansial dan status final dokumen (seperti `POST /api/v1/sales/orders`, `POST /api/v1/sales/invoices/pay`) mewajibkan header HTTP:
  - `X-Idempotency-Key: <UUIDv4>`
- Backend menyimpan status eksekusi idempotency key di Redis dengan TTL 24 jam. Jika permintaan dengan key yang sama diulang, sistem mengembalikan respon tersimpan sebelumnya tanpa mengeksekusi ulang mutasi database.

### 4.4 Granular RBAC (Role-Based Access Control)
- Struktur hak akses menggunakan tuple: `Resource:Action:Scope`
  - Contoh: `inventory.moves:create:warehouse_01`, `sales.orders:approve:all`, `accounting.reports:read:company`.
  - Token JWT hanya membawa `sub`, `tenant_id`, dan `role_ids`. Validasi permission detail dievaluasi oleh memory-cached policy layer.

---

## Navigasi Dokumen & Modul

| Navigasi | Tautan Dokumen |
| :--- | :--- |
| **← Dokumen Sebelumnya** | [00-overview.md (Ikhtisar Sistem)](00-overview.md) |
| **Arsitektur & Tech Stack** | [01-architecture-and-techstack.md](01-architecture-and-techstack.md) *(Halaman ini)* |
| **Katalog Fitur Lengkap** | [features/README.md](features/README.md) |
| **Dokumen Selanjutnya →** | [FR-01: Multi-Tenant Core & RBAC →](features/FR-01-multi-tenant-core-and-rbac.md) |
| **Roadmap Implementasi** | [roadmap.md →](roadmap.md) |

