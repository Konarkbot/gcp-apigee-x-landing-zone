#!/usr/bin/env bash
set -euo pipefail

# Placeholder guardrail for the Edge export -> Apigee X migration pipeline.
# This intentionally does not copy secrets automatically.
#
# Usage:
#   ./scripts/migrate-edge-export.sh ./edge-export ./migration-output
#
# The migration process should classify KVM entries before generating any
# Terraform/Apigee artifacts.

INPUT_DIR="${1:-}"
OUTPUT_DIR="${2:-}"

if [[ -z "$INPUT_DIR" || -z "$OUTPUT_DIR" ]]; then
  echo "Usage: $0 <edge-export-dir> <output-dir>"
  exit 2
fi

mkdir -p "$OUTPUT_DIR"
cat > "$OUTPUT_DIR/README.md" <<MSG
# Edge export staging area

Source: $INPUT_DIR

Before generating Apigee X resources, classify every exported artifact:

- proxy
- shared flow
- KVM/config
- target server
- certificate
- API product
- developer/app

**Do not commit raw Edge exports if they contain credentials, private keys,
tokens or other secrets.**
MSG

echo "Created migration staging instructions at $OUTPUT_DIR"
