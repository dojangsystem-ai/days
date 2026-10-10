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
