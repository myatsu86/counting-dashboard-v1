# Counting Dashboard Infrastructure (Terraform)

This project provisions AWS infrastructure using **Terraform (Infrastructure as Code)** and deploys two applications:

- **Dashboard Service** (public subnet)
- **Counting Service** (private subnet)

The dashboard service communicates with the counting service using **private networking within the VPC**.

---

## 📐 Architecture Overview

- **VPC** with public and private subnets
- **Internet Gateway** for public access
- **NAT Gateway + Elastic IP** for private subnet outbound access
- **EC2 Instances**
  - Dashboard (public subnet)
  - Counting (private subnet)
- **Security Groups**
  - SSH access control
  - App-to-app communication (port 9000)

---

## 🔗 Network Flow

```text
Internet
   │
   ▼
[Internet Gateway]
   │
   ▼
[Public Subnet]
   └── Dashboard EC2 (public IP)
            │
            ▼
      (Private IP communication)
            │
            ▼
[Private Subnet]
   └── Counting EC2 (no public IP)
            │
            ▼
      [NAT Gateway + EIP]
            │
            ▼
         Internet (outbound only)