"""
SageMaker Unified Studio Domain CDK Stack

This stack creates a SageMaker Unified Studio domain using AWS CDK with the same
configuration as the successful CloudFormation and API deployments.
"""

from aws_cdk import (
    Stack,
    CfnOutput,
    aws_datazone as datazone,
)
from constructs import Construct


class SageMakerUnifiedStudioStack(Stack):
    """CDK Stack for SageMaker Unified Studio Domain"""

    def __init__(self, scope: Construct, construct_id: str, **kwargs) -> None:
        super().__init__(scope, construct_id, **kwargs)

        # Domain configuration - using the same values from your successful deployments
        domain_name = "Corporate-CDK-Test"
        
        # IAM roles from your working configuration
        domain_execution_role_arn = "arn:aws:iam::000557565608:role/service-role/AmazonSageMakerDomainExecution"
        service_role_arn = "arn:aws:iam::000557565608:role/service-role/AmazonSageMakerDomainService"
        manage_access_role_arn = "arn:aws:iam::000557565608:role/service-role/AmazonSageMakerManageAccess-us-west-2-dzd_c3mt22a3kr50wg"
        provisioning_role_arn = "arn:aws:iam::000557565608:role/service-role/AmazonSageMakerProvisioning-000557565608"
        
        # Network configuration from your working setup
        vpc_id = "vpc-07ad87ee29c085136"
        subnet_ids = [
            "subnet-0f126720addaa10a3",
            "subnet-01bc87ea3b8c1f394", 
            "subnet-0e2725180c8108193"
        ]
        
        # S3 bucket for tooling blueprint
        s3_bucket = "amazon-sagemaker-000557565608-us-west-2-76069271d5a4"
        
        # IAM Identity Center configuration
        idc_instance_arn = "arn:aws:sso:::instance/ssoins-790730fbc9d864c7"

        # Create the SageMaker Unified Studio Domain (V2)
        domain = datazone.CfnDomain(
            self,
            "SageMakerUnifiedStudioDomain",
            name=domain_name,
            domain_version="V2",
            domain_execution_role=domain_execution_role_arn,
            service_role=service_role_arn,
            single_sign_on=datazone.CfnDomain.SingleSignOnProperty(
                type="IAM_IDC",
                user_assignment="MANUAL",
                idc_instance_arn=idc_instance_arn
            ),
            description=f"SageMaker Unified Studio Domain created via CDK - {domain_name}"
        )

        # Note: Environment blueprint configurations will be added manually after domain creation
        # The blueprint IDs appear to be domain-specific and cannot be configured during initial creation

        # Stack Outputs
        CfnOutput(
            self,
            "DomainId",
            value=domain.attr_id,
            description="SageMaker Unified Studio Domain ID"
        )
        
        CfnOutput(
            self,
            "DomainArn", 
            value=domain.attr_arn,
            description="SageMaker Unified Studio Domain ARN"
        )
        
        CfnOutput(
            self,
            "PortalUrl",
            value=domain.attr_portal_url,
            description="SageMaker Unified Studio Portal URL"
        )
        
        CfnOutput(
            self,
            "RootDomainUnitId",
            value=domain.attr_root_domain_unit_id,
            description="Root Domain Unit ID"
        )

        # Store domain reference for potential use by other stacks
        self.domain = domain
        self.domain_id = domain.attr_id
        self.portal_url = domain.attr_portal_url
