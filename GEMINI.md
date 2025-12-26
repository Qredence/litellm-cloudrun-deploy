# LiteLLM Cloud Run Deployment

## Project Overview
This project provides a high-performance, cost-optimized deployment of LiteLLM Proxy on Google Cloud Run. It is designed for enterprise applications requiring model routing, Redis-based caching, and observability.

## Key Technologies
- **LiteLLM**: A proxy server for multiple LLM providers.
- **Google Cloud Run**: Serverless container hosting.
- **Redis**: High-performance caching for cost and latency optimization.
- **Vertex AI**: Primary provider for Gemini and Moonshot models.
- **Docker**: For containerized deployment.
- **Google Cloud Build**: Automated container builds.

## Building and Running

### Local Development
To run the proxy locally using Docker:
1. Create a `.env` file from `.env.example`.
2. Execute the following command:
   ```bash
   docker run --name litellm-proxy \
     --env-file .env \
     -p 4000:4000 \
     -v $(pwd)/litellm_config.yaml:/app/config.yaml \
     docker.litellm.ai/berriai/litellm-database:main-stable \
     --config /app/config.yaml --port 4000 --num_workers 8
   ```

### Cloud Deployment
The project includes an automated deployment script `deploy_gcloud.sh`.
1. Ensure you are authenticated with `gcloud auth login`.
2. Set your active project: `gcloud config set project qlaus-398610`.
3. Run the script:
   ```bash
   ./deploy_gcloud.sh
   ```
   *Note: This script builds the image via Cloud Build and deploys to Cloud Run with environment variables from your session.*

## Development Conventions

### Configuration Files
- `litellm_config.yaml`: Used for local testing with manual key injection.
- `litellm_config_cloud.yaml`: Optimized for Cloud Run; utilizes `os.environ` for secrets.

### Infrastructure Specs (Cloud Run)
- **Resources**: 2 vCPU / 4GB RAM.
- **Workers**: 8 workers (`--num_workers 8`) to match uvicorn to CPU allocation.
- **Database Pooling**: Limit set to 20 to prevent connection exhaustion.

### Observability & Caching
- **Observability**: Pre-configured for Langfuse (tracing), Context7, and Tavily (search).
- **Caching**: Redis is required for production caching. Configure via `REDIS_HOST`, `REDIS_PORT`, and `REDIS_PASSWORD`.

## Security
- Secrets should be managed via Google Secret Manager in production (see `docs/PRODUCTION-SECRETS.md`).
- `LITELLM_SALT_KEY` is used for internal database encryption.
- Use `LITELLM_MASTER_KEY` for authenticated proxy access.
