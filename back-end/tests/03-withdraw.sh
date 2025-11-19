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

print_header "WITHDRAW TEST"

if [ -z "$ERC20_ADDRESS" ]; then
    print_error "ERC20_ADDRESS not set"
    exit 1
fi

print_info "Using stablecoin: $STABLECOIN_ID"
print_info "Using ERC20 Address: $ERC20_ADDRESS"

# Test 1: Valid withdraw request
print_header "Test 1: Create valid withdraw request"
WITHDRAW_DATA=$(cat <<EOF
{
  "stablecoin_address": "$ERC20_ADDRESS",
  "amount": 50,
  "pix_address": "email@example.com"
}
EOF
)

print_info "Creating withdraw request with:"
echo "$WITHDRAW_DATA" | jq '.'

RESPONSE=$(api_call "POST" "withdraw" "$WITHDRAW_DATA")
print_info "Response:"
format_json "$RESPONSE"

# Save operation_id
WITHDRAW_OPERATION_ID=$(echo "$RESPONSE" | jq -r '.operation_id' 2>/dev/null)

if [ "$WITHDRAW_OPERATION_ID" != "null" ] && [ ! -z "$WITHDRAW_OPERATION_ID" ]; then
    print_success "Withdraw request created: $WITHDRAW_OPERATION_ID"
    echo "export WITHDRAW_OPERATION_ID='$WITHDRAW_OPERATION_ID'" >> "$(dirname "$0")/operation.env"
else
    print_error "Failed to create withdraw request"
    format_json "$RESPONSE"
fi

# Test 2: Invalid stablecoin address
print_header "Test 2: Invalid stablecoin address"
INVALID_ADDR=$(cat <<EOF
{
  "stablecoin_address": "0x0000000000000000000000000000000000000000",
  "amount": 50,
  "pix_address": "email@example.com"
}
EOF
)

RESPONSE=$(api_call "POST" "withdraw" "$INVALID_ADDR")
if echo "$RESPONSE" | grep -q "not found\|Stablecoin"; then
    print_success "Correctly rejected invalid stablecoin address"
else
    print_error "Should have rejected invalid stablecoin address"
    format_json "$RESPONSE"
fi

# Test 3: Negative amount
print_header "Test 3: Negative amount"
NEGATIVE_DATA=$(cat <<EOF
{
  "stablecoin_address": "$ERC20_ADDRESS",
  "amount": -100,
  "pix_address": "email@example.com"
}
EOF
)

RESPONSE=$(api_call "POST" "withdraw" "$NEGATIVE_DATA")
if echo "$RESPONSE" | grep -q "amount\|positive\|invalid\|Validation"; then
    print_success "Correctly rejected negative amount"
else
    print_error "Should have rejected negative amount"
    format_json "$RESPONSE"
fi

# Test 4: Missing pix_address
print_header "Test 4: Missing pix_address"
MISSING_PIX=$(cat <<EOF
{
  "stablecoin_address": "$ERC20_ADDRESS",
  "amount": 50
}
EOF
)

RESPONSE=$(api_call "POST" "withdraw" "$MISSING_PIX")
if echo "$RESPONSE" | grep -q "pix_address\|Validation"; then
    print_success "Correctly rejected missing pix_address"
else
    print_error "Should have rejected missing pix_address"
    format_json "$RESPONSE"
fi

# Test 5: Invalid PIX address format
print_header "Test 5: Valid PIX address formats"
VALID_PIX_FORMATS=(
    "email@example.com"
    "12345678901234567890123456"  # CPF
    "+5512999999999"  # Phone
    "key-uuid-1234"  # UUID key
)

for pix_addr in "${VALID_PIX_FORMATS[@]}"; do
    WITHDRAW_DATA=$(cat <<EOF
{
  "stablecoin_address": "$ERC20_ADDRESS",
  "amount": 10,
  "pix_address": "$pix_addr"
}
EOF
)

    RESPONSE=$(api_call "POST" "withdraw" "$WITHDRAW_DATA")
    if echo "$RESPONSE" | jq -e '.operation_id' > /dev/null 2>&1; then
        print_success "PIX format accepted: $pix_addr"
    else
        print_info "PIX format response: $pix_addr"
        format_json "$RESPONSE"
    fi
done

# Test 6: Large withdraw amount (may fail on blockchain)
print_header "Test 6: Large withdraw amount"
LARGE_WITHDRAW=$(cat <<EOF
{
  "stablecoin_address": "$ERC20_ADDRESS",
  "amount": 999999999,
  "pix_address": "email@example.com"
}
EOF
)

RESPONSE=$(api_call "POST" "withdraw" "$LARGE_WITHDRAW")
print_info "Large withdraw response (may fail on blockchain):"
format_json "$RESPONSE"

print_header "WITHDRAW TESTS COMPLETED"
