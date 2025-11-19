#!/bin/bash

# Import configuration
source "$(dirname "$0")/config.sh"

print_header "STABLECOIN CREATE TEST"

SYMBOL="TBR${RANDOM}"

# Test 1: Valid stablecoin creation
print_header "Test 1: Create valid stablecoin"
STABLECOIN_DATA=$(cat <<EOF
{
  "client_name": "Test Corretora",
  "symbol": "$SYMBOL",
  "client_wallet": "0x1234567890123456789012345678901234567890",
  "webhook": "https://webhook.example.com/events",
  "total_supply": 1000000,
  "cpf_cnpj": "52998224725"
}
EOF
)

print_info "Creating stablecoin with:"
echo "$STABLECOIN_DATA" | jq '.'

RESPONSE=$(api_call "POST" "stablecoin-create" "$STABLECOIN_DATA")
print_info "Response:"
format_json "$RESPONSE"

# Save stablecoin_id for later tests
STABLECOIN_ID=$(echo "$RESPONSE" | jq -r '.stablecoin_id' 2>/dev/null)
ERC20_ADDRESS=$(echo "$RESPONSE" | jq -r '.erc20_address' 2>/dev/null)

if [ "$STABLECOIN_ID" != "null" ] && [ ! -z "$STABLECOIN_ID" ]; then
    print_success "Stablecoin created: $STABLECOIN_ID"
    print_success "ERC20 Address: $ERC20_ADDRESS"

    # Save to file for other tests
    echo "export STABLECOIN_ID='$STABLECOIN_ID'" > "$(dirname "$0")/stablecoin.env"
    echo "export ERC20_ADDRESS='$ERC20_ADDRESS'" >> "$(dirname "$0")/stablecoin.env"
else
    print_error "Failed to create stablecoin"
    exit 1
fi

# Test 2: Invalid symbol (too long)
print_header "Test 2: Invalid symbol (> 10 chars)"
INVALID_DATA=$(cat <<EOF
{
  "client_name": "Test Corretora",
  "symbol": "VERYLONGSYMBOL",
  "client_wallet": "0x1234567890123456789012345678901234567890",
  "webhook": "https://webhook.example.com/events",
  "total_supply": 1000000
}
EOF
)

RESPONSE=$(api_call "POST" "stablecoin-create" "$INVALID_DATA")
if echo "$RESPONSE" | grep -q "Invalid symbol"; then
    print_success "Correctly rejected invalid symbol"
else
    print_error "Should have rejected invalid symbol"
fi

# Test 3: Invalid wallet address
print_header "Test 3: Invalid wallet address"
INVALID_WALLET=$(cat <<EOF
{
  "client_name": "Test Corretora",
  "symbol": "TESTBRL2",
  "client_wallet": "invalid-address",
  "webhook": "https://webhook.example.com/events",
  "total_supply": 1000000
}
EOF
)

RESPONSE=$(api_call "POST" "stablecoin-create" "$INVALID_WALLET")
if echo "$RESPONSE" | grep -q "Invalid client_wallet"; then
    print_success "Correctly rejected invalid wallet"
else
    print_error "Should have rejected invalid wallet"
fi

# Test 4: Missing total_supply
print_header "Test 4: Missing total_supply"
MISSING_SUPPLY=$(cat <<EOF
{
  "client_name": "Test Corretora",
  "symbol": "TESTBRL3",
  "client_wallet": "0x1234567890123456789012345678901234567890",
  "webhook": "https://webhook.example.com/events"
}
EOF
)

RESPONSE=$(api_call "POST" "stablecoin-create" "$MISSING_SUPPLY")
if echo "$RESPONSE" | grep -q "total_supply"; then
    print_success "Correctly rejected missing total_supply"
else
    print_error "Should have rejected missing total_supply"
fi

# Test 5: Missing API key
print_header "Test 5: Missing API key"
RESPONSE=$(curl -s -X POST "${API_URL}/stablecoin-create" \
  -H "Content-Type: application/json" \
  -d '{"client_name":"Test","symbol":"TEST","client_wallet":"0x1234567890123456789012345678901234567890","webhook":"http://example.com","total_supply":1000}')

if echo "$RESPONSE" | grep -q "x-api-key"; then
    print_success "Correctly rejected request without API key"
else
    print_error "Should have rejected request without API key"
fi

print_header "STABLECOIN CREATE TESTS COMPLETED"
