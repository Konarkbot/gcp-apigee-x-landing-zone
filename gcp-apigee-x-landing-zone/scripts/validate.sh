#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

command -v terraform >/dev/null || { echo "Terraform is required"; exit 1; }

echo "== Terraform formatting check =="
terraform -chdir="$ROOT/env/nonprod" fmt -check -recursive
terraform -chdir="$ROOT/env/prod" fmt -check -recursive

echo "== Terraform initialization/validation (no backend) =="
terraform -chdir="$ROOT/env/nonprod" init -backend=false -input=false
terraform -chdir="$ROOT/env/nonprod" validate
terraform -chdir="$ROOT/env/prod" init -backend=false -input=false
terraform -chdir="$ROOT/env/prod" validate

echo "Validation completed."
