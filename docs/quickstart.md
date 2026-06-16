# TokenRouter — Quickstart

## What Is This?

Drop-in middleware that sits between your app and any LLM provider (OpenAI, Anthropic, local). It routes queries through 5 optimization tiers before hitting the expensive API call.

**Average savings: 50-80% on token costs.**

## 30-Second Install

### Option A: Docker (recommended)
```bash
docker run -d -p 9960:9960 --name tokenrouter tokenrouter/server
```

### Option B: PyPI (Python)
```bash
pip install tokenrouter
tokenrouter --port 9960
```

### Option C: From source
```bash
git clone https://github.com/qq-army/tokenrouter
cd tokenrouter
pip install -r requirements.txt
python3 server.py
```

## 60-Second Integration

Change ONE line in your code:

```python
# Before
import openai
openai.api_base = "https://api.openai.com/v1"

# After
import openai
openai.api_base = "http://localhost:9960/v1"  # Same API, just routed through TokenRouter
```

That's it. Every request to OpenAI now goes through 5 optimization tiers automatically.

## What Happens Behind the Scenes

```
Your code → TokenRouter (localhost:9960) → Upstream LLM (OpenAI, etc.)
                  ↓
            ┌─────┴─────┬────────┬────────┐
            ↓           ↓        ↓        ↓
         Template    Cache    Script    Batch
         (0 token)  (0 token) (0 token) (-70%)
            ↓
         (if all miss)
            ↓
         Upstream LLM
```

**Tier 1 - Template Match**: Known patterns (greetings, status) → instant 0-token response
**Tier 2 - Answer Cache**: LRU cache → 0 tokens on hit
**Tier 3 - Script Runner**: Math, parsing, deterministic ops → 0 tokens (local exec)
**Tier 4 - Batch LLM**: Combine queries → -70% tokens
**Tier 5 - LLM Fallback**: Only when needed → baseline cost

## Test It (Live Demo)

```bash
# Try the route endpoint
curl http://localhost:9960/route?q=hello
# → {"route": "template", "saved_tokens": 100, ...}

# Try a script
curl -X POST http://localhost:9967/run \
  -H 'Content-Type: application/json' \
  -d '{"script": "result = sum([1,2,3,4,5])"}'
# → {"ok": true, "result": 15}

# Check your savings
curl http://localhost:9964/health
# → {"hits": 7, "miss": 4, "tokens_saved": 1400, "hit_ratio": 0.6364}
```

## Configuration

Environment variables:
- `OPENAI_API_KEY` — your upstream key (required for Tier 5)
- `CACHE_SIZE` — LRU cache size (default 1000)
- `TEMPLATE_DIR` — path to template files (default `./templates`)
- `LOG_LEVEL` — debug/info/warn (default info)

## Pricing (Hosted Version)

| Tier | Requests/mo | Price |
|------|-------------|-------|
| Free | 10,000 | $0 |
| Starter | 100,000 | $29/mo |
| Pro | 1,000,000 | $99/mo |
| Enterprise | Unlimited | Custom |

Self-hosted is free forever (MIT license).

## What's Next?

- See [API Reference](docs/api.md) for full endpoint docs
- See [Self-Hosting](docs/self-host.md) for production deployment
- See [Cost Calculator](docs/calculator.md) for your savings estimate

## Support

- GitHub Issues: https://github.com/qq-army/tokenrouter/issues
- Email: 247658430@qq.com
- Discord: (coming soon)