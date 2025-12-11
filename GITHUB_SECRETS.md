# GitHub Actions Secrets Configuration

This document explains which GitHub Secrets you need to add for the CI/CD workflows.

## 🔐 Required Secrets

### Where to Add Secrets:
1. Go to your GitHub repository
2. Click **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Add each secret below

---

## 📋 Secrets Needed

### ✅ **CI Workflow (ci.yml)** - NO SECRETS REQUIRED
The CI workflow runs automatically on every push/PR and doesn't need any secrets. It will:
- Run tests
- Build Docker images
- Scan for security issues

---

### 🚀 **CD Workflow (deploy.yml)** - REQUIRED FOR DEPLOYMENT

Add these secrets when you're ready to deploy to EC2:

#### **EC2 Connection Secrets**

| Secret Name | Description | Example/How to Get |
|------------|-------------|-------------------|
| `EC2_HOST` | Your EC2 public IP or domain | `54.123.456.789` or `yourdomain.com` |
| `EC2_USERNAME` | SSH username (usually `ubuntu` or `ec2-user`) | `ubuntu` |
| `EC2_SSH_KEY` | Your EC2 private key | Copy entire content of your `.pem` file |

**How to get EC2_SSH_KEY:**
```bash
cat your-ec2-key.pem
# Copy the entire output including:
# -----BEGIN RSA PRIVATE KEY-----
# ... content ...
# -----END RSA PRIVATE KEY-----
```

#### **Database Secrets**

| Secret Name | Description | Example |
|------------|-------------|---------|
| `USER_DB_USER` | PostgreSQL user for user-service | `postgres` or `userdb_admin` |
| `USER_DB_PASSWORD` | PostgreSQL password for user-service | `your-strong-password-123` |
| `POST_DB_USER` | PostgreSQL user for post-service | `postgres` or `postdb_admin` |
| `POST_DB_PASSWORD` | PostgreSQL password for post-service | `your-strong-password-456` |
| `INTERACTION_DB_USER` | PostgreSQL user for interaction-service | `postgres` or `interactiondb_admin` |
| `INTERACTION_DB_PASSWORD` | PostgreSQL password for interaction-service | `your-strong-password-789` |

#### **Application Secrets**

| Secret Name | Description | Example |
|------------|-------------|---------|
| `JWT_SECRET` | Secret key for JWT tokens | `super-secret-jwt-key-change-in-production-xyz123` |
| `GRAFANA_PASSWORD` | Grafana admin password | `your-grafana-password` |

**Generate a strong JWT_SECRET:**
```bash
# On Linux/Mac:
openssl rand -base64 32

# On Windows (PowerShell):
[Convert]::ToBase64String((1..32 | ForEach-Object { Get-Random -Minimum 0 -Maximum 256 }))
```

---

### 🐳 **Docker Build Workflow (docker-build.yml)** - NO MANUAL SECRETS NEEDED

This workflow uses `GITHUB_TOKEN` which is automatically provided by GitHub Actions.
It will push images to GitHub Container Registry (ghcr.io).

---

## 📝 Quick Setup Checklist

### For CI Only (No Deployment):
- ✅ Just push to GitHub - CI runs automatically
- ✅ No secrets needed

### For Full CI/CD (With Deployment):
- [ ] Set up EC2 instance
- [ ] Install Docker on EC2
- [ ] Install Docker Compose on EC2
- [ ] Generate SSH key pair for EC2
- [ ] Add all secrets listed above to GitHub
- [ ] Enable deploy.yml workflow (uncomment the push trigger)
- [ ] Push to main branch to trigger deployment

---

## 🔒 Security Best Practices

1. **Never commit secrets to Git**
   - Use `.env` files (already in `.gitignore`)
   - Only use GitHub Secrets for sensitive data

2. **Use strong passwords**
   - Minimum 16 characters
   - Mix of letters, numbers, symbols
   - Different password for each database

3. **Rotate secrets regularly**
   - Change JWT_SECRET every 90 days
   - Update database passwords quarterly

4. **Limit SSH access**
   - Only allow GitHub Actions IP (optional)
   - Use SSH key, not password
   - Disable root login

---

## 🎯 What Each Workflow Does

### **ci.yml** (Runs on every push/PR)
```
✓ Tests user-service
✓ Tests post-service  
✓ Lints code
✓ Builds Docker images
✓ Scans for security issues
✓ NO DEPLOYMENT - safe to run anytime
```

### **deploy.yml** (Manual or on push to main)
```
✓ Creates production .env file
✓ Copies code to EC2 via SSH
✓ Runs database migrations
✓ Restarts Docker containers
✓ Runs health checks
✓ ONLY runs when you trigger it
```

### **docker-build.yml** (Manual or on release)
```
✓ Builds Docker images
✓ Pushes to GitHub Container Registry
✓ Tags with version numbers
✓ Multi-platform builds (amd64/arm64)
```

---

## 🚀 How to Use

### Step 1: Test CI Locally
```bash
# CI will run automatically when you push
git add .
git commit -m "Add GitHub Actions"
git push origin main
```
Check GitHub Actions tab to see CI running!

### Step 2: When Ready to Deploy
1. Set up your EC2 instance
2. Add all the secrets listed above
3. Go to GitHub → Actions → "CD - Deploy to Production"
4. Click "Run workflow" to deploy manually

OR

5. Uncomment the `push:` trigger in `deploy.yml`
6. Now it auto-deploys on every push to main

---

## 📞 Need Help?

- **CI failing?** Check the Actions tab for error logs
- **Deployment failing?** Verify all secrets are added correctly
- **Docker build issues?** Make sure Dockerfiles are present in each service

---

## 🎉 Summary

**Right Now (No Setup Needed):**
- ✅ CI workflow will run on every push
- ✅ Tests your code automatically
- ✅ No secrets required

**When You're Ready to Deploy:**
- Add the 11 secrets listed above
- Trigger manual deployment
- Your app goes live on EC2!

**Secrets to Add (11 total):**
1. EC2_HOST
2. EC2_USERNAME  
3. EC2_SSH_KEY
4. USER_DB_USER
5. USER_DB_PASSWORD
6. POST_DB_USER
7. POST_DB_PASSWORD
8. INTERACTION_DB_USER
9. INTERACTION_DB_PASSWORD
10. JWT_SECRET
11. GRAFANA_PASSWORD
