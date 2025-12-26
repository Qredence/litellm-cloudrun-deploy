# litellm-cloudrun-deploy 🚀

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Build Status](https://img.shields.io/badge/Build-Cloud%20Run-blue?logo=google-cloud)](https://cloud.google.com)
[![Documentation](https://img.shields.io/badge/Docs-Internal-green)](docs/)

A high-performance, cost-optimized LiteLLM Proxy deployment for **Google Cloud Run**. This setup is designed for enterprise-grade applications requiring model routing, caching, and observability.

## 🌟 Key Features

- **Scalable Serverless**: Deploys to Google Cloud Run with optimized 2 vCPU / 4GB RAM specs.
- **Enterprise Caching**: Built-in **Redis** integration for sub-second latent responses and heavy cost savings.
- **Full Observability**: Pre-configured for **Langfuse**, **Context7**, and **Tavily**.
- **Secure by Default**:
  - Zero hardcoded secrets (Env-var injection).
  - Encrypted database storage with custom salt keys.
  - IAM-based invocation control.
- **Multi-Model Support**: Gemini 1.5 Pro/Flash, Moonshot Kimi, and more.

## 🚀 Quick Start

### 1. Local Run (Docker)

Ensure you have Docker installed and a `.env` file based on `.env.example`.

```bash
docker run --name litellm-proxy \
  --env-file .env \
  -p 4000:4000 \
  -v $(pwd)/litellm_config.yaml:/app/config.yaml \
  docker.litellm.ai/berriai/litellm-database:main-stable \
  --config /app/config.yaml --port 4000 --num_workers 8
```

### 2. One-Click Deploy to Cloud Run

[![](https://deploy.cloud.run/button.svg)](https://deploy.cloud.run)

_(Note: Ensure your Google Cloud project is active and billing is enabled)_

### 3. CLI Deployment

We use a streamlined deployment script for production updates.

```bash
# Load your secrets
export $(grep -v '^#' .env | xargs)

# Deploy to Cloud Run
./deploy_gcloud.sh
```

## 📖 Documentation

- [**Production Best Practices**](docs/PRODUCTION.md) - Learn about our worker and machine optimizations.
- [**Caching Implementation**](docs/CACHING.md) - How to configure and verify Redis caching.
- [**Deployment Logic**](deploy_gcloud.sh) - Deep dive into the automated deployment script.

## 🛠 Configuration

The core configuration is split into two files:

- `litellm_config.yaml`: Used for local testing with dummy or temporary keys.
- `litellm_config_cloud.yaml`: Optimized for Cloud Run, reading secrets from `os.environ`.

## 🔒 Permissions

Grant access to the service using the Google Cloud SDK:

```bash
gcloud run services add-iam-policy-binding litellm-proxy \
    --member="user:NAME@DOMAIN.COM" \
    --role="roles/run.invoker" \
    --region="us-central1" \
    --project="YOUR_PROJECT_ID"
```

---

Built with ❤️ by [Qredence](https://qredence.ai).
