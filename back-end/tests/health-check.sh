#!/bin/bash

# Health check - verifies API and database are healthy

source "$(dirname "$0")/config.sh"

print_header "API HEALTH CHECK"
echo ""

# Check API connectivity
print_info "Checking API connectivity..."
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "${API_URL}/list-client-stablecoins" \
  -H "x-api-key: $API_KEY")

if [ "$HTTP_CODE" = "200" ]; then
    print_success "API is accessible (HTTP $HTTP_CODE)"
else
    print_error "API returned HTTP $HTTP_CODE"
    echo "  URL: $API_URL"
fi

# Check database connectivity
print_info "Checking database connectivity..."
DB_CHECK=$(api_call "GET" "list-client-stablecoins")

if echo "$DB_CHECK" | jq -e '.data' > /dev/null 2>&1 || echo "$DB_CHECK" | grep -q "data"; then
    print_success "Database is accessible"
else
    print_error "Database connection failed"
    format_json "$DB_CHECK"
fi

# Check API key
print_info "Checking API key..."
RESPONSE=$(api_call "GET" "list-client-stablecoins")

if echo "$RESPONSE" | jq -e '.data' > /dev/null 2>&1; then
    print_success "API key is valid"
else
    if echo "$RESPONSE" | grep -q "Unauthorized\|Invalid\|x-api-key"; then
        print_error "API key is invalid or missing"
    fi
fi

# Get stats
print_info "Retrieving database statistics..."
echo ""

RESPONSE=$(api_call "GET" "list-client-stablecoins")
STABLECOIN_COUNT=$(echo "$RESPONSE" | jq '.data | length' 2>/dev/null || echo "0")

RESPONSE=$(api_call "GET" "list-client-operations")
OPERATION_COUNT=$(echo "$RESPONSE" | jq '.data | length' 2>/dev/null || echo "0")

echo "Database Statistics:"
echo "  Stablecoins: $STABLECOIN_COUNT"
echo "  Operations: $OPERATION_COUNT"

# Version info
print_info "API Configuration:"
echo "  URL: $API_URL"
echo "  API Key: ${API_KEY:0:20}..."
echo ""

# Check required environment variables
print_info "Environment Variables:"

if [ ! -z "$BLOCKCHAIN_RPC_URL" ]; then
    print_success "BLOCKCHAIN_RPC_URL is set"
else
    print_error "BLOCKCHAIN_RPC_URL is not set"
fi

if [ ! -z "$FACTORY_CONTRACT_ADDRESS" ]; then
    print_success "FACTORY_CONTRACT_ADDRESS is set"
else
    print_error "FACTORY_CONTRACT_ADDRESS is not set"
fi

if [ ! -z "$OWNER_ADDRESS" ]; then
    print_success "OWNER_ADDRESS is set"
else
    print_error "OWNER_ADDRESS is not set"
fi

if [ ! -z "$ASAAS_API_KEY" ]; then
    print_success "ASAAS_API_KEY is set"
else
    print_error "ASAAS_API_KEY is not set (required for deposits/withdrawals)"
fi

echo ""
print_header "HEALTH CHECK COMPLETE"
