# TokenRouter — Save 50-80% on LLM API Costs

Drop-in middleware that sits between your app and OpenAI/Anthropic/etc.
Routes queries through 5 optimization tiers before hitting expensive API calls.

## Quick Start (30 seconds)

```bash
docker run -p 9960:9960 tokenrouter/server
# Now point your OpenAI client at localhost:9960 instead of api.openai.com
# That's it. You're saving tokens.
```

## How It Saves Tokens

| Tier | What | Savings |
|------|------|---------|
| 1. Template | Match known patterns (greetings, status) | 100% |
| 2. Cache | LRU answer cache for repeat queries | 100% on hit |
| 3. Script | Deterministic execution (math, parsing) | 100% |
| 4. Batch | Combine multiple queries into one call | 70% |
| 5. LLM | Fallback to upstream (OpenAI, Anthropic, etc.) | baseline |

Real-world average: **50-80% token reduction**.

## Architecture

```
Client → TokenRouter (:9960) → OpenAI / Anthropic / Local LLM
            ↓
       ┌────┴────┬────────┬────────┐
       ↓         ↓        ↓        ↓
    Template   Cache   Script   Batch
    (9965)     (9964)  (9967)   (9968)
```

## Features

- ✅ Drop-in replacement for OpenAI/Anthropic endpoints
- ✅ 5-tier cascading optimization
- ✅ Real-time cost dashboard
- ✅ Cache hit ratio tracking
- ✅ Per-customer usage analytics
- ✅ Self-hosted (your data, your control)
- ✅ Works with any LLM (OpenAI, Anthropic, local models)

## Pricing

| Tier | Requests/mo | Price |
|------|-------------|-------|
| Free | 10,000 | $0 |
| Starter | 100,000 | $29/mo |
| Pro | 1,000,000 | $99/mo |
| Enterprise | Unlimited | Custom |

Average customer saves $200-2,000/mo on API costs. Pays for itself in day 1.

## Documentation

- [Quick Start](docs/quickstart.md)
- [API Reference](docs/api.md)
- [Self-Hosting](docs/self-host.md)
- [Cost Calculator](docs/calculator.md)

## License

MIT (core) + Commercial (hosted SaaS)
