# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 🔴 SECURITY FIX #2: TERRAFORM VERSION PINNING
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 7yo: Always use the same magic tool version so your toy works the same way.
#
# SME: FIX: Changed from '>= 1.6.0' (any version from 1.6 onward) to '~> 1.9.5'
#      (exactly 1.9.5). This matches the workflow version (setup-terraform: 1.9.5)
#      and prevents drift. Prevents breaking changes from Terraform 2.0+.
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

terraform {
  required_version = "~> 1.9.5"

  backend "s3" {
    key     = "github-snow/prod/terraform.tfstate"
    encrypt = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.100"
    }
  }
}
