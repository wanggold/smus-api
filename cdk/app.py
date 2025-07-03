#!/usr/bin/env python3
"""
SageMaker Unified Studio Domain CDK App

This CDK application creates a SageMaker Unified Studio domain with environment blueprints
using the same configuration as the successful CloudFormation and API deployments.
"""

import aws_cdk as cdk
from sagemaker_unified_studio_stack import SageMakerUnifiedStudioStack

app = cdk.App()

# Create the SageMaker Unified Studio domain stack
SageMakerUnifiedStudioStack(
    app, 
    "SageMakerUnifiedStudioStack",
    env=cdk.Environment(
        account="000557565608",  # Your account ID from the working deployments
        region="us-west-2"      # Region where your successful deployments are running
    ),
    description="SageMaker Unified Studio Domain with Environment Blueprints - CDK Implementation"
)

app.synth()
