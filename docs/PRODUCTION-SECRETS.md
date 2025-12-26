# Production Deployment with Secret Manager

This guide explains how to upgrade your LiteLLM deployment to use Google Secret Manager for secure secret management.

## Why Use Secret Manager?

- **Security**: Secrets are encrypted at rest and in transit
- **Audit Trail**: Complete visibility into who accessed which secrets and when
- **IAM Control**: Fine-grained access control using standard Google Cloud IAM roles
- **Versioning**: Automatic versioning with rollback capability
- **Compliance**: Meets enterprise security requirements

## Before You Begin

1. Enable the Secret Manager API:
   ```bash
   gcloud services enable secretmanager.googleapis.com
   ```

2. Verify you have the following IAM roles:
   - `roles/secretmanager.admin` (or `roles/secretmanager.secretAdmin`)
   - `roles/run.developer`

## Step 1: Create Secrets

Create each secret using the following commands:

### Database Connection
```bash
gcloud secrets create database-url \
  --data-file=<(echo -n "postgresql://user:password@host:5432/dbname")
```

### LiteLLM Authentication
```bash
gcloud secrets create litellm-master-key \
  --data-file=<(echo -n "sk-your-master-key-here")

gcloud secrets create litellm-salt-key \
  --data-file=<(echo -n "sk-your-salt-key-here")
```

### UI Credentials
```bash
gcloud secrets create ui-username \
  --data-file=<(echo -n "admin")

gcloud secrets create ui-password \
  --data-file=<(echo -n "your-secure-password")
```

### Redis Configuration
```bash
gcloud secrets create redis-host \
  --data-file=<(echo -n "your-redis-host")

gcloud secrets create redis-password \
  --data-file=<(echo -n "your-redis-password")
```

### Optional Observability Keys
```bash
gcloud secrets create langfuse-secret-key \
  --data-file=<(echo -n "sk-lf-your-key")

gcloud secrets create langfuse-public-key \
  --data-file=<(echo -n "pk-lf-your-key")

gcloud secrets create context7-api-key \
  --data-file=<(echo -n "ctx7sk-your-key")

gcloud secrets create tavily-api-key \
  --data-file=<(echo -n "tvly-your-key")
```

## Step 2: Grant Cloud Run Service Account Access

Find your Cloud Run service's service account:
```bash
gcloud run services describe litellm-proxy \
  --region=us-central1 \
  --format="value(spec.template.spec.serviceAccountName)"
```

Grant the service account access to secrets:
```bash
PROJECT_ID="your-project-id"
SERVICE_ACCOUNT=$(gcloud run services describe litellm-proxy \
  --region=us-central1 \
  --format="value(spec.template.spec.serviceAccountName)")

# Grant secret accessor role
gcloud secrets add-iam-policy-binding database-url \
  --member="serviceAccount:$SERVICE_ACCOUNT" \
  --role="roles/secretmanager.secretAccessor"

# Repeat for all secrets
for secret in litellm-master-key litellm-salt-key ui-password redis-password \
              langfuse-secret-key langfuse-public-key context7-api-key tavily-api-key; do
  gcloud secrets add-iam-policy-binding $secret \
    --member="serviceAccount:$SERVICE_ACCOUNT" \
    --role="roles/secretmanager.secretAccessor"
done
```

## Step 3: Deploy with Secret Manager References

Update your deployment to reference secrets:

### Option A: Using deploy_gcloud.sh
```bash
# Add secret references to deploy_gcloud.sh
gcloud run deploy litellm-proxy \
  --image gcr.io/$PROJECT_ID/litellm-proxy \
  --platform managed \
  --region us-central1 \
  --memory 4Gi \
  --cpu 2 \
  --port 4000 \
  --set-secrets=DATABASE_URL=database-url:latest \
  --set-secrets=LITELLM_MASTER_KEY=litellm-master-key:latest \
  --set-secrets=LITELLM_SALT_KEY=litellm-salt-key:latest \
  --set-secrets=UI_USERNAME=ui-username:latest \
  --set-secrets=UI_PASSWORD=ui-password:latest \
  --set-secrets=REDIS_HOST=redis-host:latest \
  --set-secrets=REDIS_PASSWORD=redis-password:latest \
  --set-secrets=LANGFUSE_SECRET_KEY=langfuse-secret-key:latest \
  --set-secrets=LANGFUSE_PUBLIC_KEY=langfuse-public-key:latest \
  --set-secrets=CONTEXT7_API_KEY=context7-api-key:latest \
  --set-secrets=TAVILY_API_KEY=tavily-api-key:latest \
  --set-env-vars=STORE_MODEL_IN_DB=True \
  --set-env-vars=LITELLM_LOG=INFO \
  --set-env-vars=REDIS_PORT=6379 \
  --set-env-vars=LANGFUSE_BASE_URL=https://cloud.langfuse.com \
  --allow-unauthenticated
```

### Option B: Using Cloud Console
1. Go to Cloud Run service
2. Click "Edit & Deploy New Revision"
3. Scroll to "Variables & Secrets"
4. For each secret:
   - Click "Reference a secret"
   - Select the secret
   - Set the environment variable name
5. Click Deploy

## Step 4: Remove Environment Variables

After verifying deployment works:

```bash
# Remove old environment variables
gcloud run services update litellm-proxy \
  --region=us-central1 \
  --clear-env-vars \
  --update-secrets DATABASE_URL=database-url:latest,LITELLM_MASTER_KEY=litellm-master-key:latest,...
```

## Managing Secrets

### List All Secrets
```bash
gcloud secrets list
```

### View Secret Details
```bash
gcloud secrets describe database-url
```

### Access Secret Value
```bash
gcloud secrets versions access latest --secret=database-url
```

### Update a Secret
```bash
echo -n "new-value" | gcloud secrets versions add database-url --data-file=-
```

### Delete a Secret
```bash
# Disable secret first (required)
gcloud secrets versions disable latest --secret=database-url

# Then delete
gcloud secrets delete database-url
```

### Rotate Secrets
```bash
# Add new version
echo -n "new-secret-value" | gcloud secrets versions add litellm-master-key --data-file=-

# Grant new version access (automatically inherits latest version)
gcloud run services update litellm-proxy \
  --region=us-central1 \
  --update-secrets=LITELLM_MASTER_KEY=litellm-master-key:latest
```

## Setting Up Database & Redis

### Option A: Cloud SQL (PostgreSQL)
```bash
# Create Cloud SQL instance
gcloud sql instances create litellm-db \
  --tier=db-f1-micro \
  --region=us-central1 \
  --database-version=POSTGRES_15

# Create database
gcloud sql databases create litellm --instance=litellm-db

# Create user
gcloud sql users create litellm --instance=litellm-db --password=secure-password

# Get connection string
gcloud sql instances describe litellm-db --format="value(connectionName)"
```

### Option B: Cloud Memorystore (Redis)
```bash
# Create Memorystore instance
gcloud redis instances create litellm-redis \
  --region=us-central1 \
  --tier=STANDARD \
  --memory-size-gb=1 \
  --redis-version=redis_7_2

# Get connection host
gcloud redis instances describe litellm-redis \
  --region=us-central1 \
  --format="value(host)"
```

## Security Best Practices

1. **Use Principle of Least Privilege**
   - Grant `roles/secretmanager.secretAccessor` only to service accounts that need it
   - Avoid using `roles/secretmanager.admin` in production

2. **Rotate Secrets Regularly**
   - Create new secret versions periodically
   - Update Cloud Run to use latest version

3. **Monitor Secret Access**
   - Enable Secret Manager audit logs
   - Set up alerts for unauthorized access attempts

4. **Use Secret Versioning**
   - Always reference specific versions when possible
   - Use `latest` only during migrations

## Troubleshooting

### "Permission denied" error
```bash
# Verify service account has correct IAM role
gcloud secrets get-iam-policy database-url
```

### "Secret not found" error
```bash
# Verify secret exists
gcloud secrets list
```

### Service fails to start
```bash
# Check logs
gcloud run services logs tail litellm-proxy --region=us-central1

# Verify secret values are correct
gcloud secrets versions access latest --secret=database-url
```

### IAM changes not taking effect
```bash
# IAM changes can take 2-5 minutes to propagate
# Try redeploying the service
gcloud run services update litellm-proxy --region=us-central1
```

## Additional Resources

- [Secret Manager Documentation](https://cloud.google.com/secret-manager/docs)
- [Secret Manager with Cloud Run](https://cloud.google.com/run/docs/configuring/secrets)
- [Cloud SQL Integration](https://cloud.google.com/sql/docs/postgres/connect-run)
- [Cloud Memorystore Integration](https://cloud.google.com/memorystore/docs/redis/connect-run-instance)
