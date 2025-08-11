#!/bin/bash

echo "🚀 Setting up Medical Appointment Booking System"
echo "================================================"

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker first."
    exit 1
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose is not installed. Please install Docker Compose first."
    exit 1
fi

echo "✅ Docker and Docker Compose are available"

# Generate encryption key if not exists
if [ ! -f "n8n/config/.env" ]; then
    echo "🔐 Generating n8n encryption key..."
    ENCRYPTION_KEY=$(openssl rand -hex 32)
    
    # Copy environment template
    cp n8n/config/env.example n8n/config/.env
    
    # Replace encryption key
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        sed -i '' "s/your-32-character-encryption-key-here/$ENCRYPTION_KEY/g" n8n/config/.env
    else
        # Linux
        sed -i "s/your-32-character-encryption-key-here/$ENCRYPTION_KEY/g" n8n/config/.env
    fi
    
    echo "✅ Generated and configured encryption key"
else
    echo "✅ Environment file already exists"
fi

# Start n8n
echo "🐳 Starting n8n container..."
docker-compose up -d n8n

# Wait for n8n to be ready
echo "⏳ Waiting for n8n to be ready..."
sleep 10

# Check if n8n is running
if curl -s http://localhost:5678 > /dev/null; then
    echo "✅ n8n is running at http://localhost:5678"
    echo ""
    echo "🎯 Next Steps:"
    echo "1. Open http://localhost:5678 in your browser"
    echo "2. Create your n8n account"
    echo "3. Import the workflow files from n8n/workflows/"
    echo "4. Configure your credentials (Google Calendar, Twilio, Airtable, etc.)"
    echo "5. Update the Vapi agent configuration with your n8n webhook URL"
    echo ""
    echo "📚 Documentation:"
    echo "- Main README: README.md"
    echo "- Data contracts: docs/data-contracts.md"
    echo "- Implementation guide: docs/implementation-guide.md"
else
    echo "❌ n8n failed to start. Check logs with: docker-compose logs n8n"
    exit 1
fi

echo ""
echo "🎉 Setup complete! Happy booking!" 