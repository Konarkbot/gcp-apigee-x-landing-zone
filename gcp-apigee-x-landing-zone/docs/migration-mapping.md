# Apigee Edge → Apigee X Migration Mapping

| Apigee Edge artifact | Apigee X target | Landing-zone dependency |
|---|---|---|
| Edge org | Apigee X organization | Apigee + VPC Service Networking |
| Environment | Apigee X environment | Apigee runtime instance |
| API Proxy | Apigee API proxy | Apigee environment |
| Proxy revision | API revision / deployment | Apigee deployment |
| Target Server | Target Server / endpoint attachment / DNS | Private routing, LB, PSC where applicable |
| KVM | Secret Manager + Apigee configuration strategy | Secret Manager, IAM |
| Encrypted KVM | Secret Manager / KMS-backed secret workflow | KMS, Secret Manager |
| Shared Flow | Shared flow | Apigee |
| Flow hook | Flow hook | Apigee |
| API Product | API Product | Apigee |
| Developer | Developer | Apigee |
| Developer App | App / credentials | Apigee |
| OAuth / client cert | Apigee security + certificate strategy | Certificate Manager/CAS/Secret Manager |
| mTLS truststore | Truststore / CA strategy | CAS/Certificate Manager + Apigee |
| Edge hostname | Environment group hostname | DNS + certificate + LB architecture |
| Analytics | Apigee analytics | Logging/Monitoring/SIEM integration |

## KVM migration recommendation

Do not blindly convert every Edge KVM entry into a Google Cloud Secret. First classify each entry:

1. **Secret** — password, token, private key, credential → Secret Manager / secure Apigee mechanism.
2. **Configuration** — URL, feature flag, non-sensitive identifier → Apigee configuration / runtime configuration.
3. **Certificate** — CA/client/server certificate → Certificate Manager/CAS/Apigee keystore/truststore strategy.
4. **Environment-specific value** — keep separate per environment and inject through Terraform/CI/CD.

This prevents a bulk Edge export from accidentally placing sensitive values into Git or Terraform state.
