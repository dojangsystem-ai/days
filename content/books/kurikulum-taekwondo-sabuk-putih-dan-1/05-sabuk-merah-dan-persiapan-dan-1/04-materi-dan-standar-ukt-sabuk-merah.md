---
title: "Bab 5.4: Materi dan Standar UKT Sabuk Merah & Merah Strip (Geup 3 ke 2 & 2 ke 1)"
slug: "04-materi-dan-standar-ukt-sabuk-merah"
date: "2026-10-10"
author: "Content & System Engineering Agent"
tags: ["taekwondo", "ukt", "sabuk-merah", "geup-3", "geup-2", "geup-1", "pra-dan", "ujian-kenaikan-tingkat"]
category: "Technical Books"
status: "published"
---

# Bab 5.4: Materi dan Standar UKT Sabuk Merah & Merah Strip (Geup 3 ke 2 & 2 ke 1)

Jenjang **Sabuk Merah (Geup 3)**, **Merah Strip I (Geup 2)**, dan **Merah Strip II / Pra-Dan (Geup 1)** merupakan gerbang akhir sebelum Taekwondoin melangkah ke tingkatan Sabuk Hitam (Dan 1 Kukkiwon). Warna merah melambangkan bahaya: peserta telah memiliki daya hancur fisik yang tinggi sehingga dituntut kontrol diri, maturitas etika, serta kesempurnaan teknik mutlak dalam Ujian Kenaikan Tingkat (UKT).

---

## 1. Peta Kualifikasi Pra-Dan 1 (Geup 3 → Geup 1)

```mermaid
flowchart LR
    G3["Geup 3 (Sabuk Merah)"] -- "UKT Geup 2: Taegeuk 8 + Kyukpa 2 Papan" --> G2["Geup 2 (Merah Strip I)"]
    G2 -- "UKT Geup 1: Random Taegeuk 1-8 + Kyukpa 3 Papan" --> G1["Geup 1 (Merah Strip II / Pra-Dan)"]
    G1 -- "Persiapan Mandiri 6 Bulan + Wawancara" --> DAN1["Ujian Dan 1 Kukkiwon"]
```

| Tingkatan Ujian | Target Poomsae | Spesifikasi Kyukpa | Hosinsool & Kyorugi | Standard Fisik |
| :--- | :--- | :--- | :--- | :--- |
| **Geup 3 → Geup 2** | *Taegeuk Pal Jang (8 Jang)* | 2 Bilah Papan (2.5 cm) dengan *Dwit Chagi* / *Yeop Chagi* | 3 Variasi Hosinsool + Sparring 2 Ronde | Push-up 35x, Sit-up 40x |
| **Geup 2 → Geup 1 (Pra-Dan)** | *Taegeuk 8 Jang* + 2 Jurus Undian (*Taegeuk 1-7*) | 3 Bilah Papan (2.5 cm) dengan *Dolgae Chagi* / *Twiyeo Dwit Chagi* | Hosinsool Multi-Attacker + Sparring 3 Ronde | Push-up 50x, Sit-up 50x, Run 3km < 15 mnt |

---

## 2. Rincian Materi Pengujian UKT Sabuk Merah

### A. Pengujian Poomsae Komprehensif (Random Drawing System)
Pada ujian Geup 1 (Pra-Dan), penguji tidak hanya menilai *Taegeuk 8 Jang*, tetapi memilih **2 Taegeuk acak** dari Taegeuk 1 hingga 7 secara tiba-tiba:
- Penguji menguji ingatan memori otot (*Muscle Memory*) dan kedalaman filosofi trigram setiap Poomsae.
- Penilaian ketat pada: *Accuracy* (5.0) dan *Presentation* (5.0).

### B. Pemecahan Daya & Teknik Akrobatik (Kyukpa - 격파)

```mermaid
classDiagram
    class KyukpaPraDan {
        +String media_papan
        +Boolean ketepatan_titik
    }
    class WiRyokKyukpa {
        +Pemecahan Daya Pukul/Tendang
        +Target: 3 Bilah Papan Kayu Pinus (Total 7.5 cm)
        +Teknik: Dwit Chagi / Yeop Chagi
    }
    class YeosangKyukpa {
        +Pemecahan Udara / Atraksi
        +Target: 1 Bilah Papan Ketinggian 2.2 Meter
        +Teknik: Twiyeo Yeop Chagi / Dolgae Chagi
    }
    KyukpaPraDan <|-- WiRyokKyukpa
    KyukpaPraDan <|-- YeosangKyukpa
```

### C. Hosinsool Lanjutan & Kyorugi Bebas (Multi-Attacker & Sparring)
1. **Hosinsool Multi-Attacker (2 Penyerang):** Peserta dikepung oleh 2 lawan (satu menyerang dengan pukulan, satu mencoba memegang dari belakang). Peserta wajib melakukan *Sidestep*, melumpuhkan penyerang belakang dengan *Elbow Strike*, dan mengeksekusi bantingan pada penyerang depan.
2. **Kyorugi Sparring Intensif (3 Ronde x 2 Menit):** Evaluasi ketahanan fisik, pembacaan taktik (*Feinting & Timing*), serta kepatuhan pada aturan World Taekwondo (WT).

---

## 3. Matriks Kualifikasi Menuju rekomendasi Dan 1 Kukkiwon

```mermaid
gantt
    title Jadwal Persiapan UKT Sabuk Merah hingga rekomendasi Dan 1
    dateFormat  YYYY-MM-DD
    section Geup 3 ke Geup 2
    Pelatihan & Pemantapan Taegeuk 8   :active, g3_1, 2026-10-01, 2026-11-15
    UKT Geup 2                        :crit, g3_2, 2026-11-16, 2026-11-17
    section Geup 2 ke Geup 1
    Review All Taegeuk 1-8            :active, g2_1, 2026-11-18, 2027-01-15
    UKT Geup 1 (Pra-Dan)               :crit, g2_2, 2027-01-16, 2027-01-17
    section Pra-Dan ke Dan 1
    Karantina & Karya Tulis Filosofi   :crit, g1_1, 2027-01-18, 2027-04-01
    Ujian Resmi Kukkiwon Dan 1         :done, g1_2, 2027-04-02, 2027-04-03
```

---
[← Bab 5.3: Standar Ujian Dan 1 Kukkiwon](03-standar-ujian-dan-1-kukkiwon.md) | [Daftar Isi](../_index.md)
