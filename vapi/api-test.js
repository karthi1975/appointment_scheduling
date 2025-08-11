#!/usr/bin/env node

/**
 * Vapi API Test Script
 * Tests connectivity and functionality of your Vapi voice agent
 */

const https = require('https');
const readline = require('readline');

// Configuration
const config = {
  apiKey: process.env.VAPI_API_KEY || 'your_vapi_api_key_here',
  agentId: process.env.VAPI_AGENT_ID || 'your_vapi_agent_id_here',
  baseUrl: 'https://api.vapi.ai',
  timeout: 30000
};

// Colors for console output
const colors = {
  reset: '\x1b[0m',
  bright: '\x1b[1m',
  red: '\x1b[31m',
  green: '\x1b[32m',
  yellow: '\x1b[33m',
  blue: '\x1b[34m',
  magenta: '\x1b[35m',
  cyan: '\x1b[36m'
};

// Utility functions
function log(message, color = 'reset') {
  console.log(`${colors[color]}${message}${colors.reset}`);
}

function logSuccess(message) {
  log(`✅ ${message}`, 'green');
}

function logError(message) {
  log(`❌ ${message}`, 'red');
}

function logWarning(message) {
  log(`⚠️  ${message}`, 'yellow');
}

function logInfo(message) {
  log(`ℹ️  ${message}`, 'blue');
}

// HTTP request helper
function makeRequest(options, data = null) {
  return new Promise((resolve, reject) => {
    const req = https.request(options, (res) => {
      let responseData = '';
      
      res.on('data', (chunk) => {
        responseData += chunk;
      });
      
      res.on('end', () => {
        try {
          const parsed = JSON.parse(responseData);
          resolve({
            statusCode: res.statusCode,
            headers: res.headers,
            data: parsed
          });
        } catch (error) {
          resolve({
            statusCode: res.statusCode,
            headers: res.headers,
            data: responseData
          });
        }
      });
    });
    
    req.on('error', (error) => {
      reject(error);
    });
    
    req.on('timeout', () => {
      req.destroy();
      reject(new Error('Request timeout'));
    });
    
    req.setTimeout(config.timeout);
    
    if (data) {
      req.write(JSON.stringify(data));
    }
    
    req.end();
  });
}

// Test functions
async function testApiKey() {
  logInfo('Testing Vapi API key...');
  
  try {
    const options = {
      hostname: 'api.vapi.ai',
      port: 443,
      path: '/v1/agents',
      method: 'GET',
      headers: {
        'Authorization': `Bearer ${config.apiKey}`,
        'Content-Type': 'application/json'
      }
    };
    
    const response = await makeRequest(options);
    
    if (response.statusCode === 200) {
      logSuccess('API key is valid');
      if (response.data && response.data.data) {
        logInfo(`Found ${response.data.data.length} agents`);
        return true;
      }
    } else {
      logError(`API key test failed: ${response.statusCode}`);
      return false;
    }
  } catch (error) {
    logError(`API key test error: ${error.message}`);
    return false;
  }
}

async function testAgentAccess() {
  logInfo('Testing agent access...');
  
  try {
    const options = {
      hostname: 'api.vapi.ai',
      port: 443,
      path: `/v1/agents/${config.agentId}`,
      method: 'GET',
      headers: {
        'Authorization': `Bearer ${config.apiKey}`,
        'Content-Type': 'application/json'
      }
    };
    
    const response = await makeRequest(options);
    
    if (response.statusCode === 200) {
      logSuccess('Agent access confirmed');
      logInfo(`Agent: ${response.data.name}`);
      logInfo(`Status: ${response.data.status}`);
      return true;
    } else {
      logError(`Agent access failed: ${response.statusCode}`);
      return false;
    }
  } catch (error) {
    logError(`Agent access error: ${error.message}`);
    return false;
  }
}

async function testPhoneNumbers() {
  logInfo('Testing phone numbers...');
  
  try {
    const options = {
      hostname: 'api.vapi.ai',
      port: 443,
      path: '/v1/phone-numbers',
      method: 'GET',
      headers: {
        'Authorization': `Bearer ${config.apiKey}`,
        'Content-Type': 'application/json'
      }
    };
    
    const response = await makeRequest(options);
    
    if (response.statusCode === 200) {
      if (response.data && response.data.data && response.data.data.length > 0) {
        logSuccess(`Found ${response.data.data.length} phone number(s)`);
        response.data.data.forEach((phone, index) => {
          logInfo(`Phone ${index + 1}: ${phone.phoneNumber} (${phone.status})`);
        });
        return true;
      } else {
        logWarning('No phone numbers found');
        return false;
      }
    } else {
      logError(`Phone numbers test failed: ${response.statusCode}`);
      return false;
    }
  } catch (error) {
    logError(`Phone numbers test error: ${error.message}`);
    return false;
  }
}

async function testWebhookEndpoints() {
  logInfo('Testing webhook endpoints...');
  
  const endpoints = [
    'http://localhost:5678/webhook/vapi-intake',
    'http://localhost:5678/webhook/appointment-status',
    'http://localhost:5678/webhook/appointment-reschedule',
    'http://localhost:5678/webhook/appointment-cancel'
  ];
  
  let successCount = 0;
  
  for (const endpoint of endpoints) {
    try {
      const url = new URL(endpoint);
      const options = {
        hostname: url.hostname,
        port: url.port || (url.protocol === 'https:' ? 443 : 80),
        path: url.pathname,
        method: 'GET',
        timeout: 5000
      };
      
      const response = await makeRequest(options);
      
      if (response.statusCode === 200 || response.statusCode === 404) {
        logSuccess(`${endpoint} - Accessible`);
        successCount++;
      } else {
        logWarning(`${endpoint} - Status: ${response.statusCode}`);
      }
    } catch (error) {
      logError(`${endpoint} - Error: ${error.message}`);
    }
  }
  
  return successCount === endpoints.length;
}

async function testCallCreation() {
  logInfo('Testing call creation...');
  
  try {
    const callData = {
      phoneNumberId: 'test-phone-id',
      agentId: config.agentId,
      metadata: {
        test: true,
        timestamp: new Date().toISOString()
      }
    };
    
    const options = {
      hostname: 'api.vapi.ai',
      port: 443,
      path: '/v1/calls',
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${config.apiKey}`,
        'Content-Type': 'application/json'
      }
    };
    
    const response = await makeRequest(options, callData);
    
    if (response.statusCode === 201) {
      logSuccess('Call creation test passed');
      return true;
    } else {
      logWarning(`Call creation test: ${response.statusCode}`);
      return false;
    }
  } catch (error) {
    logWarning(`Call creation test: ${error.message}`);
    return false;
  }
}

async function runAllTests() {
  log('\n' + '='.repeat(60), 'bright');
  log('🧪 Vapi API Test Suite', 'bright');
  log('='.repeat(60), 'bright');
  
  const results = {
    apiKey: false,
    agentAccess: false,
    phoneNumbers: false,
    webhooks: false,
    callCreation: false
  };
  
  // Run tests
  results.apiKey = await testApiKey();
  if (results.apiKey) {
    results.agentAccess = await testAgentAccess();
    results.phoneNumbers = await testPhoneNumbers();
    results.webhooks = await testWebhookEndpoints();
    results.callCreation = await testCallCreation();
  }
  
  // Summary
  log('\n' + '='.repeat(60), 'bright');
  log('📊 Test Results Summary', 'bright');
  log('='.repeat(60), 'bright');
  
  Object.entries(results).forEach(([test, result]) => {
    const status = result ? 'PASS' : 'FAIL';
    const color = result ? 'green' : 'red';
    log(`${test}: ${status}`, color);
  });
  
  const passedTests = Object.values(results).filter(Boolean).length;
  const totalTests = Object.keys(results).length;
  
  log(`\nOverall: ${passedTests}/${totalTests} tests passed`, passedTests === totalTests ? 'green' : 'yellow');
  
  if (passedTests === totalTests) {
    log('\n🎉 All tests passed! Your Vapi setup is working correctly.', 'green');
  } else {
    log('\n⚠️  Some tests failed. Please check the errors above.', 'yellow');
  }
  
  return results;
}

// Main execution
async function main() {
  try {
    // Check environment variables
    if (!process.env.VAPI_API_KEY) {
      logWarning('VAPI_API_KEY environment variable not set');
      logInfo('Please set your Vapi API key: export VAPI_API_KEY=your_key_here');
    }
    
    if (!process.env.VAPI_AGENT_ID) {
      logWarning('VAPI_AGENT_ID environment variable not set');
      logInfo('Please set your Vapi Agent ID: export VAPI_AGENT_ID=your_agent_id_here');
    }
    
    // Run tests
    await runAllTests();
    
  } catch (error) {
    logError(`Test suite error: ${error.message}`);
    process.exit(1);
  }
}

// Run if called directly
if (require.main === module) {
  main();
}

module.exports = {
  testApiKey,
  testAgentAccess,
  testPhoneNumbers,
  testWebhookEndpoints,
  testCallCreation,
  runAllTests
}; 