---
title: "OJK-Compliant Credit Scoring Platform"
slug: "ojk-credit-scoring"
date: "2026-10-10"
author: "System Architect Agent"
tags: ["prd", "fintech", "credit-scoring", "ojk-compliance", "xai", "p2p-lending"]
category: "Product Spec"
status: "draft"
priority: "P0"
complexity: "Critical"
estimated_effort: "8-12 weeks"
---

# 00. Product Overview: OJK-Compliant Credit Scoring Engine

## 1. Problem Statement
Lembaga jasa keuangan (LJK), penyedia P2P lending, dan lembaga keuangan mikro di Indonesia menghadapi kendala regulasi dan operasional dalam penilaian kelayakan kredit (credit assessment):
1. **Regulasi Kepatuhan OJK & UU PDP:** Pemrosesan data finansial wajib mematuhi SEOJK No. 29/SEOJK.05/2021 (Inovasi Keuangan Digital) dan UU No. 27 Tahun 2022 tentang Perlindungan Data Pribadi (UU PDP), yang mengharuskan persetujuan eksplisit (explicit consent), jejak audit (audit trail), dan transparansi model (Explainable AI / XAI).
2. **Keterbatasan Data Tradisional:** Banyak calon debitur segmen unbanked/underbanked tidak memiliki riwayat kredit di SLIK (Sistem Layanan Informasi Keuangan) OJK, sehingga membutuhkan pengolahan data alternatif (telco, e-commerce, utility bill, payment gateway).
3. **Risiko Bias & Black-box AI:** Model Machine Learning konvensional seringkali bertindak sebagai *black box*, menyulitkan auditor OJK dan risiko kepatuhan ketika klaim penolakan kredit dipertanyakan debitur.

## 2. Value Proposition
Platform **OJK-Compliant Credit Scoring Engine (OJK-CS)** menyediakan infrastruktur API penilai risiko kredit berkecepatan tinggi (< 1.5 detik per penilaian) yang fully-compliant terhadap regulasi OJK dan UU PDP.

### Keunggulan Utama:
- **Explainable AI (XAI) Engine:** Menggunakan metode SHAP (SHapley Additive exPlanations) dan LIME untuk menghasilkan alasan kuantitatif di balik setiap skor kredit (Adverse Action Notice).
- **Consent-First Architecture:** Manajemen konsen terenkripsi dengan immutable audit log cryptographic hashing (SHA-256) untuk menjamin transparansi pemrosesan data debitur.
- **Dual-Data Scoring Hybrid:** Penggabungan data finansial formal (SLIK OJK) dengan data alternatif (E-Wallet, E-Commerce, Telco, Utility) menggunakan ensemble model Gradient Boosting (XGBoost/LightGBM).
- **Zero Raw-Data Storage Policy:** Data alternatif mentah di-hash/di-anonymize sebelum diolah, meminimalkan liabilitas kebocoran data pribadi sesuai batasan UU PDP.

## 3. Target User Personas

### 3.1 Primary Personas
1. **Underwriting / Risk Analyst (LJK & P2P Lender):** Membutuhkan dashboard evaluasi cepat, scorecard kuantitatif, dan analisis variabel risiko debitur.
2. **Compliance & Audit Officer (Internal & OJK Inspector):** Membutuhkan akses penuh ke audit log, dokumen konsen digital debitur, dan matriks validasi model XAI.
3. **Credit Applicant / Debitur:** Pemohon kredit yang memberikan konsen dan berhak mendapatkan informasi transparansi skor serta hak penghapusan data (Right to be Forgotten).

### 3.2 Secondary Personas
1. **System Integration Engineer (B2B Partner):** Mengintegrasikan API Credit Scoring ke dalam aplikasi pengajuan pinjaman pihak ketiga.

## 4. Core Success Metrics (KPIs)

| Kategori KPI | Parameter / Metrik | Target Benchmark |
| :--- | :--- | :--- |
| **Performance** | API Scoring Latency (P95) | $\le 1200\text{ ms}$ per request |
| **Performance** | System Availability | $99.95\%$ Uptime SLAs |
| **Accuracy** | Gini Coefficient / ROC-AUC | Gini $\ge 0.55$ / AUC $\ge 0.78$ |
| **Compliance** | Consent Audit Log Completeness | $100\%$ terverifikasi cryptographically |
| **Regulatory** | Explainability Coverage (SHAP) | $100\%$ scoring request menghasilkan top-5 factor drivers |

## 5. Financial Strategy & Commercial Pricing Model

### 5.1 Alokasi Anggaran Pengembangan (R&D & Infrastructure CAPEX/OPEX)
- **CAPEX (R&D Development 12 Minggu):** $\text{Rp } 550.000.000$ (Termasuk gaji tim Engineering: Go/Python Lead, ML Engineer, Security Specialist, Dukcapil & iDeb Integration Specialist, serta legal/OJK sandbox consultant).
- **OPEX Infrastructure (Bulanan):** $\text{Rp } 35.000.000\text{ /bulan}$ (Cloud AWS/GCP Multi-AZ, iDeb SLIK Gateway proxy, Vault KMS, Redis Enterprise, TimescaleDB cluster).

### 5.2 Skema Harga Jual & Model Komersial B2B

1. **Model API Pay-Per-Query (Pay-as-you-go):**
   - **Tier Starter (< 5.000 hits/bulan):** $\text{Rp } 4.500\text{ per API scoring hit}$.
   - **Tier Growth (5.000 - 50.000 hits/bulan):** $\text{Rp } 2.800\text{ per API scoring hit}$.
   - **Tier Enterprise (> 50.000 hits/bulan):** $\text{Rp } 1.500\text{ per API scoring hit}$.

2. **Model Langganan / Subscription SaaS (Bulanan/Tahunan):**
   - **Starter Plan (BPR & Lembaga Keuangan Mikro):** $\text{Rp } 7.500.000\text{ /bulan}$ (Inklusi $2.000$ API hits, basic XAI scorecard, standar support).
   - **Business Plan (P2P Lending & Multifinance):** $\text{Rp } 25.000.000\text{ /bulan}$ (Inklusi $10.000$ API hits, full XAI SHAP factor, custom risk threshold, SLA $99.9\%$).
   - **Enterprise Plan (Bank Komersial & Platform Fintek Besar):** $\text{Rp } 65.000.000\text{ /bulan}$ (Inklusi $30.000$ API hits, dedicated infrastructure, SLA $99.95\%$, & unlimited audit log retention).

3. **Model Project Enterprise / On-Premise License (Custom Implementation):**
   - **One-Time Implementation & Perpetual License:** $\text{Rp } 950.000.000 - 1.500.000.000$ (Deployment On-Premise di Private Data Center Bank/LJK, integrasi Host-to-Host Core Banking & iDeb SLIK OJK, transfer knowledge, & kustomisasi scorecard).
   - **Annual Maintenance & Support (AMC):** $15\% - 20\%$ dari nilai lisensi project per tahun ($\approx \text{Rp } 150.000.000 - 250.000.000\text{ /tahun}$).

