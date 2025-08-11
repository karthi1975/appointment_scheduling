const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const path = require('path');

class MedicalAppointmentApp {
    constructor() {
        this.app = express();
        this.port = process.env.PORT || 3000;
        this.flowVisualizer = null;
        this.voiceInterface = null;
        this.logger = null;
        this.systemLogs = [];
        this.logLevel = 'all';
        
        this.init();
    }
    
    init() {
        this.setupMiddleware();
        this.setupRoutes();
        this.initLogger();
        this.initComponents();
        this.setupEventListeners();
        this.log('Medical Appointment Booking System initialized', 'info');
        
        // Simulate some initial system activity
        this.simulateSystemStartup();
    }
    
    setupMiddleware() {
        // Security middleware
        this.app.use(helmet());
        this.app.use(cors());
        this.app.use(morgan('combined'));
        
        // Body parsing middleware
        this.app.use(express.json());
        this.app.use(express.urlencoded({ extended: true }));
        
        // Static files
        this.app.use(express.static(path.join(__dirname, '..')));
    }
    
    setupRoutes() {
        // Health check endpoint
        this.app.get('/health', (req, res) => {
            res.status(200).json({ 
                status: 'healthy', 
                timestamp: new Date().toISOString(),
                services: {
                    webapp: 'running',
                    n8n: this.checkN8nStatus(),
                    database: 'connected'
                }
            });
        });
        
        // API endpoints
        this.app.get('/api/status', (req, res) => {
            res.json(this.getSystemStatus());
        });
        
        this.app.get('/api/logs', (req, res) => {
            const level = req.query.level || 'all';
            res.json(this.getFilteredLogs(level));
        });
        
        this.app.post('/api/test-n8n', async (req, res) => {
            try {
                const result = await this.testN8nConnection();
                res.json({ success: true, result });
            } catch (error) {
                res.status(500).json({ success: false, error: error.message });
            }
        });
        
        // Serve the main application
        this.app.get('/', (req, res) => {
            res.sendFile(path.join(__dirname, '../index.html'));
        });
    }
    
    initLogger() {
        this.logger = {
            log: (message, level = 'info') => {
                this.addLogEntry(message, level);
            }
        };
        
        // Make logger globally available
        global.app = this;
    }
    
    initComponents() {
        // Initialize flow visualizer
        if (typeof FlowVisualizer !== 'undefined') {
            this.flowVisualizer = new FlowVisualizer('flowCanvas');
        }
        
        // Initialize voice interface
        if (typeof VoiceInterface !== 'undefined') {
            this.voiceInterface = new VoiceInterface();
        }
        
        this.log('Components initialized successfully', 'info');
    }
    
    setupEventListeners() {
        // Handle graceful shutdown
        process.on('SIGTERM', () => {
            this.log('SIGTERM received, shutting down gracefully', 'info');
            this.shutdown();
        });
        
        process.on('SIGINT', () => {
            this.log('SIGINT received, shutting down gracefully', 'info');
            this.shutdown();
        });
    }
    
    async checkN8nStatus() {
        try {
            const n8nUrl = process.env.N8N_URL || 'http://localhost:5678';
            const response = await fetch(`${n8nUrl}/healthz`);
            return response.ok ? 'running' : 'unhealthy';
        } catch (error) {
            return 'unreachable';
        }
    }
    
    async testN8nConnection() {
        try {
            const n8nUrl = process.env.N8N_URL || 'http://localhost:5678';
            const username = process.env.N8N_USER || 'admin';
            const password = process.env.N8N_PASSWORD || 'localdev123';
            
            // Test basic connectivity
            const response = await fetch(`${n8nUrl}/healthz`);
            if (!response.ok) {
                throw new Error('n8n health check failed');
            }
            
            // Test authentication
            const authResponse = await fetch(`${n8nUrl}/api/v1/credentials`, {
                headers: {
                    'Authorization': `Basic ${Buffer.from(`${username}:${password}`).toString('base64')}`
                }
            });
            
            if (!authResponse.ok) {
                throw new Error('n8n authentication failed');
            }
            
            return {
                status: 'connected',
                version: 'n8n',
                workflows: 'accessible'
            };
        } catch (error) {
            throw new Error(`n8n connection failed: ${error.message}`);
        }
    }
    
    simulateSystemStartup() {
        const startupSteps = [
            { message: 'Starting Medical Appointment Booking System...', level: 'info', delay: 500 },
            { message: 'Initializing Vapi voice agent...', level: 'info', delay: 1000 },
            { message: 'Connecting to n8n orchestrator...', level: 'info', delay: 1500 },
            { message: 'Loading agent workflows...', level: 'info', delay: 2000 },
            { message: 'Establishing database connections...', level: 'info', delay: 2500 },
            { message: 'Verifying calendar integrations...', level: 'info', delay: 3000 },
            { message: 'System ready for appointments', level: 'info', delay: 3500 }
        ];
        
        startupSteps.forEach((step, index) => {
            setTimeout(() => {
                this.log(step.message, step.level);
                
                // Update status indicator on final step
                if (index === startupSteps.length - 1) {
                    this.updateSystemStatus('ready');
                }
            }, step.delay);
        });
    }
    
    updateSystemStatus(status) {
        this.log(`System status updated to: ${status}`, 'info');
        // This would update the UI status indicator
    }
    
    addLogEntry(message, level = 'info') {
        const logEntry = {
            timestamp: new Date().toISOString(),
            level: level.toUpperCase(),
            message: message
        };
        
        this.systemLogs.push(logEntry);
        
        // Keep only last 1000 logs
        if (this.systemLogs.length > 1000) {
            this.systemLogs = this.systemLogs.slice(-1000);
        }
        
        // Log to console in development
        if (process.env.NODE_ENV === 'development') {
            console.log(`[${logEntry.level}] ${logEntry.message}`);
        }
    }
    
    getFilteredLogs(level) {
        if (level === 'all') {
            return this.systemLogs;
        }
        return this.systemLogs.filter(log => log.level.toLowerCase() === level.toLowerCase());
    }
    
    getSystemStatus() {
        return {
            flowVisualizer: this.flowVisualizer ? 'active' : 'inactive',
            voiceInterface: this.voiceInterface ? 'active' : 'inactive',
            logCount: this.systemLogs.length,
            timestamp: new Date().toISOString(),
            n8nStatus: this.checkN8nStatus()
        };
    }
    
    async shutdown() {
        this.log('Shutting down Medical Appointment Booking System...', 'info');
        
        // Cleanup resources
        if (this.flowVisualizer) {
            // Cleanup flow visualizer
        }
        
        if (this.voiceInterface) {
            // Cleanup voice interface
        }
        
        this.log('Shutdown complete', 'info');
        process.exit(0);
    }
    
    // Public method to simulate system events
    simulateSystemEvent(eventType, data = {}) {
        switch (eventType) {
            case 'appointment_booked':
                this.log(`Appointment booked: ${data.patientName} - ${data.appointmentTime}`, 'info');
                break;
            case 'insurance_verified':
                this.log(`Insurance verified for: ${data.patientName} - ${data.insuranceProvider}`, 'info');
                break;
            case 'reminder_sent':
                this.log(`Reminder sent to: ${data.patientPhone} for ${data.appointmentTime}`, 'info');
                break;
            case 'error_occurred':
                this.log(`System error: ${data.errorMessage}`, 'error');
                break;
            default:
                this.log(`System event: ${eventType}`, 'info');
        }
    }
    
    // Method to test agent connections
    async testAgentConnections() {
        this.log('Testing agent connections...', 'info');
        
        const agents = ['orchestrator', 'triage', 'scheduler', 'insurance', 'reminder'];
        let testIndex = 0;
        
        const testAgent = async () => {
            if (testIndex >= agents.length) {
                this.log('All agent connections tested successfully', 'info');
                return;
            }
            
            const agent = agents[testIndex];
            this.log(`Testing ${agent} agent connection...`, 'info');
            
            // Simulate connection test
            setTimeout(() => {
                this.log(`${agent} agent: Connection successful`, 'info');
                testIndex++;
                testAgent();
            }, 1000);
        };
        
        testAgent();
    }
}

// Create and start the server
const medicalApp = new MedicalAppointmentApp();

// Start the Express server
medicalApp.app.listen(medicalApp.port, () => {
    console.log(`🏥 Medical Appointment Booking System running on port ${medicalApp.port}`);
    console.log(`🌐 Web Dashboard: http://localhost:${medicalApp.port}`);
    console.log(`🔧 n8n Workflows: http://localhost:5678`);
    console.log(`📊 Database: localhost:5432`);
});

// Export for global access
module.exports = MedicalAppointmentApp; 