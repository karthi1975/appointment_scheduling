# 🚀 Quick Start Guide - Medical Appointment Booking System

Get your AI-powered medical appointment booking system running in **5 minutes**!

## ⚡ Super Quick Start (2 minutes)

```bash
# 1. Navigate to your project
cd /Users/karthi/proto_projects

# 2. Run automated setup
chmod +x scripts/setup-local.sh
./scripts/setup-local.sh

# 3. Get Vapi API key from console.vapi.ai
# 4. Update .env file with your key
# 5. Restart services
docker-compose restart
```

**🎉 Done! Your system is running at:**
- **Dashboard**: http://localhost:3000
- **n8n**: http://localhost:5678 (admin/localdev123)

---

## 📋 Step-by-Step Setup

### Step 1: Prerequisites Check
```bash
# Check if Docker is running
docker --version
docker-compose --version

# If not installed, get Docker from docker.com
```

### Step 2: Automated Setup
```bash
# Make script executable and run
chmod +x scripts/setup-local.sh
./scripts/setup-local.sh
```

**What this does:**
- ✅ Creates necessary directories
- ✅ Sets up Docker containers
- ✅ Initializes PostgreSQL database
- ✅ Starts n8n workflow engine
- ✅ Launches web application
- ✅ Creates sample medical data

### Step 3: Get Vapi API Key
1. Visit [console.vapi.ai](https://console.vapi.ai)
2. Create free account
3. Get your API key and agent ID
4. Update `.env` file:

```env
VAPI_API_KEY=your_actual_api_key_here
VAPI_AGENT_ID=your_actual_agent_id_here
```

### Step 4: Restart & Test
```bash
# Restart services with new credentials
docker-compose restart

# Test everything is working
./scripts/test-endpoints.sh
```

---

## 🎯 What You Get

### 🌐 Web Dashboard (http://localhost:3000)
- **Flow Visualization**: See AI agents working together
- **Voice Interface**: Simulate voice conversations
- **Real-time Monitoring**: Live system status and logs
- **Professional UI**: Medical-themed, responsive design

### 🔧 n8n Workflows (http://localhost:5678)
- **5 Agent Workflows**: Orchestrator, Triage, Scheduler, Insurance, Reminder
- **Visual Editor**: Drag-and-drop workflow design
- **Real-time Execution**: Monitor workflow runs
- **Webhook Integration**: Connect with Vapi voice agents

### 💾 Database (localhost:5432)
- **Sample Data**: 3 patients, 3 appointments, 4 providers
- **Medical Schema**: Appointments, patients, insurance, providers
- **Real-time Updates**: Live data synchronization

---

## 🧪 Test Your System

### Quick Health Check
```bash
# Test webapp
curl http://localhost:3000/health

# Test n8n
curl http://localhost:5678/healthz

# Test database
docker-compose exec database pg_isready -U admin -d medical_booking
```

### Full Test Suite
```bash
# Run comprehensive tests
./scripts/test-endpoints.sh
```

### Manual Testing
1. **Open Dashboard**: http://localhost:3000
2. **Click "Play Flow"**: Watch agent visualization
3. **Click "Start Voice Session"**: Test voice interface
4. **Check n8n**: http://localhost:5678 (admin/localdev123)

---

## 🔄 Daily Usage

### Start Services
```bash
docker-compose up -d
```

### Stop Services
```bash
docker-compose down
```

### View Logs
```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f webapp
docker-compose logs -f n8n
docker-compose logs -f database
```

### Restart Services
```bash
# All services
docker-compose restart

# Specific service
docker-compose restart webapp
```

---

## 🚨 Troubleshooting

### Services Won't Start
```bash
# Check Docker
docker info

# Check ports
lsof -i :3000
lsof -i :5678
lsof -i :5432

# View logs
docker-compose logs -f
```

### Can't Access Dashboard
```bash
# Check webapp status
docker-compose ps webapp

# Restart webapp
docker-compose restart webapp

# Check logs
docker-compose logs webapp
```

### n8n Issues
```bash
# Check n8n status
docker-compose ps n8n

# Restart n8n
docker-compose restart n8n

# Check credentials
curl -u admin:localdev123 http://localhost:5678/api/v1/credentials
```

### Database Issues
```bash
# Check database
docker-compose exec database pg_isready -U admin -d medical_booking

# Reset database
docker-compose down -v
docker-compose up -d
```

---

## 📱 Next Steps

### 1. Import n8n Workflows
1. Go to http://localhost:5678
2. Login: admin/localdev123
3. Import workflows from `n8n/workflows/` folder

### 2. Test Voice Integration
1. Get Vapi API key
2. Update `.env` file
3. Test voice conversations

### 3. Customize Workflows
1. Open workflows in n8n editor
2. Modify nodes and connections
3. Test with sample data

### 4. Add Real APIs
1. Google Calendar integration
2. Insurance verification APIs
3. SMS/email services

---

## 🎉 Success Indicators

You'll know it's working when you see:

✅ **Docker containers** all showing "Up" status  
✅ **Web dashboard** accessible at localhost:3000  
✅ **n8n workflows** visible at localhost:5678  
✅ **Flow visualization** showing 5 connected agents  
✅ **Voice interface** responding to button clicks  
✅ **Sample data** in the appointment status panel  

---

## 🆘 Need Help?

- **Check logs**: `docker-compose logs -f`
- **Run tests**: `./scripts/test-endpoints.sh`
- **Restart all**: `docker-compose restart`
- **Full reset**: `docker-compose down -v && docker-compose up -d`

**🎯 Your Medical Appointment Booking System is ready to revolutionize healthcare!** 