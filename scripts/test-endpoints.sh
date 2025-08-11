#!/bin/bash

# Medical Appointment Booking System - Endpoint Test Script
# This script tests all endpoints and services to ensure they're working correctly

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[TEST]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[PASS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[FAIL]${NC} $1"
}

# Function to test HTTP endpoint
test_endpoint() {
    local name=$1
    local url=$2
    local expected_status=$3
    local method=${4:-GET}
    local data=${5:-""}
    
    print_status "Testing $name: $method $url"
    
    if [ -n "$data" ]; then
        response=$(curl -s -w "%{http_code}" -X "$method" -H "Content-Type: application/json" -d "$data" "$url" 2>/dev/null || echo "000")
    else
        response=$(curl -s -w "%{http_code}" -X "$method" "$url" 2>/dev/null || echo "000")
    fi
    
    # Extract status code (last 3 characters)
    status_code="${response: -3}"
    # Extract response body (everything except last 3 characters)
    response_body="${response%???}"
    
    if [ "$status_code" = "$expected_status" ]; then
        print_success "$name: HTTP $status_code"
        return 0
    else
        print_error "$name: Expected HTTP $expected_status, got HTTP $status_code"
        if [ -n "$response_body" ]; then
            echo "Response: $response_body"
        fi
        return 1
    fi
}

# Function to test database connection
test_database() {
    print_status "Testing database connection..."
    
    if docker-compose exec -T database pg_isready -U admin -d medical_booking >/dev/null 2>&1; then
        print_success "Database connection: OK"
        return 0
    else
        print_error "Database connection: FAILED"
        return 1
    fi
}

# Function to test n8n workflows
test_n8n_workflows() {
    print_status "Testing n8n workflows..."
    
    local n8n_url="http://localhost:5678"
    local username="admin"
    local password="localdev123"
    
    # Test n8n health
    if curl -s -f "$n8n_url/healthz" >/dev/null 2>&1; then
        print_success "n8n health check: OK"
    else
        print_error "n8n health check: FAILED"
        return 1
    fi
    
    # Test n8n authentication
    local auth_response=$(curl -s -w "%{http_code}" -u "$username:$password" "$n8n_url/api/v1/credentials" 2>/dev/null || echo "000")
    local auth_status="${auth_response: -3}"
    
    if [ "$auth_status" = "200" ]; then
        print_success "n8n authentication: OK"
    else
        print_error "n8n authentication: FAILED (HTTP $auth_status)"
        return 1
    fi
    
    return 0
}

# Function to test Docker services
test_docker_services() {
    print_status "Testing Docker services..."
    
    local services=("database" "n8n" "webapp")
    local all_healthy=true
    
    for service in "${services[@]}"; do
        if docker-compose ps "$service" | grep -q "Up"; then
            print_success "$service: Running"
        else
            print_error "$service: Not running"
            all_healthy=false
        fi
    done
    
    if [ "$all_healthy" = true ]; then
        return 0
    else
        return 1
    fi
}

# Function to test API endpoints
test_api_endpoints() {
    print_status "Testing API endpoints..."
    
    local base_url="http://localhost:3000"
    local all_tests_passed=true
    
    # Test health endpoint
    if test_endpoint "Health Check" "$base_url/health" "200"; then
        print_success "Health endpoint: OK"
    else
        print_error "Health endpoint: FAILED"
        all_tests_passed=false
    fi
    
    # Test status endpoint
    if test_endpoint "Status API" "$base_url/api/status" "200"; then
        print_success "Status API: OK"
    else
        print_error "Status API: FAILED"
        all_tests_passed=false
    fi
    
    # Test logs endpoint
    if test_endpoint "Logs API" "$base_url/api/logs" "200"; then
        print_success "Logs API: OK"
    else
        print_error "Logs API: FAILED"
        all_tests_passed=false
    fi
    
    # Test n8n connection endpoint
    if test_endpoint "n8n Test API" "$base_url/api/test-n8n" "200" "POST"; then
        print_success "n8n Test API: OK"
    else
        print_error "n8n Test API: FAILED"
        all_tests_passed=false
    fi
    
    if [ "$all_tests_passed" = true ]; then
        return 0
    else
        return 1
    fi
}

# Function to test webapp functionality
test_webapp_functionality() {
    print_status "Testing webapp functionality..."
    
    local base_url="http://localhost:3000"
    local all_tests_passed=true
    
    # Test main page
    if test_endpoint "Main Page" "$base_url/" "200"; then
        print_success "Main page: OK"
    else
        print_error "Main page: FAILED"
        all_tests_passed=false
    fi
    
    # Test static files
    if test_endpoint "CSS Styles" "$base_url/styles.css" "200"; then
        print_success "CSS styles: OK"
    else
        print_error "CSS styles: FAILED"
        all_tests_passed=false
    fi
    
    if test_endpoint "JavaScript App" "$base_url/js/app.js" "200"; then
        print_success "JavaScript app: OK"
    else
        print_error "JavaScript app: FAILED"
        all_tests_passed=false
    fi
    
    if [ "$all_tests_passed" = true ]; then
        return 0
    else
        return 1
    fi
}

# Function to run performance tests
test_performance() {
    print_status "Running performance tests..."
    
    local base_url="http://localhost:3000"
    local start_time=$(date +%s%N)
    
    # Test response time for health endpoint
    local response_time=$(curl -s -w "%{time_total}" -o /dev/null "$base_url/health" 2>/dev/null || echo "0")
    
    local end_time=$(date +%s%N)
    local duration=$(( (end_time - start_time) / 1000000 ))  # Convert to milliseconds
    
    if (( $(echo "$response_time < 1.0" | bc -l) )); then
        print_success "Response time: ${response_time}s (Good)"
    elif (( $(echo "$response_time < 3.0" | bc -l) )); then
        print_warning "Response time: ${response_time}s (Acceptable)"
    else
        print_error "Response time: ${response_time}s (Slow)"
    fi
    
    return 0
}

# Main test function
main() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}  Medical Appointment Booking    ${NC}"
    echo -e "${BLUE}      System Test Script         ${NC}"
    echo -e "${BLUE}================================${NC}"
    echo ""
    
    local all_tests_passed=true
    
    # Test Docker services
    if test_docker_services; then
        print_success "Docker services: All running"
    else
        print_error "Docker services: Some failed"
        all_tests_passed=false
    fi
    
    echo ""
    
    # Test database
    if test_database; then
        print_success "Database: Connected"
    else
        print_error "Database: Connection failed"
        all_tests_passed=false
    fi
    
    echo ""
    
    # Test n8n
    if test_n8n_workflows; then
        print_success "n8n: Working correctly"
    else
        print_error "n8n: Some tests failed"
        all_tests_passed=false
    fi
    
    echo ""
    
    # Test API endpoints
    if test_api_endpoints; then
        print_success "API endpoints: All working"
    else
        print_error "API endpoints: Some failed"
        all_tests_passed=false
    fi
    
    echo ""
    
    # Test webapp functionality
    if test_webapp_functionality; then
        print_success "Webapp functionality: All working"
    else
        print_error "Webapp functionality: Some failed"
        all_tests_passed=false
    fi
    
    echo ""
    
    # Test performance
    if test_performance; then
        print_success "Performance tests: Completed"
    else
        print_warning "Performance tests: Some issues"
    fi
    
    echo ""
    echo -e "${BLUE}================================${NC}"
    
    if [ "$all_tests_passed" = true ]; then
        echo -e "${GREEN}🎉 All tests passed! System is working correctly.${NC}"
        echo ""
        echo -e "${BLUE}Your system is ready at:${NC}"
        echo -e "  🌐 Web Dashboard: ${GREEN}http://localhost:3000${NC}"
        echo -e "  🔧 n8n Workflows: ${GREEN}http://localhost:5678${NC}"
        echo -e "  📊 Database: ${GREEN}localhost:5432${NC}"
        exit 0
    else
        echo -e "${RED}❌ Some tests failed. Please check the errors above.${NC}"
        echo ""
        echo -e "${YELLOW}Troubleshooting tips:${NC}"
        echo -e "  1. Check Docker containers: ${GREEN}docker-compose ps${NC}"
        echo -e "  2. View logs: ${GREEN}docker-compose logs -f${NC}"
        echo -e "  3. Restart services: ${GREEN}docker-compose restart${NC}"
        echo -e "  4. Rebuild: ${GREEN}docker-compose up -d --build${NC}"
        exit 1
    fi
}

# Check if curl is available
if ! command -v curl >/dev/null 2>&1; then
    print_error "curl is required but not installed. Please install curl and try again."
    exit 1
fi

# Check if bc is available for floating point math
if ! command -v bc >/dev/null 2>&1; then
    print_warning "bc is not installed. Performance tests will be limited."
fi

# Run main function
main "$@" 