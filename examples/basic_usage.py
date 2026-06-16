"""Basic TokenRouter usage example."""
import sys
import json
sys.path.insert(0, '..')
from tokenrouter import TokenRouter

def main():
    # Simple cache-only router (no clients needed)
    router = TokenRouter(cache={
        'hash1': 'Cached answer for "what is X?"',
    }, templates={
        'greeting': lambda q: 'hello' in q.lower() and (lambda: 'Hi there!'),
    })

    # Route a query
    print("=== Basic Usage ===")
    result = router.route("hello there")
    print(f"Response: {result['response']}")
    print(f"Tier: {result['tier']}")
    print(f"Cost saved: {result['cost_saved_pct']}%")

    # Stats
    print("\n=== Stats ===")
    print(json.dumps(router.get_stats(), indent=2))

if __name__ == '__main__':
    main()