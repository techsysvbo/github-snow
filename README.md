# github-snow test PR ANother test. Fix this
# github-snow test PR ANother test. Fix this
# github-snow test PR ANother test. Fix this
# github-snow test PR ANother test. Fix this
# github-snow test PR ANother test. Fix this
# github-snow test PR ANother test. Fix this
testthis
Thank you My Lord and Saviour Jesus Christ!
Thank you My Lord and Saviour Jesus Christ!
Thank you My Lord and Saviour Jesus Christ!
Thank you My Lord and Saviour Jesus Christ!
Thank you My Lord and Saviour Jesus Christ!
Thank you My Lord and Saviour Jesus Christ!
Thank you My Lord and Saviour Jesus Christ!
Prayer works
Prayer works
Prayer works
Prayer works
Prayer works
Prayer works
Prayer really really really ...  works 
Prayer really really really ...  works 
Prayer really really really ...  works 
Master 
Cluade for CHRIST
GPT for CHRIST
GPT for CHRIST
chatgpt for MY LORD JESUS CHRIST
claude for MY LORD JESUS CHRIST
claude for MY LORD JESUS CHRIST
claude for MY LORD JESUS CHRIST
claude for MY LORD JESUS CHRIST
Thank you JESUS MY LORD
Thank you JESUS MY LORD


GitHub Secrets

Go to:

GitHub repo → Settings → Secrets and variables → Actions → Secrets → New repository secret

Add these:

AWS_PROD_DEPLOY_ROLE_ARN
AWS_REGION

SN_INSTANCE_URL
SN_API_PATH
SN_DEPLOYMENT_CALLBACK_PATH
SN_API_USER
SN_API_PASSWORD
SN_GITHUB_SHARED_SECRET

SN_OAUTH_TOKEN_URL
SN_OAUTH_CLIENT_ID
SN_OAUTH_CLIENT_SECRET
SN_OAUTH_USERNAME
SN_OAUTH_PASSWORD

CMDB_CI_NAME
GitHub Variables

Go to:

GitHub repo → Settings → Secrets and variables → Actions → Variables → New repository variable

Add these:

TF_STATE_BUCKET
TF_LOCK_TABLE
How to get each value
AWS values
AWS_PROD_DEPLOY_ROLE_ARN

Run:

aws iam get-role \
  --role-name github-snow-terraform-deploy-role \
  --query 'Role.Arn' \
  --output text

Add the output to GitHub secret:

AWS_PROD_DEPLOY_ROLE_ARN

Example format:

arn:aws:iam::<ACCOUNT_ID>:role/github-snow-terraform-deploy-role
AWS_REGION

Use:

us-east-1

Add it as GitHub secret:

AWS_REGION=us-east-1
Terraform backend values
TF_STATE_BUCKET

Run:

echo "github-snow-tfstate-$(aws sts get-caller-identity --query Account --output text)-us-east-1"

Add the output as GitHub variable:

TF_STATE_BUCKET

Example format:

github-snow-tfstate-123456789012-us-east-1
TF_LOCK_TABLE

Use:

github-snow-tf-locks

Add it as GitHub variable:

TF_LOCK_TABLE=github-snow-tf-locks
ServiceNow values
SN_INSTANCE_URL

Use:

https://dev198292.service-now.com

Add it as GitHub secret:

SN_INSTANCE_URL
SN_API_PATH

Use:

/api/x_2000997_github_0/github_pr_approval/submit

Add it as GitHub secret:

SN_API_PATH
SN_DEPLOYMENT_CALLBACK_PATH

Use:

/api/x_2000997_github_0/github_pr_approval/deployment-result

Add it as GitHub secret:

SN_DEPLOYMENT_CALLBACK_PATH
SN_API_USER

Use the ServiceNow API user account username.

Example:

github.integration

Add it as GitHub secret:

SN_API_USER
SN_API_PASSWORD

Use the password for the ServiceNow API user.

Add it as GitHub secret:

SN_API_PASSWORD
SN_GITHUB_SHARED_SECRET

Use the same shared secret stored in your ServiceNow system property:

x_2000997_github_0.shared_secret

Add it as GitHub secret:

SN_GITHUB_SHARED_SECRET

Because this secret has been pasted before, rotate it in ServiceNow and GitHub before using it in production.

ServiceNow OAuth values

These are used by:

.github/workflows/send-approved-pr-to-snow.yml
SN_OAUTH_TOKEN_URL

Use:

https://dev198292.service-now.com/oauth_token.do

Add it as GitHub secret:

SN_OAUTH_TOKEN_URL
SN_OAUTH_CLIENT_ID

In ServiceNow, go to:

System OAuth → Application Registry

Open your OAuth application and copy:

Client ID

Add it as GitHub secret:

SN_OAUTH_CLIENT_ID
SN_OAUTH_CLIENT_SECRET

        In the same OAuth application, copy:

        Client Secret

        Add it as GitHub secret:

        SN_OAUTH_CLIENT_SECRET
        SN_OAUTH_USERNAME

        Use the ServiceNow OAuth/API username.

        Add it as GitHub secret:

SN_OAUTH_USERNAME
SN_OAUTH_PASSWORD

Use that ServiceNow user’s password.

Add it as GitHub secret:

SN_OAUTH_PASSWORD
Optional value
CMDB_CI_NAME

Use your ServiceNow CI name if you have one.

Example:

GitHub-ServiceNow-IaC-Approval

Add it as GitHub secret:

CMDB_CI_NAME

Checkov workflow test - Wed Jul  8 21:01:11 -04 2026
