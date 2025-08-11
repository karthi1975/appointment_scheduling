# Implementation Guide

This guide provides step-by-step instructions for implementing the Medical Appointment Booking System.

## Prerequisites

### Required Software
- Docker and Docker Compose
- Git
- curl (for testing)
- jq (optional, for JSON formatting)

### Required Accounts & APIs
- Vapi account (for voice agent)
- n8n instance (will be created)
- Google Calendar API access
- Twilio account (for SMS)
- Airtable account (for logging)
- OpenAI API key (for triage)
- Insurance verification API access

## Step 1: System Setup

### 1.1 Clone and Navigate
```bash
git clone <your-repo-url>
cd medical-appointment-booking
```

### 1.2 Make Scripts Executable
```bash
chmod +x scripts/setup.sh
chmod +x scripts/test-endpoints.sh
```

### 1.3 Run Setup Script
```bash
./scripts/setup.sh
```

This script will:
- Check Docker installation
- Generate n8n encryption key
- Start n8n container
- Verify n8n is running

## Step 2: n8n Configuration

### 2.1 Access n8n
1. Open http://localhost:5678 in your browser
2. Create your n8n account
3. Complete the initial setup

### 2.2 Import Workflows
1. In n8n, go to **Workflows** → **Import from File**
2. Import each workflow in this order:
   - `n8n/workflows/triage-agent.json`
   - `n8n/workflows/scheduler-agent.json`
   - `n8n/workflows/insurance-agent.json`
   - `n8n/workflows/reminder-agent.json`
   - `n8n/workflows/orchestrator.json`

### 2.3 Configure Credentials
Set up the following credentials in n8n:

#### Google Calendar
1. Go to **Credentials** → **Add Credential**
2. Select **Google Calendar OAuth2 API**
3. Follow OAuth2 setup process
4. Test the connection

#### Twilio
1. Go to **Credentials** → **Add Credential**
2. Select **Twilio API**
3. Enter your Account SID and Auth Token
4. Test the connection

#### Airtable
1. Go to **Credentials** → **Add Credential**
2. Select **Airtable API**
3. Enter your API key
4. Test the connection

#### OpenAI
1. Go to **Credentials** → **Add Credential**
2. Select **OpenAI API**
3. Enter your API key
4. Test the connection

### 2.4 Update Environment Variables
1. Go to **Settings** → **Environment Variables**
2. Add the following variables:
   ```
   INSURANCE_API_ENDPOINT=https://your-insurance-api.com/verify
   INSURANCE_API_KEY=your-insurance-api-key
   TWILIO_PHONE_NUMBER=+18005551234
   AIRTABLE_BASE_ID=your-airtable-base-id
   ```

## Step 3: Vapi Agent Configuration

### 3.1 Create Vapi Project
1. Go to [Vapi Console](https://console.vapi.ai)
2. Create a new project
3. Note your project ID

### 3.2 Configure Agent
1. Import the agent configuration from `vapi/agent-config.json`
2. Update the webhook URLs with your n8n domain:
   ```json
   "url": "https://your-n8n-domain.com/webhook/vapi-intake"
   ```

### 3.3 Test Agent
1. Use the Vapi testing interface
2. Make a test call to verify the agent responds correctly
3. Check that webhooks are being sent to n8n

## Step 4: Testing

### 4.1 Test Endpoints
```bash
./scripts/test-endpoints.sh
```

This will test:
- Basic connectivity
- POST requests with test payloads
- Response format validation
- Missing field handling

### 4.2 Manual Testing
1. **Test Triage**: Send symptoms, verify specialty classification
2. **Test Scheduling**: Verify calendar integration
3. **Test Insurance**: Test with missing DOB scenario
4. **Test Reminders**: Verify SMS and email sending

### 4.3 Monitor Logs
1. Check n8n workflow execution logs
2. Monitor Airtable for case logging
3. Verify calendar entries are created
4. Check SMS/email delivery

## Step 5: Production Deployment

### 5.1 Update Configuration
1. Change `N8N_HOST` to your production domain
2. Update `N8N_PROTOCOL` to `https`
3. Configure SSL certificates
4. Update Vapi webhook URLs

### 5.2 Security Configuration
1. **Webhook Authentication**: Add HMAC or bearer token auth
2. **IP Allowlisting**: Restrict to Vapi egress IPs
3. **Rate Limiting**: Configure appropriate limits
4. **Data Masking**: Never log raw PHI

### 5.3 Monitoring Setup
1. **Error Alerts**: Configure n8n error workflows
2. **Logging**: Set up centralized logging
3. **Metrics**: Track success rates and latency
4. **Health Checks**: Set up endpoint monitoring

## Step 6: Go Live

### 6.1 Final Verification
1. Test complete appointment booking flow
2. Verify all integrations are working
3. Check error handling scenarios
4. Test with real phone numbers

### 6.2 Point Vapi Number
1. Configure your Vapi phone number
2. Route calls to your agent
3. Test with real calls
4. Monitor for any issues

### 6.3 Operational Checklist
- [ ] All workflows are active
- [ ] Credentials are properly configured
- [ ] Error notifications are working
- [ ] Case logging is functional
- [ ] Calendar integration is working
- [ ] SMS/email delivery is confirmed

## Troubleshooting

### Common Issues

#### n8n Not Starting
```bash
# Check logs
docker-compose logs n8n

# Restart container
docker-compose restart n8n
```

#### Workflow Execution Errors
1. Check credential configuration
2. Verify environment variables
3. Check workflow connections
4. Review execution logs

#### Vapi Integration Issues
1. Verify webhook URLs are correct
2. Check n8n is accessible from Vapi
3. Verify webhook authentication
4. Test with simple payloads

#### Calendar Integration Issues
1. Check Google Calendar API permissions
2. Verify calendar ID is correct
3. Check OAuth2 token expiration
4. Test calendar operations manually

### Debug Mode
Enable debug logging in n8n:
1. Go to **Settings** → **Logging**
2. Set log level to **debug**
3. Restart n8n
4. Check detailed execution logs

## Performance Optimization

### Workflow Optimization
1. **Parallel Execution**: Run independent agents in parallel
2. **Caching**: Cache insurance verification results
3. **Batch Processing**: Group similar operations
4. **Timeout Management**: Set appropriate timeouts

### Resource Management
1. **Database Indexing**: Optimize Airtable queries
2. **API Rate Limits**: Respect provider limits
3. **Connection Pooling**: Reuse HTTP connections
4. **Memory Management**: Monitor n8n resource usage

## Maintenance

### Regular Tasks
1. **Credential Rotation**: Update API keys regularly
2. **Log Review**: Monitor for errors and anomalies
3. **Performance Monitoring**: Track response times
4. **Backup**: Export workflow configurations

### Updates
1. **n8n Updates**: Keep n8n version current
2. **API Updates**: Monitor for breaking changes
3. **Security Patches**: Apply security updates promptly
4. **Feature Updates**: Evaluate new capabilities

## Support

### Documentation
- [n8n Documentation](https://docs.n8n.io/)
- [Vapi Documentation](https://docs.vapi.ai/)
- [Google Calendar API](https://developers.google.com/calendar)
- [Twilio API](https://www.twilio.com/docs)

### Community
- [n8n Community](https://community.n8n.io/)
- [Vapi Discord](https://discord.gg/vapi)

### Professional Support
- Consider enterprise support for production deployments
- Engage with API providers for integration issues
- Consult with healthcare compliance experts 