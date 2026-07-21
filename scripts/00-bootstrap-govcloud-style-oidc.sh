#!/usr/bin/env bash
# One-shot bootstrap for GitHub Actions OIDC + Terraform backend + deploy role.
# Keeps GovCloud-style GitHub key names, but works in commercial or GovCloud partitions.
set -euo pipefail

# -----------------------------
# Config (override via env vars)
# -----------------------------
REPO="${REPO:-techsysvbo/github-snow}"
ENVIRONMENT_NAME="${ENVIRONMENT_NAME:-production}"
BRANCH_NAME="${BRANCH_NAME:-main}"
AWS_REGION="${AWS_REGION:-us-east-1}"
ROLE_NAME="${ROLE_NAME:-github-snow-terraform-deploy-role}"
GOVCLOUD_PREFIX="${GOVCLOUD_PREFIX:-github-snow-govcloud}"
DEMO_BUCKET_NAME="${DEMO_BUCKET_NAME:-${GOVCLOUD_PREFIX}-s3-demo}"

ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text)"
CALLER_ARN="$(aws sts get-caller-identity --query Arn --output text)"
PARTITION="$(printf '%s' "${CALLER_ARN}" | cut -d: -f2)"

OIDC_PROVIDER_HOST="token.actions.githubusercontent.com"
OIDC_PROVIDER_ARN="arn:${PARTITION}:iam::${ACCOUNT_ID}:oidc-provider/${OIDC_PROVIDER_HOST}"
TF_STATE_BUCKET="${TF_STATE_BUCKET:-${GOVCLOUD_PREFIX}-tfstate-${ACCOUNT_ID}-${AWS_REGION}}"
TF_LOCK_TABLE="${TF_LOCK_TABLE:-${GOVCLOUD_PREFIX}-tf-locks}"

WORKDIR="$(mktemp -d)"
trap 'rm -rf "${WORKDIR}"' EXIT

TRUST_FILE="${WORKDIR}/github-oidc-trust.json"
POLICY_FILE="${WORKDIR}/github-terraform-deploy-policy.json"

log() { printf '%s\n' "$*"; }
err() { printf 'ERROR: %s\n' "$*" >&2; }

log "Account: ${ACCOUNT_ID}"
log "Partition: ${PARTITION}"
log "Region: ${AWS_REGION}"
log "Role: ${ROLE_NAME}"
log "Repo: ${REPO}"
log "Environment gate: ${ENVIRONMENT_NAME}"
log "Branch gate: ${BRANCH_NAME}"
log "Terraform state bucket: ${TF_STATE_BUCKET}"
log "Terraform lock table: ${TF_LOCK_TABLE}"
log "Demo S3 bucket name: ${DEMO_BUCKET_NAME}"
log ""

# ---------------------------------
# 1) Terraform backend prerequisites
# ---------------------------------
if aws s3api head-bucket --bucket "${TF_STATE_BUCKET}" >/dev/null 2>&1; then
  log "State bucket exists: ${TF_STATE_BUCKET}"
else
  log "Creating state bucket: ${TF_STATE_BUCKET}"
  if [[ "${AWS_REGION}" == "us-east-1" ]]; then
    aws s3api create-bucket --bucket "${TF_STATE_BUCKET}" --region "${AWS_REGION}"
  else
    aws s3api create-bucket \
      --bucket "${TF_STATE_BUCKET}" \
      --region "${AWS_REGION}" \
      --create-bucket-configuration "LocationConstraint=${AWS_REGION}"
  fi
fi

aws s3api put-bucket-encryption \
  --bucket "${TF_STATE_BUCKET}" \
  --server-side-encryption-configuration '{
    "Rules": [
      {
        "ApplyServerSideEncryptionByDefault": {
          "SSEAlgorithm": "AES256"
        },
        "BucketKeyEnabled": true
      }
    ]
  }'

aws s3api put-bucket-versioning \
  --bucket "${TF_STATE_BUCKET}" \
  --versioning-configuration Status=Enabled

aws s3api put-public-access-block \
  --bucket "${TF_STATE_BUCKET}" \
  --public-access-block-configuration '{
    "BlockPublicAcls": true,
    "IgnorePublicAcls": true,
    "BlockPublicPolicy": true,
    "RestrictPublicBuckets": true
  }'

if aws dynamodb describe-table --table-name "${TF_LOCK_TABLE}" --region "${AWS_REGION}" >/dev/null 2>&1; then
  log "Lock table exists: ${TF_LOCK_TABLE}"
else
  log "Creating lock table: ${TF_LOCK_TABLE}"
  aws dynamodb create-table \
    --table-name "${TF_LOCK_TABLE}" \
    --attribute-definitions AttributeName=LockID,AttributeType=S \
    --key-schema AttributeName=LockID,KeyType=HASH \
    --billing-mode PAY_PER_REQUEST \
    --region "${AWS_REGION}"
  aws dynamodb wait table-exists --table-name "${TF_LOCK_TABLE}" --region "${AWS_REGION}"
fi

# -----------------------
# 2) GitHub OIDC provider
# -----------------------
if aws iam get-open-id-connect-provider --open-id-connect-provider-arn "${OIDC_PROVIDER_ARN}" >/dev/null 2>&1; then
  log "OIDC provider exists: ${OIDC_PROVIDER_ARN}"
else
  log "Creating OIDC provider: ${OIDC_PROVIDER_ARN}"
  aws iam create-open-id-connect-provider \
    --url "https://${OIDC_PROVIDER_HOST}" \
    --client-id-list "sts.amazonaws.com" \
    --thumbprint-list "6938fd4d98bab03faadb97b34396831e3780aea1"
fi

# -----------------------------
# 3) Role trust + deploy policy
# -----------------------------
cat > "${TRUST_FILE}" <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "GitHubActionsOidcTrust",
      "Effect": "Allow",
      "Principal": {
        "Federated": "${OIDC_PROVIDER_ARN}"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
        },
        "StringLike": {
          "token.actions.githubusercontent.com:sub": [
            "repo:${REPO}:environment:${ENVIRONMENT_NAME}",
            "repo:${REPO}:ref:refs/heads/${BRANCH_NAME}"
          ]
        }
      }
    }
  ]
}
EOF

if aws iam get-role --role-name "${ROLE_NAME}" >/dev/null 2>&1; then
  log "Role exists. Updating trust policy: ${ROLE_NAME}"
  aws iam update-assume-role-policy \
    --role-name "${ROLE_NAME}" \
    --policy-document "file://${TRUST_FILE}"
else
  log "Creating role: ${ROLE_NAME}"
  aws iam create-role \
    --role-name "${ROLE_NAME}" \
    --assume-role-policy-document "file://${TRUST_FILE}" \
    --description "GitHub Actions OIDC role for Terraform deploy from ${REPO}" \
    --tags Key=Project,Value=github-snow-govcloud Key=ManagedBy,Value=GitHubActions
fi

# S3-only deploy policy (+ terraform backend access).
cat > "${POLICY_FILE}" <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "TerraformStateS3Access",
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject",
        "s3:ListBucket",
        "s3:GetBucketLocation"
      ],
      "Resource": [
        "arn:${PARTITION}:s3:::${TF_STATE_BUCKET}",
        "arn:${PARTITION}:s3:::${TF_STATE_BUCKET}/*"
      ]
    },
    {
      "Sid": "TerraformStateDynamoDBLockAccess",
      "Effect": "Allow",
      "Action": [
        "dynamodb:DescribeTable",
        "dynamodb:GetItem",
        "dynamodb:PutItem",
        "dynamodb:DeleteItem",
        "dynamodb:UpdateItem"
      ],
      "Resource": "arn:${PARTITION}:dynamodb:${AWS_REGION}:${ACCOUNT_ID}:table/${TF_LOCK_TABLE}"
    },
    {
      "Sid": "S3DemoResourceAccess",
      "Effect": "Allow",
      "Action": [
        "s3:CreateBucket",
        "s3:DeleteBucket",
        "s3:GetBucket*",
        "s3:PutBucket*",
        "s3:ListBucket",
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject",
        "s3:GetObjectVersion",
        "s3:PutObjectTagging",
        "s3:GetObjectTagging",
        "s3:DeleteObjectTagging"
      ],
      "Resource": [
        "arn:${PARTITION}:s3:::${DEMO_BUCKET_NAME}",
        "arn:${PARTITION}:s3:::${DEMO_BUCKET_NAME}/*"
      ]
    }
  ]
}
EOF

aws iam put-role-policy \
  --role-name "${ROLE_NAME}" \
  --policy-name "${ROLE_NAME}-terraform-deploy" \
  --policy-document "file://${POLICY_FILE}"

ROLE_ARN="$(aws iam get-role --role-name "${ROLE_NAME}" --query 'Role.Arn' --output text)"

log ""
log "Bootstrap complete."
log "Role ARN: ${ROLE_ARN}"
log ""
log "Set these GitHub Secrets (keep GovCloud names, commercial values are OK):"
log "  AWS_GOVCLOUD_WEST_DEPLOY_ROLE_ARN=${ROLE_ARN}"
log "  AWS_GOVCLOUD_REGION=${AWS_REGION}"
log ""
log "Set these GitHub Variables:"
log "  TF_GOVCLOUD_STATE_BUCKET=${TF_STATE_BUCKET}"
log "  TF_GOVCLOUD_LOCK_TABLE=${TF_LOCK_TABLE}"
log "  TF_GOVCLOUD_S3_BUCKET_NAME=${DEMO_BUCKET_NAME}"
log ""
log "Sanity checks:"
log "  1) The role trust policy contains sub repo:${REPO}:environment:${ENVIRONMENT_NAME}"
log "  2) Environment in workflow is ${ENVIRONMENT_NAME}"
log "  3) Secret AWS_GOVCLOUD_WEST_DEPLOY_ROLE_ARN points to the same account shown above"
