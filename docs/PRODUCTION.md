# Production Best Practices

To ensure stability and performance, this repository follows LiteLLM and Cloud Run best practices.

## 1. Machine Level Recommendation

We use **2 vCPU** and **4GB RAM**. This allows the container to handle high throughput and background tasks like database connection pooling without bottlenecking.

## 2. Worker Configuration

The `Dockerfile` is configured with `--num_workers 8`.

- In a production environment, matching uvicorn workers to CPU resource allocation prevents context switching overhead.
- We avoid dynamic `$(nproc)` in serverless environments for more predictable startup times.

## 3. Database Connection Pooling

In `litellm_config_cloud.yaml`, we set:

```yaml
general_settings:
  database_connection_pool_limit: 20
```

This limits the number of active connections to the database per instance, preventing connection exhaustion on serverless scales.

## 4. Monitoring & Observability

- **Langfuse**: Integration is enabled via environment variables for tracing and spend tracking.
- **Context7**: Documentation and context retrieval integration.
- **Tavily**: Search grounding enabled.

## 5. Security

- **Salt Key**: `LITELLM_SALT_KEY` is used to encrypt database values (keys/configs stored in DB).
- **Master Key**: Use `LITELLM_MASTER_KEY` starting with `sk-` for all proxy API calls.
- **IAM Roles**: Use `roles/run.invoker` for precise access control instead of making the service public.
