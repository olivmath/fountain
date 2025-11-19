#!/bin/bash

# Master test runner - executes all tests in order

SCRIPT_DIR="$(dirname "$0")"
cd "$SCRIPT_DIR"

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}"
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║         RAYLS STABLECOIN GATEWAY - TEST SUITE                  ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Track test results
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

run_test() {
    local test_script=$1
    local test_name=$2

    echo ""
    echo -e "${BLUE}Running: $test_name${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    if [ -f "$test_script" ]; then
        # Make script executable
        chmod +x "$test_script"

        # Run the test
        if bash "$test_script"; then
            echo -e "${GREEN}✓ $test_name completed${NC}"
            ((TESTS_PASSED++))
        else
            echo -e "${RED}✗ $test_name failed${NC}"
            ((TESTS_FAILED++))
        fi
    else
        echo -e "${RED}✗ $test_script not found${NC}"
        ((TESTS_FAILED++))
    fi

    ((TESTS_RUN++))
}

# Check if API is accessible
echo -e "${BLUE}Checking API connectivity...${NC}"

source "$(dirname "$0")/config.sh"

# Try a simple query to check if API is up
HEALTH_CHECK=$(curl -s -o /dev/null -w "%{http_code}" "${API_URL}/list-client-stablecoins" \
  -H "x-api-key: $API_KEY")

if [ "$HEALTH_CHECK" = "200" ] || [ "$HEALTH_CHECK" = "400" ]; then
    echo -e "${GREEN}✓ API is accessible (HTTP $HEALTH_CHECK)${NC}"
else
    echo -e "${RED}✗ API is not accessible (HTTP $HEALTH_CHECK)${NC}"
    echo -e "${RED}Using URL: ${API_URL}${NC}"
    echo -e "${BLUE}Tip: Use 'deno task serve' for local testing${NC}"
    exit 1
fi

echo ""
echo -e "${BLUE}API Configuration:${NC}"
echo "  URL: $API_URL"
echo "  API Key: ${API_KEY:0:20}..."
echo ""

# Run tests in order
run_test "01-stablecoin-create.sh" "Stablecoin Creation Tests"
run_test "02-deposit-request.sh" "Deposit Request Tests"
run_test "03-withdraw.sh" "Withdraw Tests"
run_test "04-query-functions.sh" "Query Functions Tests"

# Summary
echo ""
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║                     TEST SUMMARY                               ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""
echo "Total Tests Run: $TESTS_RUN"
echo -e "${GREEN}Passed: $TESTS_PASSED${NC}"
if [ $TESTS_FAILED -gt 0 ]; then
    echo -e "${RED}Failed: $TESTS_FAILED${NC}"
fi
echo ""

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}✓ All tests completed successfully!${NC}"
    exit 0
else
    echo -e "${RED}✗ Some tests failed. Review the output above.${NC}"
    exit 1
fi
