#!/usr/bin/env bash
# 7yo: Tells AWS "GitHub is my friend; trust its badge." Once per account.
# SME: Registers token.actions.githubusercontent.com as an OIDC IdP. Idempotent.
set -euo pipefail
OIDC_URL="https://token.actions.githubusercontent.com"
OIDC_AUDIENCE="sts.amazonaws.com"
THUMBPRINT="6938fd4d98bab03faadb97b34396831e3780aea1"
ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text)"
PROVIDER_ARN="arn:aws:iam::${ACCOUNT_ID}:oidc-provider/token.actions.githubusercontent.com"
echo ">> AWS Account: ${ACCOUNT_ID}"
if aws iam get-open-id-connect-provider --open-id-connect-provider-arn "${PROVIDER_ARN}" >/dev/null 2>&1; then
  echo ">> OIDC provider already exists: ${PROVIDER_ARN}"
else
  aws iam create-open-id-connect-provider \
    --url "${OIDC_URL}" \
    --client-id-list "${OIDC_AUDIENCE}" \
    --thumbprint-list "${THUMBPRINT}" \
    --tags Key=ManagedBy,Value=github-snow-bootstrap Key=Purpose,Value=github-actions-oidc
  echo ">> Created: ${PROVIDER_ARN}"
fi
echo ">> Provider ARN (needed in step 02): ${PROVIDER_ARN}"
