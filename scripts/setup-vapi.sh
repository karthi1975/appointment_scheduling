#!/bin/bash

# Vapi Voice Agent Setup Script
# This script helps you set up and test your Vapi voice agent

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[VAPI]${NC} $1"
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

# Function to validate API key format
validate_api_key() {
    local api_key="$1"
    # Vapi API keys are UUIDs: 8-4-4-4-12 format (36 characters total)
    if [[ "$api_key" =~ ^[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}$ ]]; then
        return 0
    else
        return 1
    fi
}

# Function to validate agent ID format
validate_agent_id() {
    local agent_id="$1"
    # Vapi Agent IDs are UUIDs: 8-4-4-4-12 format (36 characters total)
    if [[ "$agent_id" =~ ^[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}$ ]]; then
        return 0
    else
        return 1
    fi
}

# Main setup function
main() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}  Vapi Voice Agent Setup        ${NC}"
    echo -e "${BLUE}================================${NC}"
    echo ""
    
    print_status "Setting up Vapi Voice Agent for Medical Appointment Booking"
    echo ""
    
    # Check prerequisites
    print_status "Checking prerequisites..."
    
    if ! command_exists curl; then
        print_error "curl is required but not installed. Please install curl and try again."
        exit 1
    fi
    
    if ! command_exists node; then
        print_warning "Node.js is not installed. Some tests may not work."
    fi
    
    print_success "Prerequisites check completed"
    echo ""
    
    # Get Vapi credentials
    print_status "Please provide your Vapi credentials:"
    echo ""
    
    # Get API Key
    while true; do
        api_key=$(get_input "Enter your Vapi API Key")
        if validate_api_key "$api_key"; then
            break
        else
            print_error "Invalid API key format. Please check your Vapi console."
        fi
    done
    
    # Get Agent ID
    while true; do
        agent_id=$(get_input "Enter your Vapi Agent ID")
        if validate_agent_id "$agent_id"; then
            break
        else
            print_error "Invalid Agent ID format. Please check your Vapi console."
        fi
    done
    
    # Get Phone Number (optional)
    phone_number=$(get_input "Enter your Vapi phone number (optional)" "")
    
    echo ""
    print_success "Credentials collected successfully"
    
    # Update environment file
    print_status "Updating environment configuration..."
    
    if [ -f .env ]; then
        # Update existing .env file
        sed -i.bak "s/VAPI_API_KEY=.*/VAPI_API_KEY=$api_key/" .env
        sed -i.bak "s/VAPI_AGENT_ID=.*/VAPI_AGENT_ID=$agent_id/" .env
        
        if [ -n "$phone_number" ]; then
            if grep -q "VAPI_PHONE_NUMBER" .env; then
                sed -i.bak "s/VAPI_PHONE_NUMBER=.*/VAPI_PHONE_NUMBER=$phone_number/" .env
            else
                echo "VAPI_PHONE_NUMBER=$phone_number" >> .env
            fi
        fi
        
        print_success "Environment file updated"
    else
        # Create new .env file
        cat > .env << EOF
# Medical Appointment Booking System Environment
# Vapi Voice Agent Configuration

VAPI_API_KEY=$api_key
VAPI_AGENT_ID=$agent_id
EOF
        
        if [ -n "$phone_number" ]; then
            echo "VAPI_PHONE_NUMBER=$phone_number" >> .env
        fi
        
        print_success "Environment file created"
    fi
    
    # Test Vapi connectivity
    echo ""
    print_status "Testing Vapi connectivity..."
    
    # Test API key
    api_test=$(curl -s -w "%{http_code}" -H "Authorization: Bearer $api_key" \
        "https://api.vapi.ai/v1/agents" -o /dev/null)
    
    if [ "$api_test" = "200" ]; then
        print_success "API key is valid"
    else
        print_error "API key test failed (HTTP $api_test)"
        print_warning "Please check your API key in the Vapi console"
    fi
    
    # Test agent access
    agent_test=$(curl -s -w "%{http_code}" -H "Authorization: Bearer $api_key" \
        "https://api.vapi.ai/v1/agents/$agent_id" -o /dev/null)
    
    if [ "$agent_test" = "200" ]; then
        print_success "Agent access confirmed"
    else
        print_error "Agent access test failed (HTTP $agent_test)"
        print_warning "Please check your Agent ID in the Vapi console"
    fi
    
    # Test phone numbers
    phone_test=$(curl -s -w "%{http_code}" -H "Authorization: Bearer $api_key" \
        "https://api.vapi.ai/v1/phone-numbers" -o /dev/null)
    
    if [ "$phone_test" = "200" ]; then
        print_success "Phone numbers accessible"
    else
        print_warning "Phone numbers test failed (HTTP $phone_test)"
    fi
    
    echo ""
    
    # Check n8n connectivity
    print_status "Checking n8n connectivity..."
    
    if curl -s -f "http://localhost:5678/healthz" >/dev/null 2>&1; then
        print_success "n8n is running and accessible"
    else
        print_warning "n8n is not accessible at localhost:5678"
        print_warning "Please start n8n first: docker-compose up -d n8n"
    fi
    
    # Test webhook endpoints
    print_status "Testing webhook endpoints..."
    
    webhooks=(
        "http://localhost:5678/webhook/vapi-intake"
        "http://localhost:5678/webhook/appointment-status"
        "http://localhost:5678/webhook/appointment-reschedule"
        "http://localhost:5678/webhook/appointment-cancel"
    )
    
    for webhook in "${webhooks[@]}"; do
        if curl -s -f "$webhook" >/dev/null 2>&1; then
            print_success "$webhook - Accessible"
        else
            print_warning "$webhook - Not accessible"
        fi
    done
    
    echo ""
    
    # Run comprehensive test if Node.js is available
    if command_exists node; then
        print_status "Running comprehensive Vapi tests..."
        
        if [ -f "vapi/api-test.js" ]; then
            # Set environment variables for the test
            export VAPI_API_KEY="$api_key"
            export VAPI_AGENT_ID="$agent_id"
            
            # Run the test
            node vapi/api-test.js
            
            if [ $? -eq 0 ]; then
                print_success "Comprehensive tests completed"
            else
                print_warning "Some tests failed - check output above"
            fi
        else
            print_warning "Vapi test script not found at vapi/api-test.js"
        fi
    fi
    
    echo ""
    echo -e "${GREEN}================================${NC}"
    echo -e "${GREEN}     Vapi Setup Complete! 🎉    ${NC}"
    echo -e "${GREEN}================================${NC}"
    echo ""
    echo -e "${BLUE}Next steps:${NC}"
    echo -e "1. Start your services: ${GREEN}docker-compose up -d${NC}"
    echo -e "2. Test your voice agent by calling your Vapi number"
    echo -e "3. Monitor calls in Vapi console: ${BLUE}https://console.vapi.ai${NC}"
    echo -e "4. Check n8n workflows: ${BLUE}http://localhost:5678${NC}"
    echo ""
    echo -e "${BLUE}Test your setup:${NC}"
    echo -e "  Run: ${GREEN}./scripts/test-endpoints.sh${NC}"
    echo -e "  Or:  ${GREEN}node vapi/api-test.js${NC}"
    echo ""
    echo -e "${BLUE}Your Vapi agent is configured with:${NC}"
    echo -e "  API Key: ${GREEN}${api_key:0:8}...${api_key: -8}${NC}"
    echo -e "  Agent ID: ${GREEN}${agent_id}${NC}"
    if [ -n "$phone_number" ]; then
        echo -e "  Phone: ${GREEN}${phone_number}${NC}"
    fi
    echo ""
}

# Function to cleanup on exit
cleanup() {
    print_status "Cleaning up..."
    if [ -f .env.bak ]; then
        rm .env.bak
    fi
}

# Set trap for cleanup
trap cleanup EXIT

# Run main function
main "$@" 