"""Core TokenRouter: 5-tier routing for LLM API cost optimization.

Tiers:
  1. Cache hit (0 tokens)
  2. Template match (0 tokens)
  3. Local small model (cheap, ~1B params)
  4. Distilled model (medium, ~7B params)
  5. Frontier model (expensive, GPT-4/Claude)
"""
import hashlib
import time
import json
from typing import Optional, Dict, Any

class TokenRouter:
    """Routes LLM queries through 5 optimization tiers."""

    def __init__(self, cache=None, templates=None, local_client=None,
                 distilled_client=None, frontier_client=None):
        self.cache = cache or {}
        self.templates = templates or {}
        self.local_client = local_client
        self.distilled_client = distilled_client
        self.frontier_client = frontier_client
        self.stats = {'hits': 0, 'misses': 0, 'total_saved': 0}

    def route(self, query: str, context: Optional[Dict] = None) -> Dict[str, Any]:
        """Route a query through 5 tiers."""
        context = context or {}
        start = time.time()

        # Tier 1: Cache hit
        qhash = hashlib.sha256(query.encode()).hexdigest()
        if qhash in self.cache:
            self.stats['hits'] += 1
            return {'response': self.cache[qhash], 'tier': 'cache',
                    'latency_ms': int((time.time()-start)*1000),
                    'cost_saved_pct': 100}

        # Tier 2: Template match
        for template_id, template_fn in self.templates.items():
            if template_fn(query):
                result = template_fn(query)
                self.cache[qhash] = result
                self.stats['hits'] += 1
                return {'response': result, 'tier': 'template',
                        'tier_name': template_id,
                        'latency_ms': int((time.time()-start)*1000),
                        'cost_saved_pct': 100}

        # Tier 3: Local small model (cheap)
        if self.local_client and context.get('complexity') in ['simple', 'low']:
            try:
                resp = self.local_client(query)
                self.cache[qhash] = resp
                self.stats['hits'] += 1
                return {'response': resp, 'tier': 'local_small',
                        'latency_ms': int((time.time()-start)*1000),
                        'cost_saved_pct': 90}
            except Exception:
                pass

        # Tier 4: Distilled model (medium)
        if self.distilled_client and context.get('complexity') in ['medium', 'moderate']:
            try:
                resp = self.distilled_client(query)
                self.cache[qhash] = resp
                self.stats['hits'] += 1
                return {'response': resp, 'tier': 'distilled',
                        'latency_ms': int((time.time()-start)*1000),
                        'cost_saved_pct': 70}
            except Exception:
                pass

        # Tier 5: Frontier model (expensive fallback)
        if self.frontier_client:
            resp = self.frontier_client(query)
            self.cache[qhash] = resp
            self.stats['misses'] += 1
            return {'response': resp, 'tier': 'frontier',
                    'latency_ms': int((time.time()-start)*1000),
                    'cost_saved_pct': 0}

        # No client available
        self.stats['misses'] += 1
        return {'response': None, 'tier': 'none',
                'error': 'no client available'}

    def get_stats(self):
        total = self.stats['hits'] + self.stats['misses']
        hit_rate = (self.stats['hits'] / total * 100) if total else 0
        return {**self.stats, 'total': total, 'hit_rate_pct': round(hit_rate, 2)}