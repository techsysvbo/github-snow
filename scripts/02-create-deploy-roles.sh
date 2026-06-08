#!/usr/bin/env bash
# 7yo: Makes a DEV and a PROD costume for the GitHub robot. PROD costume only fits
#      code coming from main (after the SNOW merge). The costume vanishes in ~1h.
# SME: Two OIDC-assumable roles. PROD trusts ONLY refs/heads/main (SoD); DEV also
#      trusts pull_request. Tight trust (sub+aud) + least-privilege inline policy.
set -euo pipefail
GH_ORG="techsysvbo"; GH_REPO="github-snow"; AWS_REGION="us-east-1"
ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text)"
PROVIDER_ARN="arn:aws:iam::${ACCOUNT_ID}:oidc-provider/token.actions.githubusercontent.com"
DEV_ROLE_NAME="github-snow-dev-deploy-role"
PROD_ROLE_NAME="github-snow-prod-deploy-role"
TF_STATE_BUCKET="github-snow-tfstate-${ACCOUNT_ID}"
TF_LOCK_TABLE="github-snow-tflock"

make_trust_policy () {
  local subs_json="$1"
  cat <<JSON
{ "Version":"2012-10-17","Statement":[{
  "Effect":"Allow","Principal":{"Federated":"${PROVIDER_ARN}"},
  "Action":"sts:AssumeRoleWithWebIdentity",
  "Condition":{
    "StringEquals":{"token.actions.githubusercontent.com:aud":"sts.amazonaws.com"},
    "StringLike":{"token.actions.githubusercontent.com:sub": ${subs_json}}
  }}]}
JSON
}
make_perms_policy () {
  cat <<JSON
{ "Version":"2012-10-17","Statement":[
  {"Sid":"TerraformRemoteState","Effect":"Allow",
   "Action":["s3:GetObject","s3:PutObject","s3:ListBucket"],
   "Resource":["arn:aws:s3:::${TF_STATE_BUCKET}","arn:aws:s3:::${TF_STATE_BUCKET}/*"]},
  {"Sid":"TerraformStateLock","Effect":"Allow",
   "Action":["dynamodb:GetItem","dynamodb:PutItem","dynamodb:DeleteItem"],
   "Resource":"arn:aws:dynamodb:${AWS_REGION}:${ACCOUNT_ID}:table/${TF_LOCK_TABLE}"},
  {"Sid":"DeployManagedResources","Effect":"Allow",
   "Action":["s3:CreateBucket","s3:DeleteBucket","s3:PutBucket*","s3:GetBucket*",
     "s3:PutEncryptionConfiguration","s3:PutBucketPolicy","s3:PutBucketTagging",
     "ec2:RunInstances","ec2:TerminateInstances","ec2:Describe*",
     "ec2:CreateTags","ec2:Create*","ec2:Delete*","ec2:Modify*"],
   "Resource":"*"}
]}
JSON
}
upsert_role () {
  local role="$1"; local subs="$2"; local note="$3"
  local trust; trust="$(make_trust_policy "${subs}")"
  local perms; perms="$(make_perms_policy)"
  if aws iam get-role --role-name "${role}" >/dev/null 2>&1; then
    aws iam update-assume-role-policy --role-name "${role}" --policy-document "${trust}"
  else
    aws iam create-role --role-name "${role}" \
      --assume-role-policy-document "${trust}" \
      --max-session-duration 3600 --description "${note}" \
      --tags Key=ManagedBy,Value=github-snow-bootstrap
  fi
  aws iam put-role-policy --role-name "${role}" \
    --policy-name "${role}-inline" --policy-document "${perms}"
  echo ">> Role ARN: arn:aws:iam::${ACCOUNT_ID}:role/${role}"
}
DEV_SUBS=$(printf '["repo:%s/%s:ref:refs/heads/main","repo:%s/%s:pull_request"]' "$GH_ORG" "$GH_REPO" "$GH_ORG" "$GH_REPO")
upsert_role "${DEV_ROLE_NAME}" "${DEV_SUBS}" "GitHub Actions DEV deploy (OIDC)"
PROD_SUBS=$(printf '["repo:%s/%s:ref:refs/heads/main"]' "$GH_ORG" "$GH_REPO")
upsert_role "${PROD_ROLE_NAME}" "${PROD_SUBS}" "GitHub Actions PROD deploy (OIDC, main only)"
echo "AWS_DEV_DEPLOY_ROLE_ARN  = arn:aws:iam::${ACCOUNT_ID}:role/${DEV_ROLE_NAME}"
echo "AWS_PROD_DEPLOY_ROLE_ARN = arn:aws:iam::${ACCOUNT_ID}:role/${PROD_ROLE_NAME}"
echo "AWS_REGION               = ${AWS_REGION}"
