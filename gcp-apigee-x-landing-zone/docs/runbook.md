# Deployment Runbook

## Phase 0 — Enterprise prerequisites

- Confirm project IDs and billing.
- Confirm organization/folder placement.
- Confirm region and analytics region.
- Approve all CIDRs.
- Confirm AWS VPC CIDRs and on-prem/Equinix routes.
- Obtain production SWP certificate.
- Confirm Apigee subscription/billing model.
- Confirm DNS ownership for Apigee hostnames.

## Phase 1 — Landing zone

```bash
cd env/nonprod
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform fmt -recursive
terraform validate
terraform plan -out=tfplan
terraform apply tfplan
```

Validate:

```bash
gcloud compute networks describe apigee-lz-nonprod
gcloud compute routers describe apigee-lz-router --region=us-central1
gcloud apigee organizations list
gcloud network-services gateways list --location=us-central1
```

## Phase 2 — Connectivity

Coordinate with the network team for:

- Partner Interconnect
- Cross-Cloud Interconnect
- BGP ASN/IPs
- AWS-side routing
- Equinix routing
- firewall rules
- return routes

Do not enable broad routes just to make testing pass.

## Phase 3 — Backend connectivity

For each API proxy, identify the target category:

```text
GCP private backend
AWS private backend
On-prem backend
Internet/SaaS backend
```

Use the appropriate path:

```text
GCP/AWS/on-prem private target -> routing / ILB / Interconnect / PSC as designed
Internet/SaaS target            -> SWP / approved egress path
```

## Phase 4 — Apigee migration

Migrate in this order:

1. Environment structure
2. Hostnames/certificates
3. Shared flows
4. KVM/configuration classification
5. Target servers
6. API proxies
7. Policies
8. API products
9. Developers/apps
10. Quotas and traffic controls
11. Analytics/monitoring
12. DNS / traffic cutover

## Phase 5 — Cutover

Use parallel validation wherever possible:

```text
Client
  |
  +----> Apigee Edge  (baseline)
  |
  +----> Apigee X     (candidate)
```

Compare:

- HTTP status
- latency
- backend response
- authentication result
- headers
- policy behavior
- TLS/mTLS handshake
- quota behavior
- error rates

Only then perform DNS or traffic cutover.
