---
title: "Arsitektur Sistem & Tech Stack — DAYS"
slug: "dojang-management"
date: "2026-10-12"
author: "System Architect Agent"
tags: ["architecture", "techstack", "erd", "security", "dojang", "days"]
category: "Product Spec"
status: "draft"
priority: "P0"
complexity: "High"
estimated_effort: "8-12 weeks"
---

# 🏗️ Arsitektur Sistem & Tech Stack — DAYS

> **Official Portal & Website:** [https://dojang.warsootech.com](https://dojang.warsootech.com)  
> 📍 **Navigasi Cepat:** [🏠 Overview](00-overview.md) • [🏗️ 01-Arsitektur](01-architecture-and-techstack.md) • [💎 02-Nilai & Monetisasi](02-value-system-and-monetization.md) • [🗺️ 03-Roadmap](03-roadmap.md) • [⚡ Fitur (FR-01 s/d 06)](features/FR-01-user-authentication.md) • [📸 Showcase UI](modules/days-admin/SHOWCASE.md)

## 1. Arsitektur Topologi Sistem (System Topology)

Ekosistem **DAYS** ([dojang.warsootech.com](https://dojang.warsootech.com)) mengusung arsitektur *Modular Micro-Frontend with Unified High-Resilience Backend*. Sistem memisahkan pengalaman pengguna ke dalam portal publik yang ringan, mobile apps untuk aktivitas lapangan, dan modul web komando untuk pengelolaan administrasi dan event skala besar:

```mermaid
flowchart TD
    subgraph Clients ["Lapis Klien Antarmuka (Clients Layer)"]
        CORE_WEB["🌐 DAYS Core Web<br/>(Next.js / Astro - SSR/SSG)<br/><i>Public Portal & Auth Gate</i>"]
        ADM_WEB["🖥️ DAYS Admin Web<br/>(React / Vite SPA)<br/><i>Club Ops & Multi-Branch</i>"]
        CCH_PWA["📱 DAYS Coach App<br/>(React PWA / Mobile Viewport)<br/><i>QR Scan, Scoring, Readiness</i>"]
        MBR_PWA["📱 DAYS Member App<br/>(React PWA / Mobile Viewport)<br/><i>Schedule, Dues, Sports Science</i>"]
        EXE_WEB["🎛️ DAYS Executive Command Center<br/>(React SPA / WebSocket Client)<br/><i>Tournaments, UKT, Governance</i>"]
        TV_DISP["📺 Arena Scoreboard TV<br/>(Ultra-Low-Latency Display)<br/><i>Fullscreen Dual-View</i>"]
    end

    subgraph Gateway ["API Gateway & Security Layer"]
        KONG["🛡️ API Gateway (Kong / Cloudflare)<br/>• TLS 1.3 Termination<br/>• Rate Limiting & DDoS Shield<br/>• Smart Role Routing"]
    end

    subgraph Services ["Lapis Layanan Backend (Microservices / Modular Monolith)"]
        AUTH_SVC["🔐 Auth & RBAC Service<br/>(JWT, Refresh Tokens, Scopes)"]
        DOJANG_SVC["🥋 Dojang Management Service<br/>(Members, Dues, Schedules, CMS)"]
        READINESS_SVC["💪 Sports Science & Readiness Service<br/>(5P Algorithm, Session-RPE, Injuries)"]
        EVENT_SVC["🏆 UKT & Event Grading Service<br/>(Pos Grouping, Rubric, E-Cert Gen)"]
        TOURNAMENT_SVC["⚔️ Tournament Engine Service<br/>(Brackets, Call Room, Weigh-in, Live Scoring)"]
        FEDERATION_SVC["🏛️ Federation Governance Service<br/>(Territorial GIS, Transfer, MAU & Health Index)"]
        NOTIF_SVC["📨 Notification & Dispatch Service<br/>(WhatsApp Bot, Web Push, Email)"]
    end

    subgraph DataStore ["Lapis Data & Message Bus"]
        PG_DB[(🐘 Primary PostgreSQL<br/>Multi-Tenant DB with Row-Level Security)]
        REDIS_CACHE[(⚡ Redis Cache & Pub/Sub<br/>Match Realtime & Session Store)]
        S3_STORAGE[(🪣 MinIO / AWS S3<br/>E-Cert PDFs, Photos, Documents)]
    end

    CORE_WEB & ADM_WEB & CCH_PWA & MBR_PWA & EXE_WEB & TV_DISP -->|HTTPS / WSS| KONG

    KONG --> AUTH_SVC
    KONG --> DOJANG_SVC
    KONG --> READINESS_SVC
    KONG --> EVENT_SVC
    KONG --> TOURNAMENT_SVC
    KONG --> FEDERATION_SVC

    AUTH_SVC & DOJANG_SVC & READINESS_SVC & EVENT_SVC & TOURNAMENT_SVC & FEDERATION_SVC --> PG_DB
    TOURNAMENT_SVC <-->|Score Stream WSS| REDIS_CACHE
    EVENT_SVC & TOURNAMENT_SVC --> S3_STORAGE
    DOJANG_SVC & TOURNAMENT_SVC --> NOTIF_SVC
```

![Ilustrasi Arena Kejuaraan & Digital Scoring DAYS](assets/tournament-engine-illust.jpg)
*Gambar 2.1: Ilustrasi Digital Arena Kejuaraan — Mengintegrasikan Terminal Scoring Meja Wasit, Live LED Scoreboard TV Arena, dan Smart Bracket Engine.*

---

## 2. Skema Database Terintegrasi (Entity-Relationship Diagram)

```mermaid
erDiagram
    users ||--o{ user_roles : has
    users ||--o| member_profiles : extends
    users ||--o| coach_profiles : extends
    
    dojangs ||--o{ dojang_branches : operates
    dojangs ||--o{ member_profiles : registers
    dojangs ||--o{ coach_profiles : contracts
    dojangs ||--o{ classes : organizes
    dojangs ||--o{ monthly_dues : invoices
    
    classes ||--o{ schedules : schedules
    coach_profiles ||--o{ schedules : instructs
    schedules ||--o{ attendances : records
    member_profiles ||--o{ attendances : logs
    
    member_profiles ||--o{ athlete_readiness_logs : submits
    member_profiles ||--o{ physical_histories : updates
    
    events ||--o{ event_categories : partitions
    events ||--o{ event_registrations : enrolls
    dojangs ||--o{ event_registrations : represents
    member_profiles ||--o{ event_registrations : snapshot_of
    
    event_categories ||--o{ tournament_matches : brackets
    tournament_matches ||--o{ match_scores : evaluates
    tournament_matches ||--o{ match_protests : resolves
    
    events ||--o{ e_certificates : issues
    member_profiles ||--o{ member_transfers : petitions

    users {
        uuid id PK
        string email UK
        string phone UK
        string password_hash
        string full_name
        string status
        timestamp created_at
    }

    dojangs {
        uuid id PK
        string code UK
        string name
        uuid federation_id FK
        string address
        string province
        string city
        float latitude
        float longitude
        string status
        integer health_score
    }

    member_profiles {
        uuid id PK
        uuid user_id FK
        uuid dojang_id FK
        string pbti_number
        string current_belt
        float weight_kg
        float height_cm
        date date_of_birth
        string gender
        string guardian_phone
        boolean is_active
    }

    coach_profiles {
        uuid id PK
        uuid user_id FK
        uuid dojang_id FK
        string employment_type
        string dan_rank
        string kukkiwon_number
        string pbti_license_level
        string specialization
        decimal per_session_fee
        decimal monthly_salary
        string app_access_level
        boolean is_active
    }

    attendances {
        uuid id PK
        uuid schedule_id FK
        uuid member_id FK
        uuid coach_id FK
        timestamp check_in_time
        string status
        string notes
    }

    monthly_dues {
        uuid id PK
        uuid dojang_id FK
        uuid member_id FK
        string billing_month
        decimal amount
        string payment_status
        string proof_url
        timestamp paid_at
    }

    athlete_readiness_logs {
        uuid id PK
        uuid member_id FK
        date log_date
        integer sleep_quality
        integer energy_level
        integer muscle_soreness
        integer stress_level
        integer mental_state
        float readiness_score
        float current_weight_kg
        integer session_rpe
    }

    events {
        uuid id PK
        string event_type
        string name
        date start_date
        date end_date
        string venue_name
        string status
        jsonb config_rules
    }

    event_registrations {
        uuid id PK
        uuid event_id FK
        uuid dojang_id FK
        uuid member_id FK
        string athlete_name
        string belt_rank
        float verified_weight_kg
        string registration_type
        string status
    }

    tournament_matches {
        uuid id PK
        uuid category_id FK
        uuid arena_id FK
        integer match_number
        integer round_number
        uuid chung_reg_id FK
        uuid hong_reg_id FK
        uuid winner_reg_id FK
        string match_status
    }

    match_scores {
        uuid id PK
        uuid match_id FK
        integer round_number
        integer chung_points
        integer hong_points
        integer chung_gamjeom
        integer hong_gamjeom
        jsonb point_logs
    }

    e_certificates {
        uuid id PK
        uuid event_id FK
        uuid member_id FK
        string registration_number UK
        string certificate_type
        string qr_hash
        string pdf_storage_url
        timestamp issued_at
    }

    member_transfers {
        uuid id PK
        uuid member_id FK
        uuid origin_dojang_id FK
        uuid target_dojang_id FK
        string status
        string letter_url
        timestamp approved_at
    }
```

---

## 3. Tech Stack & Ekosistem Pustaka

| Layer | Teknologi / Pustaka | Alasan Pemilihan & Kegunaan |
| :--- | :--- | :--- |
| **Public Frontend (Core)** | **Next.js 15 (App Router) / React 19** | Server-Side Rendering (SSR) & Static Generation untuk SEO optimal, landing page cepat dimuat, dan metadata dinamis. |
| **Admin & Executive Web** | **Vite + React SPA + TypeScript + Tailwind CSS** | Kompilasi kilat, bundling efisien, typed security tinggi, komponen rich UI dashboard komando. |
| **Mobile PWA (Coach & Member)** | **React PWA + Tailwind CSS + Lucide Icons + Workbox** | Instalasi 1-klik PWA pada smartphone tanpa biaya komisi App Store/Play Store, akses kamera scanner offline-ready. |
| **Backend & Microservices** | **Go (Golang) / Node.js (NestJS)** | Kecepatan concurrency tinggi untuk engine drawing & socket scoring (Go), dan produktivitas modular CRUD (NestJS). |
| **Database Primer** | **PostgreSQL 16 (PostGIS Extension)** | Integritas transaksi ACID, Row-Level Security (RLS) multi-tenant, dan PostGIS untuk peta geospasial territorial federasi. |
| **Cache & Real-Time Engine** | **Redis 7 + Redis Pub/Sub + WebSockets** | Latensi sub-100ms untuk synchronizer live score terminal arena ke TV display venue dan scoreboard publik. |
| **File Storage & Asset Delivery** | **MinIO S3 / AWS S3 + Cloudflare CDN** | Penyimpanan dokumen surat mutasi atlet, foto bukti iuran, dan e-sertifikat PDF beresolusi tinggi. |
| **Document & PDF Generator** | **Chromium Headless / Puppeteer / PDFKit** | Rendering presisi dokumen legal Result Book Kejuaraan PBTI dan E-Sertifikat ber-QR anti pemalsuan. |
| **Integrasi Pihak Ketiga** | **Midtrans / Xendit (Payment Gateway)**, **Wablas / Fonnte (WA API)** | Pembayaran otomatis iuran via QRIS/VA dan notifikasi antrean partai / tagihan WhatsApp. |

---

## 4. Model Keamanan, RBAC, & Privasi Data

### 4.1 Mekanisme Autentikasi & Sesi
- **Token Format:** Dual-token mechanism menggunakan **Access Token JWT** (masa aktif 15 menit) dan **Refresh Token HttpOnly Cookie** (masa aktif 30 hari).
- **Single Sign-On (Smart Role Routing):** Satu endpoint autentikasi terpusat (`/api/v1/auth/login`) yang mengembalikan token berisi klaim peran (`roles`) dan langsung mendisposisikan klien ke rute aplikasi yang berwenang.

### 4.2 Matriks Hak Akses (Role-Based Access Control / RBAC)

| Peran (Role) | Core Portal | Dojang Admin | Coach App | Member App | Executive Platform |
| :--- | :---: | :---: | :---: | :---: | :---: |
| **Super Admin Ekosistem** | Full | Full | Full | Full | Full |
| **Pengurus Federasi (Pengcab/Pengprov)** | Read | Read (Binaan) | - | - | Full (Modul Federasi) |
| **Tournament Director / Panitia UKT** | Read | - | - | - | Full (Modul Event & Turnamen) |
| **Dojang Owner / Admin** | Read | Full (Unit Sendiri) | Read | Read | Kontingen Sendiri |
| **Pelatih / Coach (Sabeum)** | Read | Presensi/Laporan | Full | Read | Wasit / Sudut Arena |
| **Atlet / Murid (Member)** | Read | - | - | Full (Pribadi) | Lihat Bagan / Hasil |
| **Orang Tua / Wali Murid** | Read | - | - | Tagihan & Jadwal | Lihat Pertandingan Anak |
| **Publik Tanpa Login** | Read-Only | Denied | Denied | Denied | Display TV & Cek E-Cert |

### 4.3 Privasi Data & Enkripsi
1. **Enkripsi At-Rest:** Seluruh data pribadi sensitif (nomor kontak darurat, rekam medis cedera, NIK/PBTI) dienkripsi menggunakan AES-256 pada level storage database.
2. **Enkripsi In-Transit:** Wajib TLS 1.3 dengan sertifikat SSL Cloudflare Full (Strict) untuk seluruh payload HTTP dan WebSocket.
3. **Data Isolation (Multi-Tenancy):** Pemisahan data per `dojang_id` ditegakkan pada tingkat query ORM dan PostgreSQL Row-Level Security (RLS) guna mencegah kebocoran data antar-dojang.

---

## 5. Ketahanan Jaringan Lapangan (Field Network Resilience & Arena Offline-Mode)

Tantangan terbesar kompetisi beladiri di Indonesia adalah **kualitas sinyal seluler yang buruk di dalam Gedung Olahraga (GOR) tertutup**. DAYS mengatasi masalah ini dengan pendekatan arsitektur khusus:

1. **Local Edge WebSocket Broker:** Pada turnamen besar, unit komando lokal (Raspberry Pi / Mini PC on-premise) dapat berperan sebagai edge gateway lokal sehingga scoring meja wasit dan scoreboard TV tetap tersinkronisasi dalam hitungan milidetik (*sub-50ms*) tanpa bergantung pada koneksi internet publik.
2. **Offline-First PWA Caching:** PWA Coach dan Wasit menyimpan antrean penilaian (*scoring logs*) di IndexedDB terenkripsi. Ketika koneksi terputus, pertandingan tetap berjalan, dan data otomatis disinkronisasi ke PostgreSQL cloud saat koneksi pulih (*auto-reconnection reconciliation*).
3. **Dual-Display TV Engine:** Scoreboard TV beroperasi pada mode fullscreen HTML5 Canvas berbasis hardware acceleration, tahan terhadap lag refresh rate browser dan kompatibel dengan kabel HDMI maupun Miracast nirkabel.

---

## Navigasi Dokumen

[← 00-Ikhtisar Sistem](00-overview.md) | [02-Sistem Nilai & Monetisasi →](02-value-system-and-monetization.md) | [03-Roadmap Produk →](03-roadmap.md)
