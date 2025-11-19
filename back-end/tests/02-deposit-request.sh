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

print_header "DEPOSIT REQUEST TEST"

if [ -z "$STABLECOIN_ID" ]; then
    print_error "STABLECOIN_ID not set"
    exit 1
fi

print_info "Using stablecoin: $STABLECOIN_ID"

# Test 1: Valid deposit request
print_header "Test 1: Create valid deposit request"
DEPOSIT_DATA=$(cat <<EOF
{
  "stablecoin_id": "$STABLECOIN_ID",
  "amount": 100,
  "cpf_cnpj": "52998224725"
}
EOF
)

print_info "Creating deposit request with:"
echo "$DEPOSIT_DATA" | jq '.'

RESPONSE=$(api_call "POST" "deposit-request" "$DEPOSIT_DATA")
print_info "Response:"
format_json "$RESPONSE"

# Save operation_id for later tests
OPERATION_ID=$(echo "$RESPONSE" | jq -r '.operation_id' 2>/dev/null)
QRCODE_PAYLOAD=$(echo "$RESPONSE" | jq -r '.qrcode.payload' 2>/dev/null)

if [ "$OPERATION_ID" != "null" ] && [ ! -z "$OPERATION_ID" ]; then
    print_success "Deposit requested: $OPERATION_ID"
    print_info "QR Code Payload: ${QRCODE_PAYLOAD:0:50}..."

    # Save to file
    echo "export OPERATION_ID='$OPERATION_ID'" > "$(dirname "$0")/operation.env"
    echo "export QRCODE_PAYLOAD='$QRCODE_PAYLOAD'" >> "$(dirname "$0")/operation.env"
else
    print_error "Failed to create deposit request"
    format_json "$RESPONSE"
    exit 1
fi

# Test 2: Invalid stablecoin_id
print_header "Test 2: Invalid stablecoin_id"
INVALID_DATA=$(cat <<EOF
{
  "stablecoin_id": "invalid-id",
  "amount": 100
}
EOF
)

RESPONSE=$(api_call "POST" "deposit-request" "$INVALID_DATA")
if echo "$RESPONSE" | grep -q "not found\|not exist"; then
    print_success "Correctly rejected invalid stablecoin_id"
else
    print_error "Should have rejected invalid stablecoin_id"
    format_json "$RESPONSE"
fi

# Test 3: Negative amount
print_header "Test 3: Negative amount"
NEGATIVE_DATA=$(cat <<EOF
{
  "stablecoin_id": "$STABLECOIN_ID",
  "amount": -50
}
EOF
)

RESPONSE=$(api_call "POST" "deposit-request" "$NEGATIVE_DATA")
if echo "$RESPONSE" | grep -q "amount\|positive\|invalid"; then
    print_success "Correctly rejected negative amount"
else
    print_error "Should have rejected negative amount"
    format_json "$RESPONSE"
fi

# Test 4: Zero amount
print_header "Test 4: Zero amount"
ZERO_DATA=$(cat <<EOF
{
  "stablecoin_id": "$STABLECOIN_ID",
  "amount": 0
}
EOF
)

RESPONSE=$(api_call "POST" "deposit-request" "$ZERO_DATA")
if echo "$RESPONSE" | grep -q "amount\|positive\|invalid"; then
    print_success "Correctly rejected zero amount"
else
    print_error "Should have rejected zero amount"
    format_json "$RESPONSE"
fi

# Test 5: Multiple deposits (same stablecoin)
print_header "Test 5: Create second deposit request"
DEPOSIT_DATA_2=$(cat <<EOF
{
  "stablecoin_id": "$STABLECOIN_ID",
  "amount": 500
}
EOF
)

RESPONSE=$(api_call "POST" "deposit-request" "$DEPOSIT_DATA_2")
OPERATION_ID_2=$(echo "$RESPONSE" | jq -r '.operation_id' 2>/dev/null)

if [ "$OPERATION_ID_2" != "null" ] && [ ! -z "$OPERATION_ID_2" ]; then
    print_success "Second deposit created: $OPERATION_ID_2"
else
    print_error "Failed to create second deposit"
    format_json "$RESPONSE"
fi

print_header "DEPOSIT REQUEST TESTS COMPLETED"
