# 🚂 Railway.app Deployment Guide

Complete guide to deploy your Medical Appointment Booking System webhooks and n8n workflows to Railway.app.

## 🎯 Why Railway.app?

- **🚀 Easy Deployment**: One-click deployment from GitHub
- **🔒 Automatic HTTPS**: SSL certificates included
- **📱 Custom Domains**: Professional URLs for production
- **💰 Free Tier**: Generous free tier for development
- **🔧 Auto-scaling**: Automatic scaling based on traffic
- **📊 Built-in Monitoring**: Performance and health monitoring

## 🚀 Quick Deployment (5 minutes)

### 1. Prepare Your Repository
```bash
# Ensure all files are committed
git add .
git commit -m "Prepare for Railway deployment"
git push origin main
```

### 2. Deploy to Railway
```bash
# Install Railway CLI
npm install -g @railway/cli

# Login to Railway
railway login

# Initialize Railway project
railway init

# Deploy to Railway
railway up
```

### 3. Get Your Production URLs
```bash
# View deployment info
railway status

# Get your production URL
railway domain
```

## 🔧 Detailed Deployment Steps

### Step 1: Install Railway CLI
```bash
# Install globally
npm install -g @railway/cli

# Verify installation
railway --version
```

### Step 2: Login to Railway
```bash
# Login with your Railway account
railway login

# This will open your browser for authentication
```

### Step 3: Create Railway Project
```bash
# Navigate to your project directory
cd /Users/karthi/proto_projects

# Initialize Railway project
railway init

# Choose options:
# - Project name: medical-appointment-booking
# - Environment: development (or production)
```

### Step 4: Configure Environment Variables
```bash
# Set production environment variables
railway variables set NODE_ENV=production
railway variables set VAPI_API_KEY=your_vapi_api_key
railway variables set VAPI_AGENT_ID=your_vapi_agent_id
railway variables set DATABASE_URL=your_production_database_url
```

**Required Environment Variables:**
```env
# Production Settings
NODE_ENV=production
PORT=3000

# Vapi Configuration
VAPI_API_KEY=your_vapi_api_key_here
VAPI_AGENT_ID=your_vapi_agent_id_here

# Database (Use Railway PostgreSQL plugin)
DATABASE_URL=postgresql://username:password@host:port/database

# n8n Configuration
N8N_BASIC_AUTH_USER=admin
N8N_BASIC_AUTH_PASSWORD=your_secure_password
N8N_ENCRYPTION_KEY=your_32_character_encryption_key

# Webhook URLs (Will be set automatically)
WEBHOOK_URL=https://your-app-name.railway.app
```

### Step 5: Deploy Your Application
```bash
# Deploy to Railway
railway up

# Monitor deployment
railway logs

# Check status
railway status
```

### Step 6: Get Production URLs
```bash
# Get your production domain
railway domain

# Example output: https://medical-appointment-booking-production.up.railway.app
```

## 🌐 Update Vapi Webhook URLs

### Update Agent Configuration
Once deployed, update your Vapi agent configuration with the new production URLs:

```json
{
  "webhooks": [
    {
      "name": "appointment_booking_webhook",
      "url": "https://your-app-name.railway.app/webhook/vapi-intake",
      "description": "Production webhook for appointment booking"
    },
    {
      "name": "status_check_webhook",
      "url": "https://your-app-name.railway.app/webhook/appointment-status",
      "description": "Production webhook for status checks"
    },
    {
      "name": "reschedule_webhook",
      "url": "https://your-app-name.railway.app/webhook/appointment-reschedule",
      "description": "Production webhook for rescheduling"
    },
    {
      "name": "cancellation_webhook",
      "url": "https://your-app-name.railway.app/webhook/appointment-cancel",
      "description": "Production webhook for cancellations"
    }
  ]
}
```

### Update Vapi Console
1. Go to [console.vapi.ai](https://console.vapi.ai)
2. Select your Medical Appointment Booking agent
3. Update webhook URLs with your Railway production URLs
4. Save changes

## 🗄️ Database Setup

### Option 1: Railway PostgreSQL Plugin (Recommended)
```bash
# Add PostgreSQL plugin
railway add

# Choose PostgreSQL from the list
# Railway will automatically set DATABASE_URL
```

### Option 2: External Database
```bash
# Set external database URL
railway variables set DATABASE_URL=postgresql://user:pass@host:port/db
```

### Initialize Database
```bash
# Run database initialization
railway run "psql $DATABASE_URL -f data/init.sql"
```

## 🔐 Security Configuration

### Update n8n Credentials
```bash
# Generate secure encryption key
openssl rand -hex 16

# Set secure credentials
railway variables set N8N_BASIC_AUTH_PASSWORD=your_secure_password
railway variables set N8N_ENCRYPTION_KEY=your_generated_key
```

### Environment-Specific Variables
```bash
# Development environment
railway variables set --environment development NODE_ENV=development

# Production environment
railway variables set --environment production NODE_ENV=production
```

## 📱 Custom Domain Setup

### Add Custom Domain
```bash
# Add custom domain
railway domain add yourdomain.com

# Verify domain ownership
# Follow Railway's DNS verification instructions
```

### SSL Certificate
- Railway automatically provides SSL certificates
- Custom domains get automatic HTTPS
- No additional configuration needed

## 🧪 Testing Production Deployment

### Test Webhook Endpoints
```bash
# Test production webhooks
curl -X POST https://your-app-name.railway.app/webhook/vapi-intake \
  -H "Content-Type: application/json" \
  -d '{
    "conversation_id": "test-1",
    "intent": "book_appointment",
    "caller": {"name": "Test User", "phone": "+1234567890"},
    "symptoms": "test symptoms",
    "insurance": {"payer": "Test", "member_id": "12345"}
  }'
```

### Test Health Endpoints
```bash
# Test health check
curl https://your-app-name.railway.app/health

# Test n8n health
curl https://your-app-name.railway.app/n8n/healthz
```

### Test Vapi Integration
1. **Update Vapi webhook URLs** with production URLs
2. **Make a test call** to your Vapi number
3. **Monitor logs** in Railway dashboard
4. **Check n8n executions** in production

## 📊 Monitoring & Logs

### View Application Logs
```bash
# View real-time logs
railway logs

# View logs for specific service
railway logs --service webapp
```

### Monitor Performance
- **Railway Dashboard**: Built-in performance monitoring
- **Health Checks**: Automatic health monitoring
- **Metrics**: CPU, memory, and response time tracking

### Set Up Alerts
```bash
# Set up monitoring alerts
railway alerts add --service webapp --metric cpu --threshold 80
railway alerts add --service webapp --metric memory --threshold 80
```

## 🔄 Continuous Deployment

### GitHub Integration
1. **Connect GitHub repository** in Railway dashboard
2. **Enable auto-deploy** on push to main branch
3. **Set deployment environments** (dev/prod)

### Deployment Commands
```bash
# Deploy to development
railway up --environment development

# Deploy to production
railway up --environment production

# Deploy specific service
railway up --service webapp
```

## 🚨 Troubleshooting

### Common Issues

#### Deployment Fails
```bash
# Check build logs
railway logs

# Verify Dockerfile
docker build -f Dockerfile.railway .

# Check environment variables
railway variables list
```

#### Webhooks Not Working
```bash
# Test webhook endpoints
curl -v https://your-app-name.railway.app/webhook/vapi-intake

# Check n8n status
curl https://your-app-name.railway.app/n8n/healthz

# Verify environment variables
railway variables list
```

#### Database Connection Issues
```bash
# Test database connection
railway run "psql $DATABASE_URL -c 'SELECT 1'"

# Check database URL
railway variables get DATABASE_URL
```

### Debug Commands
```bash
# SSH into Railway container
railway shell

# Run commands in Railway environment
railway run "node -v"

# View service status
railway status
```

## 💰 Cost Optimization

### Free Tier Limits
- **Monthly Usage**: 500 hours
- **Bandwidth**: 1GB/month
- **Storage**: 1GB
- **Custom Domains**: 1 domain

### Upgrade Options
- **Pro Plan**: $20/month for higher limits
- **Team Plan**: $40/month for team collaboration
- **Enterprise**: Custom pricing for large deployments

## 🔄 Migration from Local

### Update Local Configuration
```bash
# Update local .env with production URLs
echo "PRODUCTION_URL=https://your-app-name.railway.app" >> .env
echo "PRODUCTION_WEBHOOKS=true" >> .env
```

### Test Local vs Production
```bash
# Test local endpoints
./scripts/test-endpoints.sh

# Test production endpoints
curl https://your-app-name.railway.app/health
```

## 🎉 Success Indicators

You'll know your Railway deployment is working when:

✅ **Application deploys** without errors  
✅ **Health endpoint** returns 200 status  
✅ **Webhook endpoints** are accessible  
✅ **n8n workflows** execute successfully  
✅ **Vapi calls** process through production  
✅ **Custom domain** works with HTTPS  
✅ **Database connections** are stable  

## 🆘 Need Help?

### Railway Resources
- **Documentation**: [docs.railway.app](https://docs.railway.app)
- **Community**: [discord.gg/railway](https://discord.gg/railway)
- **Support**: [railway.app/support](https://railway.app/support)

### Local Testing
- **Test Scripts**: `./scripts/test-endpoints.sh`
- **Vapi Tests**: `node vapi/api-test.js`
- **Railway CLI**: `railway --help`

---

## 🚀 Deploy Now!

**1. Install Railway CLI**: `npm install -g @railway/cli`  
**2. Login**: `railway login`  
**3. Initialize**: `railway init`  
**4. Deploy**: `railway up`  
**5. Update Vapi**: Use production webhook URLs  

**🎯 Your Medical Appointment Booking System will be live on Railway with automatic HTTPS, scaling, and monitoring!** 🏥🚂 