---
title: "Tournament Management System (TMS) - Platform Manajemen Event & Kejuaraan Olahraga"
slug: "tournament-event-management"
date: "2026-10-10"
author: "System Architect Agent"
tags: ["prd", "saas", "sports", "tournament-management", "event-tech"]
category: "Product Spec"
status: "draft"
priority: "P0"
complexity: "High"
estimated_effort: "6-8 weeks"
---

# Tournament Management System (TMS) — Product Overview & Financial Specification

## 1. Executive Summary & Problem Statement

Penyelenggaraan kejuaraan dan turnamen olahraga (seperti Beladiri, Bulutangkis, Futsal, E-sports, dll.) di Indonesia saat ini masih didominasi oleh proses manual atau aplikasi legacy berkendala tinggi. Masalah utama yang sering dihadapi oleh Event Organizer (EO) dan Panitia Pelaksana meliputi:

1. **Registrasi & Verifikasi Lambat:** Proses pendaftaran kontingen, validasi berkas fisik (akta, verifikasi kelas tanding/berat badan), dan pembayaran yang masih terpisah-pisah, memicu *human error* dan antrean panjang saat *re-registration*.
2. **Drawing Bagan Rawan Human Error:** Pembuatan bagan pertandingan (*tournament bracket*) secara manual berisiko tinggi menghasilkan kesalahan aturan *seeding*, kontingen se-daerah bertemu di babak awal, serta memakan waktu berjam-jam saat *technical meeting*.
3. **Ketidakjelasan Antrean Atlet (Call Room):** Memanggil atlet dari area pemanasan ke arena pertandingan (*mat/court*) secara lisan atau megapon sering menyebabkan atlet terlambat masuk arena (*walkover* yang tidak perlu) dan jadwal pertandingan menjadi berantakan (*delay* berjam-jam).
4. **Rekapitulasi Juara & Medali Berantakan:** Penghitungan poin kontingen, perolehan medali, dan penentuan Juara Umum sering kali lambat, rawan manipulasi, dan berisiko salah hitung.
5. **Penerbitan Buku Hasil Kejuaraan Lama:** Laporan resmi hasil pertandingan (*Official Result Book*) yang dibutuhkan pengurus cabor, sponsor, dan dinas pemuda olahraga baru selesai berhari-hari setelah kejuaraan usai.

**Tournament Management System (TMS)** hadir sebagai platform *end-to-end* berbasis *cloud* dan *real-time* yang mengotomatisasi seluruh alur kejuaraan mulai dari pendaftaran, *drawing bagan*, pemanggilan atlet di *Call Room*, rekapitulasi medali, hingga pembuatan *Buku Hasil Kejuaraan* instan.

---

## 2. Value Proposition & Key Differentiators

- **Automated Algorithmic Drawing:** Algoritma *bracket generation* otomatis yang mendukung *single elimination*, *double elimination*, dan *round robin* dengan *constraint handling* (mencegah atlet dari kontingen yang sama bertanding di ronde pertama).
- **Real-time Call Room Dispatch System:** Layar panggilan digital (*Call Room Display*) dan notifikasi otomatis (WhatsApp/SMS/Web Push) yang mengoordinasikan pergerakan atlet dari *Holding Area* ke *Call Room* hingga ke *Arena/Mat*.
- **Instant Official Result Book Generator:** Sekali klik untuk mengompilasi seluruh statistik pertandingan, bagan hasil, daftarmedali, dan lembar pengesahan menjadi dokumen PDF resmi bersertifikat digital.
- **Dynamic Medal & Contingent Tally:** Dashboard perolehan medali yang diperbarui secara *real-time* setelah tiap partai selesai, menghitung otomatis Juara Umum 1, 2, 3 berdasarkan bobot emas, perak, dan perunggu.
- **Hybrid Infrastructure Ready:** Dapat berjalan secara *Cloud SaaS* penuh atau *Local Edge Server* untuk venue kejuaraan dengan koneksi internet terbatas.

---

## 3. Target User Personas

| Persona | Role & Deskripsi | Needs & Goals |
| :--- | :--- | :--- |
| **Event Organizer (EO) / Chairman** | Penyelenggara kejuaraan | Memastikan event berjalan tepat waktu, laporan keuangan registrasi transparan, dan hasil laporan langsung terbit. |
| **Admin Sekretariat / Pendaftaran** | Pengelola data kontingen | Memverifikasi berkas atlet, kelas tanding, pembayaran, dan mengelola *timbang badan*. |
| **Call Room Officer / Manager** | Petugas pemanggil atlet | Memanggil atlet ronde berikutnya, memeriksa proteksi/perlengkapan atlet, dan mengarahkan ke matras/lapangan. |
| **Technical Delegate (TD) / Wasit Utama** | Pengawas teknis pertandingan | Memantau *drawing bagan*, menyetujui perubahan jadwal (*reschedule*), dan memverifikasi skor akhir. |
| **Coach / Manager Kontingen** | Perwakilan klub/kontingen | Daftarkan atlet, pantau status panggilan atlet via mobile, dan lihat bagan pertandingan langsung. |
| **Audience & Sponsor** | Penonton & Pihak luar | Mengetahui skor *live*, bagan pertandingan publik, dan klasemen perolehan medali. |

---

## 4. Core Success Metrics (KPIs)

- **Bracket Generation Time:** Pembuatan bagan untuk 1.000+ peserta dalam waktu `< 3 detik`.
- **Call Room Efficiency:** Mengurangi durasi kosong arena (*mat downtime*) dari rata-rata 5 menit menjadi `< 30 detik` antar-partai.
- **Report Book Generation:** Penerbitan *Official Result Book* PDF komprehensif dalam waktu `< 10 detik` setelah partai terakhir selesai.
- **System Availability:** *Uptime* 99.9% selama hari-H event dengan latency WebSocket `< 100ms`.
- **Zero Calculation Error:** 100% akurasi dalam kalkulasi Juara Umum dan akumulasi medali kontingen.

---

## 5. Model Pembiayaan & Analisis Finansial (Pricing, Capex & Opex)

Untuk mencakup pasar yang beragam—mulai dari event skala kecil/komunitas hingga event kejuaraan nasional bertingkat—TMS menerapkan **dua skema pembiayaan utama**: **Pola Project (Event-Based)** dan **Pola Subscription (SaaS Berlangganan)**.

### 5.1 Skema Pembiayaan 1: Pola Project (Event-Based Pricing)
Cocok untuk **Panitia Pelaksana / EO Musiman** yang hanya menggelar kejuaraan 1 hingga 2 kali per tahun dan tidak ingin menanggung biaya rutin bulanan.

- **Tier Small Event (Up to 300 Peserta):**
  - **Harga:** Rp 5.000.000 / Event
  - **Fasilitas:** 3 Hari Event Lisensi, Registrasi Online, Auto Drawing, Call Room Module, Result Book Generator, Support Online.
- **Tier Medium Event (301 - 800 Peserta):**
  - **Harga:** Rp 12.000.000 / Event
  - **Fasilitas:** Up to 5 Hari Event, Multi-Arena (max 4 Arena/Matras), WhatsApp Gateway Call Alert, 1 Teknisi Support On-Site, Custom Branding Certificate.
- **Tier Enterprise Event (801 - 2.500+ Peserta / Kejuaraan Nasional):**
  - **Harga:** Rp 25.000.000 - Rp 45.000.000 / Event (atau Rp 25.000 - Rp 35.000 per peserta)
  - **Fasilitas:** Unlimited Arena/Matras, Edge Server Local Deployment (Anti Rontok Sinyal), Dedicated On-Site Technical Team (2-3 Personel), Live Streaming Overlay Integration, Priority Support.

### 5.2 Skema Pembiayaan 2: Pola Subscription (SaaS Berlangganan)
Cocok untuk **Pengurus Provinsi/Cabang Olahraga (Pengprov/Pengcab)**, **Federasi**, atau **EO Profesional** yang menyelenggarakan turnamen secara berkelanjutan sepanjang tahun.

- **Plan Starter (Bulanan):** Rp 1.500.000 / bulan (Maksimal 2 Event/bulan, kuota total 600 peserta/bulan).
- **Plan Pro (Tahunan):** Rp 35.000.000 / tahun (Maksimal 12 Event/tahun, kuota hingga 8.000 peserta/tahun, diskon ~20%).
- **Plan Federation / Unlimited (Tahunan):** Rp 75.000.000 / tahun (Unlimited Event, Unlimited Peserta, Multi-Pengcab Tenant Management, Custom Domain).

---

### 5.3 Perhitungan Capital Expenditure (Capex)

Capex mencakup seluruh investasi awal untuk riset, pengembangan software, arsitektur infrastruktur, dan lisensi awal platform TMS.

| Komponen Capex | Deskripsi & Scope | Biaya (IDR) |
| :--- | :--- | :--- |
| **Software Architecture & Development** | Tim Senior Engineering (1 Architect, 2 Fullstack Dev, 1 UI/UX, 1 QA) selama 2 Bulan (8 minggu) pengembangan core engine (Bracket Engine, Call Room Socket, PDF Engine). | Rp 160.000.000 |
| **UI/UX Design & Design System** | Pembuatan Design System, High-Fidelity UI untuk Admin Dashboard, Call Room Monitor Display, dan Mobile View Kontingen. | Rp 25.000.000 |
| **Edge Hardware Toolkit (2 Set)** | 2 Unit Mini PC Edge Server (Intel NUC/AMD Ryzen), 4 Unit Tablet Call Room, Portable Wi-Fi 6 Router, Hardcase Box untuk Deployment On-Site Event. | Rp 35.000.000 |
| **Legal, Trademark & Security Audit** | Pendaftaran HAKI Brand & Source Code, Penetration Testing awal, Pembentukan PT/Badan Hukum. | Rp 20.000.000 |
| **Total Capex (Investasi Awal)** | | **Rp 240.000.000** |

---

### 5.4 Perhitungan Operational Expenditure (Opex)

Opex mencakup biaya operasional rutin bulanan serta *variable cost* per event.

#### A. Fixed Opex (Rutin Bulanan Platform SaaS)
| Komponen Opex Rutin | Deskripsi & Provider | Biaya / Bulan (IDR) |
| :--- | :--- | :--- |
| **Cloud Infrastructure** | AWS / DigitalOcean (Managed PostgreSQL High Availability, Redis Cluster, App Server Auto-Scaling). | Rp 4.500.000 |
| **WebSocket & Realtime Server** | Socket Cluster / Ably / Pusher Tier Premium untuk sinkronisasi realtime Call Room & Scoring. | Rp 2.000.000 |
| **Third-Party SaaS Tools** | GitHub, Sentry Error Tracking, CI/CD Pipeline, Figma, Domain & SSL Management. | Rp 1.500.000 |
| **DevOps & Maintenance Retainer** | Maintenance sistem, patching security, dan update minor bulanan. | Rp 8.000.000 |
| **Total Fixed Opex** | | **Rp 16.000.000 / bulan** |

#### B. Variable Opex (Per Event - Asumsi Event Scale Medium ~600 Peserta)
| Komponen Opex Variable | Deskripsi | Biaya / Event (IDR) |
| :--- | :--- | :--- |
| **WhatsApp Notification Gateway** | ~3.000 pesan WA (Notifikasi jadwal, Call Room Alert ke Manager/Coach @ Rp 400/WA API). | Rp 1.200.000 |
| **Payment Gateway Transaction Fee** | Midtrans/Xendit fee (~1.5% - 2% dari transaksi registrasi atlet). | Covered by admin fee |
| **Cloud Bursting Infrastructure** | Temporary scaling server selama 3 hari H-Event untuk menampung traffic penonton & live score. | Rp 800.000 |
| **On-site Technical Support (1 Pax)** | Uang saku, transportasi, & akomodasi teknisi lapangan (jika dibutuhkan panitia). | Rp 2.500.000 |
| **Total Variable Opex per Event** | | **Rp 4.500.000 / event** |

---

### 5.5 Rasional & Alasan Penentuan Harga (Pricing Rationale)

1. **Value-Based Pricing (Efisiensi SDM Panitia):**
   - Penyelenggaraan kejuaraan konvensional biasanya membutuhkan **10-15 orang sekretariat** yang bekerja lembur hingga pagi untuk membuat bagan manual dan merekap medali. Biaya honor sekretariat manual berkisar **Rp 15-25 juta per event**.
   - Dengan TMS, kebutuhan SDM sekretariat berkurang hingga **70% (cukup 3-4 orang)**, dan risiko penundaan jadwal yang memicu pembengkakan sewa gedung/venue dapat dieliminasi. Harga Rp 12-25 juta per event sangat logis karena *net cost* panitia justru berkurang.
2. **High Margin pada Pola Project:**
   - Untuk Event Medium (Harga Rp 12.000.000), Variable Opex adalah Rp 4.500.000. Gross profit per event mencapai **Rp 7.500.000 (Margin ~62.5%)**.
3. **Break-Even Point (BEP) Projection:**
   - Investasi Capex: **Rp 240.000.000**.
   - Target BEP tercapai dalam **8 - 10 bulan** dengan asumsi rata-rata 4 Event Medium per bulan atau kombinasi 20 Event Project + 5 Klien Subscription Tahunan.
4. **Fleksibilitas Beban Biaya (Pass-Through Cost):**
   - Panitia pelaksana memiliki opsi membebankan biaya sistem TMS langsung ke biaya pendaftaran atlet (misal: menambahkan Rp 15.000 - Rp 25.000 per nomor tanding pada registrasi atlet), sehingga panitia pada dasarnya mendapatkan platform TMS secara **Gratis / Zero Net Cost**.
