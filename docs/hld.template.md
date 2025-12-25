# High-Level Design (HLD)

## 1. Overview

_Describe the purpose of the HLD, what it covers, and its role in the delivery lifecycle._

### 1.1 Audience

_List intended readers: architects, engineers, governance teams, security reviewers, delivery managers._

### 1.2 Stakeholders

_A table listing stakeholders and the interest/concern in the solution._

### 1.3 Document Ownership

_Define who owns the document, who contributes, and who approves updates._

### 1.4 References

_List architectural standards, ADRs, Microsoft documentation, related design documents._

---

## 2. Context

### 2.1 Problem Statement

_Describe the business and technical problem being solved.  
Explain constraints of the current system and why change is required._

### 2.2 Objectives

_List the target outcomes (functional & non-functional).  
Use clear, concise statements._

### 2.3 Requirements

_Provide high-level functional and non-functional requirements.  
Keep this section minimal; detailed requirements can live elsewhere._

---

## 3. Architecture Design

### 3.1 Component Design

_Describe the major software components and their responsibilities.  
Focus on **application-level components**, not infrastructure (e.g., Policy Management Module, Provider Factory, Asset Service).  
Keep statements concise._

### 3.2 Architecture Decisions

_Summarise major architectural decisions (or reference ADRs).  
Describe chosen patterns, rejected alternatives, and rationale._

### 3.3 Data Flow Diagram

_Describe the core system flows (e.g., policy import, asset upload, scheduled jobs).  
Keep this section high-level and behavioural._

### 3.4 Deployment Diagram

_Describe the environment-level deployment model.  
Include: App Services, Storage Accounts, Key Vault, Front Door/VNet, monitoring.  
Focus on **where** components run and how they are hosted._

---

## 4. Module Design

_Describe the internal structure of the application in terms of logical modules/services.  
For each module:_

- _What responsibilities it owns_  
- _How it interacts with other modules_  
- _Any relevant patterns or interfaces_  

_(Typical modules: Policy Management, Graph Providers, Asset Module, Audit Module, Reporting Module, UI Module.)_

---

## 5. Data Design

_Describe data domains and their purpose along with what technologies underpin the data. Examples could be: user, audit, reporting, caching._

### 5.x Data Retention & Classification

_Placeholder for retention rules, data classification, encryption requirements._

---

## 6. Security Design

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

_Summarise Graph app-only permission model, least privilege, how secrets are stored._

#### 6.6.1 Microsoft Graph Permissions

_Summary plus pointer to detailed permissions list._

#### 6.6.2 Other External Integrations

_Describe GitHub, Azure DevOps, or other third-party services._

---

## 7. Glossary

_Define terms, acronyms, internal names, and domain-specific terminology._
