# SageMaker Unified Studio Domain Creation: API vs CloudFormation

This document compares two approaches for creating SageMaker Unified Studio domains: using CloudFormation templates and using the DataZone API directly.

## 🎯 Summary

Both approaches successfully created identical SageMaker Unified Studio domains with the same configuration and environment blueprints.

## 📊 Comparison Table

| Aspect | CloudFormation | DataZone API |
|--------|----------------|--------------|
| **Complexity** | Higher (template syntax) | Lower (direct API calls) |
| **Automation** | Excellent (declarative) | Good (imperative) |
| **Error Handling** | Built-in rollback | Manual handling required |
| **Reproducibility** | Excellent | Good |
| **Version Control** | Excellent | Good (with scripts) |
| **Learning Curve** | Steeper | Gentler |
| **Flexibility** | Limited to CF resources | Full API access |

## 🏗️ CloudFormation Approach

### ✅ Successfully Deployed
- **Stack Name**: `sagemaker-unified-studio-domain-minimal`
- **Domain ID**: `dzd_3is8hf193ykyc0`
- **Domain Name**: `Corporate-Test`
- **Portal URL**: `https://dzd_3is8hf193ykyc0.sagemaker.us-west-2.on.aws`

### 📁 Key Files
- `sagemaker-unified-studio-domain-final.yaml` - Final working template
- `sagemaker-unified-studio-parameters-simple.json` - Parameters
- `deploy-sagemaker-unified-studio.sh` - Deployment script

### 🔧 Template Structure
```yaml
Resources:
  SageMakerUnifiedStudioDomain:
    Type: AWS::DataZone::Domain
    Properties:
      Name: !Ref DomainName
      DomainVersion: "V2"
      # ... other properties

  LakehouseCatalogBlueprint:
    Type: AWS::DataZone::EnvironmentBlueprintConfiguration
    Properties:
      DomainIdentifier: !Ref SageMakerUnifiedStudioDomain
      EnvironmentBlueprintIdentifier: "LakehouseCatalog"
      # ... other properties
```

### 🚀 Deployment Command
```bash
aws cloudformation create-stack \
  --stack-name sagemaker-unified-studio-domain \
  --template-body file://sagemaker-unified-studio-domain-final.yaml \
  --parameters file://sagemaker-unified-studio-parameters-simple.json \
  --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM \
  --region us-west-2
```

## 🔌 DataZone API Approach

### ✅ Successfully Deployed
- **Domain ID**: `dzd_d0rnqxsgrm8ogg`
- **Domain Name**: `Corporate-API-Test`
- **Portal URL**: `https://dzd_d0rnqxsgrm8ogg.sagemaker.us-west-2.on.aws`

### 📁 Key Files
- `create_sagemaker_domain_api.py` - Python script for domain creation

### 🔧 API Calls Used
1. **Create Domain**:
   ```bash
   aws datazone create-domain \
     --name "Corporate-API-Test" \
     --domain-version "V2" \
     --single-sign-on type=IAM_IDC,userAssignment=MANUAL \
     --domain-execution-role "arn:aws:iam::ACCOUNT:role/..." \
     --service-role "arn:aws:iam::ACCOUNT:role/..."
   ```

2. **Configure Blueprints**:
   ```bash
   aws datazone put-environment-blueprint-configuration \
     --domain-identifier "dzd_d0rnqxsgrm8ogg" \
     --environment-blueprint-identifier "ciw5fxhc6v6rio" \
     --manage-access-role-arn "arn:aws:iam::ACCOUNT:role/..." \
     --provisioning-role-arn "arn:aws:iam::ACCOUNT:role/..."
   ```

### 🐍 Python Script Usage
```bash
python3 create_sagemaker_domain_api.py
```

## 📋 Configured Environment Blueprints

Both approaches configured the same 5 environment blueprints:

| Blueprint Name | Blueprint ID | Purpose |
|----------------|--------------|---------|
| **Lakehouse Catalog** | `ciw5fxhc6v6rio` | Redshift Managed Storage catalog |
| **ML Experiments** | `c9gx7j7bemrv0w` | Machine learning experimentation |
| **Tooling** | `4k186sfh08eqxc` | Development and collaboration tools |
| **Data Lake** | `d8w7c3fmbsz5cg` | Data storage and cataloging |
| **Workflows** | `c9ybygnen3sukw` | Orchestration and automation |

## 🔑 Key Configuration Parameters

Both approaches used identical configuration:

```json
{
  "domainExecutionRole": "arn:aws:iam::000557565608:role/service-role/AmazonSageMakerDomainExecution",
  "serviceRole": "arn:aws:iam::000557565608:role/service-role/AmazonSageMakerDomainService",
  "manageAccessRole": "arn:aws:iam::000557565608:role/service-role/AmazonSageMakerManageAccess-us-west-2-dzd_c3mt22a3kr50wg",
  "provisioningRole": "arn:aws:iam::000557565608:role/service-role/AmazonSageMakerProvisioning-000557565608",
  "idcInstanceArn": "arn:aws:sso:::instance/ssoins-790730fbc9d864c7",
  "userAssignment": "MANUAL",
  "domainVersion": "V2"
}
```

## 🛠️ Lessons Learned

### CloudFormation Challenges
1. **Blueprint Identifiers**: Had to use actual blueprint IDs, not logical names
2. **Project Profiles**: Complex syntax caused validation errors
3. **RAM Resource Sharing**: Principal ID format issues
4. **Capabilities**: Required `CAPABILITY_AUTO_EXPAND` for transforms

### API Challenges
1. **Blueprint Discovery**: Need to know exact blueprint IDs beforehand
2. **Error Handling**: Manual rollback required on failures
3. **Sequencing**: Must create domain before configuring blueprints

## 🎯 Recommendations

### Use CloudFormation When:
- You need infrastructure as code
- You want automatic rollback on failures
- You're deploying to multiple environments
- You need version control and change tracking
- You want declarative configuration

### Use DataZone API When:
- You need maximum flexibility
- You're building custom automation
- You want to integrate with existing Python/SDK workflows
- You need to handle complex conditional logic
- You're prototyping or experimenting

## 🔄 Migration Between Approaches

### From API to CloudFormation:
1. Export domain configuration using `get-domain`
2. Export blueprint configurations using `list-environment-blueprint-configurations`
3. Create CloudFormation template with exported values
4. Import existing resources using CloudFormation import

### From CloudFormation to API:
1. Extract resource IDs from CloudFormation outputs
2. Use API calls to modify configurations
3. Consider deleting CloudFormation stack if no longer needed

## 📚 Additional Resources

- [AWS DataZone API Reference](https://docs.aws.amazon.com/datazone/latest/APIReference/)
- [CloudFormation DataZone Resources](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/AWS_DataZone.html)
- [SageMaker Unified Studio Documentation](https://docs.aws.amazon.com/sagemaker/latest/dg/unified-studio.html)
- [Official GitHub Templates](https://github.com/aws/Unified-Studio-for-Amazon-Sagemaker)

## 🎉 Conclusion

Both approaches successfully created identical SageMaker Unified Studio domains. The choice between them depends on your specific requirements for automation, error handling, and integration with existing workflows. CloudFormation provides better infrastructure management capabilities, while the DataZone API offers more flexibility and easier integration with custom applications.
