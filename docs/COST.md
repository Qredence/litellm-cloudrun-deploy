# Cost Optimization & Estimations

This guide breaks down the costs associated with running LiteLLM on Google Cloud Run and providing strategies to minimize your monthly spend.

## 1. Google Cloud Run Pricing Model

Cloud Run follows a "pay-as-you-go" model based on four main components:
*   **CPU Allocation**: Charged per vCPU-second.
*   **Memory Allocation**: Charged per GB-second.
*   **Requests**: Charged per million requests.
*   **Networking**: Egress traffic charges.

### CPU Allocation Options
*   **CPU is only allocated during request processing (Default)**: You only pay when LiteLLM is actively handling a request. This is best for low-to-medium traffic.
*   **CPU is always allocated**: You pay for the instance as long as it's running. This is best for high-traffic or when using "Min Instances" to eliminate cold starts.

---

## 2. Configuration Profiles (Monthly Estimates)

Estimates are based on `us-central1` pricing and 100% utilization during "active" hours.

| Profile | CPU / RAM | Best For | Est. Monthly (Active) |
|:--- |:--- |:--- |:--- |
| **Development** | 1 vCPU / 2GB | Testing & Single Users | ~$15 - $30 |
| **Standard Prod** | 2 vCPU / 4GB | Small Teams (Current Config) | ~$60 - $120 |
| **High Performance**| 4 vCPU / 8GB | Enterprise / Heavy RAG | ~$200+ |

*Note: These estimates cover only the Cloud Run compute. Networking and storage are extra.*

---

## 3. Supporting Infrastructure Costs

### Redis (Memorystore)
*   **Standard Tier (1GB)**: ~$35/month.
*   **Cost Impact**: Highly recommended. While it adds a fixed cost, it can reduce your LLM API bill by **30-80%** depending on query redundancy.

### Database (Cloud SQL)
*   **db-f1-micro (Shared CPU)**: ~$9/month.
*   **db-g1-small**: ~$25/month.
*   **Cost Impact**: Required for persistent API keys and logging. The `db-f1-micro` is sufficient for most LiteLLM proxy workloads.

---

## 4. Cost Optimization Strategies

### A. Redis Caching (The "Money Saver")
Caching identical queries at the proxy level means you don't pay the LLM provider (Google, OpenAI, etc.) for those tokens.
*   **Benefit**: 100% savings on cached tokens.
*   **Implementation**: See [CACHING.md](CACHING.md).

### B. Concurrency Tuning
LiteLLM is highly asynchronous. A single 2 vCPU instance can handle **80+ concurrent requests**. 
*   **Optimization**: Ensure your Cloud Run concurrency setting matches your load.
*   **Command**: `gcloud run deploy --concurrency=80` (Default is 80).

### C. Scaling to Zero
If your proxy is only used during business hours, ensure `min-instances` is set to 0.
*   **Savings**: You pay $0 during nights and weekends.
*   **Trade-off**: The first request after a period of inactivity will experience a "cold start" delay (typically 2-4 seconds).

### D. Committed Use Discounts (CUDs)
If you know you will run LiteLLM 24/7, you can purchase a Cloud Run CUD for 1 or 3 years to save **17% to 46%** on compute costs.

---

## 5. Sample Monthly Bill (Small Team)

*   **Cloud Run** (2 vCPU/4GB, medium usage): $45
*   **Cloud SQL** (db-f1-micro): $9
*   **Memorystore Redis** (Basic 1GB): $35
*   **Total**: **~$89/month** (Fixed) + LLM API Usage.

---

Built with ❤️ by [Qredence](https://qredence.ai).
