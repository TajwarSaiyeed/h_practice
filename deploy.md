# Deployment Guide for AWS EC2

This guide outlines the steps to set up your infrastructure on AWS and configure GitHub Actions for automated deployment.

## Phase 1: Launch EC2 Instance

1.  **Login to AWS Console** and search for **EC2**.
2.  Click **Launch Instance**.
3.  **Name and Tags**:
    - Name: `microservices-vps`
4.  **Application and OS Images (AMI)**:
    - Select **Ubuntu**.
    - AMI: **Ubuntu Server 24.04 LTS** (or 22.04 LTS).
5.  **Instance Type**:
    - Select **`t3.medium`** (2 vCPU, 4 GiB Memory).
    - _Warning_: Do not use `t2.micro` (1GB RAM). It is too small for this stack.
6.  **Key Pair (Login)**:
    - Click **Create new key pair**.
    - Name: `aws-deploy-key`.
    - Key pair type: **RSA**.
    - Private key file format: **.pem**.
    - Click **Create key pair**.
    - **Save the file** immediately. You cannot download it again.
7.  **Network Settings**:
    - **Firewall (security groups)**: Select **Create security group**.
    - Check **Allow SSH traffic from** -> **Anywhere** (0.0.0.0/0).
    - Check **Allow HTTP traffic from the internet**.
    - Check **Allow HTTPS traffic from the internet**.
8.  **Configure Storage**:
    - Change `8 GiB` to **`20 GiB`** (gp3). Docker images need space.
9.  **Advanced Details (User Data)**:
    - Scroll down to the bottom **Advanced details** section.
    - Scroll to the very end to **User data**.
    - Paste this script to automatically install Docker:
      ```bash
      #!/bin/bash
      apt-get update
      apt-get upgrade -y
      curl -fsSL https://get.docker.com -o get-docker.sh
      sh get-docker.sh
      usermod -aG docker ubuntu
      sysctl -w vm.max_map_count=262144
      echo "vm.max_map_count=262144" >> /etc/sysctl.conf
      apt-get install -y make
      ```
10. Click **Launch Instance**.

## Phase 2: Security Group Configuration (Ports)

1.  Go to the **EC2 Dashboard** -> **Instances**.
2.  Click on your instance ID.
3.  Click the **Security** tab -> Click the **Security Group** link (e.g., `sg-0123...`).
4.  Click **Edit inbound rules**.
5.  Add the following rules:
    - **Custom TCP** | Port **3000** | Source: `0.0.0.0/0` (Grafana)
    - _(Optional)_ **Custom TCP** | Port **5601** | Source: `0.0.0.0/0` (Kibana)
    - _(Ensure SSH (22) and HTTP (80) are already there)_.
6.  Click **Save rules**.

## Phase 3: Elastic IP (Static IP)

_AWS IPs change if you stop/start the instance. An Elastic IP is static._

1.  Go to **Network & Security** -> **Elastic IPs** (left sidebar).
2.  Click **Allocate Elastic IP address** -> **Allocate**.
3.  Select the new IP address and click **Actions** -> **Associate Elastic IP address**.
4.  **Instance**: Choose your `microservices-vps`.
5.  Click **Associate**.
6.  **Copy this Public IPv4 address**. This is your `HOST`.

## Phase 4: GitHub Configuration

1.  Go to your GitHub Repository.
2.  Navigate to **Settings** > **Secrets and variables** > **Actions**.
3.  Click **New repository secret**.

### Required Secrets

| Secret Name    | Value                                                                                                  |
| :------------- | :----------------------------------------------------------------------------------------------------- |
| `EC2_HOST`     | The **Elastic IP** you allocated in Phase 3.                                                           |
| `EC2_USERNAME` | `ubuntu`                                                                                               |
| `EC2_SSH_KEY`  | Open your `aws-deploy-key.pem` file with a text editor. Copy the **entire** content and paste it here. |

### Application Secrets (From your .env)

Add these based on your project configuration:

- `JWT_SECRET`
- `USER_DB_USER`
- `USER_DB_PASSWORD`
- `POST_DB_USER`
- `POST_DB_PASSWORD`
- `INTERACTION_DB_USER`
- `INTERACTION_DB_PASSWORD`
- `GRAFANA_ADMIN_PASSWORD`
- `RABBITMQ_DEFAULT_USER`
- `RABBITMQ_DEFAULT_PASS`

## Phase 5: Deploy

1.  **Trigger Deployment**:

    - Go to GitHub Actions tab.
    - Select **CD - Deploy to Production**.
    - Click **Run workflow**.

2.  **Verify**:
    - Wait for the action to complete.
    - Visit `http://<YOUR_ELASTIC_IP>/api/users/health`.
