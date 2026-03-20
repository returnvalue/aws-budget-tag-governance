# AWS provider configuration for LocalStack
provider "aws" {
  region                      = "us-east-1"
  access_key                  = "test"
  secret_key                  = "test"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  s3_use_path_style           = true

  endpoints {
    iam            = "http://localhost:4566"
    resourcegroups = "http://localhost:4566"
    s3             = "http://s3.localhost.localstack.cloud:4566"
    sns            = "http://localhost:4566"
    sts            = "http://localhost:4566"
  }
}

# SNS Topic: The central hub for governance alerts
resource "aws_sns_topic" "governance_alerts" {
  name = "sysops-governance-alerts"
}

# Resource Group: Organizes all "Production" resources based on their tags
resource "aws_resourcegroups_group" "prod_fleet" {
  name = "production-resource-fleet"

  resource_query {
    query = jsonencode({
      ResourceTypeFilters = ["AWS::AllSupported"]
      TagFilters = [
        {
          Key    = "Environment"
          Values = ["Prod"]
        }
      ]
    })
  }
}

# Sample Managed Resource: Demonstrates the standardized tagging schema
resource "aws_s3_bucket" "prod_data" {
  bucket        = "sysops-governed-prod-data"
  force_destroy = true

  tags = {
    Name        = "Production-Data-Bucket"
    Environment = "Prod"
    CostCenter  = "12345"
    Owner       = "SysOps-Team"
  }
}

# Outputs: Key identifiers for governance verification
output "resource_group_arn" {
  value = aws_resourcegroups_group.prod_fleet.arn
}

output "sns_alerts_topic_arn" {
  value = aws_sns_topic.governance_alerts.arn
}
