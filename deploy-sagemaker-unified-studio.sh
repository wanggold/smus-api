#!/bin/bash

# SageMaker Unified Studio Domain Deployment Script
# This script deploys the SageMaker Unified Studio domain using CloudFormation

set -e

# Configuration
STACK_NAME="sagemaker-unified-studio-domain"
TEMPLATE_FILE="sagemaker-unified-studio-domain.yaml"
PARAMETERS_FILE="sagemaker-unified-studio-parameters.json"
REGION="us-west-2"
PROFILE="bwangyu+sagemaker+unified"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if stack exists
stack_exists() {
    aws cloudformation describe-stacks \
        --stack-name "$STACK_NAME" \
        --region "$REGION" \
        --profile "$PROFILE" \
        --output text \
        --query 'Stacks[0].StackName' 2>/dev/null || echo ""
}

# Function to wait for stack operation to complete
wait_for_stack() {
    local operation=$1
    print_status "Waiting for stack $operation to complete..."
    
    aws cloudformation wait "stack-${operation}-complete" \
        --stack-name "$STACK_NAME" \
        --region "$REGION" \
        --profile "$PROFILE"
    
    if [ $? -eq 0 ]; then
        print_success "Stack $operation completed successfully"
    else
        print_error "Stack $operation failed"
        exit 1
    fi
}

# Function to validate template
validate_template() {
    print_status "Validating CloudFormation template..."
    
    aws cloudformation validate-template \
        --template-body "file://$TEMPLATE_FILE" \
        --region "$REGION" \
        --profile "$PROFILE" > /dev/null
    
    if [ $? -eq 0 ]; then
        print_success "Template validation successful"
    else
        print_error "Template validation failed"
        exit 1
    fi
}

# Function to deploy stack
deploy_stack() {
    local operation=$1
    
    print_status "Starting stack $operation..."
    
    if [ "$operation" = "create" ]; then
        aws cloudformation create-stack \
            --stack-name "$STACK_NAME" \
            --template-body "file://$TEMPLATE_FILE" \
            --parameters "file://$PARAMETERS_FILE" \
            --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM CAPABILITY_AUTO_EXPAND \
            --region "$REGION" \
            --profile "$PROFILE" \
            --tags Key=Environment,Value=Production Key=Purpose,Value=SageMakerUnifiedStudio Key=CreatedBy,Value=CloudFormation
    else
        aws cloudformation update-stack \
            --stack-name "$STACK_NAME" \
            --template-body "file://$TEMPLATE_FILE" \
            --parameters "file://$PARAMETERS_FILE" \
            --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM CAPABILITY_AUTO_EXPAND \
            --region "$REGION" \
            --profile "$PROFILE"
    fi
    
    if [ $? -eq 0 ]; then
        wait_for_stack "$operation"
    else
        print_error "Failed to initiate stack $operation"
        exit 1
    fi
}

# Function to show stack outputs
show_outputs() {
    print_status "Retrieving stack outputs..."
    
    aws cloudformation describe-stacks \
        --stack-name "$STACK_NAME" \
        --region "$REGION" \
        --profile "$PROFILE" \
        --query 'Stacks[0].Outputs[*].[OutputKey,OutputValue,Description]' \
        --output table
}

# Function to show stack events (for troubleshooting)
show_events() {
    print_status "Showing recent stack events..."
    
    aws cloudformation describe-stack-events \
        --stack-name "$STACK_NAME" \
        --region "$REGION" \
        --profile "$PROFILE" \
        --query 'StackEvents[0:10].[Timestamp,ResourceStatus,ResourceType,LogicalResourceId,ResourceStatusReason]' \
        --output table
}

# Main execution
main() {
    echo "=========================================="
    echo "SageMaker Unified Studio Domain Deployment"
    echo "=========================================="
    
    # Check if required files exist
    if [ ! -f "$TEMPLATE_FILE" ]; then
        print_error "Template file $TEMPLATE_FILE not found"
        exit 1
    fi
    
    if [ ! -f "$PARAMETERS_FILE" ]; then
        print_error "Parameters file $PARAMETERS_FILE not found"
        exit 1
    fi
    
    # Validate template
    validate_template
    
    # Check if stack exists
    existing_stack=$(stack_exists)
    
    if [ -n "$existing_stack" ]; then
        print_warning "Stack $STACK_NAME already exists"
        read -p "Do you want to update it? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            deploy_stack "update"
        else
            print_status "Deployment cancelled"
            exit 0
        fi
    else
        print_status "Creating new stack $STACK_NAME"
        deploy_stack "create"
    fi
    
    # Show outputs
    show_outputs
    
    print_success "Deployment completed successfully!"
    print_status "You can access your SageMaker Unified Studio domain through the AWS Console"
}

# Handle command line arguments
case "${1:-}" in
    "validate")
        validate_template
        ;;
    "events")
        show_events
        ;;
    "outputs")
        show_outputs
        ;;
    "delete")
        print_warning "This will delete the entire SageMaker Unified Studio domain!"
        read -p "Are you sure? Type 'DELETE' to confirm: " confirmation
        if [ "$confirmation" = "DELETE" ]; then
            print_status "Deleting stack..."
            aws cloudformation delete-stack \
                --stack-name "$STACK_NAME" \
                --region "$REGION" \
                --profile "$PROFILE"
            wait_for_stack "delete"
            print_success "Stack deleted successfully"
        else
            print_status "Deletion cancelled"
        fi
        ;;
    "help"|"-h"|"--help")
        echo "Usage: $0 [command]"
        echo ""
        echo "Commands:"
        echo "  (no command)  Deploy or update the stack"
        echo "  validate      Validate the CloudFormation template"
        echo "  events        Show recent stack events"
        echo "  outputs       Show stack outputs"
        echo "  delete        Delete the stack"
        echo "  help          Show this help message"
        ;;
    "")
        main
        ;;
    *)
        print_error "Unknown command: $1"
        echo "Use '$0 help' for usage information"
        exit 1
        ;;
esac
