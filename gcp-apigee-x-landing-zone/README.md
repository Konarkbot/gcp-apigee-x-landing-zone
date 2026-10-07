# GCP Landing Zone for Apigee Edge → Apigee X Migration

Terraform repository for an enterprise GCP landing zone supporting an **AWS/Apigee Edge → GCP Apigee X** migration.

## Architecture scope

This repo intentionally separates the landing-zone foundation from API-proxy migration code. It provisions the shared GCP foundation required around Apigee X:

- Custom-mode VPC and regional subnets
- Private Google Access
- Cloud Router + Cloud NAT
- Service Networking / reserved peering range for Apigee
- Secure Web Proxy (SWP) for controlled outbound HTTP/S egress
- Cloud DNS private-zone hook
- KMS / Secret Manager / logging / monitoring foundations
- Apigee X organization, runtime instance, environments, environment groups and instance attachments
- Optional project APIs and enterprise labels
- CI validation workflow

### Important design decision: SWP instead of PSC for egress

The current target design uses **Secure Web Proxy (SWP)** as the controlled web-egress layer. Private Service Connect is **not** used as a blanket replacement for SWP. PSC can still be introduced where the final architecture requires private published services or an SWP PSC service attachment.

The repository does **not** automatically force Apigee southbound traffic through SWP. Private GCP/AWS/on-prem backend connectivity is modeled separately because that path depends on the actual BCBSA/enterprise routing and backend requirements.

## Repository layout

```text
gcp-apigee-x-landing-zone/
├── README.md
├── LICENSE
├── .gitignore
├── .terraform-version
├── docs/
│   ├── architecture.md
│   ├── migration-mapping.md
│   └── runbook.md
├── env/
│   ├── nonprod/
│   │   ├── backend.tf.example
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── terraform.tfvars.example
│   │   └── outputs.tf
│   └── prod/
│       ├── backend.tf.example
│       ├── main.tf
│       ├── variables.tf
│       ├── terraform.tfvars.example
│       └── outputs.tf
├── modules/
│   ├── project-services/
│   ├── network/
│   ├── swp/
│   ├── apigee/
│   ├── security/
│   └── observability/
├── bootstrap/
│   └── project.tf.example
├── scripts/
│   ├── validate.sh
│   └── migrate-edge-export.sh
└── .github/workflows/terraform.yml
```

## Prerequisites

- Terraform >= 1.6
- Google Cloud CLI
- A GCP project with billing enabled
- Permissions to enable APIs and create networking/Apigee resources
- A Google Cloud organization/folder structure appropriate for your enterprise
- For production SWP: a Certificate Manager certificate suitable for the SWP listener
- For Interconnect: partner/provider coordination and the required VLAN attachment details

Google documents Terraform support for Apigee and the current Google provider exposes resources for the Apigee organization, runtime instance, environments, environment groups and instance attachments. citeturn0search2turn4search8turn6search0

## Quick start

### 1. Authenticate

```bash
gcloud auth application-default login
gcloud auth login
gcloud config set project YOUR_PROJECT_ID
```

### 2. Configure non-prod

```bash
cd env/nonprod
cp terraform.tfvars.example terraform.tfvars
# edit terraform.tfvars
terraform init
terraform fmt -recursive
terraform validate
terraform plan -out=tfplan
terraform apply tfplan
```

### 3. Production

Use the same process from `env/prod`. Keep production state in a dedicated locked remote backend; see `backend.tf.example`.

## What this repo creates

| Layer | Main services |
|---|---|
| Governance | IAM, project services, labels, Org Policy hooks |
| Network | VPC, subnets, firewall rules, routes |
| Hybrid | Cloud Router; optional Interconnect attachment inputs are documented separately |
| Egress | Secure Web Proxy, Cloud NAT, DNS |
| API Management | Apigee X organization, instance, environments, env group, attachments |
| Security | KMS, Secret Manager, SWP policy, optional Certificate Manager integration |
| Observability | Logging bucket, audit-log sink, Monitoring-ready APIs |

## What is deliberately not auto-created

The following depend on enterprise-specific values and should be added after the landing zone is accepted:

1. Partner/Cross-Cloud Interconnect VLAN attachments and BGP peer parameters.
2. Exact on-prem/Equinix CIDRs and routes.
3. Production TLS/mTLS certificates and private CA trust configuration.
4. Global/Regional HTTPS load balancers and backend NEGs.
5. Cloud Armor policies with production WAF rules.
6. Apigee custom domains and DNS cutover.
7. Apigee API proxies, shared flows, KVMs, target servers, API products, developers/apps and quotas migrated from Edge.
8. SWP allow-list domains supplied by the security team.

This separation prevents Terraform from inventing network routes, certificates, DNS names or backend endpoints that are not known yet.

## Security defaults

- SWP rules are deny-by-default unless explicit allow rules are supplied.
- No credentials or private keys are committed to Git.
- Secret values should be created outside Git and referenced from Secret Manager.
- Terraform state must be treated as sensitive.
- Production should use a GCS backend with state locking/controls appropriate to the organization's standard.
- CMEK for Apigee is left as an explicit design option because changing Apigee organization encryption settings later can be restrictive.

## SWP notes

Google's current SWP guidance requires a VPC subnet and a proxy-only subnet for regional deployment. SWP can operate in explicit-routing mode or next-hop routing mode. This repo uses explicit routing by default because it is easier to introduce during a controlled migration; next-hop routing can be enabled after the routing design is approved. citeturn0search0turn0search11turn0search17

The repository consumes Google's maintained Terraform SWP module, currently pinned to `0.4.6` in this scaffold. citeturn3search3

## Migration flow

```text
AWS Apigee Edge
      │
      ├── API proxies ───────────────► Apigee X APIs
      ├── Policies ──────────────────► Apigee X policies
      ├── KVMs ──────────────────────► Secret/config strategy
      ├── Target Servers ─────────────► Apigee target configuration
      ├── Certificates / mTLS ────────► Certificate Manager / CAS / Apigee
      ├── Shared Flows ───────────────► Apigee shared flows
      └── Products / Apps ────────────► Apigee products / developers / apps

                       GCP Landing Zone
                              │
          ┌───────────────────┼───────────────────┐
          ▼                   ▼                   ▼
        VPC              Cloud Router             SWP
          │                   │                   │
          │          Interconnect / AWS            │
          │                   │                   │
          └─────────────► Apigee X ◄──────────────┘
                              │
                              ▼
                    GCP / AWS / On-prem backends
```
