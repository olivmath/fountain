# Quick Start Guide

Get started testing the API in 2 minutes.

## 1. Start Local Server

```bash
cd /Users/olivmath/dev/rayls/back-end
deno task serve
```

Wait for: `Functions available at http://localhost:54321/functions/v1`

## 2. Run All Tests

```bash
cd tests
./run-all-tests.sh
```

Or run individual tests:

```bash
./01-stablecoin-create.sh
./02-deposit-request.sh
./03-withdraw.sh
./04-query-functions.sh
```

## 3. Try a Complete Flow

```bash
./flow-example.sh
```

This creates a stablecoin, makes deposits and withdrawals, then queries the data.

## 4. Manual Testing

Use `test-custom.sh` for ad-hoc testing:

```bash
# Create a stablecoin
./test-custom.sh stablecoin-create POST '{
  "client_name":"My Client",
  "symbol":"MYBRL",
  "client_wallet":"0x1234567890123456789012345678901234567890",
  "webhook":"https://webhook.example.com",
  "total_supply":1000000
}'

# List your stablecoins
./test-custom.sh list-client-stablecoins GET

# Check API health
./health-check.sh
```

## 5. Clean Up

Remove test artifacts:

```bash
./cleanup.sh
```

## Scripts Overview

| Script | Purpose |
|--------|---------|
| `run-all-tests.sh` | Run complete test suite |
| `01-stablecoin-create.sh` | Test stablecoin creation |
| `02-deposit-request.sh` | Test deposit requests |
| `03-withdraw.sh` | Test withdrawals |
| `04-query-functions.sh` | Test read-only queries |
| `flow-example.sh` | Complete lifecycle example |
| `test-custom.sh` | Manual/custom tests |
| `health-check.sh` | Check API & DB health |
| `cleanup.sh` | Remove test artifacts |

## Switching Between Local and Production

Edit `config.sh`:

```bash
# Local (default)
export API_URL="$LOCAL_URL"

# Production
export API_URL="$BASE_URL"
```

## Default Test Credentials

- **API Key:** `test-api-key-123`
- **Client ID:** `test-client-01`
- **Client Name:** `Test Corretora`

## Tips

- Tests generate `.env` files automatically - don't delete them between runs
- Use `./health-check.sh` before running tests to verify connectivity
- Check `README.md` for detailed documentation
- All API responses are pretty-printed with `jq`

## Troubleshooting

### "API is not accessible"
Make sure local server is running: `deno task serve`

### "Invalid API key"
Add test API key to database:
```bash
psql postgresql://postgres:$PGPASSWORD@db.bzxdqkttnkxqaecaiekt.supabase.co:5432/postgres <<EOF
INSERT INTO api_keys (client_id, client_name, api_key_hash, is_active)
VALUES ('test-client-01', 'Test Corretora', 'a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3', true);
EOF
```

### "jq: command not found"
Install jq: `brew install jq` (macOS) or `apt-get install jq` (Ubuntu)

## Next Steps

1. Read `/README.md` for complete documentation
2. Check endpoints in the CLAUDE.md file
3. Review test output for errors
4. Inspect database logs: `SELECT * FROM logs ORDER BY timestamp DESC LIMIT 50`
5. Check blockchain transactions in logs

Enjoy testing! 🚀
