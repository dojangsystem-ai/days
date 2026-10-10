---
title: "FR-05: Buku Hasil Report Kejuaraan (Official Result Book)"
slug: "tournament-event-management"
date: "2026-10-10"
author: "System Architect Agent"
tags: ["prd", "report-book", "pdf-generator", "official-results", "export"]
category: "Product Spec"
status: "draft"
priority: "P0"
complexity: "High"
estimated_effort: "1-2 weeks"
---

# Feature Specification: Buku Hasil Report Kejuaraan / Official Result Book (FR-05)

## 1. User Story

**As a** Event Organizer, Panitia Pelaksana, & Pengurus Cabang Olahraga,  
**I want to** meng-generate *Official Result Book* (Buku Hasil Kejuaraan) secara otomatis dalam format PDF komprehensif yang siap cetak dan diunduh,  
**So that** laporan pertanggungjawaban event ke instansi pemerintah/sponsor, federasi, dan pers dapat diselesaikan secara instan tanpa menunggu pembuatan dokumen manual berhari-hari.

---

## 2. Acceptance Criteria (Gherkin Format)

### Scenario 1: Penjanaan Buku Hasil Kejuaraan PDF Instan
```gherkin
Given a completed tournament where all match results have been finalized and verified by the Technical Delegate
When the Event Organizer clicks "Generate Official Result Book" via the Admin Panel
Then the system compiles:
  - Cover page & Executive Summary
  - List of participating contingents & total athlete statistics
  - Medal Tally & Champion Contingents
  - Complete Winner List per category (Juara 1, 2, 3)
  - Full Bracket Results for every category
  - Digital signature verification page
And renders a print-ready PDF document within < 10 seconds
And returns HTTP status code 200 OK with the S3 download URL
```

### Scenario 2: Ekspor Data ke Format Excel Spreadsheet untuk Sekretariat
```gherkin
Given a request to export raw results data for federation archive
When the Secretariat Admin sends a GET request to "/api/v1/tournaments/{id}/reports/export-excel"
Then the system generates a multi-sheet XLSX file containing raw athlete data, match scores, and medal matrices
```

---

## 3. API Endpoint Specifications

### 3.1 Generate Official Result Book PDF
- **HTTP Method:** `POST`
- **Endpoint URI:** `/api/v1/tournaments/{tournament_id}/reports/official-result-book`
- **Headers:**
  - `Authorization: Bearer <jwt_access_token>`
  - `Content-Type: application/json`

#### Request Body Schema:
```json
{
  "include_brackets": true,
  "include_athlete_photos": false,
  "watermark_text": "OFFICIAL FINAL RESULT",
  "signatories": [
    {
      "name": "Dr. Ir. H. Ahmad Subardjo, M.Si",
      "title": "Ketua Umum Pengprov",
      "digital_signature_id": "sig-001"
    },
    {
      "name": "Master Herman Wijaya",
      "title": "Technical Delegate",
      "digital_signature_id": "sig-002"
    }
  ]
}
```

#### Response Payload (200 OK):
```json
{
  "status": "success",
  "data": {
    "report_id": "rep-tn2026-final-v1",
    "pdf_url": "https://s3.ap-southeast-1.amazonaws.com/tms-reports/TN-2026-BDG_Official_Result_Book.pdf",
    "file_size_bytes": 14285000,
    "page_count": 84,
    "generated_at": "2026-10-10T18:00:00Z"
  }
}
```

---

## 4. Edge Cases & Failure Modes

1. **Ukuran File Terlalu Besar (>100 Halaman):** Jika kejuaraan memiliki 100+ kategori dengan bagan lengkap, rendering PDF dilakukan secara *asynchronous background job* menggunakan Redis Queue (BullMQ). Progress bar dikirimkan ke frontend via WebSocket.
2. **Kategori Belum Selesai (Draft Report):** Jika terdapat kategori yang belum menyelesaikan partai final, sistem memberikan konfirmasi peringatan dan membubuhkan stempel watermark *"DRAFT - UNFINALIZED RESULT"* pada dokumen PDF yang diproduksi.

---

## 5. Security & Data Privacy Review

- Laporan resmi akhir dilindungi dengan *SHA-256 Hash Verification* dan QR Code validasi keaslian dokumen pada bagian footer setiap halaman.
