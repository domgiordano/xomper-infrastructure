# Xomper Infrastructure

Terraform IaC for Xomper - fantasy football companion at [xomper.xomware.com](https://xomper.xomware.com).

## Xomware Ecosystem

| App | URL | Frontend | Backend | Infrastructure |
|-----|-----|----------|---------|----------------|
| **Xomware** (Hub) | [xomware.com](https://xomware.com) | [xomware-frontend](https://github.com/domgiordano/xomware-frontend) | - | [xomware-infrastructure](https://github.com/domgiordano/xomware-infrastructure) |
| **Xomify** | [xomify.xomware.com](https://xomify.xomware.com) | [xomify-frontend](https://github.com/domgiordano/xomify-frontend) | [xomify-backend](https://github.com/domgiordano/xomify-backend) | [xomify-infrastructure](https://github.com/domgiordano/xomify-infrastructure) |
| **Xomcloud** | [xomcloud.xomware.com](https://xomcloud.xomware.com) | [xomcloud-frontend](https://github.com/domgiordano/xomcloud-frontend) | [xomcloud-backend](https://github.com/domgiordano/xomcloud-backend) | [xomcloud-infrastructure](https://github.com/domgiordano/xomcloud-infrastructure) |
| **Xomper** | [xomper.xomware.com](https://xomper.xomware.com) | [xomper-front-end](https://github.com/domgiordano/xomper-front-end) | [xomper-back-end](https://github.com/domgiordano/xomper-back-end) | [xomper-infrastructure](https://github.com/domgiordano/xomper-infrastructure) |

**Terraform Workspace:** [xomper-infrastructure](https://app.terraform.io/app/Domjgiordano/workspaces/xomper-infrastructure)

## Resources

- **S3 + CloudFront** - Static site hosting via [web-hosting](https://github.com/domgiordano/web-hosting) module (v1.1.0)
- **API Gateway** - REST API via [api-gateway-service](https://github.com/domgiordano/api-gateway-service) module (v2.2.0)
- **WAF** - CloudFront + API Gateway WAFs via [waf](https://github.com/domgiordano/waf) module (v1.1.0)
- **Lambda** - Python 3.13 functions (authorizer, email)
- **DynamoDB** - User data
- **SES** - Email service (noreply@xomper.xomware.com)
- **KMS** - Encryption for S3 and DynamoDB
- **Route53** - DNS records under xomware.com zone
- **ACM** - SSL certificates for web and API subdomains
- **SSM** - Parameter store for secrets
- **CloudWatch** - Lambda and API Gateway logging

## Terraform Cloud

- **Organization:** Domjgiordano
- **Workspace:** xomper-infrastructure
