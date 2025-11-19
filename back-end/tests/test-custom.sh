#!/bin/bash

# Custom test - allows testing with custom values
# Usage: ./test-custom.sh [endpoint] [method] [data]
# Example: ./test-custom.sh stablecoin-create POST '{"client_name":"Test","symbol":"BRL","client_wallet":"0x1234...","webhook":"http://example.com","total_supply":1000000}'

source "$(dirname "$0")/config.sh"

# Show usage if no arguments
if [ $# -lt 1 ]; then
    print_header "CUSTOM API TEST"
    echo ""
    echo "Usage:"
    echo "  $0 [endpoint] [method] [data]"
    echo ""
    echo "Examples:"
    echo "  # Create stablecoin"
    echo "  $0 stablecoin-create POST '{\"client_name\":\"Test\",\"symbol\":\"BRL\",\"client_wallet\":\"0x1234567890123456789012345678901234567890\",\"webhook\":\"http://example.com\",\"total_supply\":1000000}'"
    echo ""
    echo "  # Get client stablecoins"
    echo "  $0 list-client-stablecoins GET"
    echo ""
    echo "  # Request deposit"
    echo "  $0 deposit-request POST '{\"stablecoin_id\":\"ID\",\"amount\":100}'"
    echo ""
    echo "  # Withdraw"
    echo "  $0 withdraw POST '{\"stablecoin_address\":\"0x...\",\"amount\":50,\"pix_address\":\"email@example.com\"}'"
    echo ""
    echo "Configuration:"
    echo "  API_URL: $API_URL"
    echo "  API_KEY: ${API_KEY:0:20}..."
    echo ""
    exit 0
fi

ENDPOINT=$1
METHOD=${2:-POST}
DATA=$3

print_header "CUSTOM API TEST"
echo ""
print_info "Endpoint: $ENDPOINT"
print_info "Method: $METHOD"
print_info "URL: ${API_URL}/${ENDPOINT}"
echo ""

if [ ! -z "$DATA" ]; then
    print_info "Request Body:"
    echo "$DATA" | jq '.' 2>/dev/null || echo "$DATA"
    echo ""
fi

print_info "Making request..."
echo ""

if [ -z "$DATA" ]; then
    RESPONSE=$(api_call "$METHOD" "$ENDPOINT")
else
    RESPONSE=$(api_call "$METHOD" "$ENDPOINT" "$DATA")
fi

print_info "Response:"
echo ""
format_json "$RESPONSE"
echo ""

# Try to extract useful info
if echo "$RESPONSE" | jq -e '.stablecoin_id' > /dev/null 2>&1; then
    STABLECOIN_ID=$(echo "$RESPONSE" | jq -r '.stablecoin_id')
    print_success "Stablecoin ID: $STABLECOIN_ID"
fi

if echo "$RESPONSE" | jq -e '.erc20_address' > /dev/null 2>&1; then
    ERC20_ADDRESS=$(echo "$RESPONSE" | jq -r '.erc20_address')
    print_success "ERC20 Address: $ERC20_ADDRESS"
fi

if echo "$RESPONSE" | jq -e '.operation_id' > /dev/null 2>&1; then
    OPERATION_ID=$(echo "$RESPONSE" | jq -r '.operation_id')
    print_success "Operation ID: $OPERATION_ID"
fi

if echo "$RESPONSE" | jq -e '.error' > /dev/null 2>&1; then
    ERROR=$(echo "$RESPONSE" | jq -r '.error')
    print_error "Error: $ERROR"
fi
