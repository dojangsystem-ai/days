---
title: "Bab 2.2: Arsitektur High-Concurrency, Realtime Leaderboard & Database Schema"
slug: "02-arsitektur-high-concurrency-dan-realtime"
date: "2026-10-10"
author: "System Architect & Product Engineering Agent"
tags: ["system-architecture", "database-schema", "redis", "websockets", "high-concurrency"]
category: "Technical Books"
status: "published"
---

# Bab 2.2: Arsitektur High-Concurrency, Realtime Leaderboard & Database Schema

Pada saat babak final atau pembukaan pendaftaran turnamen populer, sistem akan mengalami *traffic spike* ribuan request per detik (RPS). Subbab ini membahas skema database relasional yang ternormalisasi serta arsitektur pendukung *high-concurrency*.

---

## 1. Skema Database Relasional (Entity Relationship Diagram)

Skema database dirancang untuk mendukung variasi format turnamen, riwayat skor, serta audit trail sengketa:

```mermaid
erDiagram
    TOURNAMENTS ||--|{ STAGES : contains
    STAGES ||--|{ MATCHES : contains
    MATCHES ||--|{ MATCH_PARTICIPANTS : includes
    TEAMS ||--|{ MATCH_PARTICIPANTS : participates
    USERS ||--|{ TEAMS : belongs_to
    MATCHES ||--|{ DISPUTES : generates

    TOURNAMENTS {
        uuid id PK
        string title
        string format
        string status
        timestamp start_at
    }

    STAGES {
        uuid id PK
        uuid tournament_id FK
        string name
        int stage_order
    }

    MATCHES {
        uuid id PK
        uuid stage_id FK
        uuid parent_match_id FK
        int round_number
        string status
        uuid winner_team_id FK
    }

    TEAMS {
        uuid id PK
        string name
        string logo_url
    }

    MATCH_PARTICIPANTS {
        uuid match_id PK, FK
        uuid team_id PK, FK
        int score
        string slot_position
    }

    DISPUTES {
        uuid id PK
        uuid match_id FK
        uuid reported_by_user_id FK
        string reason
        string status
    }
```

---

## 2. High-Concurrency Architecture for Live Score & Bracket Updates

Untuk mencegah *database bottleneck* akibat jutaan penonton yang me-refresh halaman bagan (*bracket viewer*), digunakan strategi caching dan pub/sub WebSockets:

```mermaid
flowchart TD
    Client["Penonton / Player (Web App)"]
    CDN["Cloudflare CDN (Static Assets & Caching)"]
    Gateway["API Gateway (Kong / Nginx)"]
    WSAdapter["WebSocket Gateway (Socket.io Cluster)"]
    MatchService["Match Service (Golang / Node.js)"]
    RedisCache[("Redis Cluster (Pub/Sub & Bracket Cache)")]
    DB[("PostgreSQL Database (Read Replica / Master)")]

    Client -->|HTTP GET Bracket| CDN
    CDN -->|Cache Miss| Gateway
    Gateway --> MatchService
    MatchService -->|Query Cache| RedisCache
    RedisCache -->|Miss| DB

    Client <-->|Subscribe 'tournament:123:updates'| WSAdapter
    MatchService -->|Publish Result Update| RedisCache
    RedisCache -->|Pub/Sub Event| WSAdapter
    WSAdapter -->|Push Score Event| Client
```

---

## 3. Strategi Penanganan Traffic Spike (Concurrency Control)

### A. Slot Reservation & Anti Race-Condition
Saat pendaftaran dibuka (misal: 64 slot diperebutkan oleh 5,000 tim secara bersamaan), penggunaan transaksi basis data standar akan menyebabkan *database locking*. Solusinya adalah **Redis Atomic Decr / Distributed Locking**:

```typescript
// Pattern: Redis Atomic Slot Reservation
export async function reserveTournamentSlot(tournamentId: string, teamId: string): Promise<boolean> {
  const lockKey = `tournament:${tournamentId}:slots`;
  
  // Mengurangi sisa slot secara atomik
  const remainingSlots = await redis.decr(lockKey);

  if (remainingSlots < 0) {
    // Slot habis, rollback counter
    await redis.incr(lockKey);
    return false;
  }

  // Enqueue job ke RabbitMQ / BullMQ untuk pemrosesan pembayaran & persistensi DB
  await queue.add('process_registration', { tournamentId, teamId });
  return true;
}
```

### B. Read Optimization (Redis Sorted Sets untuk Leaderboard)
Untuk turnamen berbasis poin (seperti Battle Royale / PUBG / Free Fire), perhitungan *leaderboard* memanfaatkan data struktur **Redis Sorted Sets (ZSET)**:

```bash
# Menambah poin tim secara atomik saat match selesai
ZINCRBY leaderboard:tournament_999 15 "Team_Alpha"
ZINCRBY leaderboard:tournament_999 10 "Team_Bravo"

# Mengambil Top 10 Tim secara Real-time dengan Latensi <1ms
ZREVRANGE leaderboard:tournament_999 0 9 WITHSCORES
```

---
[← Bab Sebelumnya](01-desain-sistem-bracket-dan-matchmaking.md) | [Daftar Isi](../_index.md) | [Subbab Selanjutnya →](../03-monetisasi-dan-pertumbuhan/01-strategi-monetisasi-dan-retensi-penyelenggara.md)
