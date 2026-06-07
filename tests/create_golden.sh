#!/bin/bash
# Generate (or regenerate) golden files for run_tests.sh.
#
# Run this after:
#   - changing tests/test.ledger or tests/test.pricedb
#   - intentionally changing script behaviour
#   - changing LEDGER_TEST_DATE in run_tests.sh
#
# Commits are NOT automatic — review the diff in tests/golden/ before committing.

set -euo pipefail

TESTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
bash "$TESTS_DIR/run_tests.sh" --update-golden
