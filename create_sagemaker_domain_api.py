#!/usr/bin/env python3
"""
SageMaker Unified Studio Domain Creation using DataZone API

This script creates a SageMaker Unified Studio domain and configures environment blueprints
using the AWS DataZone API directly, replicating the CloudFormation deployment.
"""

import boto3
import json
import time
from typing import Dict, List, Optional

class SageMakerDomainCreator:
    def __init__(self, profile_name: str = None, region: str = 'us-west-2'):
        """Initialize the domain creator with AWS session."""
        if profile_name:
            session = boto3.Session(profile_name=profile_name)
            self.datazone = session.client('datazone', region_name=region)
        else:
            self.datazone = boto3.client('datazone', region_name=region)
        
        self.region = region
        
    def create_domain(self, 
                     name: str,
                     description: str,
                     domain_execution_role: str,
                     service_role: str,
                     idc_instance_arn: str,
                     user_assignment: str = 'MANUAL',
                     tags: Optional[Dict[str, str]] = None) -> Dict:
        """Create a SageMaker Unified Studio domain."""
        
        domain_params = {
            'name': name,
            'description': description,
            'domainExecutionRole': domain_execution_role,
            'serviceRole': service_role,
            'domainVersion': 'V2',
            'singleSignOn': {
                'type': 'IAM_IDC',
                'userAssignment': user_assignment,
                'idcInstanceArn': idc_instance_arn
            }
        }
        
        if tags:
            domain_params['tags'] = tags
            
        print(f"Creating domain: {name}")
        response = self.datazone.create_domain(**domain_params)
        
        domain_id = response['id']
        print(f"Domain created successfully!")
        print(f"  Domain ID: {domain_id}")
        print(f"  Domain ARN: {response['arn']}")
        print(f"  Portal URL: {response['portalUrl']}")
        
        return response
    
    def configure_blueprint(self,
                           domain_id: str,
                           blueprint_id: str,
                           manage_access_role: str,
                           provisioning_role: str,
                           enabled_regions: List[str] = None) -> Dict:
        """Configure an environment blueprint for the domain."""
        
        if enabled_regions is None:
            enabled_regions = [self.region]
            
        params = {
            'domainIdentifier': domain_id,
            'environmentBlueprintIdentifier': blueprint_id,
            'manageAccessRoleArn': manage_access_role,
            'provisioningRoleArn': provisioning_role,
            'enabledRegions': enabled_regions
        }
        
        print(f"Configuring blueprint: {blueprint_id}")
        response = self.datazone.put_environment_blueprint_configuration(**params)
        print(f"  Blueprint configured successfully!")
        
        return response
    
    def list_blueprint_configurations(self, domain_id: str) -> List[Dict]:
        """List all configured blueprints for a domain."""
        
        response = self.datazone.list_environment_blueprint_configurations(
            domainIdentifier=domain_id
        )
        
        return response.get('items', [])
    
    def get_domain_details(self, domain_id: str) -> Dict:
        """Get detailed information about a domain."""
        
        return self.datazone.get_domain(identifier=domain_id)

def main():
    """Main function to create the domain and configure blueprints."""
    
    # Configuration - Update these values as needed
    config = {
        'profile_name': 'bwangyu+sagemaker+unified',
        'region': 'us-west-2',
        'domain_name': 'Corporate-Python-API',
        'domain_description': 'SageMaker Unified Studio domain created via Python DataZone API',
        'domain_execution_role': 'arn:aws:iam::000557565608:role/service-role/AmazonSageMakerDomainExecution',
        'service_role': 'arn:aws:iam::000557565608:role/service-role/AmazonSageMakerDomainService',
        'idc_instance_arn': 'arn:aws:sso:::instance/ssoins-790730fbc9d864c7',
        'manage_access_role': 'arn:aws:iam::000557565608:role/service-role/AmazonSageMakerManageAccess-us-west-2-dzd_c3mt22a3kr50wg',
        'provisioning_role': 'arn:aws:iam::000557565608:role/service-role/AmazonSageMakerProvisioning-000557565608',
        'tags': {
            'Environment': 'Test',
            'Purpose': 'SageMaker Unified Studio Python API',
            'CreatedBy': 'Python DataZone API'
        }
    }
    
    # Blueprint IDs from the successful CloudFormation deployment
    blueprint_ids = [
        'ciw5fxhc6v6rio',  # Lakehouse Catalog
        'c9gx7j7bemrv0w',  # ML Experiments
        '4k186sfh08eqxc',  # Tooling
        'd8w7c3fmbsz5cg',  # Data Lake
        'c9ybygnen3sukw'   # Workflows
    ]
    
    blueprint_names = [
        'Lakehouse Catalog',
        'ML Experiments',
        'Tooling',
        'Data Lake',
        'Workflows'
    ]
    
    try:
        # Initialize the domain creator
        creator = SageMakerDomainCreator(
            profile_name=config['profile_name'],
            region=config['region']
        )
        
        # Create the domain
        print("=" * 60)
        print("Creating SageMaker Unified Studio Domain")
        print("=" * 60)
        
        domain_response = creator.create_domain(
            name=config['domain_name'],
            description=config['domain_description'],
            domain_execution_role=config['domain_execution_role'],
            service_role=config['service_role'],
            idc_instance_arn=config['idc_instance_arn'],
            tags=config['tags']
        )
        
        domain_id = domain_response['id']
        
        # Wait a moment for domain to be fully ready
        print("\\nWaiting for domain to be ready...")
        time.sleep(5)
        
        # Configure blueprints
        print("\\n" + "=" * 60)
        print("Configuring Environment Blueprints")
        print("=" * 60)
        
        for blueprint_id, blueprint_name in zip(blueprint_ids, blueprint_names):
            try:
                creator.configure_blueprint(
                    domain_id=domain_id,
                    blueprint_id=blueprint_id,
                    manage_access_role=config['manage_access_role'],
                    provisioning_role=config['provisioning_role']
                )
            except Exception as e:
                print(f"  Warning: Failed to configure {blueprint_name}: {str(e)}")
        
        # List all configured blueprints
        print("\\n" + "=" * 60)
        print("Configured Blueprints Summary")
        print("=" * 60)
        
        blueprints = creator.list_blueprint_configurations(domain_id)
        print(f"Total configured blueprints: {len(blueprints)}")
        
        for i, blueprint in enumerate(blueprints, 1):
            print(f"  {i}. Blueprint ID: {blueprint['environmentBlueprintId']}")
            print(f"     Enabled Regions: {', '.join(blueprint['enabledRegions'])}")
            print(f"     Created: {blueprint['createdAt']}")
        
        # Get final domain details
        print("\\n" + "=" * 60)
        print("Final Domain Details")
        print("=" * 60)
        
        domain_details = creator.get_domain_details(domain_id)
        
        print(f"Domain Name: {domain_details['name']}")
        print(f"Domain ID: {domain_details['id']}")
        print(f"Domain ARN: {domain_details['arn']}")
        print(f"Portal URL: {domain_details['portalUrl']}")
        print(f"Root Domain Unit ID: {domain_details['rootDomainUnitId']}")
        print(f"Status: {domain_details['status']}")
        print(f"Domain Version: {domain_details['domainVersion']}")
        
        print("\\n" + "=" * 60)
        print("Domain Creation Completed Successfully!")
        print("=" * 60)
        print(f"You can access your domain at: {domain_details['portalUrl']}")
        
        # Save domain info to file
        domain_info = {
            'domain_id': domain_id,
            'domain_arn': domain_details['arn'],
            'portal_url': domain_details['portalUrl'],
            'root_domain_unit_id': domain_details['rootDomainUnitId'],
            'configured_blueprints': [bp['environmentBlueprintId'] for bp in blueprints]
        }
        
        with open('domain_info.json', 'w') as f:
            json.dump(domain_info, f, indent=2)
        
        print(f"Domain information saved to: domain_info.json")
        
    except Exception as e:
        print(f"Error: {str(e)}")
        return 1
    
    return 0

if __name__ == "__main__":
    exit(main())
