# API Test Suite

Comprehensive test suite for the Rayls Stablecoin Gateway API.

## Quick Start

### 1. Configure API Endpoint

Edit `config.sh` to choose between local and production:

```bash
# For local development (default)
export API_URL="$LOCAL_URL"

# For production
export API_URL="$BASE_URL"
```

### 2. Start Local Server (optional)

```bash
deno task serve
# Functions available at http://localhost:54321/functions/v1
```

### 3. Run Tests

Execute all tests in sequence:

```bash
chmod +x *.sh
./run-all-tests.sh
```

Or run individual test suites:

```bash
./01-stablecoin-create.sh
./02-deposit-request.sh
./03-withdraw.sh
./04-query-functions.sh
```

## Test Files

### `config.sh`
Shared configuration and helper functions.

**Variables:**
- `API_KEY` - Test API key (default: `test-api-key-123`)
- `API_URL` - API endpoint (local or production)
- `HEADERS` - Default request headers

**Helper Functions:**
- `print_header()` - Print blue section header
- `print_success()` - Print green success message
- `print_error()` - Print red error message
- `print_info()` - Print yellow info message
- `api_call()` - Make API request with headers
- `format_json()` - Pretty-print JSON response

### `01-stablecoin-create.sh`
Tests stablecoin creation endpoint.

**Tests:**
1. ✓ Valid stablecoin creation
2. ✓ Invalid symbol (> 10 chars)
3. ✓ Invalid wallet address
4. ✓ Missing total_supply
5. ✓ Missing API key

**Output Files:**
- `stablecoin.env` - Saves `STABLECOIN_ID` and `ERC20_ADDRESS` for later tests

### `02-deposit-request.sh`
Tests deposit request (PIX QR code generation).

**Requires:** `stablecoin.env` from test 01

**Tests:**
1. ✓ Valid deposit request
2. ✓ Invalid stablecoin_id
3. ✓ Negative amount
4. ✓ Zero amount
5. ✓ Multiple deposits (same stablecoin)

**Output Files:**
- `operation.env` - Saves `OPERATION_ID` and `QRCODE_PAYLOAD`

### `03-withdraw.sh`
Tests token burning and PIX transfer.

**Requires:** `stablecoin.env` from test 01

**Tests:**
1. ✓ Valid withdraw request
2. ✓ Invalid stablecoin address
3. ✓ Negative amount
4. ✓ Missing pix_address
5. ✓ Valid PIX address formats (email, CPF, phone)
6. ✓ Large withdraw amount

### `04-query-functions.sh`
Tests read-only query endpoints.

**Tests:**
1. ✓ List client stablecoins
2. ✓ Get stablecoin info by ID
3. ✓ Get stablecoin info by ERC20 address
4. ✓ List stablecoin operations
5. ✓ List all client operations
6. ✓ Get operation details
7. ✓ Get stablecoin stats
8. ✓ Query without API key (should fail)
9. ✓ Query with invalid API key (should fail)
10. ✓ Pagination test

### `run-all-tests.sh`
Master test runner that executes all tests in correct order.

## Environment Files

Tests generate environment files for data sharing:

```bash
# stablecoin.env - Created by test 01
export STABLECOIN_ID='xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx'
export ERC20_ADDRESS='0x...'

# operation.env - Created by test 02
export OPERATION_ID='xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx'
export QRCODE_PAYLOAD='...'
export WITHDRAW_OPERATION_ID='...' (added by test 03)
```

## API Endpoints Tested

### Authentication-Required Endpoints

| Function | Method | Endpoint | Tests |
|----------|--------|----------|-------|
| Create Stablecoin | POST | `/stablecoin-create` | 01 |
| Deposit Request | POST | `/deposit-request` | 02 |
| Withdraw | POST | `/withdraw` | 03 |
| List Stablecoins | GET | `/list-client-stablecoins` | 04 |
| Get Stablecoin Info | GET | `/get-stablecoin-info` | 04 |
| List Stablecoin Ops | GET | `/list-stablecoin-operations` | 04 |
| List Client Ops | GET | `/list-client-operations` | 04 |
| Get Operation Details | GET | `/get-operation-details` | 04 |
| Get Stablecoin Stats | GET | `/get-stablecoin-stats` | 04 |

## Test API Key

```
Key: test-api-key-123
SHA-256: a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3
```

To add to database:

```bash
psql postgresql://postgres:PASSWORD@db.bzxdqkttnkxqaecaiekt.supabase.co:5432/postgres <<EOF
INSERT INTO api_keys (client_id, client_name, api_key_hash, is_active)
VALUES ('test-client-01', 'Test Corretora', 'a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3', true);
EOF
```

## Example Manual Test (cURL)

```bash
# 1. Create stablecoin
curl -X POST https://bzxdqkttnkxqaecaiekt.supabase.co/functions/v1/stablecoin-create \
  -H "Content-Type: application/json" \
  -H "x-api-key: test-api-key-123" \
  -d '{
    "client_name": "Test Corretora",
    "symbol": "TESTBRL1",
    "client_wallet": "0x1234567890123456789012345678901234567890",
    "webhook": "https://webhook.example.com/events",
    "total_supply": 1000000
  }'

# 2. Request deposit
curl -X POST https://bzxdqkttnkxqaecaiekt.supabase.co/functions/v1/deposit-request \
  -H "Content-Type: application/json" \
  -H "x-api-key: test-api-key-123" \
  -d '{
    "stablecoin_id": "STABLECOIN_ID_FROM_STEP_1",
    "amount": 100
  }'

# 3. Withdraw
curl -X POST https://bzxdqkttnkxqaecaiekt.supabase.co/functions/v1/withdraw \
  -H "Content-Type: application/json" \
  -H "x-api-key: test-api-key-123" \
  -d '{
    "stablecoin_address": "ERC20_ADDRESS_FROM_STEP_1",
    "amount": 50,
    "pix_address": "email@example.com"
  }'

# 4. List stablecoins
curl -X GET https://bzxdqkttnkxqaecaiekt.supabase.co/functions/v1/list-client-stablecoins \
  -H "x-api-key: test-api-key-123"
```

## Troubleshooting

### API Not Accessible
```bash
# Make sure local server is running
deno task serve

# Check if functions are deployed
supabase functions list
```

### API Key Invalid
```bash
# Verify test API key is in database
psql postgresql://postgres:PASSWORD@db.bzxdqkttnkxqaecaiekt.supabase.co:5432/postgres \
  -c "SELECT * FROM api_keys WHERE client_id = 'test-client-01'"
```

### jq Not Installed
```bash
# Install jq for JSON formatting
brew install jq  # macOS
apt-get install jq  # Ubuntu
```

### Tests Depend on Previous Tests
- Test 02 requires output from test 01 (`stablecoin.env`)
- Test 03 requires output from test 01 (`stablecoin.env`)
- Test 04 uses outputs from all previous tests

Always run `run-all-tests.sh` to execute tests in correct order.

## Extending Tests

To add a new test:

1. Create `05-new-feature.sh`
2. Source `config.sh` at the top
3. Use helper functions for consistent formatting
4. Save any IDs to `.env` files for other tests
5. Add to `run-all-tests.sh` in correct order

Template:

```bash
#!/bin/bash
source "$(dirname "$0")/config.sh"

print_header "NEW FEATURE TEST"

# Your tests here

print_header "NEW FEATURE TESTS COMPLETED"
```
