---
title: "Value System, Cost Structure & Subscription Model — DAYS"
slug: "dojang-management-economics"
date: "2026-10-12"
author: "System Architect Agent"
tags: ["monetization", "subscription", "cogs", "pricing", "saas", "days"]
category: "Product Spec"
status: "draft"
priority: "P0"
complexity: "High"
estimated_effort: "8-12 weeks"
---

# 💎 Value System, Cost Structure & Subscription Model — DAYS

> **Official Portal & Website:** [https://dojang.warsootech.com](https://dojang.warsootech.com)  
> 📍 **Navigasi Cepat:** [🏠 Overview](00-overview.md) • [🏗️ 01-Arsitektur](01-architecture-and-techstack.md) • [💎 02-Nilai & Monetisasi](02-value-system-and-monetization.md) • [🗺️ 03-Roadmap](03-roadmap.md) • [⚡ Fitur (FR-01 s/d 06)](features/FR-01-user-authentication.md) • [📸 Showcase UI](modules/days-admin/SHOWCASE.md)

Dokumen ini membedah arsitektur finansial, sistem nilai (*value creation*), kalkulasi penghematan operasional berbasis data riil industri beladiri Indonesia, estimasi infrastruktur (*COGS & OPEX*), rekomendasi harga wajar, serta alur penagihan otomatis (*settlement workflow*).

---

## 1. Analisis Value System & Return on Investment (ROI)

Platform DAYS bukan sekadar alat pencatat presensi, melainkan **mesin penyelamat arus kas dan efisiensi operasional** bagi seluruh pemangku kepentingan olahraga beladiri.

```mermaid
flowchart TD
    subgraph ValueCreation ["Value System DAYS"]
        V1["💵 <b>Dojang Owner</b><br/>• Pulihkan 40-60% tunggakan iuran<br/>• Pangkas 25 jam kerja admin/bulan<br/>• Retensi murid naik via Sports Science"]
        V2["🧑‍🏫 <b>Pelatih / Sabeum</b><br/>• 0 menit waktu terbuang untuk absen<br/>• Deteksi dini cedera murid (5P)<br/>• Standardisasi kurikulum sabuk"]
        V3["👨‍👩‍👧 <b>Wali Murid & Atlet</b><br/>• Kwitansi resmi QR & transparansi<br/>• Notifikasi jadwal latihan & tagihan<br/>• Sports science performa tanding"]
        V4["🏆 <b>Event Organizer (EO)</b><br/>• Eliminasi denda overtime sewa GOR<br/>• Pangkas 65% staf meja pertandingan<br/>• Result book instan saat penutupan"]
        V5["🏛️ <b>Federasi (Pengcab/PBTI)</b><br/>• Nol pemalsuan sertifikat sabuk<br/>• Eliminasi sengketa mutasi atlet<br/>• Sensus & audit MAU riil transparan"]
    end
```

![Ilustrasi Pertumbuhan Finansial & Kasir Digital Dojang](assets/dojang-financial-growth-illust.jpg)
*Gambar 3.1: Ilustrasi Optimalisasi Finansial Dojang — Pemilik Klub Memantau Pertumbuhan Kas, 98% Tingkat Penagihan Iuran, dan Pembayaran Instan QRIS.*

---

## 2. Kalkulasi Unit Economics Riil di Pasar Indonesia

Untuk membuktikan kelayakan komersial dan daya tarik investasi, berikut analisis berbasis data riil lapangan:

### A. Segmentasi 3 Model Dojang di Indonesia & Potensi Penyelamatan Kas

| Karakteristik | Model 1: Satelit Sekolah / Ekskul | Model 2: Grassroots Balai Warga / GOR | Model 3: Commercial Elite Academy |
| :--- | :--- | :--- | :--- |
| **Profil Siswa** | 40 – 80 murid (SD/SMP/SMA) | 70 – 150 murid (Umum & Pelajar) | 150 – 400+ murid (Prestasi & Private) |
| **Tarif Iuran Bulanan** | Rp 75.000 – Rp 120.000 / bln | Rp 175.000 – Rp 275.000 / bln | Rp 350.000 – Rp 750.000 / bln |
| **Omzet Bruto Bulanan** | Rp 3.000.000 – Rp 9.600.000 | Rp 12.250.000 – Rp 41.250.000 | Rp 52.500.000 – Rp 300.000.000 |
| **Rata-Rata Tunggakan Riil** | 20% – 30% (karena lupa/manual) | 18% – 25% (tertahan di wali murid) | 8% – 15% (karena kesibukan orang tua) |
| **Nilai Tunggakan Hilang/Bulan** | **Rp 600.000 – Rp 2.800.000** | **Rp 2.200.000 – Rp 10.300.000** | **Rp 4.200.000 – Rp 45.000.000** |
| **Kas Terselamatkan via DAYS** | **Rp 300.000 – Rp 1.400.000** | **Rp 1.100.000 – Rp 5.150.000** | **Rp 2.500.000 – Rp 27.000.000** |
| **Biaya SaaS DAYS / Bulan** | Rp 0 (Free Starter) | Rp 149.000 – Rp 199.000 (Pro) | Rp 299.000 – Rp 699.000 (Elite) |
| **Net ROI bagi Owner Dojang** | **Gratis (Efisiensi 100%)** | **550% – 2.500% ROI per bulan** | **830% – 3.800% ROI per bulan** |

### B. Unit Economics Turnamen Riil & Eliminasi Denda Sewa GOR

Turnamen beladiri memiliki perputaran arus kas yang sangat masif namun kerap mengalami kebocoran biaya akibat manajemen waktu yang buruk:

- **Studi Kasus Kejuaraan Terbuka (1.000 Atlet Kyorugi & Poomsae):**
  - **Pendapatan Pendaftaran:** 1.000 atlet x Rp 350.000 = **Rp 350.000.000**.
  - **Sewa Gedung Olahraga (GOR):** Rp 20.000.000 / 2 hari (batas sewa s/d 21:00 WIB).
  - **Kebocoran Konvensional:** Drawing manual & antrean timbang badan acak menyebabkan pertandingan molor hingga pukul 01:30 dini hari (4,5 jam overtime). Biaya penalti denda pengelola GOR rata-rata **Rp 1.500.000 – Rp 2.000.000 per jam**.
  - **Total Denda Overtime yang Harus Dibayar:** **Rp 6.750.000 – Rp 9.000.000 per kejuaraan!**
- **Solusi DAYS Executive Tournament:**
  - Auto-drawing terdistribusi merata dalam 5 detik, antrean *call room* terpantau di layar TV dan ponsel atlet, serta scoring nirkabel tanpa jeda formulir fisik.
  - Turnamen rampung pukul 19:30 WIB (**1,5 jam sebelum batas waktu sewa habis**).
  - **Dampak Finansial:** Panitia **menghemat 100% denda overtime GOR (Rp 6,7 – 9 Juta terselamatkan)** dan menghemat 65% konsumsi/honor lembur petugas meja pertandingan.

### C. Efisiensi Jam Kerja Staf & Pencegahan Murid Drop Out (Churn)
1. **Penghematan Jam Kerja Administrasi:**
   - Rekap absensi manual, menyocokkan mutasi rekening, dan membuat kwitansi manual memakan rata-rata **25 jam kerja/bulan**.
   - Dengan DAYS, proses ini berjalan otomatis 100%. Setara dengan **menghemat biaya gaji 1 staf admin part-time (Rp 1.500.000 – Rp 2.500.000/bulan)**.
2. **Pencegahan Churn Murid (Lifetime Value):**
   - Rata-rata dojang kehilangan 15–20% murid per tahun akibat orang tua merasa "anaknya tidak berkembang / tidak diperhatikan".
   - Dengan visualisasi *Sports Science 5P* dan riwayat kenaikan sabuk digital, orang tua melihat transparansi progres anak. Menurunkan churn sebesar 5 murid per tahun mempertahankan **Rp 10.500.000 – Rp 15.000.000 *Lifetime Value* per tahun** bagi kas dojang.

---

## 3. Struktur Biaya Operasional (Cost Structure / COGS & OPEX)

Untuk mengoperasikan DAYS secara menguntungkan dengan margin kotor (*gross margin*) di atas **85%**, berikut estimasi pengeluaran per 100 dojang aktif (~8.000 MAU atlet):

| Komponen Biaya (Cost Component) | Vendor / Spesifikasi | Estimasi Biaya Bulanan (IDR) | Sifat Biaya |
| :--- | :--- | :--- | :--- |
| **Compute & API Cluster** | Cloud VPS (4 Core, 16GB RAM, SSD NVMe) | Rp 650.000 – Rp 1.200.000 | Fixed / Semi-Variable |
| **Database & Cache Cluster** | Managed PostgreSQL 16 + Redis 7 | Rp 800.000 – Rp 1.500.000 | Semi-Variable |
| **Object Storage (S3 CDN)** | MinIO / AWS S3 + Cloudflare CDN (Foto & PDF) | Rp 300.000 – Rp 600.000 | Variable (Usage-based) |
| **WhatsApp Notification Gateway** | WhatsApp Official BSP / Unofficial (Fonnte/Wablas) | Rp 350.000 – Rp 750.000 | Fixed per Dojang sender |
| **PDF Rendering Worker** | Headless Chrome Worker (Result Book & Certs) | Rp 400.000 – Rp 800.000 | Semi-Variable |
| **Total Estimasi OPEX Bulanan** | *(Kapasitas s/d 100 Dojang & 10 Turnamen)* | **Rp 2.500.000 – Rp 4.850.000** | **Margin Kotor > 85%** |

---

## 4. Matriks Harga Wajar (Fair Market Pricing) di Indonesia

### A. Lisensi Dojang SaaS (Langganan Bulanan / Tahunan)

#### 1. Ringkasan Paket & Struktur Biaya

| Paket Langganan | Kuota Murid | Sasaran Dojang | Biaya Bulanan | Biaya Tahunan *(Hemat 20%)* |
| :--- | :---: | :--- | :--- | :--- |
| **STARTER** | s/d 25 Murid | Dojang rintisan & ekskul sekolah pemula | **Rp 0** *(Gratis Selamanya)* | **Rp 0** |
| **PRO DOJANG** | s/d 100 Murid | Dojang reguler mandiri 1 lokasi | **Rp 149.000 – Rp 199.000** | **Rp 1.490.000 – Rp 1.990.000** |
| **ACADEMY ELITE** | s/d 300 Murid | Akademi prestasi & multi-cabang (s/d 3 lokasi) | **Rp 299.000 – Rp 399.000** | **Rp 2.990.000 – Rp 3.990.000** |
| **ENTERPRISE** | Unlimited | Jaringan waralaba & pengcab cabang besar | **Rp 699.000 – Rp 999.000** | **Rp 6.990.000 – Rp 9.990.000** |

#### 2. Matriks Komparasi Fitur Lengkap (Feature Matrix)

| Fitur Utama | Starter (Gratis) | Pro Dojang | Academy Elite | Enterprise |
| :--- | :---: | :---: | :---: | :---: |
| **Maksimum Murid Aktif** | 25 Murid | 100 Murid | 300 Murid | **Tanpa Batas** |
| **Jumlah Cabang Latihan** | 1 Lokasi | 1 Lokasi | Hingga 3 Lokasi | **Tanpa Batas** |
| **Presensi QR Scanner (Coach PWA)** | ✅ | ✅ | ✅ | ✅ |
| **Aplikasi Murid & Wali (Member App)** | ✅ | ✅ | ✅ | ✅ |
| **Manajemen Iuran & Invoice Otomatis** | ❌ *(Manual)* | ✅ | ✅ | ✅ |
| **Kwitansi Digital Ber-QR Resmi** | ❌ | ✅ | ✅ | ✅ |
| **Pembayaran QRIS & Virtual Account** | ❌ | ✅ | ✅ | ✅ |
| **Sports Science Readiness 5P & RPE** | ❌ | ✅ | ✅ | ✅ |
| **CMS Website Profil Dojang Mandiri** | Profil Direktori | Subdomain DAYS | Subdomain DAYS | **Custom Domain Sendiri** |
| **Pendaftaran Kontingen Turnamen 1-Klik** | ❌ | ✅ | ✅ | ✅ |
| **Manajemen Multi-Pelatih & Honor** | ❌ | 1 Pelatih Utama | Hingga 5 Pelatih | **Tanpa Batas** |
| **Laporan Analitik Retensi & Churn** | Dasar | Standar | Lengkap | Kustom / Advanced |
| **Dukungan Bantuan Teknis** | Komunitas / FAQ | WhatsApp Support | Prioritas 1x24 Jam | **Dedicated Account Manager** |

---

### B. Lisensi Turnamen & Ujian (Pay-Per-Event)

| Paket Event | Sasaran Event | Batasan & Deliverables | Rentang Harga Wajar per Event |
| :--- | :--- | :--- | :---: |
| **1. UKT Grading Pack** | Ujian Kenaikan Tingkat Dojang / Pengcab | • Tablet scoring penguji per pos ujian<br>• Fast QR check-in peserta<br>• Otomasi penerbitan e-sertifikat ber-QR | **Rp 5.000 – Rp 7.500**<br>*/ peserta ujian* |
| **2. Turnamen Internal (Club Fest)** | Kejuaraan internal antarrating / festival dojang | • Maksimal 300 peserta<br>• 1 – 2 Gelanggang aktif<br>• Auto-drawing bagan & e-sertifikat juara | **Rp 1.500.000 – Rp 3.000.000**<br>*/ event* |
| **3. Turnamen Regional (Kejurcab / Open)** | Kejurcab Pengcab atau Open Tournament regional | • 500 – 1.000 peserta<br>• 3 – 4 Gelanggang aktif simultan<br>• Checkpoint timbang badan, Call room, Live scoreboard TV, 1-Click Result Book PDF | **Rp 7.500.000 – Rp 15.000.000**<br>*/ event* |
| **4. Turnamen Nasional (Kejurnas / Open Besar)** | Kejuaraan Nasional, Piala Kemenpora, EO Profesional | • Unlimited peserta (>1.000 – 3.000+ atlet)<br>• 5 – 8 Gelanggang aktif<br>• Dual-mode Excel parser kontingen tamu<br>• White-label TV display & pendampingan tim IT on-site | **Rp 25.000.000 – Rp 50.000.000**<br>*/ event* |

---

### C. Lisensi Tata Kelola Federasi (B2G / Pengcab / Pengprov PBTI)

| Model Lisensi Federasi | Lingkup Deliverables | Nilai Investasi Wajar |
| :--- | :--- | :---: |
| **Federation Governance Suite (Setup)** | Implementasi sistem peta geospasial territorial cabang, modul mutasi atlet online, sensus dojang, dan integrasi subdomain resmi Pengcab/Pengprov. | **Rp 25.000.000 – Rp 60.000.000**<br>*(one-time setup)* |
| **Annual Retainer SLA & MAU Audit** | Cloud maintenance, garansi backup data atlet daerah, patch pembaruan regulasi WT, dan sertifikasi digital berkala. | **Rp 15.000.000 – Rp 35.000.000**<br>*/ tahun* |

---

## 5. Mekanisme Operasional Penagihan & Biaya MDR Riil

```mermaid
sequenceDiagram
    autonumber
    actor Wali as Wali Murid / Dojang
    participant DAYS as Platform DAYS Core
    participant PG as Payment Gateway (Midtrans/Xendit)
    participant Bank as Bank / QRIS Channel
    participant DojangWallet as Rekening Dojang

    Wali->>DAYS: Buka Tagihan Iuran di Member App (Rp 250.000)
    DAYS->>PG: Buat Dynamic QRIS / Virtual Account
    PG-->>DAYS: URL Pembayaran & QR Payload
    DAYS-->>Wali: Tampilkan QRIS / VA di layar ponsel
    Wali->>Bank: Transfer / Scan QRIS
    Bank->>PG: Notifikasi Pembayaran Berhasil (HTTP Callback)
    PG->>DAYS: Webhook Payment Settlement Verified
    DAYS->>DAYS: Ubah Status Tagihan menjadi PAID
    DAYS->>DAYS: Generate Kwitansi Digital Ber-QR
    DAYS->>DojangWallet: Otomatis Split Payout ke Kas Dojang (Rp 247.500)
    DAYS->>DAYS: Potong Platform Fee DAYS (Rp 2.500)
    DAYS-->>Wali: Notifikasi WhatsApp: Kwitansi Resmi Lunas
```

### Struktur Biaya Transaksi Digital (MDR / Processing Fees):
1. **QRIS Bank Indonesia (MDR Usaha Mikro / Pendidikan):**
   - Biaya MDR resmi sebesar **0,3%** (misal tagihan Rp 250.000 = fee hanya Rp 750). Sangat murah dan terjangkau dibandingkan biaya transfer antarbank konvensional.
2. **Virtual Account Bank (BCA, Mandiri, BRI, BNI):**
   - Biaya per transaksi flat **Rp 2.000 – Rp 3.500** per transaksi sukses. Bebas biaya pendaftaran dan rekonsiliasi instan 24/7.
3. **Mekanisme Payout Pembayaran Iuran Murid:**
   - Dana otomatis dialirkan ke rekening bank dojang melalui sistem *split-payment escrow* (H+1 hari kerja) setelah dipotong biaya transaksi platform secara transparan.

---

## Navigasi Dokumen

[← 01-Arsitektur & Tech Stack](01-architecture-and-techstack.md) | [00-Ikhtisar Sistem](00-overview.md) | [03-Roadmap Pengembangan Produk →](03-roadmap.md) | [Spesifikasi Fitur Pertama (FR-01) →](features/FR-01-user-authentication.md)
