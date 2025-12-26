# Caching Architecture

Caching is critical for reducing LLM latency and significantly cutting API costs.

## Redis Configuration

We use **Standard Redis** for response caching. The configuration is dynamic and relies on the following environment variables:

- `REDIS_HOST`: Your Redis endpoint (e.g., `redis-12345.c1.us-central1-2.gce.cloud.redislabs.com`).
- `REDIS_PORT`: The Redis port (default `6379`).
- `REDIS_PASSWORD`: Authentication secret.

### config.yaml setup

```yaml
litellm_settings:
  cache: True
  cache_params:
    type: redis
    host: os.environ/REDIS_HOST
    port: os.environ/REDIS_PORT
    password: os.environ/REDIS_PASSWORD
```

## Cache Verification

To verify the cache is connected, use the internal ping endpoint:

```bash
curl -X GET "https://YOUR_PROXY_URL/cache/ping" \
     -H "Authorization: Bearer YOUR_MASTER_KEY"
```

## Benefits

- **Sub-100ms Responses**: Identical queries reach the cache instead of the model.
- **Cost Savings**: Cached tokens are free.
- **Rate Limit Buffer**: Reduces the number of requests sent to the LLM provider.
