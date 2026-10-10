---
title: "OJK-Compliant Credit Scoring System Architecture & Tech Stack"
slug: "ojk-credit-scoring"
date: "2026-10-10"
author: "System Architect Agent"
tags: ["architecture", "erd", "techstack", "security", "ojk", "xai"]
category: "Product Spec"
status: "draft"
priority: "P0"
complexity: "Critical"
estimated_effort: "8-12 weeks"
---

# 01. Architecture & Tech Stack Specification

## 1. System Architecture Diagram

Sistem menggunakan arsitektur Microservices terenkripsi berkinerja tinggi, memisahkan Gateway, Engine Konsen PDP, Integrator Data SLIK/Alternatif, Inference Engine ML/XAI, dan Vault Log Audit.

```mermaid
flowchart TD
    subgraph ClientLayer ["Client & Integration Layer (B2B / Partner)"]
        FintechClient["Fintech / Bank App (B2B Client)"]
        AdminDashboard["Compliance & Underwriting Portal (React/TS)"]
    end

    subgraph APIGatewayLayer ["API Gateway & Security Proxy"]
        KongGateway["Kong API Gateway (mTLS & Rate Limiting)"]
        WAF["Cloudflare Enterprise WAF"]
    end

    subgraph CoreServices ["Microservices Core (Go & Python)"]
        AuthService["Auth & RBAC Service (Go)"]
        ConsentService["PDP Consent Engine (Go)"]
        IngestionService["Data Ingestion & Anonymizer (Go)"]
        ScoringEngineService["Scoring Orchestrator Service (Go)"]
        XAIInferenceService["XAI ML Inference Microservice (Python/FastAPI)"]
        AuditLogService["Immutable Audit Service (Go)"]
    end

    subgraph DataIntegrations ["External Third-Party Data Providers"]
        DukcapilAPI["Dukcapil e-KYC Identity"]
        SLIKGateway["OJK SLIK / LIK Gateway"]
        AltDataAggregator["Telco & E-Commerce Aggregator API"]
    end

    subgraph DataStorage ["Data & Model Storage Layer"]
        PrimaryDB[(PostgreSQL 16 - Encrypted DB)]
        CacheDB[(Redis Enterprise - Token & Session)]
        AuditVault[(TimescaleDB - Write-Only Immutable Log)]
        ModelRegistry[(S3 Compatible Storage - Encrypted Model Artifacts)]
    end

    FintechClient -->|"mTLS / HTTPS"| WAF
    AdminDashboard -->|"HTTPS / JWT"| WAF
    WAF --> KongGateway

    KongGateway --> AuthMicroserviceCheck
    AuthMicroserviceCheck --> AuthService
    KongGateway --> ConsentService
    KongGateway --> ScoringEngineService

    ScoringEngineService --> ConsentService
    ConsentService --> IngestionService
    IngestionService --> DukcapilAPI
    IngestionService --> SLIKGateway
    IngestionService --> AltDataAggregator

    IngestionService -->|"Pseudonymized Features"| XAIInferenceService
    XAIInferenceService -->|"Load XGBoost Artifacts"| ModelRegistry
    XAIInferenceService -->|"Score + SHAP Factors"| ScoringEngineService

    ScoringEngineService --> AuditLogService
    ConsentService --> AuditLogService
    
    AuthService --> PrimaryDB
    ConsentService --> PrimaryDB
    ScoringEngineService --> PrimaryDB
    AuditLogService --> AuditVault
    KongGateway --> CacheDB
```

---

## 2. Database Schema (Mermaid ERD)

```mermaid
erDiagram
    TENANTS ||--o{ USERS : "has"
    TENANTS {
        uuid id PK
        string company_name
        string ojk_license_number
        string client_id UK
        string client_secret_hash
        string status
        timestamp created_at
    }

    USERS ||--o{ AUDIT_LOGS : "generates"
    USERS {
        uuid id PK
        uuid tenant_id FK
        string full_name
        string email UK
        string password_hash
        string role
        boolean is_active
        timestamp last_login_at
    }

    APPLICANTS ||--o{ CONSENT_RECORDS : "grants"
    APPLICANTS ||--o{ SCORING_REQUESTS : "requests"
    APPLICANTS {
        uuid id PK
        string nik_hash UK "HMAC-SHA256"
        string encrypted_nik "AES-256-GCM"
        string encrypted_full_name "AES-256-GCM"
        string encrypted_phone "AES-256-GCM"
        timestamp created_at
    }

    CONSENT_RECORDS ||--o{ SCORING_REQUESTS : "authorizes"
    CONSENT_RECORDS {
        uuid id PK
        uuid applicant_id FK
        uuid tenant_id FK
        string consent_type "SLIK_AND_ALT_DATA"
        string consent_document_version
        string digital_signature_hash
        timestamp granted_at
        timestamp expires_at
        boolean is_revoked
    }

    SCORING_REQUESTS ||--|| SCORE_RESULTS : "produces"
    SCORING_REQUESTS {
        uuid id PK
        uuid applicant_id FK
        uuid consent_id FK
        uuid tenant_id FK
        string status "PENDING | COMPLETED | FAILED"
        string request_id UK
        timestamp requested_at
        timestamp completed_at
    }

    SCORE_RESULTS ||--o{ XAI_FACTOR_EXPLANATIONS : "contains"
    SCORE_RESULTS {
        uuid id PK
        uuid scoring_request_id FK
        integer credit_score "Range 300 - 850"
        string risk_grade "AAA | AA | A | BBB | BB | B | CCC | D"
        decimal probability_of_default "0.0000 to 1.0000"
        string decision_recommendation "APPROVE | REFER | REJECT"
        timestamp generated_at
    }

    XAI_FACTOR_EXPLANATIONS {
        uuid id PK
        uuid score_result_id FK
        string feature_name
        decimal feature_value
        decimal shap_value
        string impact_direction "POSITIVE | NEGATIVE"
        integer rank_order
    }

    AUDIT_LOGS {
        uuid id PK
        uuid tenant_id FK
        uuid user_id FK
        string action_type
        string target_resource
        string ip_address
        string payload_sha256_hash
        timestamp created_at
    }
```

---

## 3. Technology Stack Specification

| Component | Technology / Library | Selection Rationale |
| :--- | :--- | :--- |
| **API Gateway** | Kong API Gateway v3.5 | Support mTLS B2B, Rate Limiting, OpenID Connect plugin |
| **Core API Backend** | Go (Golang) 1.22 + Gin Framework | High concurrency (< 20ms microservice latency), low memory footprint |
| **ML/XAI Engine** | Python 3.11 + FastAPI + XGBoost + SHAP | Standard industri ML & Explainable AI (SHAP & LIME) |
| **Primary Database** | PostgreSQL 16 dengan Transparent Data Encryption | SQL ACD compliant, PG-Crypto untuk enkripsi kolom |
| **Immutable Audit Storage**| TimescaleDB (Append-Only PostgreSQL extension) | High throughput time-series logging, partitioning otomatis |
| **Cache & Session** | Redis Enterprise Cluster 7.2 | Rate limit caching, session state management |
| **Object Storage** | MinIO / AWS S3 (AES-256 SSE) | Penyimpanan model ML artifacts (.onnx / .json model) |
| **Message Broker** | Apache Kafka / Redpanda | Asynchronous data ingestion & decoupled audit streaming |
| **Frontend Portal** | React 18 + Vite + TailwindCSS | UI/UX modern untuk Underwriter & Compliance Dashboard |

---

## 4. Security, Privacy & Regulatory Compliance Model

### 4.1 Authentikasi & Otorisasi
- **B2B API Integration:** Mandatory Mutual TLS (mTLS) + OAuth2 Client Credentials Flow (RS256 JWT Signed Keys).
- **Internal Dashboard Access:** OAuth2 PKCE + Mandatory Multi-Factor Authentication (TOTP/FIDO2) + RBAC (`SUPER_ADMIN`, `AUDITOR_OJK`, `UNDERWRITER`, `COMPLIANCE_OFFICER`).

### 4.2 Skema Enkripsi Data (UU PDP & ISO 27001)
- **Data-in-Transit:** Encrypted via TLS 1.3 dengan cipher suite modern (ECDHE-RSA-AES128-GCM-SHA256).
- **Data-at-Rest:** Column-level encryption untuk PII (NIK, Nama, Phone) menggunakan **AES-256-GCM** dengan Key Management Service (AWS KMS / HashiCorp Vault) per-tenant data key rotation.
- **Data Pseudonymization:** NIK di-hash menggunakan `HMAC-SHA256` dengan secret pepper yang disimpan di Hardware Security Module (HSM).

### 4.3 OJK Compliance Safeguards (SEOJK No. 29/SEOJK.05/2021)
1. **Explicit Consent & Revocation:** API scoring menolak pemrosesan jika token konsen expired atau `is_revoked = true`.
2. **Right to be Forgotten:** Mendukung enkripsi ulang key (crypto-shredding) sehingga data PII ter-anonymize irreversibly ketika permohonan pembersihan data diajukan.
3. **Audit Trail Immutability:** Setiap request scoring menghasilkan log transaksi terenkripsi dengan SHA-256 signature chain untuk mencegah tampered log oleh pihak mana pun.
