Based on the templates in https://github.com/aws/Unified-Studio-for-Amazon-Sagemaker/tree/main/cloudformation/domain, create a yaml file that is similar with sagemaker unified studio domain: https://us-west-2.console.aws.amazon.com/datazone/home?region=us-west-2#/domains/dzd_c3mt22a3kr50wg


In /Users/bwangyu/Library/CloudStorage/OneDrive-amazon.com/workspaces/smus-cdk-sdk/sagemaker-unified-studio-domain.yaml, 
* 'OrganizationId' must be given? Any way to set any default value like SageMaker Unified studio domain 'Corporate'?
* 'AmazonSageMakerManageAccessRole' must be given? Any way to set any default value like SageMaker Unified studio domain 'Corporate'?
* 'AmazonSageMakerProvisioningRole' must be given? Any way to set any default value like SageMaker Unified studio domain 'Corporate'?
* 'DZS3Bucket' must be given? Any way to set any default value like SageMaker Unified studio domain 'Corporate'?
* 'SageMakerSubnets' must be given? Any way to set any default value like SageMaker Unified studio domain 'Corporate'?
* 'AmazonSageMakerVpcId' must be given? Any way to set any default value like SageMaker Unified studio domain 'Corporate'?


Deploy the cloudformation. If anything wrong, keep the resources that have been deployed successfully; update the cloudformation, and then deploy again 

Great! Can you create the similar sagemaker unified studio domain like you has deployed with https://us-west-2.console.aws.amazon.com/cloudformation/home?region=us-west-2#/stacks/events?filteringText=&filteringStatus=active&viewNested=true&stackId=arn%3Aaws%3Acloudformation%3Aus-west-2%3A000557565608%3Astack%2Fsagemaker-unified-studio-domain-minimal%2F0515c920-571c-11f0-a4d3-02022c65c757 using the API: https://docs.aws.amazon.com/datazone/latest/APIReference/API_CreateDomain.html