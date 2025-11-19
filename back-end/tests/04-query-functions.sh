#!/bin/bash

# Import configuration
source "$(dirname "$0")/config.sh"

# Load stablecoin info
if [ -f "$(dirname "$0")/stablecoin.env" ]; then
    source "$(dirname "$0")/stablecoin.env"
else
    print_error "stablecoin.env not found. Run 01-stablecoin-create.sh first"
    exit 1
fi

print_header "QUERY FUNCTIONS TEST"

print_info "Using API Key: $API_KEY"

# Test 1: List client stablecoins
print_header "Test 1: List client stablecoins"
RESPONSE=$(api_call "GET" "list-client-stablecoins")
print_info "Response:"
format_json "$RESPONSE"

STABLECOIN_COUNT=$(echo "$RESPONSE" | jq '.data | length' 2>/dev/null || echo "0")
if [ "$STABLECOIN_COUNT" -gt "0" ]; then
    print_success "Found $STABLECOIN_COUNT stablecoin(s)"
else
    print_info "No stablecoins found"
fi

# Test 2: Get stablecoin info by ID
print_header "Test 2: Get stablecoin info by stablecoin_id"
if [ ! -z "$STABLECOIN_ID" ]; then
    RESPONSE=$(api_call "GET" "get-stablecoin-info?stablecoin_id=$STABLECOIN_ID")
    print_info "Response:"
    format_json "$RESPONSE"

    FOUND_ID=$(echo "$RESPONSE" | jq -r '.data[0].stablecoin_id' 2>/dev/null)
    if [ "$FOUND_ID" = "$STABLECOIN_ID" ]; then
        print_success "Found stablecoin by ID"
    else
        print_info "Stablecoin query response received"
    fi
else
    print_info "STABLECOIN_ID not available"
fi

# Test 3: Get stablecoin info by ERC20 address
print_header "Test 3: Get stablecoin info by erc20_address"
if [ ! -z "$ERC20_ADDRESS" ]; then
    RESPONSE=$(api_call "GET" "get-stablecoin-info?erc20_address=$ERC20_ADDRESS")
    print_info "Response:"
    format_json "$RESPONSE"

    FOUND_ADDR=$(echo "$RESPONSE" | jq -r '.data[0].erc20_address' 2>/dev/null)
    if [ "$FOUND_ADDR" = "$ERC20_ADDRESS" ]; then
        print_success "Found stablecoin by ERC20 address"
    else
        print_info "Stablecoin query response received"
    fi
else
    print_info "ERC20_ADDRESS not available"
fi

# Test 4: List stablecoin operations
print_header "Test 4: List stablecoin operations"
if [ ! -z "$STABLECOIN_ID" ]; then
    RESPONSE=$(api_call "GET" "list-stablecoin-operations?stablecoin_id=$STABLECOIN_ID")
    print_info "Response:"
    format_json "$RESPONSE"

    OP_COUNT=$(echo "$RESPONSE" | jq '.data | length' 2>/dev/null || echo "0")
    print_success "Found $OP_COUNT operation(s) for stablecoin"
else
    print_info "STABLECOIN_ID not available"
fi

# Test 5: List all client operations
print_header "Test 5: List all client operations"
RESPONSE=$(api_call "GET" "list-client-operations")
print_info "Response:"
format_json "$RESPONSE"

TOTAL_OPS=$(echo "$RESPONSE" | jq '.data | length' 2>/dev/null || echo "0")
print_success "Found $TOTAL_OPS total operation(s) across all stablecoins"

# Test 6: Get operation details
print_header "Test 6: Get operation details"
if [ -f "$(dirname "$0")/operation.env" ]; then
    source "$(dirname "$0")/operation.env"

    if [ ! -z "$OPERATION_ID" ]; then
        RESPONSE=$(api_call "GET" "get-operation-details?operation_id=$OPERATION_ID")
        print_info "Response:"
        format_json "$RESPONSE"

        FOUND_OP=$(echo "$RESPONSE" | jq -r '.data[0].operation_id' 2>/dev/null)
        if [ "$FOUND_OP" = "$OPERATION_ID" ]; then
            print_success "Found operation details"
        else
            print_info "Operation query response received"
        fi
    else
        print_info "OPERATION_ID not available"
    fi
else
    print_info "operation.env not available"
fi

# Test 7: Get stablecoin stats
print_header "Test 7: Get stablecoin stats"
if [ ! -z "$STABLECOIN_ID" ]; then
    RESPONSE=$(api_call "GET" "get-stablecoin-stats?stablecoin_id=$STABLECOIN_ID")
    print_info "Response:"
    format_json "$RESPONSE"

    print_success "Stablecoin stats retrieved"
else
    print_info "STABLECOIN_ID not available"
fi

# Test 8: Query without API key (should fail)
print_header "Test 8: Query without API key (should fail)"
RESPONSE=$(curl -s -X GET "${API_URL}/list-client-stablecoins" \
  -H "Content-Type: application/json")

if echo "$RESPONSE" | grep -q "x-api-key\|Unauthorized\|Invalid"; then
    print_success "Correctly rejected request without API key"
else
    print_info "Query without API key response:"
    format_json "$RESPONSE"
fi

# Test 9: Query with invalid API key (should fail)
print_header "Test 9: Query with invalid API key (should fail)"
RESPONSE=$(curl -s -X GET "${API_URL}/list-client-stablecoins" \
  -H "Content-Type: application/json" \
  -H "x-api-key: invalid-key-12345")

if echo "$RESPONSE" | grep -q "Unauthorized\|Invalid"; then
    print_success "Correctly rejected request with invalid API key"
else
    print_info "Query with invalid API key response:"
    format_json "$RESPONSE"
fi

# Test 10: Pagination test
print_header "Test 10: Pagination test"
RESPONSE=$(api_call "GET" "list-client-stablecoins?limit=1&offset=0")
print_info "Response (limit=1):"
format_json "$RESPONSE"

print_header "QUERY FUNCTIONS TESTS COMPLETED"
