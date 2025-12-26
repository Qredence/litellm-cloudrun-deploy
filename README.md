# LiteLLM Proxy on Google Cloud Run

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Run on Google Cloud](https://deploy.cloud.run/button.svg)](https://deploy.cloud.run)

A production-ready LiteLLM Proxy setup designed for **Google Cloud Run**, featuring Redis caching, Vertex AI integration (Gemini/Moonshot), and secure secret management.

## Features

- **Serverless**: Optimized for Google Cloud Run (2 vCPU, 4GB RAM).
- **Caching**: integrated Redis support for low latency and cost reduction.
- **Security**: Secrets managed via environment variables (no hardcoded credentials).
- **Models**: Pre-configured for Gemini 1.5 Pro/Flash and Kimi (Moonshot AI).
- **Monitoring**: Integration with Langfuse and Context7.

## Quick Start

### Local Development

To run the proxy locally using Docker:

1. **Configure Environment**:
   Copy `.env.example` to `.env` and fill in your keys.

   ```bash
   cp .env.example .env
   ```

2. **Run Docker Container**:

   ```bash
   docker run --name litellm-proxy \
     --env-file .env \
     -p 4000:4000 \
     -v $(pwd)/litellm_config.yaml:/app/config.yaml \
     docker.litellm.ai/berriai/litellm-database:main-stable \
     --config /app/config.yaml --port 4000 --num_workers 8
   ```

3. **Test**:
   ```bash
   curl http://localhost:4000/v1/models
   ```

### Deploy to Cloud Run

**Prerequisites**:

- Google Cloud SDK (`gcloud`) installed and authenticated.
- A Google Cloud Project with Cloud Run enabled.

**Deployment**:
We provide a helper script `deploy_gcloud.sh` that securely injects environment variables and deploys the service.

1. **Set Secrets**: Ensure your `.env` file is populated with production values.
2. **Deploy**:

   ```bash
   # Load env vars
   export $(grep -v '^#' .env | xargs)

   # Run deploy script
   ./deploy_gcloud.sh
   ```

## Configuration

The proxy uses `litellm_config_cloud.yaml` for production. Key settings:

- **Strict Environment Variables**: Sensitive values (Redis host/pass) are read from `os.environ`.
- **Connection Pooling**: Optimized for serverless environments.
- **Logging**: Set to `ERROR` level to reduce noise and costs.

## Permissions

To invoke the service, you need the `roles/run.invoker` permission.

```bash
gcloud run services add-iam-policy-binding litellm-proxy \
    --member="user:YOUR_EMAIL@example.com" \
    --role="roles/run.invoker" \
    --region="us-central1" \
    --project="YOUR_PROJECT_ID"
```
