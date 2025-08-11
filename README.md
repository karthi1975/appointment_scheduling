# 🏥 Medical Appointment Booking System

A complete AI-powered medical appointment booking system using **Vapi voice agents** and **n8n workflow automation**. This system demonstrates how AI agents can work together to handle the entire appointment booking process through natural voice conversations.

## 🚀 Features

- **🤖 5 AI Voice Agents**: Orchestrator, Triage, Scheduler, Insurance, and Reminder
- **🔧 n8n Workflow Automation**: Visual workflow orchestration for complex business logic
- **🌐 Real-time Dashboard**: Live flow visualization and system monitoring
- **📱 Voice-First Interface**: Natural language appointment booking
- **💾 Local Database**: PostgreSQL with sample medical data
- **🔒 Secure & Scalable**: Docker-based architecture with health checks

## 🏗️ Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Vapi Voice    │    │   n8n Workflow  │    │   Web Dashboard │
│     Agents      │◄──►│   Orchestrator  │◄──►│   (React/HTML)  │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         │                       ▼                       │
         │              ┌─────────────────┐              │
         │              │   PostgreSQL    │              │
         │              │   Database      │              │
         │              └─────────────────┘              │
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│  Voice Input    │    │  Workflow Data  │    │  Real-time UI   │
│  Processing     │    │  Persistence    │    │  Updates        │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## 📋 Prerequisites

- **Docker** (20.10+) and **Docker Compose** (2.0+)
- **Node.js** (18+) for development
- **Vapi API Key** (free tier available at [console.vapi.ai](https://console.vapi.ai))

## 🚀 Quick Start (5 minutes)

### 1. Clone and Setup
```bash
# Navigate to your project directory
cd /Users/karthi/proto_projects

# Make setup script executable
chmod +x scripts/setup-local.sh

# Run the automated setup
./scripts/setup-local.sh
```

### 2. Get Vapi API Key
- Visit [console.vapi.ai](https://console.vapi.ai)
- Create a free account
- Get your API key and agent ID
- Update `.env` file with your credentials

### 3. Start Services
```bash
# Start all services
docker-compose up -d

# Check status
docker-compose ps

# View logs
docker-compose logs -f
```

### 4. Access Your System
- **🌐 Web Dashboard**: [http://localhost:3000](http://localhost:3000)
- **🔧 n8n Workflows**: [http://localhost:5678](http://localhost:5678)
- **📊 Database**: localhost:5432

## 🔧 Manual Setup

### Environment Configuration
```bash
# Copy environment template
cp n8n/config/env.example .env

# Edit with your API keys
nano .env
```

**Required Environment Variables:**
```env
# Vapi Voice Agent (Required)
VAPI_API_KEY=your_vapi_api_key_here
VAPI_AGENT_ID=your_vapi_agent_id_here

# Optional APIs
OPENAI_API_KEY=your_openai_api_key_here
GOOGLE_CALENDAR_CLIENT_ID=your_google_client_id_here
INSURANCE_API_KEY=your_insurance_api_key_here
```

### Database Setup
```bash
# Start database only
docker-compose up -d database

# Wait for database to be ready
docker-compose exec database pg_isready -U admin -d medical_booking

# Initialize with sample data
docker-compose exec database psql -U admin -d medical_booking -f /docker-entrypoint-initdb.d/init.sql
```

### n8n Configuration
```bash
# Start n8n
docker-compose up -d n8n

# Wait for n8n to be ready
curl -f http://localhost:5678/healthz

# Access n8n dashboard
open http://localhost:5678
```

**Default n8n Credentials:**
- **Username**: `admin`
- **Password**: `localdev123`

## 🧪 Testing Your Setup

### Run Complete Test Suite
```bash
# Make test script executable
chmod +x scripts/test-endpoints.sh

# Run all tests
./scripts/test-endpoints.sh
```

### Test Individual Components
```bash
# Test webapp health
curl http://localhost:3000/health

# Test n8n health
curl http://localhost:5678/healthz

# Test database connection
docker-compose exec database pg_isready -U admin -d medical_booking
```

## 🔄 n8n Workflow Management

### Import Workflows
1. Access n8n at [http://localhost:5678](http://localhost:5678)
2. Login with `admin` / `localdev123`
3. Go to **Workflows** → **Import from File**
4. Import each workflow from `n8n/workflows/` folder

### Available Workflows
- **`orchestrator.json`**: Main workflow coordinator
- **`triage-agent.json`**: Symptom classification agent
- **`scheduler-agent.json`**: Appointment scheduling agent
- **`insurance-agent.json`**: Insurance verification agent
- **`reminder-agent.json`**: Notification and reminder agent

### Workflow Testing
```bash
# Test webhook endpoint
curl -X POST http://localhost:5678/webhook/vapi-intake \
  -H "Content-Type: application/json" \
  -d '{
    "conversation_id": "test-1",
    "intent": "book_appointment",
    "caller": {"name": "John Doe", "phone": "+1234567890"},
    "symptoms": "knee pain",
    "insurance": {"payer": "Aetna", "memberId": "AET12345"}
  }'
```

## 🎯 Usage Examples

### 1. Voice Appointment Booking
1. Open web dashboard at [http://localhost:3000](http://localhost:3000)
2. Click **"Start Voice Session"**
3. Speak: *"I need to book an appointment for knee pain"*
4. Watch the AI agents coordinate in real-time
5. Complete the booking process

### 2. Flow Visualization
1. Click **"Play Flow"** to see agent interactions
2. Observe how requests flow between agents
3. Monitor real-time system logs
4. Test different appointment scenarios

### 3. n8n Workflow Monitoring
1. Access n8n dashboard at [http://localhost:5678](http://localhost:5678)
2. Monitor workflow executions
3. View execution logs and data
4. Debug and optimize workflows

## 🛠️ Development

### Project Structure
```
proto_projects/
├── docker-compose.yml          # Service orchestration
├── .env                        # Environment variables
├── data/
│   └── init.sql               # Database initialization
├── n8n/
│   ├── config/
│   │   └── env.example        # n8n configuration template
│   └── workflows/              # n8n workflow files
├── webapp/                     # Web application
│   ├── index.html             # Main dashboard
│   ├── js/                    # JavaScript components
│   ├── styles.css             # Styling
│   ├── package.json           # Dependencies
│   └── Dockerfile             # Container configuration
└── scripts/                    # Setup and testing scripts
    ├── setup-local.sh         # Automated setup
    └── test-endpoints.sh      # Endpoint testing
```

### Adding New Agents
1. Create new workflow in n8n
2. Export workflow as JSON
3. Add to `n8n/workflows/` folder
4. Update orchestrator workflow
5. Test integration

### Customizing Workflows
1. Open workflow in n8n editor
2. Modify nodes and connections
3. Test with sample data
4. Deploy changes
5. Monitor execution

## 🔍 Troubleshooting

### Common Issues

#### Services Won't Start
```bash
# Check Docker status
docker info

# View detailed logs
docker-compose logs -f [service_name]

# Restart specific service
docker-compose restart [service_name]
```

#### n8n Connection Issues
```bash
# Check n8n health
curl http://localhost:5678/healthz

# Verify credentials
curl -u admin:localdev123 http://localhost:5678/api/v1/credentials

# Restart n8n
docker-compose restart n8n
```

#### Database Connection Issues
```bash
# Check database status
docker-compose exec database pg_isready -U admin -d medical_booking

# View database logs
docker-compose logs database

# Reset database
docker-compose down -v
docker-compose up -d
```

### Performance Issues
```bash
# Check resource usage
docker stats

# Monitor logs
docker-compose logs -f --tail=100

# Restart all services
docker-compose restart
```

## 📊 Monitoring & Logs

### System Health
```bash
# Check all services
docker-compose ps

# View real-time logs
docker-compose logs -f

# Monitor resource usage
docker stats
```

### Application Logs
- **Webapp**: `docker-compose logs -f webapp`
- **n8n**: `docker-compose logs -f n8n`
- **Database**: `docker-compose logs -f database`

### API Monitoring
```bash
# Health check
curl http://localhost:3000/health

# System status
curl http://localhost:3000/api/status

# Test n8n connection
curl -X POST http://localhost:3000/api/test-n8n
```

## 🚀 Production Deployment

### Environment Variables
```env
# Production settings
NODE_ENV=production
N8N_BASIC_AUTH_PASSWORD=your_secure_password
DATABASE_URL=postgresql://user:pass@host:port/db
```

### Security Considerations
- Change default passwords
- Use SSL/TLS certificates
- Implement rate limiting
- Set up monitoring and alerting
- Regular security updates

### Scaling
- Use external PostgreSQL database
- Implement load balancing
- Set up Redis for caching
- Monitor resource usage

## 📚 API Documentation

### Webapp Endpoints
- `GET /health` - Health check
- `GET /api/status` - System status
- `GET /api/logs` - System logs
- `POST /api/test-n8n` - Test n8n connection

### n8n Webhooks
- `POST /webhook/vapi-intake` - Vapi voice agent input
- `POST /webhook/appointment-update` - Appointment updates
- `POST /webhook/insurance-verification` - Insurance checks

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🆘 Support

### Getting Help
- Check the troubleshooting section above
- Review n8n documentation at [n8n.io](https://n8n.io)
- Review Vapi documentation at [docs.vapi.ai](https://docs.vapi.ai)

### Community Resources
- n8n Community: [community.n8n.io](https://community.n8n.io)
- Vapi Community: [discord.gg/vapi](https://discord.gg/vapi)

---

**🎉 Your Medical Appointment Booking System is ready!**

Start with the [Quick Start](#-quick-start-5-minutes) section to get up and running in minutes. 