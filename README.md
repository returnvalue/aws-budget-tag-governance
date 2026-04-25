# AWS Fleet-Wide Tagging & Budget Enforcement Lab

This grand finale lab demonstrates the ultimate governance pattern for the **AWS SysOps Administrator Associate**: combining cost control, resource organization, and metadata standardization at scale.

## Architecture Overview

The system implements a multi-dimensional governance framework:

1.  **Cost Governance:** An AWS Budget monitors monthly spending, providing proactive alerts when actual costs reach 80% of the limit or when forecasted costs exceed the threshold.
2.  **Resource Organization:** An AWS Resource Group automatically identifies and aggregates resources based on a standard tagging schema (\`Environment: Prod\`), enabling fleet-wide visibility.
3.  **Metadata Standardization:** All resources are provisioned with mandatory tags (\`Name\`, \`Environment\`, \`CostCenter\`, \`Owner\`) to ensure accountability and cost attribution.
4.  **Operational Alerting:** An SNS topic acts as the communication bridge, delivering budget and governance alerts to the operations team.

## Key Components

-   **AWS Budgets:** The engine for financial oversight and proactive cost management.
-   **Resource Groups:** Provides logical organization of a disparate fleet of resources.
-   **SNS Notifications:** The automated alerting mechanism for governance events.
-   **Standardized Tagging:** The foundational "Compliance as Code" requirement for resource management.

## Prerequisites

-   [Terraform](https://www.terraform.io/downloads.html)
-   [LocalStack Pro](https://localstack.cloud/)
-   [AWS CLI / awslocal](https://github.com/localstack/awscli-local)

## Deployment

1.  **Initialize and Apply:**
    ```bash
    terraform init
    terraform apply -auto-approve
    
```

## Verification & Testing

To test the fleet-wide governance architecture:

1.  **Verify Budget Configuration:**
    ```bash
    awslocal budgets describe-budgets --account-id 000000000000
    aws budgets describe-budgets --account-id 000000000000
    
```

2.  **Inspect Resource Group:**
    List the resources automatically captured by the "Production" group:
    ```bash
    awslocal resource-groups list-group-resources --group-name production-resource-fleet
    aws resource-groups list-group-resources --group-name production-resource-fleet
    
```

3.  **Confirm Tagging Compliance:**
    Verify the tags on the sample S3 bucket:
    ```bash
    awslocal s3api get-bucket-tagging --bucket sysops-governed-prod-data
    aws s3api get-bucket-tagging --bucket sysops-governed-prod-data
    
```

4.  **Monitor SNS Alerts (Conceptual):**
    In a real environment, you would subscribe your email or a Slack webhook to the \`sysops-governance-alerts\` topic to receive real-time budget notifications.

## Cleanup

To tear down the infrastructure:
```bash
terraform destroy -auto-approve
```

---

💡 **Pro Tip: Using `aws` instead of `awslocal`**

If you prefer using the standard `aws` CLI without the `awslocal` wrapper or repeating the `--endpoint-url` flag, you can configure a dedicated profile in your AWS config files.

### 1. Configure your Profile
Add the following to your `~/.aws/config` file:
```ini
[profile localstack]
region = us-east-1
output = json
# This line redirects all commands for this profile to LocalStack
endpoint_url = http://localhost:4566
```

Add matching dummy credentials to your `~/.aws/credentials` file:
```ini
[localstack]
aws_access_key_id = test
aws_secret_access_key = test
```

### 2. Use it in your Terminal
You can now run commands in two ways:

**Option A: Pass the profile flag**
```bash
aws iam create-user --user-name DevUser --profile localstack
```

**Option B: Set an environment variable (Recommended)**
Set your profile once in your session, and all subsequent `aws` commands will automatically target LocalStack:
```bash
export AWS_PROFILE=localstack
aws iam create-user --user-name DevUser
```

### Why this works
- **Precedence**: The AWS CLI (v2) supports a global `endpoint_url` setting within a profile. When this is set, the CLI automatically redirects all API calls for that profile to your local container instead of the real AWS cloud.
- **Convenience**: This allows you to use the standard documentation commands exactly as written, which is helpful if you are copy-pasting examples from AWS labs or tutorials.
