# EpicBook — Ansible Configuration Management

This repository contains the Ansible playbooks, roles, and Azure DevOps pipeline for configuring and deploying the EpicBook application onto Azure infrastructure provisioned by the [infra-epicbook](https://github.com/Pradeepneela-github/infra-epicbook) Terraform repository.

---

## What This Repo Does

Once the infrastructure (VMs, networking, MySQL) is live in Azure, this repo takes over and handles everything at the OS and application level:

- Installs system packages and Node.js on both VMs
- Clones the EpicBook application code onto the backend VM
- Configures environment variables and starts the app as a systemd service
- Creates the MySQL application user and seeds the database
- Installs and configures Nginx on the frontend VM as a reverse proxy

---

## Repository Structure

```
theepicbook/
├── azure-pipelines.yml              # Azure DevOps app pipeline
├── README.md
└── ansible/
    ├── inventory.ini                # Server inventory (IPs injected by pipeline)
    ├── site.yml                     # Master playbook — runs all roles in order
    ├── group_vars/
    │   └── web.yml                  # Shared variables for all hosts
    └── roles/
        ├── common/                  # Base setup: packages, Node.js, PyMySQL
        ├── epicbook/                # App clone, .env, systemd service
        ├── mysql/                   # DB user creation, schema, seeding
        └── nginx/                   # Reverse proxy configuration
```

---

## Prerequisites

Before running this pipeline, the following must already be in place:

- Infra pipeline (`infra-epicbook`) has run successfully and provisioned:
  - Frontend VM with a public IP
  - Backend VM with a private IP
  - Azure MySQL Flexible Server with its FQDN
- Azure DevOps `ansible-secrets` variable group is populated with:
  - `APP_PUBLIC_IP`
  - `BACKEND_PRIVATE_IP`
  - `MYSQL_FQDN`
  - `MYSQL_ADMIN_PASSWORD`
  - `APP_DB_PASSWORD`
- SSH private key (`epicbook-ssh-key`) is uploaded to Azure DevOps Secure Files
- Self-hosted agent pool `epicbook-agents` is online (Mac agent with Ansible installed)

---

## Ansible Roles

### common
Runs on all servers. Installs base packages, PyMySQL, and Node.js 18 via the NodeSource repository. Uses `get_url` and `command` modules instead of `curl | bash` to comply with ansible-lint rules.

### epicbook
Runs on the backend VM. Clones the EpicBook application repository, installs npm dependencies, creates the `.env` file from a Jinja2 template, and registers the app as a systemd service so it starts automatically on reboot.

### mysql
Runs on the backend VM. Connects to Azure MySQL Flexible Server over SSL, creates the application database user (`bookuser`) with limited privileges, applies the database schema, and seeds author and book data — but only if the table is empty (idempotent check prevents duplicate inserts on re-runs).

### nginx
Runs on the frontend VM. Installs Nginx, deploys a reverse proxy virtual host configuration that forwards port 80 traffic to the Node.js app on port 3000, and removes the default Nginx site to avoid port conflicts.

---

## Pipeline Stages

The Azure DevOps pipeline (`azure-pipelines.yml`) runs three stages in order:

**Stage 1 — PrepareEnvironment**
Verifies Ansible is available on the self-hosted agent and installs the `community.mysql` and `community.general` Ansible Galaxy collections required by the MySQL role.

**Stage 2 — DeployEpicBook**
Downloads the SSH private key from Azure DevOps Secure Files, injects the real IP addresses and MySQL FQDN into the inventory file using `sed`, tests SSH connectivity to the frontend VM, and runs the full Ansible playbook with database passwords passed securely via `--extra-vars`.

**Stage 3 — VerifyDeployment**
Sends an HTTP request to the frontend public IP and checks for a 200 response. Fails the pipeline loudly if the app is not reachable, ensuring deployment problems are caught immediately.

---

## How IPs and FQDN Flow into Ansible

The `inventory.ini` and `group_vars/web.yml` files use placeholder strings that the pipeline replaces at runtime:

```
REPLACE_WITH_FRONTEND_IP       → real frontend public IP from Terraform output
REPLACE_WITH_BACKEND_PRIVATE_IP → real backend private IP from Terraform output
REPLACE_WITH_MYSQL_FQDN        → real MySQL FQDN from Terraform output
```

These values are stored in the `ansible-secrets` variable group in Azure DevOps Library and must be updated after each infra pipeline run.

---

## How to Run Locally (for testing)

```bash
# Install required collections
ansible-galaxy collection install community.mysql
ansible-galaxy collection install community.general

# Update inventory.ini with real IPs manually
# Then run the playbook
cd ansible/
ansible-playbook -i inventory.ini site.yml \
  --private-key ~/.ssh/epicbook \
  --extra-vars "db_password=YOUR_ADMIN_PASS app_db_password=YOUR_APP_PASS" \
  -v
```

---

## Related Repository

| Repo | Purpose |
|---|---|
| [infra-epicbook](https://github.com/Pradeepneela-github/infra-epicbook) | Terraform — provisions Azure VMs, VNet, MySQL |
| [theepicbook](https://github.com/Pradeepneela-github/theepicbook) | Ansible — configures servers and deploys the app |

---

## Tech Stack

- **Ansible** — configuration management and application deployment
- **Azure DevOps Pipelines** — CI/CD automation
- **Azure VM** — Ubuntu 22.04 LTS Gen2 (frontend and backend)
- **Azure MySQL Flexible Server** — managed database (MySQL 8.0)
- **Nginx** — reverse proxy on the frontend VM
- **Node.js 18** — application runtime on the backend VM
- **systemd** — process management for the Node.js app

---

## Author

Pradeep Kumar Neelaboyina — W13-A4 Capstone Project