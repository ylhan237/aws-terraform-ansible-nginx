# CI/CD Terraform + Ansible

Cette pipeline GitHub Actions valide Terraform et Ansible sur chaque pull request.
Un push vers `main` déclenche ensuite le déploiement dans l'environnement protégé
`production` :

1. `terraform plan`
2. `terraform apply`
3. génération de l'inventaire Ansible depuis les sorties Terraform
4. déploiement de Nginx avec Ansible

## Configuration GitHub

Créer les éléments suivants dans le dépôt :

- le secret `AWS_ROLE_ARN`, contenant l'ARN d'un rôle AWS assumable par GitHub
	Actions via OIDC ;
- le secret `ANSIBLE_SSH_PRIVATE_KEY`, contenant la clé privée OpenSSH non
	chiffrée du key pair EC2, avec ses lignes `BEGIN` et `END` conservées ;
- la variable `TF_KEY_NAME`, contenant le nom du key pair EC2 AWS ;
- un environnement GitHub nommé `production`, idéalement avec une approbation
	obligatoire avant le job `deploy`.

La pipeline détecte automatiquement l'IP publique du runner GitHub et limite
l'accès SSH à cette IP en `/32` avant le déploiement Ansible. La variable
`TF_ALLOWED_SSH_CIDR` reste utile uniquement pour un déploiement local.

Le rôle AWS doit limiter sa confiance au dépôt et à la branche `main`, et ses
permissions doivent être limitées aux ressources Terraform nécessaires.

Le backend Terraform S3 doit exister avant le premier déploiement et doit être
protégé avec le verrouillage et le chiffrement côté AWS.

## Déclenchement

- Pull request : contrôles uniquement, aucune modification AWS.
- Push sur `main` : plan, apply et déploiement Ansible.
- Exécution manuelle : choisir `deploy` ou `destroy` depuis l'onglet **Actions**.

Pour supprimer l'infrastructure manuellement, choisir `destroy` et saisir
exactement `DESTROY` dans le champ de confirmation. Le job utilise un plan
Terraform de destruction avant l'application et l'environnement `production`
peut imposer une approbation manuelle supplémentaire.
