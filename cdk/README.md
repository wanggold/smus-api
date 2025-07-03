# SageMaker Unified Studio Domain - CDK Implementation

This directory contains the AWS CDK (Cloud Development Kit) implementation for deploying SageMaker Unified Studio domains. This approach provides a third option alongside the existing CloudFormation templates and DataZone API scripts.

## Overview

The CDK implementation creates the same SageMaker Unified Studio domain configuration as the successful CloudFormation and API deployments, but using Python-based Infrastructure as Code with CDK constructs.

## Architecture

This CDK stack creates:

- **SageMaker Unified Studio Domain (V2)** with IAM Identity Center integration
- **5 Environment Blueprint Configurations**:
  - Lakehouse Catalog (`ciw5fxhc6v6rio`)
  - ML Experiments (`c9gx7j7bemrv0w`)
  - Tooling (`4k186sfh08eqxc`)
  - Data Lake (`d8w7c3fmbsz5cg`)
  - Workflows (`c9ybygnen3sukw`)

## Files Structure

```
cdk/
├── app.py                           # CDK application entry point
├── sagemaker_unified_studio_stack.py # Main stack definition
├── requirements.txt                 # Python dependencies
├── cdk.json                        # CDK configuration
├── deploy-cdk.sh                   # Deployment automation script
└── README.md                       # This documentation
```

## Prerequisites

1. **AWS CDK installed**:
   ```bash
   npm install -g aws-cdk
   ```

2. **Python 3.7+** with pip

3. **AWS CLI configured** with appropriate permissions

4. **Existing IAM roles** (same as CloudFormation approach):
   - AmazonSageMakerDomainExecution
   - AmazonSageMakerDomainService
   - AmazonSageMakerManageAccess
   - AmazonSageMakerProvisioning

## Quick Start

### Option 1: Using the Deployment Script (Recommended)

```bash
# Navigate to CDK directory
cd cdk

# Deploy the stack
./deploy-cdk.sh deploy
```

### Option 2: Manual CDK Commands

```bash
# Navigate to CDK directory
cd cdk

# Install Python dependencies
pip3 install -r requirements.txt

# Bootstrap CDK (first time only)
cdk bootstrap aws://000557565608/us-west-2 --profile bwangyu+sagemaker+unified

# Deploy the stack
cdk deploy SageMakerUnifiedStudioStack --profile bwangyu+sagemaker+unified
```

## Deployment Script Commands

The `deploy-cdk.sh` script provides several useful commands:

```bash
# Deploy the stack
./deploy-cdk.sh deploy

# Show differences between deployed and local stack
./deploy-cdk.sh diff

# Synthesize CloudFormation template
./deploy-cdk.sh synth

# Validate the CDK application
./deploy-cdk.sh validate

# Show stack outputs
./deploy-cdk.sh outputs

# Bootstrap CDK
./deploy-cdk.sh bootstrap

# Destroy the stack
./deploy-cdk.sh destroy

# Show help
./deploy-cdk.sh help
```

## Configuration

The CDK stack uses the same configuration values as your successful deployments:

| Parameter | Value | Description |
|-----------|-------|-------------|
| Domain Name | `Corporate-CDK-Test` | CDK-deployed domain name |
| Account | `000557565608` | AWS account ID |
| Region | `us-west-2` | Deployment region |
| VPC ID | `vpc-07ad87ee29c085136` | VPC for networking |
| Subnets | 3 subnets across AZs | Multi-AZ configuration |
| IDC Instance | `ssoins-790730fbc9d864c7` | IAM Identity Center |

## Stack Outputs

After successful deployment, the stack provides:

- **DomainId**: Unique domain identifier
- **DomainArn**: Domain ARN
- **PortalUrl**: SageMaker Unified Studio portal URL
- **RootDomainUnitId**: Root domain unit ID
- **Blueprint Configuration IDs**: IDs for all 5 environment blueprints

## Advantages of CDK Approach

### Compared to CloudFormation:
- **Type Safety**: Python type hints and IDE support
- **Reusability**: Easy to create reusable constructs
- **Programming Logic**: Loops, conditions, and functions
- **Testing**: Unit testing capabilities
- **Abstraction**: Higher-level constructs hide complexity

### Compared to API Scripts:
- **Infrastructure as Code**: Declarative resource management
- **Dependency Management**: Automatic resource dependency handling
- **Rollback**: Built-in rollback on failures
- **State Management**: CDK manages resource state
- **Version Control**: Full IaC benefits

## Customization

### Modify Domain Configuration

Edit `sagemaker_unified_studio_stack.py`:

```python
# Change domain name
domain_name = "Your-Custom-Domain-Name"

# Modify blueprint configurations
# Add/remove blueprints from blueprint_configs list

# Update network configuration
vpc_id = "your-vpc-id"
subnet_ids = ["subnet-1", "subnet-2", "subnet-3"]
```

### Add Additional Resources

The CDK stack can be easily extended:

```python
# Add S3 buckets
bucket = s3.Bucket(self, "DomainBucket")

# Add IAM roles
role = iam.Role(self, "CustomRole", ...)

# Add Lambda functions
function = lambda_.Function(self, "CustomFunction", ...)
```

## Troubleshooting

### Common Issues

1. **CDK Not Bootstrapped**:
   ```bash
   ./deploy-cdk.sh bootstrap
   ```

2. **Python Dependencies Missing**:
   ```bash
   pip3 install -r requirements.txt
   ```

3. **IAM Permission Errors**:
   - Verify AWS profile has CDK deployment permissions
   - Check that referenced IAM roles exist

4. **Blueprint Configuration Errors**:
   - Ensure blueprint IDs are correct
   - Verify manage access and provisioning roles exist

### Debugging Steps

1. **Validate CDK App**:
   ```bash
   ./deploy-cdk.sh validate
   ```

2. **Synthesize Template**:
   ```bash
   ./deploy-cdk.sh synth
   ```

3. **Show Differences**:
   ```bash
   ./deploy-cdk.sh diff
   ```

4. **Check CloudFormation Events**:
   ```bash
   aws cloudformation describe-stack-events \
     --stack-name SageMakerUnifiedStudioStack \
     --region us-west-2
   ```

## Comparison with Other Approaches

| Feature | CDK | CloudFormation | API Scripts |
|---------|-----|----------------|-------------|
| **Language** | Python | YAML/JSON | Python |
| **Type Safety** | ✅ Yes | ❌ No | ✅ Yes |
| **IDE Support** | ✅ Excellent | ⚠️ Limited | ✅ Good |
| **Reusability** | ✅ High | ⚠️ Medium | ⚠️ Medium |
| **Testing** | ✅ Unit tests | ❌ Limited | ✅ Possible |
| **Learning Curve** | ⚠️ Medium | ⚠️ Medium | ✅ Low |
| **Abstraction** | ✅ High-level | ⚠️ Low-level | ✅ High-level |
| **State Management** | ✅ Automatic | ✅ Automatic | ❌ Manual |

## Best Practices

1. **Version Control**: Keep CDK code in version control
2. **Environment Separation**: Use different stacks for dev/prod
3. **Parameter Management**: Use CDK context or environment variables
4. **Testing**: Write unit tests for your constructs
5. **Documentation**: Document custom constructs and configurations

## Next Steps

1. **Deploy and Test**: Use the deployment script to create your domain
2. **Customize**: Modify the stack for your specific requirements
3. **Extend**: Add additional AWS resources as needed
4. **Test**: Verify all environment blueprints work correctly
5. **Monitor**: Set up monitoring and alerting for your domain

## Integration with Existing Approaches

This CDK implementation complements your existing approaches:

- **CloudFormation**: CDK synthesizes to CloudFormation templates
- **API Scripts**: Can be used alongside CDK for operational tasks
- **Consistency**: All three approaches create identical domain configurations

The CDK approach provides the best of both worlds: the infrastructure-as-code benefits of CloudFormation with the programming flexibility of the API approach.
