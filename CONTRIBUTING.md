# Contributing to LiteLLM Proxy

We welcome contributions! Please follow these guidelines to ensure a smooth process.

## Getting Started

1.  **Fork** the repository on GitHub.
2.  **Clone** your fork locally.
3.  **Create a Branch** for your feature or fix (`git checkout -b feature/amazing-feature`).

## Development

- Use the provided `docker run` command in `README.md` to test locally.
- Ensure `litellm_config.yaml` is valid before committing.
- Do not commit `.env` files or secrets.

## Pull Requests

1.  Push your branch to GitHub.
2.  Open a Pull Request against the `main` branch.
3.  Describe your changes clearly and link to any relevant issues.

## Deploying Updates

If your PR involves configuration changes, verify them by deploying to a staging Cloud Run service if possible:

```bash
./deploy_gcloud.sh
```
