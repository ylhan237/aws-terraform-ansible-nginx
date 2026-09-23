# Architecture de deploiement

Ce document presente le flux entre le developpeur, GitHub Actions, AWS,
Terraform et Ansible.

## Vue globale

```mermaid
flowchart TB
    DEV[Developpeur] -->|Pull Request| VALIDATE[GitHub Actions - validation]
    DEV -->|Push main| PIPELINE[GitHub Actions - CI/CD]

    VALIDATE --> TF_CHECK[Terraform fmt et validate]
    VALIDATE --> ANSIBLE_CHECK[Ansible syntax check et lint]
    VALIDATE --> YAML_CHECK[YAML lint]

    PIPELINE --> OIDC[GitHub OIDC]
    OIDC --> IAM[IAM deployment role]
    IAM --> TERRAFORM[Terraform]

    TERRAFORM --> VPC[VPC 10.0.0.0/16]
    VPC --> SUBNET[Subnet public 10.0.1.0/24]
    SUBNET --> EC2[EC2 Ubuntu 22.04]
    EC2 --> WEB01[web-01]
    EC2 --> WEB02[web-02]
    EC2 --> WEB03[web-03]
    EC2 --> WEB04[web-04]
    EC2 --> WEB05[web-05]

    TERRAFORM --> OUTPUTS[Terraform outputs - public IPs]
    OUTPUTS --> INVENTORY[Inventaire Ansible temporaire]
    INVENTORY --> ANSIBLE[Ansible via SSH]
    ANSIBLE --> NGINX[Nginx installe et demarre]

    RUNNER[IP publique du runner GitHub] --> SG[Security Group - SSH /32]
    SG --> EC2
```

## Flux de deploiement

1. Une pull request execute uniquement les validations.
2. Un push vers `main` declenche le job de deploiement apres validation.
3. GitHub Actions assume le role IAM AWS via OIDC.
4. Terraform met a jour l'infrastructure et le Security Group.
5. L'IP publique du runner est autorisee temporairement pour SSH.
6. Les IPs publiques Terraform generent l'inventaire Ansible.
7. Ansible se connecte aux instances EC2 et configure Nginx.

## Flux de destruction

```mermaid
flowchart LR
    MANUAL[Run workflow manuel] --> INPUT[action = destroy]
    INPUT --> CONFIRM[confirm_destroy = DESTROY]
    CONFIRM --> PLAN[terraform plan -destroy]
    PLAN --> APPLY[terraform apply destroy.tfplan]
    APPLY --> DELETE[Suppression des ressources AWS]
```

La destruction utilise le meme backend Terraform S3 et l'environnement GitHub
`production`. Elle exige une confirmation explicite afin d'eviter une
suppression accidentelle.

## Flux reseau

- SSH : runner GitHub vers EC2 sur le port `22`, limite a l'IP du runner en
  `/32`.
- HTTP : utilisateurs vers les EC2 sur le port `80`.
- Sorties EC2 : autorisees vers Internet pour l'installation des paquets.
- Etat Terraform : stocke dans le backend S3 avec verrouillage.
