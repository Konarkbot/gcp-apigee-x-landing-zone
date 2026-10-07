# Target Landing Zone Architecture

```text
                           INTERNET / CLIENTS
                                   |
                           [Cloud Armor]
                                   |
                    [External HTTPS Load Balancer]
                                   |
                              [Apigee X]
                           /       |       \
                          /        |        \
                         /         |         \
                  GCP backend   AWS backend   outbound web APIs
                       |            |                |
                 Internal LB   Cross-Cloud       Secure Web Proxy
                       |        Interconnect          |
                       |            |              Cloud NAT
                       |         Equinix               |
                       +------------+------------------+
                                    |
                              GCP Landing Zone
                                    |
                  +-----------------+------------------+
                  |                 |                  |
                 VPC          Cloud Router          Cloud DNS
                  |                 |
             Service Networking     +-- Partner Interconnect
                  |                 +-- Cross-Cloud Interconnect
             Apigee runtime
             private peering
```

## Layer responsibilities

### 1. VPC / Service Networking

The VPC is the shared network boundary for the migration. Apigee X uses Service Networking and an authorized VPC network. A reserved VPC peering range is created so Apigee runtime connectivity does not collide with application CIDRs.

### 2. Cloud Router

Cloud Router is the dynamic routing control plane for BGP-based hybrid/multicloud connectivity. Partner Interconnect and Cross-Cloud Interconnect parameters are intentionally not hard-coded because the provider/Equinix pairing values are environment-specific.

### 3. Secure Web Proxy

SWP is the controlled HTTP/S egress checkpoint. The default policy in this repository is deny-all. Approved domains are added through `swp_allowed_domains`.

SWP can be deployed in explicit routing or next-hop routing mode. The repo uses explicit routing by default. Google documents next-hop mode as an alternative when routing should direct traffic to the SWP instead of configuring clients individually. citeturn0search17

### 4. Apigee X

The Apigee module creates:

- Apigee organization
- Runtime instance
- Development/test/production-style environments as configured
- Environment group
- Environment-to-instance attachments

API proxy bundles are intentionally excluded from the landing-zone state. They should live in a separate migration/configuration layer so application teams can version API artifacts independently.

### 5. Security

KMS and Secret Manager are foundation services. Certificate Manager/CAS should be connected to the production certificate strategy after the enterprise CA design is confirmed.

### 6. Observability

A project log bucket and audit log sink are created. Network flow logging is enabled on private workload subnets.

## Network CIDR planning

The example CIDRs are placeholders only. Before deployment, the network team should validate them against:

- enterprise on-prem CIDRs
- AWS VPC CIDRs
- Equinix/partner ranges
- Apigee reserved peering range
- Apigee runtime `/22`
- PSC ranges if later introduced
- load-balancer proxy-only ranges
- SWP subnets

Never reuse an overlapping RFC1918 range across these domains.
