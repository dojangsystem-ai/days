---
title: "Tournament Management System (TMS) - Architecture & Tech Stack"
slug: "tournament-event-management"
date: "2026-10-10"
author: "System Architect Agent"
tags: ["prd", "saas", "architecture", "mermaid", "tech-stack"]
category: "Product Spec"
status: "draft"
priority: "P0"
complexity: "High"
estimated_effort: "6-8 weeks"
---

# Tournament Management System (TMS) — System Architecture & Tech Stack

## 1. High-Level System Architecture

Tournament Management System (TMS) dirancang dengan arsitektur micro-services / modular monolith berbasis event-driven untuk menangani traffic tinggi selama hari-H kejuaraan, pengiriman pesan realtime via WebSockets, serta generasi PDF berkecepatan tinggi.

```mermaid
flowchart TD
    subgraph Clients["Client Tier (Multi-Device)"]
        PublicWeb["Public Web & Live Score (React/Next.js)"]
        AdminDash["Admin & Secretariat Panel"]
        CallRoomApp["Call Room & Arena Display App"]
        MobileCoach["Coach / Contingent Portal (PWA)"]
    end

    subgraph EdgeLayer["API & Edge Routing"]
        Nginx["Nginx Reverse Proxy / Load Balancer"]
        Gateway["API Gateway / Auth Middleware"]
    end

    subgraph CoreServices["Core Backend Services (Node.js / Go)"]
        AuthService["Auth & RBAC Service"]
        RegService["Registration & Payment Service"]
        BracketService["Bracket Engine & Drawing Service"]
        CallRoomService["Call Room & Dispatcher Service"]
        MedalService["Medal Tally & Ranking Service"]
        ReportService["PDF Report Generator Engine"]
    end

    subgraph RealtimeLayer["Event & Messaging Hub"]
        SocketServer["WebSocket Cluster (Socket.io / WS)"]
        RedisPubSub["Redis Pub/Sub Message Bus"]
    end

    subgraph DataStore["Data & Storage Tier"]
        MainDB[("PostgreSQL 16 (Primary DB)")]
        RedisCache[("Redis Cache & Leaderboard")]
        S3Storage["Object Storage (S3 / Cloudinary)"]
    end

    PublicWeb --> Nginx
    AdminDash --> Nginx
    CallRoomApp --> Nginx
    MobileCoach --> Nginx

    Nginx --> Gateway
    Gateway --> AuthService
    Gateway --> RegService
    Gateway --> BracketService
    Gateway --> CallRoomService
    Gateway --> MedalService
    Gateway --> ReportService

    CallRoomService <--> SocketServer
    SocketServer <--> RedisPubSub
    CallRoomApp <--> SocketServer
    PublicWeb <--> SocketServer

    AuthService --> MainDB
    RegService --> MainDB
    BracketService --> MainDB
    CallRoomService --> MainDB
    MedalService --> RedisCache
    MedalService --> MainDB
    ReportService --> MainDB
    ReportService --> S3Storage
```

---

## 2. Database Schema (Entity Relationship Diagram)

Berikut adalah Skema Database lengkap (*ERD*) dalam bentuk Mermaid diagram yang mengatur hierarki data dari Event, Kontingen, Atlet, Bagan Pertandingan, Status Call Room, hingga Rekapitulasi Medali.

```mermaid
erDiagram
    TOURNAMENTS ||--o{ CATEGORIES : contains
    TOURNAMENTS ||--o{ CONTINGENTS : registers
    TOURNAMENTS ||--o{ ARENAS : operates
    TOURNAMENTS ||--o{ MEDAL_TALLIES : computes

    CATEGORIES ||--o{ BRACKETS : generates
    CATEGORIES ||--o{ ATHLETES : categorizes

    CONTINGENTS ||--o{ ATHLETES : belongs_to
    ATHLETES ||--o{ MATCH_PARTICIPANTS : enters

    ARENAS ||--o{ MATCHES : hosts

    BRACKETS ||--o{ MATCHES : structures

    MATCHES ||--o{ MATCH_PARTICIPANTS : involves
    MATCHES ||--o{ CALL_ROOM_LOGS : tracks

    TOURNAMENTS {
        uuid id PK
        string name
        string slug
        date start_date
        date end_date
        string venue_name
        string status
        json pricing_config
    }

    CATEGORIES {
        uuid id PK
        uuid tournament_id FK
        string name
        string gender
        string age_group
        float min_weight
        float max_weight
        string category_type
    }

    CONTINGENTS {
        uuid id PK
        uuid tournament_id FK
        string name
        string manager_name
        string phone_number
        string email
        string payment_status
    }

    ATHLETES {
        uuid id PK
        uuid contingent_id FK
        uuid category_id FK
        string full_name
        date birth_date
        float weight_kg
        string gender
        string verification_status
    }

    BRACKETS {
        uuid id PK
        uuid category_id FK
        string bracket_type
        int total_rounds
        json bracket_tree_json
    }

    MATCHES {
        uuid id PK
        uuid bracket_id FK
        uuid arena_id FK
        int match_number
        int round_number
        string status
        uuid winner_id FK
        datetime scheduled_time
        datetime actual_start_time
    }

    MATCH_PARTICIPANTS {
        uuid id PK
        uuid match_id FK
        uuid athlete_id FK
        string corner_color
        int score
        string result_status
    }

    CALL_ROOM_LOGS {
        uuid id PK
        uuid match_id FK
        string current_stage
        datetime called_at
        datetime checked_in_at
        datetime dispatched_to_arena_at
        string officer_notes
    }

    ARENAS {
        uuid id PK
        uuid tournament_id FK
        string name
        int arena_number
        string status
    }

    MEDAL_TALLIES {
        uuid id PK
        uuid tournament_id FK
        uuid contingent_id FK
        int gold_count
        int silver_count
        int bronze_count
        int total_points
        int rank_position
    }
```

---

## 3. Tech Stack & Integration Specifications

| Layer | Technology | Justification & Role |
| :--- | :--- | :--- |
| **Frontend Framework** | Next.js 14 (App Router) + React 18 | SSR/SSG untuk halaman publik, SPA responsif untuk Admin Dashboard & Call Room Display. |
| **UI Styling & Design** | Tailwind CSS + Shadcn UI + Lucide Icons | Styling modern, responsif, glassmorphism UI untuk layar arena & display call room. |
| **State & Query** | TanStack Query v5 + Zustand | Client state management efisien & sync data server otomatis. |
| **Backend Core** | Node.js (TypeScript) / Express / NestJS | Asynchronous IO performa tinggi untuk penanganan API request dan event emitter. |
| **Realtime Engine** | Socket.io + Redis Adapter | Event-driven WebSocket broadcasting untuk Call Room queue, Arena status, dan Live Scores. |
| **Bracket Engine** | Custom TypeScript Tree Algorithm | Generasi bagan otomatis (Single/Double Elimination, Round Robin) + seeding logic. |
| **PDF Report Generator** | Puppeteer / React-PDF Engine | Rendering HTML/CSS template ke PDF server-side dengan kecepatan tinggi & layout presisi. |
| **Database** | PostgreSQL 16 (Prisma / Kysely ORM) | Relational Integrity ketat untuk data transaksi, registrasi, dan skor pertandingan. |
| **Cache & Pub/Sub** | Redis 7 | Caching data bracket, leaderboard temporary, dan Pub/Sub untuk Socket.io cluster. |
| **Storage & Media** | AWS S3 / Cloudinary | Penyimpanan berkas foto atlet, dokumen akta, dan PDF Official Result Book. |
| **Payment Gateway** | Midtrans / Xendit API | Opsi pembayaran otomatis (QRIS, Virtual Account, Credit Card) untuk registrasi kontingen. |
| **Notification Engine** | WhatsApp Business API (Fonnte / Wablas) | Pengiriman otomatis notifikasi jadwal & panggilan atlet Call Room ke Coach. |

---

## 4. Security, Auth & Multi-Tenant Privacy Model

### 4.1 Authentication & RBAC (Role-Based Access Control)
Sistem menerapkan **JWT (JSON Web Token)** dengan dual-token strategy (Access Token 15 menit & Refresh Token 7 hari stored in HttpOnly Cookies).

Roles dan Permission Matrix:
- `SUPER_ADMIN`: Akses penuh ke seluruh tenant dan konfigurasi global.
- `EVENT_ORGANIZER`: Mengelola event miliknya, skema harga, tim verifikator, dan keputusan teknis.
- `SECRETARIAT_ADMIN`: Mengelola verifikasi pendaftaran atlet, timbang badan, dan cetak id-card.
- `CALL_ROOM_OFFICER`: Akses khusus modul Call Room, pemanggilan atlet, dan verifikasi perlengkapan.
- `REFEREE_OFFICER / ARENA_OPERATOR`: Menginput skor pertandingan dan mengubah status match (*Started, Finished, WO*).
- `CONTINGENT_MANAGER`: Mengakses portal pendaftaran kontingennya sendiri, memantau status atlet & jadwal.

### 4.2 Multi-Tenant Data Isolation
- Data diisolasi berdasarkan `tournament_id` pada setiap query database.
- Row-Level Security (RLS) diaktifkan pada PostgreSQL untuk menjamin kontingen suatu event tidak dapat melihat atau mengubah data event lain.

### 4.3 Data Privacy & Encryption
- Data sensitif atlet (misal: NIK, tanggal lahir, dokumen identitas) dienkripsi *at-rest* menggunakan `AES-256-GCM`.
- Seluruh komunikasi via HTTPS dengan sertifikat TLS 1.3 dan WebSocket Secure (`wss://`).
