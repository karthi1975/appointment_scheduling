#!/bin/bash

# Medical Appointment Booking System - Local Setup Script
# This script sets up the complete system locally with n8n integration

set -e  # Exit on any error

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

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to wait for service to be ready
wait_for_service() {
    local service_name=$1
    local service_url=$2
    local max_attempts=30
    local attempt=1
    
    print_status "Waiting for $service_name to be ready..."
    
    while [ $attempt -le $max_attempts ]; do
        if curl -s -f "$service_url" >/dev/null 2>&1; then
            print_success "$service_name is ready!"
            return 0
        fi
        
        print_status "Attempt $attempt/$max_attempts - $service_name not ready yet..."
        sleep 2
        attempt=$((attempt + 1))
    done
    
    print_error "$service_name failed to start after $max_attempts attempts"
    return 1
}

# Main setup function
main() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}  Medical Appointment Booking    ${NC}"
    echo -e "${BLUE}      System Setup Script        ${NC}"
    echo -e "${BLUE}================================${NC}"
    echo ""
    
    # Check prerequisites
    print_status "Checking prerequisites..."
    
    if ! command_exists docker; then
        print_error "Docker is required but not installed."
        print_error "Please install Docker from https://docker.com"
        exit 1
    fi
    
    if ! command_exists docker-compose; then
        print_error "Docker Compose is required but not installed."
        print_error "Please install Docker Compose from https://docs.docker.com/compose/install/"
        exit 1
    fi
    
    if ! docker info >/dev/null 2>&1; then
        print_error "Docker is not running. Please start Docker and try again."
        exit 1
    fi
    
    print_success "All prerequisites are satisfied!"
    
    # Create necessary directories
    print_status "Creating necessary directories..."
    mkdir -p data
    mkdir -p n8n/workflows
    mkdir -p webapp/node_modules
    
    # Create environment file if it doesn't exist
    if [ ! -f .env ]; then
        print_status "Creating .env file..."
        cat > .env << EOF
# Medical Appointment Booking System Environment
# Update these values with your actual API keys

# Vapi Voice Agent (Required for voice functionality)
VAPI_API_KEY=your_vapi_api_key_here
VAPI_AGENT_ID=your_vapi_agent_id_here

# OpenAI API (Optional - for enhanced triage)
OPENAI_API_KEY=your_openai_api_key_here

# Google Calendar (Optional - for calendar integration)
GOOGLE_CALENDAR_CLIENT_ID=your_google_client_id_here
GOOGLE_CALENDAR_CLIENT_SECRET=your_google_client_secret_here

# Insurance API (Optional - for insurance verification)
INSURANCE_API_KEY=your_insurance_api_key_here
INSURANCE_ENDPOINT=https://api.insurance-provider.com

# Notification Services (Optional)
TWILIO_ACCOUNT_SID=your_twilio_sid_here
TWILIO_AUTH_TOKEN=your_twilio_token_here
SENDGRID_API_KEY=your_sendgrid_key_here
EOF
        print_warning "Please edit .env file with your actual API keys before starting services"
    else
        print_status ".env file already exists"
    fi
    
    # Stop any existing containers
    print_status "Stopping any existing containers..."
    docker-compose down --remove-orphans 2>/dev/null || true
    
    # Build and start services
    print_status "Building and starting services..."
    docker-compose up -d --build
    
    # Wait for database to be ready
    print_status "Waiting for database to be ready..."
    if wait_for_service "PostgreSQL" "http://localhost:5432"; then
        print_success "Database is ready!"
    else
        print_error "Database failed to start"
        docker-compose logs database
        exit 1
    fi
    
    # Wait for n8n to be ready
    print_status "Waiting for n8n to be ready..."
    if wait_for_service "n8n" "http://localhost:5678/healthz"; then
        print_success "n8n is ready!"
    else
        print_error "n8n failed to start"
        docker-compose logs n8n
        exit 1
    fi
    
    # Wait for webapp to be ready
    print_status "Waiting for webapp to be ready..."
    if wait_for_service "Web Application" "http://localhost:3000/health"; then
        print_success "Web application is ready!"
    else
        print_error "Web application failed to start"
        docker-compose logs webapp
        exit 1
    fi
    
    # Import n8n workflows
    print_status "Setting up n8n workflows..."
    sleep 10  # Give n8n time to fully initialize
    
    # Check service status
    print_status "Checking service status..."
    docker-compose ps
    
    echo ""
    echo -e "${GREEN}================================${NC}"
    echo -e "${GREEN}     Setup Complete! 🎉        ${NC}"
    echo -e "${GREEN}================================${NC}"
    echo ""
    echo -e "${BLUE}Access your system at:${NC}"
    echo -e "  🌐 Web Dashboard: ${GREEN}http://localhost:3000${NC}"
    echo -e "  🔧 n8n Workflows: ${GREEN}http://localhost:5678${NC}"
    echo -e "  📊 Database: ${GREEN}localhost:5432${NC}"
    echo ""
    echo -e "${BLUE}Default credentials:${NC}"
    echo -e "  n8n: ${GREEN}admin / localdev123${NC}"
    echo -e "  Database: ${GREEN}admin / localdev123${NC}"
    echo ""
    echo -e "${YELLOW}Next steps:${NC}"
    echo -e "  1. Get Vapi API key from ${BLUE}https://console.vapi.ai${NC}"
    echo -e "  2. Update .env file with your credentials"
    echo -e "  3. Restart services: ${GREEN}docker-compose restart${NC}"
    echo -e "  4. Import workflows in n8n dashboard"
    echo ""
    echo -e "${BLUE}Useful commands:${NC}"
    echo -e "  Start services: ${GREEN}docker-compose up -d${NC}"
    echo -e "  Stop services:  ${GREEN}docker-compose down${NC}"
    echo -e "  View logs:      ${GREEN}docker-compose logs -f${NC}"
    echo -e "  Restart:        ${GREEN}docker-compose restart${NC}"
    echo ""
}

# Function to cleanup on exit
cleanup() {
    print_status "Cleaning up..."
    docker-compose down --remove-orphans 2>/dev/null || true
}

# Set trap for cleanup
trap cleanup EXIT

# Run main function
main "$@" 