#!/bin/bash
set -e

# Configuration
PROJECT_ID=$(gcloud config get-value project)
REGION="${REGION:-us-central1}"
SERVICE_NAME="litellm-proxy"
IMAGE_NAME="gcr.io/$PROJECT_ID/$SERVICE_NAME"

echo "🚀 Building container image..."
gcloud builds submit --tag $IMAGE_NAME .

echo "🚀 Deploying to Cloud Run..."
# Note: In a real production setup, use Secret Manager for sensitive vars!
# We are using the environment variables currently set in your shell/session.
gcloud run deploy $SERVICE_NAME \
  --image $IMAGE_NAME \
  --platform managed \
  --region $REGION \
  --allow-unauthenticated \
  --memory 4Gi \
  --cpu 2 \
  --port 4000 \
  --update-startup-probe-path="/health/readiness" \
  --update-startup-probe-period=5s \
  --update-startup-probe-failure-threshold=10 \
  --update-liveness-probe-path="/health/liveness" \
  --update-liveness-probe-period=30s \
  --set-env-vars "GOOGLE_CLOUD_PROJECT=$PROJECT_ID" \
  --set-env-vars "VERTEX_LOCATION=$REGION" \
  --set-env-vars "DATABASE_URL=$DATABASE_URL" \
  --set-env-vars "LITELLM_MASTER_KEY=$LITELLM_MASTER_KEY" \
  --set-env-vars "UI_USERNAME=$UI_USERNAME" \
  --set-env-vars "UI_PASSWORD=$UI_PASSWORD" \
  --set-env-vars "STORE_MODEL_IN_DB=$STORE_MODEL_IN_DB" \
  --set-env-vars "LITELLM_SALT_KEY=$LITELLM_SALT_KEY" \
  --set-env-vars "LITELLM_LOG=$LITELLM_LOG" \
  --set-env-vars "LANGFUSE_SECRET_KEY=$LANGFUSE_SECRET_KEY" \
  --set-env-vars "LANGFUSE_PUBLIC_KEY=$LANGFUSE_PUBLIC_KEY" \
  --set-env-vars "LANGFUSE_BASE_URL=$LANGFUSE_BASE_URL" \
  --set-env-vars "CONTEXT7_API_KEY=$CONTEXT7_API_KEY" \
  --set-env-vars "TAVILY_API_KEY=$TAVILY_API_KEY" \
  --set-env-vars "REDIS_HOST=$REDIS_HOST" \
  --set-env-vars "REDIS_PORT=$REDIS_PORT" \
  --set-env-vars "REDIS_PASSWORD=$REDIS_PASSWORD"

echo "✅ Deployment complete!"
