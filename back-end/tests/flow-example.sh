#!/bin/bash

# Complete flow example: Create stablecoin -> Deposit -> Withdraw -> Query
# Shows the full lifecycle of operations

source "$(dirname "$0")/config.sh"

print_header "COMPLETE FLOW EXAMPLE"
echo ""
print_info "This script demonstrates a complete stablecoin lifecycle"
echo ""

# Step 1: Create stablecoin
print_header "Step 1: Create Stablecoin"
SYMBOL="DEMO$(date +%s | tail -c 4)"  # Generate unique symbol

STABLECOIN_DATA=$(cat <<EOF
{
  "client_name": "Demo Client",
  "symbol": "$SYMBOL",
  "client_wallet": "0x1234567890123456789012345678901234567890",
  "webhook": "https://webhook.example.com/events",
  "total_supply": 1000000
}
EOF
)

print_info "Creating stablecoin with symbol: $SYMBOL"
RESPONSE=$(api_call "POST" "stablecoin-create" "$STABLECOIN_DATA")

STABLECOIN_ID=$(echo "$RESPONSE" | jq -r '.stablecoin_id' 2>/dev/null)
ERC20_ADDRESS=$(echo "$RESPONSE" | jq -r '.erc20_address' 2>/dev/null)
TOTAL_SUPPLY=$(echo "$RESPONSE" | jq -r '.total_supply' 2>/dev/null)
CURRENT_SUPPLY=$(echo "$RESPONSE" | jq -r '.current_supply' 2>/dev/null)

if [ ! -z "$STABLECOIN_ID" ] && [ "$STABLECOIN_ID" != "null" ]; then
    print_success "Stablecoin created!"
    echo "  Stablecoin ID: $STABLECOIN_ID"
    echo "  ERC20 Address: $ERC20_ADDRESS"
    echo "  Total Supply: $TOTAL_SUPPLY"
    echo "  Current Supply: $CURRENT_SUPPLY"
else
    print_error "Failed to create stablecoin"
    format_json "$RESPONSE"
    exit 1
fi

# Step 2: Request first deposit
print_header "Step 2: Request First Deposit (100 tokens)"
DEPOSIT_DATA=$(cat <<EOF
{
  "stablecoin_id": "$STABLECOIN_ID",
  "amount": 100
}
EOF
)

RESPONSE=$(api_call "POST" "deposit-request" "$DEPOSIT_DATA")
OPERATION_ID_1=$(echo "$RESPONSE" | jq -r '.operation_id' 2>/dev/null)

if [ ! -z "$OPERATION_ID_1" ] && [ "$OPERATION_ID_1" != "null" ]; then
    print_success "First deposit requested!"
    echo "  Operation ID: $OPERATION_ID_1"
    echo "  Amount: 100"
    echo "  Status: payment_pending"
else
    print_error "Failed to request deposit"
    format_json "$RESPONSE"
    exit 1
fi

# Step 3: Request second deposit
print_header "Step 3: Request Second Deposit (250 tokens)"
DEPOSIT_DATA=$(cat <<EOF
{
  "stablecoin_id": "$STABLECOIN_ID",
  "amount": 250
}
EOF
)

RESPONSE=$(api_call "POST" "deposit-request" "$DEPOSIT_DATA")
OPERATION_ID_2=$(echo "$RESPONSE" | jq -r '.operation_id' 2>/dev/null)

if [ ! -z "$OPERATION_ID_2" ] && [ "$OPERATION_ID_2" != "null" ]; then
    print_success "Second deposit requested!"
    echo "  Operation ID: $OPERATION_ID_2"
    echo "  Amount: 250"
    echo "  Status: payment_pending"
else
    print_error "Failed to request deposit"
    format_json "$RESPONSE"
fi

# Step 4: Request withdrawal
print_header "Step 4: Request Withdrawal (75 tokens)"
WITHDRAW_DATA=$(cat <<EOF
{
  "stablecoin_address": "$ERC20_ADDRESS",
  "amount": 75,
  "pix_address": "email@example.com"
}
EOF
)

RESPONSE=$(api_call "POST" "withdraw" "$WITHDRAW_DATA")
OPERATION_ID_3=$(echo "$RESPONSE" | jq -r '.operation_id' 2>/dev/null)

if [ ! -z "$OPERATION_ID_3" ] && [ "$OPERATION_ID_3" != "null" ]; then
    print_success "Withdrawal initiated!"
    echo "  Operation ID: $OPERATION_ID_3"
    echo "  Amount: 75"
    echo "  Status: pix_transfer_pending"
else
    print_error "Failed to request withdrawal"
    format_json "$RESPONSE"
fi

# Step 5: Query stablecoin info
print_header "Step 5: Query Stablecoin Info"
RESPONSE=$(api_call "GET" "get-stablecoin-info?stablecoin_id=$STABLECOIN_ID")

QUERIED_ID=$(echo "$RESPONSE" | jq -r '.data[0].stablecoin_id' 2>/dev/null)
QUERIED_SYMBOL=$(echo "$RESPONSE" | jq -r '.data[0].symbol' 2>/dev/null)
QUERIED_STATUS=$(echo "$RESPONSE" | jq -r '.data[0].status' 2>/dev/null)

if [ ! -z "$QUERIED_ID" ] && [ "$QUERIED_ID" != "null" ]; then
    print_success "Stablecoin info retrieved!"
    echo "  Symbol: $QUERIED_SYMBOL"
    echo "  Status: $QUERIED_STATUS"
    echo "  ERC20: $ERC20_ADDRESS"
else
    print_error "Failed to retrieve stablecoin info"
    format_json "$RESPONSE"
fi

# Step 6: List all operations for this stablecoin
print_header "Step 6: List All Operations for Stablecoin"
RESPONSE=$(api_call "GET" "list-stablecoin-operations?stablecoin_id=$STABLECOIN_ID")

OP_COUNT=$(echo "$RESPONSE" | jq '.data | length' 2>/dev/null || echo "0")
print_success "Operations found: $OP_COUNT"

echo ""
print_info "Operations:"
echo "$RESPONSE" | jq -r '.data[] | "\(.operation_type | ascii_upcase) - \(.amount) tokens - \(.status)"' 2>/dev/null || echo "  (No operations)"

# Step 7: Get operation details
print_header "Step 7: Get Operation Details"
if [ ! -z "$OPERATION_ID_1" ] && [ "$OPERATION_ID_1" != "null" ]; then
    RESPONSE=$(api_call "GET" "get-operation-details?operation_id=$OPERATION_ID_1")

    OP_ID=$(echo "$RESPONSE" | jq -r '.data[0].operation_id' 2>/dev/null)
    OP_TYPE=$(echo "$RESPONSE" | jq -r '.data[0].operation_type' 2>/dev/null)
    OP_AMOUNT=$(echo "$RESPONSE" | jq -r '.data[0].amount' 2>/dev/null)
    OP_STATUS=$(echo "$RESPONSE" | jq -r '.data[0].status' 2>/dev/null)

    if [ ! -z "$OP_ID" ] && [ "$OP_ID" != "null" ]; then
        print_success "Operation details retrieved!"
        echo "  Type: $OP_TYPE"
        echo "  Amount: $OP_AMOUNT"
        echo "  Status: $OP_STATUS"
    fi
fi

# Step 8: Get stablecoin stats
print_header "Step 8: Get Stablecoin Stats"
RESPONSE=$(api_call "GET" "get-stablecoin-stats?stablecoin_id=$STABLECOIN_ID")

TOTAL_DEPOSITS=$(echo "$RESPONSE" | jq -r '.data[0].total_deposits' 2>/dev/null)
TOTAL_WITHDRAWALS=$(echo "$RESPONSE" | jq -r '.data[0].total_withdrawals' 2>/dev/null)
VOLUME=$(echo "$RESPONSE" | jq -r '.data[0].total_volume' 2>/dev/null)

print_success "Stablecoin statistics:"
echo "  Total Deposits: $TOTAL_DEPOSITS"
echo "  Total Withdrawals: $TOTAL_WITHDRAWALS"
echo "  Total Volume: $VOLUME"

# Summary
print_header "FLOW COMPLETE"
echo ""
echo "Summary:"
echo "  Stablecoin: $SYMBOL ($STABLECOIN_ID)"
echo "  ERC20 Address: $ERC20_ADDRESS"
echo "  Total Supply: $TOTAL_SUPPLY"
echo "  Operations Created: 3 (2 deposits, 1 withdrawal)"
echo ""
print_success "Full lifecycle test completed successfully!"
echo ""
echo "Next steps:"
echo "  1. Check the dashboard for webhook notifications"
echo "  2. Verify blockchain transactions on block explorer"
echo "  3. Review logs in: SELECT * FROM logs WHERE context = 'deposit-request' ORDER BY timestamp DESC"
echo "  4. Check events in: SELECT * FROM event_store WHERE aggregate_id = '$STABLECOIN_ID'"
