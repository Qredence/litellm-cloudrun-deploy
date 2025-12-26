# Quick Start Guide

This guide helps you deploy LiteLLM Proxy to Google Cloud Run in minutes.

## Prerequisites

1. **Google Cloud Account**
   - [Create a free account](https://cloud.google.com/free) with $300 credit
   - Enable billing for your project

2. **Prepare Required Services**
   - **PostgreSQL Database**: Have a connection string ready
     - Option: Cloud SQL (see Production guide)
     - Option: External PostgreSQL service

   - **Redis Cache**: Have Redis credentials ready
     - Option: Cloud Memorystore (see Production guide)
     - Option: External Redis service

3. **Generate Required Keys**
   - LITELLM_MASTER_KEY: Generate a secure key with `sk-` prefix
     ```bash
     openssl rand -hex 32 | sed 's/^/sk-/'
     ```
   - LITELLM_SALT_KEY: Generate a secure key with `sk-` prefix
     ```bash
     openssl rand -hex 32 | sed 's/^/sk-/'
     ```
   - UI_PASSWORD: Choose a strong password

## Step 1: Click to Deploy

Click the button below to open the deployment wizard:

[![Run on Google Cloud](https://deploy.cloud.run/button.svg)](https://deploy.cloud.run?git_repo=https://github.com/qredence/litellm-cloudrunner)

## Step 2: Configure Deployment

The deployment wizard will guide you through:

### a. Select Project
- Choose your Google Cloud project
- Click "Next"

### b. Configure Service
- Service name: `litellm-proxy` (pre-filled)
- Region: Choose a region near you (e.g., `us-central1`)
- Click "Next"

### c. Configure Environment Variables
You'll be prompted for these required variables:

| Variable | Description | Example |
|----------|-------------|---------|
| `DATABASE_URL` | PostgreSQL connection string | `postgresql://user:pass@host:5432/dbname` |
| `LITELLM_MASTER_KEY` | Master API key (auto-generated) | `sk-abc123...` |
| `LITELLM_SALT_KEY` | Encryption key (auto-generated) | `sk-def456...` |
| `UI_PASSWORD` | UI password | `SecurePass123!` |
| `REDIS_HOST` | Redis host address | `10.0.0.5` |
| `REDIS_PASSWORD` | Redis password | `YourRedisPass` |

**Note:** Optional variables like `LANGFUSE_*`, `CONTEXT7_API_KEY`, and `TAVILY_API_KEY` can be left blank.

### d. Review and Deploy
- Review your configuration
- Click "Deploy"
- Wait 3-5 minutes for build and deployment

## Step 3: Access Your Service

Once deployment completes, you'll receive:
- **Service URL**: Click to access the LiteLLM Proxy
- **Service Name**: `litellm-proxy`
- **Region**: The region you selected

### Test the Service

**Check Health:**
```bash
curl https://YOUR_SERVICE_URL/health
```

**Test with curl:**
```bash
curl -X POST https://YOUR_SERVICE_URL/v1/chat/completions \
  -H "Authorization: Bearer sk-MASTER_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "gemini-3-flash-preview",
    "messages": [{"role": "user", "content": "Hello!"}]
  }'
```

## Step 4: Configure Access Control (Recommended)

### Add Specific Users
```bash
gcloud run services add-iam-policy-binding litellm-proxy \
  --member="user:your-email@example.com" \
  --role="roles/run.invoker" \
  --region="us-central1"
```

### Make Service Private
```bash
gcloud run services update litellm-proxy \
  --region="us-central1" \
  --no-allow-unauthenticated
```

## What's Next?

- **Configure Models**: Add your model API keys in the LiteLLM config
- **Set Up Observability**: Integrate Langfuse, Context7, and Tavily
- **Enable Caching**: Verify Redis caching is working (see CACHING.md)
- **Production Deployment**: Migrate to Secret Manager (see PRODUCTION-SECRETS.md)

## Troubleshooting

### Deployment Failed
- Check the Cloud Build logs in Google Cloud Console
- Verify your environment variables are correctly formatted

### Service Returns 401 Unauthorized
- Ensure you're using to `LITELLM_MASTER_KEY` in the Authorization header
- Format: `Authorization: Bearer sk-MASTER_KEY`

### Service Returns 500 Internal Server Error
- Check Cloud Run logs: `gcloud run services logs tail litellm-proxy --region=us-central1`
- Verify DATABASE_URL and REDIS_HOST are correct

### Cannot Connect to Database/Redis
- Ensure your database and Redis instances allow connections from Cloud Run
- Check network settings and VPC configuration

## Need Help?

- Review [Production Best Practices](PRODUCTION.md)
- Check [Caching Implementation Guide](CACHING.md)
- Visit the [LiteLLM Documentation](https://docs.litellm.ai/)
