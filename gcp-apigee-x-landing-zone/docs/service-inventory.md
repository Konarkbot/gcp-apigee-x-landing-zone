# GCP Landing Zone Service Inventory

| Category | GCP service | Role in this migration | Status in repo |
|---|---|---|---|
| Governance | Cloud Resource Manager | Project/folder hierarchy | Bootstrap example |
| Governance | IAM | Least-privilege access | GCP foundation |
| Governance | Organization Policy | Enterprise guardrails | Central platform dependency |
| Networking | VPC | Landing-zone network | Terraform |
| Networking | Subnets | Workload/SWP/proxy-only segmentation | Terraform |
| Networking | Firewall | Network segmentation | Terraform |
| Networking | Service Networking | Apigee private VPC peering | Terraform |
| Networking | Cloud Router | BGP routing | Terraform |
| Networking | Cloud NAT | Controlled public egress path | Terraform |
| Networking | Cloud DNS | Private DNS | Optional Terraform |
| Hybrid | Partner Interconnect | Enterprise/Equinix connectivity | Integration point |
| Multicloud | Cross-Cloud Interconnect | AWS connectivity | Integration point |
| Egress security | Secure Web Proxy | HTTP/S egress policy and inspection | Terraform |
| API management | Apigee X | Target API platform | Terraform |
| API management | Apigee environments | Dev/Test/Prod isolation | Terraform |
| API management | Apigee environment groups | Hostname routing | Terraform |
| API management | Apigee instance attachments | Runtime placement | Terraform |
| Security | Secret Manager | Secrets/config separation | Terraform |
| Security | Cloud KMS | Key management foundation | Terraform |
| Security | Certificate Manager | TLS certificate lifecycle | SWP integration hook |
| Security | Certificate Authority Service | Private CA/mTLS | Enterprise integration |
| Security | Cloud Armor | WAF/DDoS at API edge | Later phase |
| Security | Security Command Center | Security posture/findings | API enabled |
| Observability | Cloud Logging | Central logs | Terraform |
| Observability | Cloud Monitoring | Metrics/alerts | API enabled |
| Observability | VPC Flow Logs | Network visibility | Terraform |
| Delivery | Cloud Build | CI/CD integration | API enabled |
| Delivery | Artifact Registry | Artifact storage | API enabled |
| IaC | Terraform | Infrastructure/configuration as code | Repository |
