#!/bin/bash
# TokenRouter - cost calculator
# Estimate your savings with TokenRouter

echo "═══════════════════════════════════════════════"
echo "  TokenRouter — Cost Savings Calculator"
echo "═══════════════════════════════════════════════"
echo

read -p "Current monthly LLM spend ($): " CURRENT
read -p "Number of API calls per month: " CALLS
read -p "Average tokens per call: " TOKENS
read -p "Estimated cache hit ratio (0-100%): " HITRATE
read -p "Estimated template/script match rate (0-100%): " MATCHRATE

# Calculate savings
HIT_SAVINGS=$(echo "$CURRENT * $HITRATE / 100" | bc -l)
MATCH_SAVINGS=$(echo "$CURRENT * $MATCHRATE / 100" | bc -l)
TOTAL_SAVINGS_PCT=$(echo "$HITRATE + $MATCHRATE + 30" | bc -l)  # 30% from batch etc
if (( $(echo "$TOTAL_SAVINGS_PCT > 80" | bc -l) )); then
    TOTAL_SAVINGS_PCT=80
fi

NEW_COST=$(echo "$CURRENT * (100 - $TOTAL_SAVINGS_PCT) / 100" | bc -l)
SAVED=$(echo "$CURRENT - $NEW_COST" | bc -l)

echo
echo "=== Your Estimated Savings ==="
echo "Current monthly cost:    \$$CURRENT"
echo "With TokenRouter:        \$$NEW_COST"
echo "Monthly savings:         \$$SAVED"
echo "Annual savings:          \$$(echo "$SAVED * 12" | bc -l)"
echo "Savings percentage:      ${TOTAL_SAVINGS_PCT}%"
echo
echo "=== Recommended Plan ==="
if (( $(echo "$CALLS < 10000" | bc -l) )); then
    echo "Plan: Free (\$0/mo)"
elif (( $(echo "$CALLS < 100000" | bc -l) )); then
    echo "Plan: Starter (\$29/mo)"
    echo "Net monthly savings after plan: \$$(echo "$SAVED - 29" | bc -l)"
elif (( $(echo "$CALLS < 1000000" | bc -l) )); then
    echo "Plan: Pro (\$99/mo)"
    echo "Net monthly savings after plan: \$$(echo "$SAVED - 99" | bc -l)"
else
    echo "Plan: Enterprise (custom)"
fi
echo
echo "═══════════════════════════════════════════════"