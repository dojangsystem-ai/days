---
name: content-idea-architect
description: >-
  Workflow for creating complete product app specifications, PRDs, and feature specs in content/ideas/<app-name>/.
  Use this skill when asked to create a new product idea, system specification, or PRD.
---

# Content Idea Architect Skill

Use this skill when architecting and specifying new product application ideas, PRDs, or system RFCs in `content/ideas/`.

## Directory Structure Requirement

Every product idea in `content/ideas/<app-name>/` MUST strictly adhere to this four-part structure:

```text
content/ideas/<app-name>/
├── assets/                             # ERD renders, wireframe mockups, flowcharts
├── 00-overview.md                      # Problem statement, value prop, persona, metrics
├── 01-architecture-and-techstack.md    # System architecture, Mermaid ERD, tech stack, security
├── features/                           # Granular feature specifications
│   ├── FR-01-user-authentication.md
│   └── FR-02-core-feature.md
└── roadmap.md                          # Implementation milestones: MVP, Phase 1, Phase 2
```

## Workflow & Frontmatter Standards

### 1. Root Frontmatter Metadata
All `.md` files under `content/ideas/<app-name>/` MUST use the extended frontmatter schema:

```yaml
---
title: "Nama Aplikasi / System Name"
slug: "app-name"
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

### 2. File Implementation Specifications

#### A. `00-overview.md`
- **Problem Statement:** Detailed technical and business pain points.
- **Value Proposition:** Core solution differentiators.
- **Target User Personas:** Primary & secondary user roles.
- **Core Success Metrics (KPIs):** Measurable targets (e.g. latency < 100ms, 99.9% uptime).

#### B. `01-architecture-and-techstack.md`
- **System Architecture Diagram:** Mermaid flowchart (`graph TD` / `flowchart TD`).
- **Database Schema:** Complete Mermaid ERD (`erDiagram`).
- **Tech Stack & Libraries:** Explicit listing of frontend, backend, database, cache, and third-party integrations.
- **Security & Privacy Model:** Auth mechanism (JWT/OAuth2), RBAC roles, encryption at-rest/in-transit.

#### C. `features/FR-<number>-<feature-name>.md`
Each feature spec MUST contain:
1. **User Story:** *As a... I want to... So that...*
2. **Acceptance Criteria (Gherkin):**
   ```gherkin
   Given a user with a valid active session
   When they send a POST request to /api/v1/resource with valid JSON body
   Then the system creates the resource and returns HTTP status code 201 Created
   ```
3. **API Endpoint Specification:**
   - HTTP Method & Path
   - Headers (e.g. `Authorization: Bearer <token>`)
   - Request Body JSON Schema
   - Response Payload JSON Schemas (200/201 Success, 400 Bad Request, 401 Unauthorized, 500 Internal Error)
4. **Edge Cases & Failure Modes:** Validation errors, rate-limiting, timeout strategies.

#### D. `roadmap.md`
- **MVP Milestone:** Mandatory core features required for launch.
- **Phase 1 (Post-MVP):** Key enhancements and scaling.
- **Phase 2 (Long-Term):** Advanced integrations and optimizations.
