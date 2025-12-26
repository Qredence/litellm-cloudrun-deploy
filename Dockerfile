FROM docker.litellm.ai/berriai/litellm-database:main-stable

WORKDIR /app

# Copy the cloud-specific configuration
COPY litellm_config_cloud.yaml /app/config.yaml

# Expose the port
EXPOSE 4000

# Run LiteLLM Proxy with the config
# The base image entrypoint handles the python/pipenv setup
CMD ["--config", "/app/config.yaml", "--port", "4000", "--num_workers", "8"]
