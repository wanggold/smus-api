#!/bin/bash

# SageMaker Unified Studio Domain CDK Deployment Script
# This script deploys the SageMaker Unified Studio domain using AWS CDK

set -e

# Configuration
STACK_NAME="SageMakerUnifiedStudioStack"
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

# Function to show help
show_help() {
    echo "SageMaker Unified Studio Domain CDK Deployment Script"
    echo ""
    echo "Usage: $0 [COMMAND]"
    echo ""
    echo "Commands:"
    echo "  deploy     Deploy the CDK stack (default)"
    echo "  diff       Show differences between deployed and local stack"
    echo "  synth      Synthesize CloudFormation template"
    echo "  destroy    Destroy the CDK stack"
    echo "  bootstrap  Bootstrap CDK in the account/region"
    echo "  outputs    Show stack outputs"
    echo "  validate   Validate the CDK app"
    echo "  help       Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 deploy     # Deploy the stack"
    echo "  $0 diff       # Show differences"
    echo "  $0 destroy    # Delete the stack"
    echo ""
}

# Function to check prerequisites
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    # Check if CDK is installed
    if ! command -v cdk &> /dev/null; then
        print_error "AWS CDK is not installed. Please install it first:"
        echo "npm install -g aws-cdk"
        exit 1
    fi
    
    # Check if Python is available
    if ! command -v python3 &> /dev/null; then
        print_error "Python 3 is not installed"
        exit 1
    fi
    
    # Check if AWS CLI is configured
    if ! aws sts get-caller-identity --profile $PROFILE &> /dev/null; then
        print_error "AWS CLI is not configured properly for profile: $PROFILE"
        exit 1
    fi
    
    print_success "Prerequisites check passed"
}

# Function to setup Python environment
setup_python_env() {
    print_status "Setting up Python environment..."
    
    # Create virtual environment if it doesn't exist
    if [ ! -d "cdk-env" ]; then
        print_status "Creating Python virtual environment..."
        python3 -m venv cdk-env
    fi
    
    # Activate virtual environment
    source cdk-env/bin/activate
    
    # Install Python dependencies
    if [ -f "requirements.txt" ]; then
        pip install -r requirements.txt
        print_success "Python dependencies installed in virtual environment"
    else
        print_warning "requirements.txt not found, skipping dependency installation"
    fi
}

# Function to bootstrap CDK
bootstrap_cdk() {
    print_status "Bootstrapping CDK..."
    source cdk-env/bin/activate
    cdk bootstrap aws://000557565608/$REGION --profile $PROFILE
    print_success "CDK bootstrap completed"
}

# Function to synthesize the stack
synth_stack() {
    print_status "Synthesizing CDK stack..."
    source cdk-env/bin/activate
    cdk synth $STACK_NAME --profile $PROFILE
    print_success "Stack synthesis completed"
}

# Function to show diff
show_diff() {
    print_status "Showing stack differences..."
    source cdk-env/bin/activate
    cdk diff $STACK_NAME --profile $PROFILE
}

# Function to deploy the stack
deploy_stack() {
    print_status "Deploying SageMaker Unified Studio Domain via CDK..."
    
    source cdk-env/bin/activate
    cdk deploy $STACK_NAME \
        --profile $PROFILE \
        --require-approval never \
        --outputs-file cdk-outputs.json
    
    if [ $? -eq 0 ]; then
        print_success "CDK deployment completed successfully!"
        
        # Show outputs if available
        if [ -f "cdk-outputs.json" ]; then
            print_status "Stack outputs:"
            cat cdk-outputs.json | python3 -m json.tool
        fi
    else
        print_error "CDK deployment failed"
        exit 1
    fi
}

# Function to destroy the stack
destroy_stack() {
    print_warning "This will destroy the SageMaker Unified Studio Domain and all associated resources!"
    read -p "Are you sure you want to continue? (yes/no): " confirm
    
    if [ "$confirm" = "yes" ]; then
        print_status "Destroying CDK stack..."
        source cdk-env/bin/activate
        cdk destroy $STACK_NAME --profile $PROFILE --force
        print_success "Stack destruction completed"
    else
        print_status "Stack destruction cancelled"
    fi
}

# Function to show outputs
show_outputs() {
    print_status "Retrieving stack outputs..."
    
    if [ -f "cdk-outputs.json" ]; then
        print_status "Cached outputs from cdk-outputs.json:"
        cat cdk-outputs.json | python3 -m json.tool
    else
        print_status "Getting outputs from AWS..."
        aws cloudformation describe-stacks \
            --stack-name $STACK_NAME \
            --region $REGION \
            --profile $PROFILE \
            --query 'Stacks[0].Outputs' \
            --output table
    fi
}

# Function to validate the CDK app
validate_app() {
    print_status "Validating CDK application..."
    
    source cdk-env/bin/activate
    
    # Check if app.py exists and is valid Python
    if [ -f "app.py" ]; then
        python3 -m py_compile app.py
        print_success "app.py is valid"
    else
        print_error "app.py not found"
        exit 1
    fi
    
    # Check if stack file exists and is valid Python
    if [ -f "sagemaker_unified_studio_stack.py" ]; then
        python3 -m py_compile sagemaker_unified_studio_stack.py
        print_success "sagemaker_unified_studio_stack.py is valid"
    else
        print_error "sagemaker_unified_studio_stack.py not found"
        exit 1
    fi
    
    # Try to synthesize to validate CDK constructs
    print_status "Validating CDK constructs..."
    cdk synth $STACK_NAME --profile $PROFILE > /dev/null
    print_success "CDK validation completed successfully"
}

# Main script logic
main() {
    local command=${1:-deploy}
    
    case $command in
        deploy)
            check_prerequisites
            setup_python_env
            deploy_stack
            ;;
        diff)
            check_prerequisites
            setup_python_env
            show_diff
            ;;
        synth)
            check_prerequisites
            setup_python_env
            synth_stack
            ;;
        destroy)
            check_prerequisites
            destroy_stack
            ;;
        bootstrap)
            check_prerequisites
            bootstrap_cdk
            ;;
        outputs)
            show_outputs
            ;;
        validate)
            check_prerequisites
            setup_python_env
            validate_app
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            print_error "Unknown command: $command"
            show_help
            exit 1
            ;;
    esac
}

# Run the main function
main "$@"
