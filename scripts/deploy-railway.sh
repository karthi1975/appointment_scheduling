#!/bin/bash

# Railway.app Deployment Script
# This script automates the deployment of your Medical Appointment Booking System to Railway

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[RAILWAY]${NC} $1"
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

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to get user input
get_input() {
    local prompt="$1"
    local default="$2"
    local input
    
    if [ -n "$default" ]; then
        read -p "$prompt [$default]: " input
        echo "${input:-$default}"
    else
        read -p "$prompt: " input
        echo "$input"
    fi
}

# Function to check Railway CLI
check_railway_cli() {
    print_status "Checking Railway CLI installation..."
    
    if ! command_exists railway; then
        print_error "Railway CLI is not installed."
        print_status "Installing Railway CLI..."
        
        if command_exists npm; then
            npm install -g @railway/cli
        else
            print_error "npm is not available. Please install Node.js first."
            exit 1
        fi
    fi
    
    print_success "Railway CLI is available"
}

# Function to check Railway login
check_railway_login() {
    print_status "Checking Railway authentication..."
    
    if ! railway whoami >/dev/null 2>&1; then
        print_warning "Not logged in to Railway. Please login first."
        railway login
        
        if ! railway whoami >/dev/null 2>&1; then
            print_error "Failed to login to Railway"
            exit 1
        fi
    fi
    
    print_success "Logged in to Railway as $(railway whoami)"
}

# Function to initialize Railway project
init_railway_project() {
    print_status "Initializing Railway project..."
    
    if [ ! -f ".railway" ]; then
        print_status "Creating new Railway project..."
        railway init
        
        if [ ! -f ".railway" ]; then
            print_error "Failed to initialize Railway project"
            exit 1
        fi
    else
        print_success "Railway project already initialized"
    fi
}

# Function to set environment variables
set_environment_variables() {
    print_status "Setting environment variables..."
    
    # Check if .env file exists
    if [ -f ".env" ]; then
        print_status "Loading environment variables from .env file..."
        
        # Read .env file and set Railway variables
        while IFS='=' read -r key value; do
            # Skip comments and empty lines
            if [[ $key =~ ^[[:space:]]*# ]] || [[ -z $key ]]; then
                continue
            fi
            
            # Remove quotes and spaces
            value=$(echo "$value" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' | sed 's/^"//;s/"$//')
            
            if [ -n "$key" ] && [ -n "$value" ]; then
                print_status "Setting $key=***"
                railway variables set "$key"="$value"
            fi
        done < .env
        
        print_success "Environment variables loaded from .env"
    else
        print_warning ".env file not found. Setting basic variables..."
        
        # Set basic production variables
        railway variables set NODE_ENV=production
        railway variables set PORT=3000
        
        print_warning "Please set additional environment variables manually:"
        print_warning "railway variables set VAPI_API_KEY=your_api_key"
        print_warning "railway variables set VAPI_AGENT_ID=your_agent_id"
        print_warning "railway variables set DATABASE_URL=your_database_url"
    fi
}

# Function to add PostgreSQL plugin
add_postgresql() {
    print_status "Adding PostgreSQL plugin..."
    
    # Check if PostgreSQL is already added
    if railway plugins list | grep -q "postgresql"; then
        print_success "PostgreSQL plugin already added"
        return 0
    fi
    
    print_status "Adding PostgreSQL plugin to Railway project..."
    railway add
    
    print_warning "Please select PostgreSQL from the plugin list"
    print_warning "This will automatically set DATABASE_URL"
    
    # Wait for user to select PostgreSQL
    read -p "Press Enter after selecting PostgreSQL plugin..."
    
    print_success "PostgreSQL plugin added"
}

# Function to deploy application
deploy_application() {
    print_status "Deploying application to Railway..."
    
    # Build and deploy
    railway up
    
    if [ $? -eq 0 ]; then
        print_success "Application deployed successfully"
    else
        print_error "Deployment failed"
        exit 1
    fi
}

# Function to get production URLs
get_production_urls() {
    print_status "Getting production URLs..."
    
    # Get Railway domain
    local domain=$(railway domain)
    
    if [ -n "$domain" ]; then
        print_success "Production domain: $domain"
        
        echo ""
        echo -e "${BLUE}Production Webhook URLs:${NC}"
        echo -e "  Appointment Booking: ${GREEN}https://$domain/webhook/vapi-intake${NC}"
        echo -e "  Status Check: ${GREEN}https://$domain/webhook/appointment-status${NC}"
        echo -e "  Reschedule: ${GREEN}https://$domain/webhook/appointment-reschedule${NC}"
        echo -e "  Cancellation: ${GREEN}https://$domain/webhook/appointment-cancel${NC}"
        echo ""
        
        # Save URLs to file for easy access
        cat > production-urls.txt << EOF
# Production Webhook URLs for Vapi
# Generated on: $(date)

APPOINTMENT_BOOKING_WEBHOOK=https://$domain/webhook/vapi-intake
STATUS_CHECK_WEBHOOK=https://$domain/webhook/appointment-status
RESCHEDULE_WEBHOOK=https://$domain/webhook/appointment-reschedule
CANCELLATION_WEBHOOK=https://$domain/webhook/appointment-cancel

# Health Check URLs
HEALTH_CHECK=https://$domain/health
N8N_HEALTH=https://$domain/n8n/healthz
EOF
        
        print_success "Production URLs saved to production-urls.txt"
    else
        print_warning "Could not get production domain"
    fi
}

# Function to test production deployment
test_production() {
    print_status "Testing production deployment..."
    
    local domain=$(railway domain)
    
    if [ -z "$domain" ]; then
        print_warning "Cannot test production - no domain available"
        return 1
    fi
    
    # Test health endpoint
    print_status "Testing health endpoint..."
    if curl -s -f "https://$domain/health" >/dev/null 2>&1; then
        print_success "Health endpoint: OK"
    else
        print_error "Health endpoint: FAILED"
        return 1
    fi
    
    # Test webhook endpoints
    print_status "Testing webhook endpoints..."
    local webhooks=(
        "/webhook/vapi-intake"
        "/webhook/appointment-status"
        "/webhook/appointment-reschedule"
        "/webhook/appointment-cancel"
    )
    
    local all_ok=true
    for webhook in "${webhooks[@]}"; do
        if curl -s -f "https://$domain$webhook" >/dev/null 2>&1; then
            print_success "$webhook - OK"
        else
            print_warning "$webhook - Not accessible (may be expected for GET requests)"
        fi
    done
    
    print_success "Production testing completed"
    return 0
}

# Function to show next steps
show_next_steps() {
    echo ""
    echo -e "${GREEN}================================${NC}"
    echo -e "${GREEN}     Deployment Complete! 🎉    ${NC}"
    echo -e "${GREEN}================================${NC}"
    echo ""
    echo -e "${BLUE}Next steps:${NC}"
    echo -e "1. Update Vapi webhook URLs with production URLs above"
    echo -e "2. Test your voice agent with production webhooks"
    echo -e "3. Monitor deployment: ${GREEN}railway logs${NC}"
    echo -e "4. Check status: ${GREEN}railway status${NC}"
    echo ""
    echo -e "${BLUE}Production URLs saved to:${NC} production-urls.txt"
    echo ""
    echo -e "${BLUE}Useful Railway commands:${NC}"
    echo -e "  View logs:      ${GREEN}railway logs${NC}"
    echo -e "  Check status:   ${GREEN}railway status${NC}"
    echo -e "  View variables: ${GREEN}railway variables list${NC}"
    echo -e "  Shell access:   ${GREEN}railway shell${NC}"
    echo ""
}

# Main deployment function
main() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}  Railway Deployment Script      ${NC}"
    echo -e "${BLUE}================================${NC}"
    echo ""
    
    print_status "Starting Railway deployment process..."
    echo ""
    
    # Check prerequisites
    check_railway_cli
    check_railway_login
    
    # Initialize project
    init_railway_project
    
    # Set environment variables
    set_environment_variables
    
    # Add PostgreSQL plugin
    add_postgresql
    
    # Deploy application
    deploy_application
    
    # Get production URLs
    get_production_urls
    
    # Test production deployment
    test_production
    
    # Show next steps
    show_next_steps
}

# Function to cleanup on exit
cleanup() {
    print_status "Cleaning up..."
    # Add any cleanup tasks here
}

# Set trap for cleanup
trap cleanup EXIT

# Check if running in interactive mode
if [[ $- == *i* ]]; then
    # Interactive mode - ask for confirmation
    echo -e "${YELLOW}This script will deploy your application to Railway.app${NC}"
    echo -e "${YELLOW}Make sure you have committed all changes to git${NC}"
    echo ""
    read -p "Do you want to continue? (y/N): " -n 1 -r
    echo ""
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_status "Deployment cancelled"
        exit 0
    fi
fi

# Run main function
main "$@" 