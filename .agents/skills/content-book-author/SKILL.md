---
name: content-book-author
description: >-
  Workflow for authoring and structuring multi-chapter technical books and tutorial series in content/books/<slug>/.
  Use this skill when asked to create a technical book, tutorial series, or add new chapters/subchapters to a book.
---

# Content Book Author Skill

Use this skill when creating or maintaining systematic tutorial series or technical books in `content/books/`.

## Directory & File Structure

```text
content/books/<book-slug>/
├── assets/                     # Media/diagram assets for this book
├── _index.md                   # Book metadata, preface, and table of contents
├── 01-nama-bab/
│   ├── 01-nama-subbab.md
│   └── 02-nama-subbab.md
└── 02-nama-bab/
    ├── 01-nama-subbab.md
    └── 02-nama-subbab.md
```

## Workflow Steps

### 1. Root Metadata (`_index.md`)
Every book directory MUST contain an `_index.md` with:

```yaml
---
title: "Judul Buku / Serial Tutorial"
slug: "book-slug"
date: "YYYY-MM-DD"
author: "Nama Penulis / Agent ID"
tags: ["book", "tutorial", "backend"]
category: "Technical Books"
status: "draft" # Choices: draft | review | published
---
```

Include a Preface, Target Audience, Prerequisites, and an explicit Table of Contents linking to each chapter file.

### 2. Chapter & Subchapter Writing Rules
- Directory names use two-digit prefix: `01-fondasi/`, `02-penerapan-lanjut/`.
- Subchapter files use two-digit prefix: `01-pengenalan.md`, `02-arsitektur-dasar.md`.
- Each subchapter file MUST include full YAML frontmatter:
  ```yaml
  ---
  title: "Bab 1.1: Judul Subbab"
  slug: "01-pengenalan"
  date: "YYYY-MM-DD"
  author: "Nama Penulis"
  tags: ["tutorial"]
  category: "Technical Books"
  status: "draft"
  ---
  ```
- **Navigation Footer:** At the bottom of every subchapter file, include relative navigation links:
  ```markdown
  ---
  [← Subbab Sebelumnya](01-subbab-sebelumnya.md) | [Daftar Isi](../_index.md) | [Subbab Selanjutnya →](02-subbab-selanjutnya.md)
  ```

### 3. Consistency Requirements
- Maintain consistent terminology, glossary definitions, and code convention throughout all chapters.
- Store all screenshots and rendered diagrams in `content/books/<book-slug>/assets/`.
