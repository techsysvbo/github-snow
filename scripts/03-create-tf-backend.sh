#!/usr/bin/env bash
# 7yo: Gives Terraform a notebook (S3) + a "do not touch" sign (DynamoDB lock).
# SME: Versioned, KMS-encrypted, fully-private state bucket + lock table. Missing
#      this is the #2 cause of "init fails after merge". Once per account.
set -euo pipefail
AWS_REGION="us-east-1"
ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text)"
TF_STATE_BUCKET="github-snow-tfstate-${ACCOUNT_ID}"
TF_LOCK_TABLE="github-snow-tflock"
if aws s3api head-bucket --bucket "${TF_STATE_BUCKET}" 2>/dev/null; then
  echo ">> Bucket exists."
else
  if [ "${AWS_REGION}" = "us-east-1" ]; then
    aws s3api create-bucket --bucket "${TF_STATE_BUCKET}" --region "${AWS_REGION}"
  else
    aws s3api create-bucket --bucket "${TF_STATE_BUCKET}" --region "${AWS_REGION}" \
      --create-bucket-configuration LocationConstraint="${AWS_REGION}"
  fi
fi
aws s3api put-bucket-versioning --bucket "${TF_STATE_BUCKET}" --versioning-configuration Status=Enabled
aws s3api put-bucket-encryption --bucket "${TF_STATE_BUCKET}" \
  --server-side-encryption-configuration '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"aws:kms"}}]}'
aws s3api put-public-access-block --bucket "${TF_STATE_BUCKET}" \
  --public-access-block-configuration BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true
if aws dynamodb describe-table --table-name "${TF_LOCK_TABLE}" >/dev/null 2>&1; then
  echo ">> Lock table exists."
else
  aws dynamodb create-table --table-name "${TF_LOCK_TABLE}" \
    --attribute-definitions AttributeName=LockID,AttributeType=S \
    --key-schema AttributeName=LockID,KeyType=HASH \
    --billing-mode PAY_PER_REQUEST --region "${AWS_REGION}"
fi
echo ">> backend bucket=${TF_STATE_BUCKET}  lock=${TF_LOCK_TABLE}  region=${AWS_REGION}"
