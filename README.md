# Central Knowledge Base & Product Ideation Hub

Selamat datang di repositori dokumentasi teknis dan sistem ideasi produk. Repositori ini berfungsi sebagai sentral pengetahuan (*knowledge base*) teknis independen, panduan tutorial berseri/buku teknis, serta *PRD / Feature Specification Hub* berbasis Markdown yang dapat dikelola secara mandiri oleh manusia maupun diautomasi oleh AI Agent.

---

## 1. Directory Tree Visualization

Struktur repositori dirancang secara modular dan terstruktur untuk memisahkan setiap jenis konten:

```text
.
├── AGENTS.md                          # Operasional & batasan perilaku AI Agent
├── README.md                          # Panduan kolaborator & tata kelola repositori
└── content/
    ├── articles/                      # Artikel teknis mandiri (independen)
    │   ├── assets/                    # Aset khusus artikel (gambar/diagram)
    │   ├── arsitektur-microservices.md
    │   └── panduan-event-driven.md
    │
    ├── books/                         # Serial tutorial & koleksi buku teknis
    │   └── <book-slug>/               # 1 Subfolder per judul buku
    │       ├── assets/                # Aset visual khusus buku
    │       ├── _index.md              # Metadata buku, daftar isi, & kata pengantar
    │       ├── 01-fondasi-sistem/
    │       │   ├── 01-pengenalan.md
    │       │   └── 02-konsep-utama.md
    │       └── 02-implementasi/
    │           ├── 01-setup-environment.md
    │           └── 02-coding-praktis.md
    │
    └── ideas/                         # Ide produk & Spesifikasi Fitur (PRD/RFC)
        └── <app-name>/                # 1 Subfolder per ide produk aplikasi
            ├── assets/                # Aset mockups, wireframe, & ERD ter-render
            ├── 00-overview.md         # Problem statement, target user, core metrics
            ├── 01-architecture-and-techstack.md # Diagram arsitektur, ERD, security model
            ├── features/              # Folder spesifikasi fitur rinci
            │   ├── FR-01-user-authentication.md
            │   └── FR-02-payment-checkout.md
            └── roadmap.md             # MVP Milestone, Phase 1, Phase 2
```

---

## 2. Content Governance & Workflow

Berikut adalah alur kontribusi (*contribution workflow*) untuk menambah atau mengedit konten di masing-masing direktori:

### 2.1 Menambah Artikel Teknis Baru (`content/articles/`)
1. Buat berkas baru di `content/articles/<judul-kebab-case>.md`.
2. Isi header dengan YAML frontmatter standar (status set ke `draft`).
3. Tulis artikel dengan pendekatan *engineering-first*, lengkapi dengan diagram Mermaid jika terdapat alur arsitektur.
4. Simpan gambar pendukung di `content/articles/assets/`.
5. Ubah status frontmatter ke `review` atau `published`.

### 2.2 Menambah Bab/Buku Baru (`content/books/`)
1. Buat subfolder baru `content/books/<book-slug>/`.
2. Buat berkas `_index.md` yang memuat metadata buku dan struktur daftar isi.
3. Buat subfolder bab bertingkat dengan prefix penomoran dua digit (contoh: `01-konsep-dasar/`, `02-lanjutan/`).
4. Buat subbab di dalam direktori bab (contoh: `01-pengenalan.md`, `02-penjelasan.md`).
5. Sertakan tautan navigasi di bagian bawah setiap subbab (`[<- Bab Sebelumnya](link) | [Bab Selanjutnya ->](link)`).

### 2.3 Menambah Ide Aplikasi & Spesifikasi Produk (`content/ideas/`)
Setiap ide produk aplikasi baru WAJIB mengikuti struktur 4 komponen utama:
1. Buat subfolder baru `content/ideas/<app-name>/`.
2. **Overview (`00-overview.md`):** Tulis latar belakang masalah, solusi yang ditawarkan, persona pengguna target, serta metrik keberhasilan produk.
3. **Arsitektur & Tech Stack (`01-architecture-and-techstack.md`):** Cantumkan diagram sistem Mermaid, skema database (ERD), API pihak ketiga, dan pertimbangan keamanan (*security model*).
4. **Spesifikasi Fitur (`features/FR-<number>-<feature-name>.md`):**
   - **User Story:** *As a... I want to... So that...*
   - **Acceptance Criteria:** Wajib menggunakan format Gherkin (*Given-When-Then*).
   - **API Specs:** HTTP Method, Endpoint URL, Headers, JSON Request Payload, JSON Response Payload.
5. **Roadmap (`roadmap.md`):** Uraikan target MVP, fitur Phase 1, dan pengembang lanjutan Phase 2.

---

## 3. Frontmatter Specification Reference

Setiap berkas Markdown dalam repositori ini wajib menyertakan YAML Frontmatter sesuai dengan tipe kontennya:

| Field | Tipe Data | Diperlukan Pada | Deskripsi & Nilai Valid |
| :--- | :--- | :--- | :--- |
| `title` | String | Semua Konten | Judul utama dokumen |
| `slug` | String | Semua Konten | URL-friendly identifier (`kebab-case`) |
| `date` | Date (YYYY-MM-DD) | Semua Konten | Tanggal pembuatan atau pembaruan terakhir |
| `author` | String | Semua Konten | Nama penulis atau ID Agent |
| `tags` | Array of Strings | Semua Konten | Kata kunci kategori (contoh: `["golang", "system-design"]`) |
| `category` | String | Semua Konten | Pengelompokan utama (contoh: `System Architecture`, `Product Spec`) |
| `status` | String | Semua Konten | Status publikasi: `draft`, `review`, atau `published` |
| `priority` | String | Khusus `ideas` | Skala prioritas pengembangan: `P0`, `P1`, `P2`, `P3` |
| `complexity` | String | Khusus `ideas` | Estimasi kerumitan: `Low`, `Medium`, `High`, `Critical` |
| `estimated_effort` | String | Khusus `ideas` | Estimasi durasi pengerjaan (contoh: `2-4 weeks`) |

---

## 4. Deployment & SSG Compatibility

Struktur repositori ini dirancang penuh agar kompatibel secara *plug-and-play* dengan Static Site Generators (SSG) modern seperti **Astro**, **Next.js (Contentlayer / MDX)**, **Nuxt Content**, atau **Hugo**.

### Fitur Kesiapan SSG:
- **Routing Otomatis:** Struktur folder di bawah `content/` secara intuitif merefleksikan hierarki URL website statis (contoh: `/articles/arsitektur-microservices`, `/ideas/fintech-app/features/FR-01-user-authentication`).
- **Dynamic Open Graph (OG) Preview:** Atribut frontmatter (`title`, `category`, `author`, `date`) siap diparse oleh build script untuk menggenerasi kartu preview sosial media secara otomatis (*auto-generated OG images*).
- **Native Mermaid Rendering:** Diagram Mermaid yang ditulis dalam codeblock standar akan di-render menjadi elemen SVG interaktif pada build pipeline menggunakan plugin SSG (seperti `rehype-mermaid`).
- **Search Index Generator:** Frontmatter dan teks utama dari berkas `.md` siap di-index oleh pustaka pencarian seperti Pagefind, Algolia, atau FlexSearch untuk pencarian instan di situs web.

---

## 5. Tools & Verification

Sebelum mengajukan Pull Request, pastikan berkas Markdown telah divalidasi dengan linter standar:

```bash
# Linting format markdown
npx markdownlint-cli "content/**/*.md"

# Format ulang secara otomatis
npx markdownlint-cli --fix "content/**/*.md"
```
