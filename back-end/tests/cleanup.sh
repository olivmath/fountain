#!/bin/bash

# Cleanup test artifacts - removes environment files from previous test runs

source "$(dirname "$0")/config.sh"

print_header "CLEANUP TEST ARTIFACTS"
echo ""

# List files to remove
FILES_TO_REMOVE=(
    "stablecoin.env"
    "operation.env"
)

print_info "Cleaning up test artifacts..."
echo ""

for file in "${FILES_TO_REMOVE[@]}"; do
    if [ -f "$(dirname "$0")/$file" ]; then
        rm "$(dirname "$0")/$file"
        print_success "Removed: $file"
    fi
done

echo ""
print_info "Cleanup complete!"
echo ""
echo "To run tests again, use:"
echo "  ./run-all-tests.sh"
