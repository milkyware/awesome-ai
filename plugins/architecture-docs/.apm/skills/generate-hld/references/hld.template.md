# High-Level Design (HLD)

_Describe the purpose of the HLD, what it covers, and its role in the delivery lifecycle._

## 1. Overview

### 1.1 Audience

_List intended readers: architects, engineers, governance teams, security reviewers, delivery managers._

### 1.2 Stakeholders

_A table listing stakeholders and the interest/concern in the solution (headings: Name, Concern)._

### 1.3 Document Ownership

_Define who owns the document, who contributes, and who approves updates._

### 1.4 References

_List architectural standards, ADRs, Microsoft documentation, related design documents._

### 1.5 Service Categorisation

_Describe the service category of the solution (for example service tier, classification, business impact)._

---

## 2. Context

### 2.1 Problem Statement

_Describe the business and technical problem being solved. Explain constraints of the current system and why change is required._

### 2.2 Objectives

_List the target outcomes (functional and non-functional). Use clear, concise statements._

### 2.3 Requirements

_Provide high-level functional and non-functional requirements as a table (ID, Functional/Non-functional, Description). Keep this section minimal; detailed requirements can live elsewhere._

---

## 3. Architecture Design

### 3.1 Component Design

_Describe the major software components and their responsibilities. Focus on application-level components, not infrastructure (for example Policy Management Module, Provider Factory, Asset Service). Keep statements concise._

### 3.2 Architecture Decisions

_Summarise major architectural decisions (or reference ADRs). Describe chosen patterns, rejected alternatives, and rationale._

### 3.3 Data Flows

_Describe the core system flows and their behaviour (for example policy import, asset upload, scheduled jobs). Keep this section high-level and behavioural._

### 3.4 Deployment Design

_Describe the environment-level deployment model. Include: App Services, Storage Accounts, Key Vault, Front Door/VNet, monitoring. Focus on where components run and how they are hosted._

---

## 4. Module Design

_Describe the internal structure of the application in terms of logical modules/services. For each module: what responsibilities it owns, how it interacts with other modules, and any relevant patterns or interfaces._

---

## 5. Data Design

_Describe data domains and their purpose, along with the technologies that underpin each. Identify the data subsections from the answers and content gathered; the examples below are illustrative, not exhaustive (for example user, audit, reporting, caching)._

### 5.x Data Design Subsections

_Common inclusions, ordered as relevant to the solution._

### 5.x Data Retention & Classification

_Describe retention rules, data classification, encryption requirements, caching, and any governance or compliance requirements. This subsection must be the last subsection in Data Design._

---

## 6. Security Design

_Identify the security subsections from the answers and content gathered; the list below is illustrative, not exhaustive. Common inclusions are: identity and authentication, authorisation and RBAC, data protection, network and infrastructure security, logging/monitoring/audit, and external permissions._

### 6.1 Identity and Authentication

_Describe how users authenticate via Entra ID/OIDC, cookie auth, JWT tokens._

### 6.2 Authorisation and RBAC

_Describe persona-based app roles, mapping via Entra groups, API/UI enforcement._

### 6.3 Data Protection

_Describe encryption at rest (Azure-managed), encryption in transit, and Key Vault usage._

### 6.4 Network and Infrastructure Security

_Describe ingress (Front Door), VNet integration, private endpoints, outbound restrictions._

### 6.5 Logging, Monitoring and Audit

_Describe Application Insights, Log Analytics, XSIAM forwarding, audit table._

### 6.6 External Permissions and App Registrations

_Summarise the Graph app-only permission model, least privilege, and how secrets are stored._

#### 6.6.1 Microsoft Graph Permissions

_Summary plus pointer to the detailed permissions list._

#### 6.6.2 Other External Integrations

_Describe GitHub, Azure DevOps, or other third-party services._

---

## 7. Glossary

_Define solution-specific and architecture-specific terms, acronyms, and domain terminology. Exclude widely understood technical terms (for example API, CI/CD, Entra ID)._
