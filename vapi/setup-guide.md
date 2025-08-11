# 🎤 Vapi Voice Agent Setup Guide

Complete setup guide for your Medical Appointment Booking Voice Agent using Vapi.

## 🚀 Quick Setup (5 minutes)

### 1. Create Vapi Account
- Visit [console.vapi.ai](https://console.vapi.ai)
- Click **"Get Started"** or **"Sign Up"**
- Create your free account
- Verify your email address

### 2. Create New Project
- Click **"Create New Project"**
- Name: `Medical Appointment Booking`
- Description: `AI voice agent for medical appointment scheduling`
- Click **"Create Project"**

### 3. Import Agent Configuration
- In your project, click **"Create Agent"**
- Choose **"Import from JSON"**
- Upload the `vapi/agent-config.json` file
- Click **"Import"**

### 4. Configure Voice Settings
- **Voice Provider**: Deepgram (recommended)
- **Model**: nova-2 (best quality)
- **Language**: English (US)
- **Speed**: 1.0 (normal)
- **Temperature**: 0.7 (balanced creativity)

### 5. Get API Credentials
- Go to **Project Settings** → **API Keys**
- Copy your **Project API Key**
- Note your **Agent ID**

## 🔧 Detailed Configuration

### Agent Settings
```json
{
  "name": "Medical Appointment Booking Agent",
  "description": "AI voice agent for booking medical appointments",
  "model": "gpt-4",
  "voice": "deepgram-nova-2",
  "language": "en-US"
}
```

### System Prompt
The system prompt is already configured in your agent and includes:
- **Professional medical assistant** persona
- **Patient intake** procedures
- **Symptom assessment** guidelines
- **Insurance verification** requirements
- **Appointment scheduling** workflow
- **HIPAA compliance** guidelines

### Available Tools
Your agent has access to these tools:

1. **`orchestrate_appointment_booking`** - Main booking workflow
2. **`check_appointment_status`** - Check existing appointments
3. **`reschedule_appointment`** - Modify appointment times
4. **`cancel_appointment`** - Cancel appointments
5. **`verify_insurance_coverage`** - Insurance verification

## 🌐 Webhook Configuration

### Local Development URLs
```json
{
  "appointment_booking_webhook": "http://localhost:5678/webhook/vapi-intake",
  "status_check_webhook": "http://localhost:5678/webhook/appointment-status",
  "reschedule_webhook": "http://localhost:5678/webhook/appointment-reschedule",
  "cancellation_webhook": "http://localhost:5678/webhook/appointment-cancel"
}
```

### Production URLs (Update these)
```json
{
  "appointment_booking_webhook": "https://your-domain.com/webhook/vapi-intake",
  "status_check_webhook": "https://your-domain.com/webhook/appointment-status",
  "reschedule_webhook": "https://your-domain.com/webhook/appointment-reschedule",
  "cancellation_webhook": "https://your-domain.com/webhook/appointment-cancel"
}
```

## 📱 Phone Number Setup

### 1. Get Phone Number
- In your Vapi project, go to **"Phone Numbers"**
- Click **"Get Phone Number"**
- Choose your preferred area code
- Select the number you want

### 2. Assign to Agent
- Select your phone number
- Click **"Assign Agent"**
- Choose your Medical Appointment Booking Agent
- Click **"Assign"**

### 3. Test Call
- Call your assigned phone number
- The agent should answer and introduce itself
- Test the greeting: *"Hello, I need to book an appointment"*

## 🔐 Environment Configuration

### Update Your .env File
```bash
# Copy environment template
cp n8n/config/env.example .env

# Edit with your Vapi credentials
nano .env
```

**Required Vapi Settings:**
```env
# Vapi Voice Agent (Required)
VAPI_API_KEY=your_vapi_api_key_here
VAPI_AGENT_ID=your_vapi_agent_id_here

# Optional: Phone number for testing
VAPI_PHONE_NUMBER=+1234567890
```

### Get Your Credentials
1. **API Key**: Project Settings → API Keys → Copy Project API Key
2. **Agent ID**: Agents → Your Agent → Copy Agent ID
3. **Phone Number**: Phone Numbers → Copy assigned number

## 🧪 Testing Your Agent

### 1. Test Call Flow
```
Call your Vapi number → Agent answers → Say "I need an appointment"
Agent collects: Name, Phone, Symptoms, Insurance
Agent processes through n8n workflows
Agent confirms appointment details
```

### 2. Test Scenarios
- **New Patient**: "Hi, I'm John Doe, I need to see a doctor for knee pain"
- **Insurance Check**: "Can you verify my Aetna coverage?"
- **Appointment Status**: "What time is my appointment tomorrow?"
- **Reschedule**: "I need to change my 2 PM appointment"

### 3. Monitor in Vapi Console
- Go to **"Calls"** in your project
- View real-time call logs
- Check agent responses
- Monitor tool usage

## 🔄 Integration with n8n

### 1. Ensure n8n is Running
```bash
# Check n8n status
docker-compose ps n8n

# View n8n logs
docker-compose logs -f n8n

# Access n8n dashboard
open http://localhost:5678
```

### 2. Verify Webhook Endpoints
```bash
# Test webhook connectivity
curl -X POST http://localhost:5678/webhook/vapi-intake \
  -H "Content-Type: application/json" \
  -d '{
    "conversation_id": "test-1",
    "intent": "book_appointment",
    "caller": {"name": "Test User", "phone": "+1234567890"},
    "symptoms": "test symptoms",
    "insurance": {"payer": "Test", "member_id": "12345"}
  }'
```

### 3. Check Workflow Execution
- In n8n dashboard, go to **"Executions"**
- Look for recent webhook executions
- Verify data flow through workflows
- Check for any errors

## 🎯 Voice Agent Features

### Professional Medical Assistant
- **Warm greeting** and clear identification
- **Systematic information gathering**
- **HIPAA compliant** communication
- **Professional yet empathetic** tone

### Intelligent Conversation Flow
- **Context awareness** throughout conversation
- **Natural language understanding**
- **Efficient information collection**
- **Clear confirmation** of details

### Multi-Tool Capability
- **Appointment booking** orchestration
- **Insurance verification**
- **Status checking**
- **Rescheduling and cancellation**

## 🚨 Troubleshooting

### Common Issues

#### Agent Not Answering
```bash
# Check agent status in Vapi console
# Verify phone number assignment
# Check agent is active and enabled
```

#### Webhook Errors
```bash
# Test n8n connectivity
curl http://localhost:5678/healthz

# Check webhook URLs in agent config
# Verify n8n workflows are active
```

#### Voice Quality Issues
```bash
# Check voice provider settings
# Verify Deepgram configuration
# Test with different voice models
```

### Debug Steps
1. **Check Vapi Console**: Look for call logs and errors
2. **Monitor n8n Logs**: Check webhook executions
3. **Test Webhooks**: Verify endpoint connectivity
4. **Check Agent Config**: Ensure tools are properly configured

## 📊 Monitoring & Analytics

### Vapi Analytics
- **Call Volume**: Number of calls per day/week
- **Success Rate**: Successful vs. failed calls
- **Tool Usage**: Which tools are used most
- **Call Duration**: Average conversation length

### n8n Monitoring
- **Workflow Executions**: Success/failure rates
- **Response Times**: How fast workflows complete
- **Error Logs**: Any workflow failures
- **Data Flow**: Information passing between agents

## 🔒 Security & Compliance

### HIPAA Compliance
- **No PHI storage** in Vapi
- **Secure webhook transmission**
- **Encrypted data storage** in n8n
- **Audit logging** for all interactions

### Data Privacy
- **Minimal data collection**
- **Secure API communication**
- **Regular security updates**
- **Access control** and authentication

## 🚀 Production Deployment

### Environment Updates
```env
# Production settings
NODE_ENV=production
VAPI_API_KEY=your_production_api_key
VAPI_AGENT_ID=your_production_agent_id
VAPI_WEBHOOK_URL=https://your-domain.com
```

### SSL/TLS Configuration
- **HTTPS webhooks** for production
- **SSL certificates** for your domain
- **Secure API communication**
- **Encrypted data transmission**

### Scaling Considerations
- **Multiple phone numbers** for high volume
- **Load balancing** for webhook endpoints
- **Database optimization** for performance
- **Monitoring and alerting** systems

## 🎉 Success Indicators

You'll know your Vapi agent is working when:

✅ **Agent answers calls** with professional greeting  
✅ **Collects patient information** systematically  
✅ **Processes requests** through n8n workflows  
✅ **Provides clear confirmations** and next steps  
✅ **Handles multiple scenarios** (booking, status, reschedule)  
✅ **Maintains conversation context** throughout calls  

---

## 🆘 Need Help?

- **Vapi Documentation**: [docs.vapi.ai](https://docs.vapi.ai)
- **Vapi Community**: [discord.gg/vapi](https://discord.gg/vapi)
- **n8n Documentation**: [docs.n8n.io](https://docs.n8n.io)
- **System Logs**: Check Vapi console and n8n logs

**🎯 Your Vapi Voice Agent is ready to revolutionize medical appointment booking!** 