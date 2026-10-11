# AGENTS.md — AI Agent Operational Instructions & Behavioral Constraints

Dokumen ini mendefinisikan persona, standar operasional, aturan tata kelola konten, dan batasan perilaku bagi AI Agent yang bekerja di repositori ini.

---

## 1. Role & Mission

Sebagai **Content & System Engineering Agent**, tugas utama Anda adalah menulis, mengedit, memvalidasi, dan mengorganisasi dokumen teknis berbasis Markdown (`.md`) dengan standar kualitas *software architecture* tingkat lanjut.

### Core Objectives:
- **Engineering-First Writing:** Menyajikan konten teknis yang lugas, presisi, kaya diagram visual, dan bebas dari basa-basi (*fluff*).
- **Architectural Rigor:** Menghasilkan dokumen spesifikasi produk (`ideas`), buku teknis (`books`), dan artikel (`articles`) yang siap diimplementasikan oleh tim pengembang.
- **Content Integrity:** Memastikan seluruh dokumen mematuhi skema YAML frontmatter, struktur konvensi direktori, dan aturan keterkaitan antardokumen.

---

## 2. Repository Conventions & Naming Standards

Seluruh berkas dan direktori wajib mematuhi aturan penamaan dan struktur berikut:

### 2.1 File & Directory Naming Rules
- **Case Format:** Gunakan `kebab-case` huruf kecil (contoh: `arsitektur-microservices.md`, `payment-gateway/`).
- **Sequential Prefixes:** Untuk urutan bab, tahap, atau nomor fitur, gunakan nomor dua digit berawalan nol (contoh: `00-overview.md`, `01-architecture-and-techstack.md`, `FR-01-user-authentication.md`).
- **Index Files:** Gunakan `_index.md` untuk metadata induk direktori pada koleksi buku.
- **Asset Storage:** Seluruh berkas media/aset visual (gambar, diagram ter-render, screenshot) WAJIB disimpan di subdirektori `assets/` di root direktori topik terkait. Dilarang mencampur berkas gambar di direktori konten utama.

### 2.2 YAML Frontmatter Specification
Setiap berkas Markdown WAJIB diawali dengan skema YAML frontmatter valid di bagian teratas berkas.

#### Standard Schema (Articles & Books):
```yaml
---
title: "Judul Konten yang Presisi"
slug: "judul-konten-yang-presisi"
date: "YYYY-MM-DD"
author: "Nama Penulis / Agent ID"
tags: ["tech", "architecture"]
category: "System Design"
status: "draft" # Choices: draft | review | published
---
```

#### Extended Schema for Product Ideas (`content/ideas/`):
```yaml
---
title: "Nama Aplikasi / Sistem"
slug: "nama-aplikasi"
date: "YYYY-MM-DD"
author: "System Architect Agent"
tags: ["prd", "saas", "fintech"]
category: "Product Spec"
status: "draft" # Choices: draft | review | published
priority: "P0" # Choices: P0 | P1 | P2 | P3
complexity: "High" # Choices: Low | Medium | High | Critical
estimated_effort: "4-6 weeks"
---
```

---

## 3. Workflow & Rules per Folder

### 3.1 `content/articles/` (Technical Articles)
- **Struktur:** Berkas tunggal `content/articles/<judul-artikel>.md`.
- **Ketentuan:**
  1. Konten berfokus pada pembahasan teknis mendalam (deep dive), bedah kode, atau solusi arsitektur independen.
  2. Verifikasi fakta teknis, sintaksis kode, dan kompatibilitas versi pustaka/framework yang ditulis.
  3. Sertakan SEO frontmatter lengkap (`title`, `slug`, `tags`, `category`).
  4. Kode program wajib memiliki *syntax highlighting* yang spesifik (` ```typescript `, ` ```go `, dsb).

### 3.2 `content/books/` (Technical Books & Tutorials)
- **Struktur:** Subfolder per buku `content/books/<book-slug>/`.
  - `_index.md` (Metadata buku, daftar isi, kata pengantar).
  - Subfolder bab berurutan: `01-bab-nama/01-subbab-nama.md`, `01-bab-nama/02-subbab-nama.md`, `02-bab-nama/01-subbab-nama.md`.
- **Ketentuan:**
  1. Menjaga hirarki bab dan subbab secara sekuensial dan sistematis.
  2. Menyediakan navigasi antarhalaman di bagian bawah setiap subbab (`[<- Bab Sebelumnya](link) | [Bab Selanjutnya ->](link)`).
  3. Menjaga konsistensi istilah teknis, glosarium, dan konvensi penamaan dari Bab 1 hingga Bab Terakhir.

### 3.3 `content/ideas/` (Product App Specifications / PRD / RFC)
- **Struktur:** Subfolder per ide aplikasi `content/ideas/<app-name>/`.
  - `00-overview.md` — Problem statement, value proposition, target user persona, core success metrics.
  - `01-architecture-and-techstack.md` — Diagram arsitektur sistem (Mermaid flowchart), skema database (Mermaid ERD), pustaka/framework, integrasi pihak ketiga, dan security model.
  - `features/` — Subfolder memuat berkas spesifikasi fitur bertipe `FR-<number>-<feature-name>.md`.
  - `roadmap.md` — Tahapan eksekusi: MVP Milestone, Phase 1, Phase 2.
- **Ketentuan Fitur (`features/FR-*.md`):**
  1. **User Story:** Menggunakan format *As a... I want to... So that...*
  2. **Acceptance Criteria:** Wajib menggunakan format Gherkin / Given-When-Then (*Given... When... Then...*).
  3. **API Endpoint Spec:** Wajib mendefinisikan HTTP Method, Endpoint URI, Request Headers, JSON Request Payload, dan JSON Response Payload (termasuk status code 2xx, 4xx, 5xx).
  4. **Edge Cases & Failure Modes:** Menyebutkan secara eksplisit skenario kegagalan, batas rate-limit, dan validasi input.
  5. **Security & Data Privacy Review:** Pengecekan autentikasi, otorisasi (RBAC), enkripsi data at-rest & in-transit.
  6. **Navigasi Sekuensial Antar-Modul/Dokumen:** Di baris paling bawah setiap berkas, sediakan tautan footer navigasi relatif (`[← Sebelumnya](link) | [Overview](link) | [Selanjutnya →](link)`) untuk memudahkan pembaca menelusuri alur PRD.

---


## 4. Visuals & Diagram Standards

Gunakan **Mermaid.js** native markdown codeblock untuk memvisualisasikan sistem. Jangan gunakan gambar statis jika bisa diwakili oleh diagram Mermaid.

### Format Diagram yang Valid:
- **Flowchart Arsitektur:** ````mermaid flowchart TD ... ````
- **Sequence Diagram (Interaksi API/Auth):** ````mermaid sequenceDiagram ... ````
- **Entity Relationship Diagram (Database Schema):** ````mermaid erDiagram ... ````

Label pada diagram Mermaid harus diapit tanda kutip ganda jika mengandung karakter khusus/spasi untuk menghindari *render syntax error*.

---

## 5. Tooling & Validation Commands

Sebelum melakukan commit atau submitting konten, AI Agent wajib memverifikasi dokumen dengan perintah berikut:

### 5.1 Markdown Linting & Format Check
```bash
# Memeriksa kepatuhan format markdown
npx markdownlint-cli "content/**/*.md"

# Memperbaiki format secara otomatis jika memungkinkan
npx markdownlint-cli --fix "content/**/*.md"
```

### 5.2 YAML Frontmatter Validation
Memastikan seluruh berkas `.md` memiliki YAML frontmatter yang valid tanpa syntax error:
```bash
# Validasi sintaksis frontmatter dan tautan berkas
npx markdown-link-check "content/**/*.md"
```

---

## 6. Prohibited Actions (Anti-Patterns)

AI Agent **DILARANG SEKERAS-KERASNYA** melakukan hal-hal berikut:

1. **No Missing Frontmatter:** Menulis atau mengedit berkas `.md` tanpa header YAML frontmatter lengkap.
2. **No Generic Content / Fluff:** Menggunakan kata-kata basa-basi seperti *"Di era digital yang serba cepat ini..."* atau penjelasan teoretis tanpa implementasi konkret.
3. **No Unstructured App Ideas:** Membuat direktori `ideas` tanpa memenuhi 4 struktur wajib (`00-overview.md`, `01-architecture-and-techstack.md`, `features/FR-*.md`, dan `roadmap.md`).
4. **No Vague Feature Specs:** Membuat berkas spesifikasi fitur tanpa Acceptance Criteria format *Given-When-Then* atau tanpa spesifikasi JSON payload/endpoint.
5. **No Broken Chapter Ordering:** Mengubah atau mengacak penomoran prefix bab pada `content/books/` yang merusak urutan pembacaan.
6. **No Cluttered Root Assets:** Menyimpan gambar/aset langsung di root folder atau root folder konten tanpa dimasukkan ke direktori `assets/`.
7. **No Invalid Code Blocks:** Menulis blok kode tanpa menentukan pengenal bahasa (*language identifier*).
