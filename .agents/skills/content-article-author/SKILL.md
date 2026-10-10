---
name: content-article-author
description: >-
  Workflow and guidelines for drafting, editing, and validating deep-dive technical articles
  in content/articles/. Use this skill when asked to write a new technical article or update an existing one.
---

# Content Article Author Skill

Use this skill when tasked with creating or refining technical articles in `content/articles/`.

## Workflow Steps

### 1. File Path & Naming Format
- File location: `content/articles/<judul-kebab-case>.md`
- Asset location: `content/articles/assets/` (if referencing external images or custom visuals)

### 2. Mandatory YAML Frontmatter Schema
Every article MUST start with this frontmatter:

```yaml
---
title: "Judul Artikel yang Presisi dan Deskriptif"
slug: "judul-kebab-case"
date: "YYYY-MM-DD"
author: "Nama Penulis / Agent ID"
tags: ["system-design", "golang", "architecture"]
category: "System Architecture"
status: "draft" # Choices: draft | review | published
---
```

### 3. Structural Guidelines
1. **Introduction & Context:** Brief, technical overview of the problem space without generic fluff.
2. **Deep-Dive Architecture & Concepts:** Explain architectural mechanics, tradeoffs, and system patterns. Use Mermaid diagrams (`flowchart TD`, `sequenceDiagram`) to visually depict workflows.
3. **Implementation / Code Examples:** Provide accurate, runnable code snippets with explicit language identifiers (e.g. ` ```typescript `, ` ```go `).
4. **Validation & Edge Cases:** Cover failure modes, rate limits, performance bottlenecks, and best practices.
5. **Conclusion & Key Takeaways:** Bulleted summary of actionable recommendations.

### 4. Verification & Validation
Before finalizing:
- Ensure code block identifiers are valid.
- Run markdown linter: `npx markdownlint-cli "content/articles/*.md"`
