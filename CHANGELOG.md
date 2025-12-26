# Changelog

All notable changes to this project will be documented in this file.

## [1.0.0] - 2025-12-26

### Added

- **Production Deployment**: Cloud Run configuration with 2 vCPU and 4GB RAM.
- **Redis Caching**: Standard Redis integration for response caching.
- **Security**: Environment variable injection for all sensitive credentials (removing hardcoded secrets).
- **Integrations**: Support for Langfuse, Context7, and Tavily.
- **Pipelines**: `deploy_gcloud.sh` script for streamlined deployment.
