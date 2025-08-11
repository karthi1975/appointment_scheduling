class VoiceInterface {
    constructor() {
        this.isListening = false;
        this.conversationId = null;
        this.currentStep = 'idle';
        this.conversationLog = document.getElementById('conversationLog');
        this.voiceStatus = document.querySelector('.voice-status .voice-text');
        this.voiceDot = document.querySelector('.voice-status .voice-dot');
        this.startButton = document.getElementById('startVoice');
        this.stopButton = document.getElementById('stopVoice');
        
        this.agentResponses = {
            orchestrator: [
                "I'll help you book an appointment. Let me route your request to the appropriate agents.",
                "Processing your request through our system. This will take a moment.",
                "I'm coordinating with our specialized agents to get you the best care."
            ],
            triage: [
                "I'm analyzing your symptoms to determine the appropriate care level.",
                "Based on your description, this appears to be a routine appointment.",
                "I've classified your visit type and urgency level."
            ],
            scheduler: [
                "I'm checking our calendar for available appointment slots.",
                "I found several options for you. Let me present them.",
                "Your appointment has been successfully scheduled."
            ],
            insurance: [
                "I'm verifying your insurance coverage and eligibility.",
                "I need a bit more information to complete the verification.",
                "Your insurance has been verified and coverage confirmed."
            ],
            reminder: [
                "I'm setting up your appointment reminders and confirmations.",
                "SMS and email confirmations have been sent.",
                "Your appointment details have been logged to our system."
            ]
        };
        
        this.init();
    }
    
    init() {
        this.setupEventListeners();
        this.log('Voice interface initialized', 'system');
    }
    
    setupEventListeners() {
        // Voice control buttons
        this.startButton.addEventListener('click', () => this.startVoiceSession());
        this.stopButton.addEventListener('click', () => this.stopVoiceSession());
        
        // Quick action buttons
        document.querySelectorAll('.action-btn').forEach(btn => {
            btn.addEventListener('click', (e) => {
                const action = e.currentTarget.dataset.action;
                this.handleQuickAction(action);
            });
        });
        
        // Clear conversation
        document.getElementById('clearConversation').addEventListener('click', () => {
            this.clearConversation();
        });
    }
    
    startVoiceSession() {
        if (this.isListening) return;
        
        this.isListening = true;
        this.conversationId = 'conv-' + Date.now();
        this.currentStep = 'intake';
        
        // Update UI
        this.startButton.disabled = true;
        this.stopButton.disabled = false;
        this.voiceStatus.textContent = 'Listening';
        this.voiceDot.classList.add('listening');
        
        this.log('Voice session started', 'system');
        this.simulateVoiceInteraction();
    }
    
    stopVoiceSession() {
        if (!this.isListening) return;
        
        this.isListening = false;
        this.currentStep = 'idle';
        
        // Update UI
        this.startButton.disabled = false;
        this.stopButton.disabled = true;
        this.voiceStatus.textContent = 'Ready';
        this.voiceDot.classList.remove('listening', 'processing');
        
        this.log('Voice session stopped', 'system');
    }
    
    simulateVoiceInteraction() {
        if (!this.isListening) return;
        
        // Simulate user input
        const userInputs = [
            "I need to book an appointment for knee pain",
            "It started after running yesterday",
            "I prefer afternoon appointments",
            "My insurance is Aetna, member ID AET12345",
            "Yes, that time works for me"
        ];
        
        let stepIndex = 0;
        const simulateStep = () => {
            if (!this.isListening || stepIndex >= userInputs.length) {
                this.completeAppointment();
                return;
            }
            
            // Simulate user speaking
            this.simulateUserInput(userInputs[stepIndex]);
            
            // Simulate agent processing
            setTimeout(() => {
                this.simulateAgentResponse(stepIndex);
                stepIndex++;
                
                if (this.isListening) {
                    setTimeout(simulateStep, 2000);
                }
            }, 1500);
        };
        
        simulateStep();
    }
    
    simulateUserInput(input) {
        this.log(input, 'user');
        this.voiceStatus.textContent = 'Processing';
        this.voiceDot.classList.remove('listening');
        this.voiceDot.classList.add('processing');
        
        // Highlight relevant agent in flow
        this.highlightRelevantAgent(this.currentStep);
    }
    
    simulateAgentResponse(stepIndex) {
        const responses = [
            "I understand you need an appointment for knee pain. Let me route this to our triage agent.",
            "Based on your symptoms, this appears to be a routine orthopedic consultation. Let me check our scheduler.",
            "I found several afternoon slots available. Would you like Tuesday at 2:00 PM or Thursday at 3:30 PM?",
            "I'm verifying your Aetna insurance. I need your date of birth to complete the verification.",
            "Perfect! I've confirmed your appointment for Tuesday at 2:00 PM. Let me set up your reminders."
        ];
        
        this.log(responses[stepIndex], 'agent');
        this.voiceStatus.textContent = 'Listening';
        this.voiceDot.classList.remove('processing');
        this.voiceDot.classList.add('listening');
        
        // Update current step
        this.updateCurrentStep(stepIndex);
    }
    
    highlightRelevantAgent(step) {
        const agentMap = {
            'intake': 'orchestrator',
            'triage': 'triage',
            'scheduling': 'scheduler',
            'insurance': 'insurance',
            'reminder': 'reminder'
        };
        
        if (window.flowVisualizer && agentMap[step]) {
            window.flowVisualizer.highlightAgent(agentMap[step]);
        }
    }
    
    updateCurrentStep(stepIndex) {
        const steps = ['intake', 'triage', 'scheduling', 'insurance', 'reminder'];
        if (stepIndex < steps.length) {
            this.currentStep = steps[stepIndex];
        }
    }
    
    completeAppointment() {
        this.log('Appointment booking completed successfully!', 'system');
        this.updateAppointmentStatus({
            date: 'Tuesday, August 13, 2025',
            time: '2:00 PM',
            provider: 'Dr. Sarah Jensen',
            location: 'Main Clinic - Orthopedics',
            duration: '45 minutes'
        });
        
        // Stop the session
        setTimeout(() => {
            this.stopVoiceSession();
        }, 2000);
    }
    
    handleQuickAction(action) {
        this.log(`Quick action triggered: ${action}`, 'system');
        
        switch (action) {
            case 'book-appointment':
                this.simulateQuickAppointment();
                break;
            case 'check-insurance':
                this.simulateInsuranceCheck();
                break;
            case 'reschedule':
                this.simulateReschedule();
                break;
            case 'cancel-appointment':
                this.simulateCancellation();
                break;
        }
    }
    
    simulateQuickAppointment() {
        this.log('Starting quick appointment booking...', 'system');
        
        // Simulate the full flow quickly
        const steps = [
            { agent: 'orchestrator', message: 'Initiating appointment booking process' },
            { agent: 'triage', message: 'Classifying appointment type: routine consultation' },
            { agent: 'scheduler', message: 'Finding available slots: 3 options found' },
            { agent: 'insurance', message: 'Insurance verified: Aetna coverage confirmed' },
            { agent: 'reminder', message: 'Setting up confirmations and reminders' }
        ];
        
        let currentStep = 0;
        const processStep = () => {
            if (currentStep >= steps.length) {
                this.log('Quick appointment booking completed!', 'system');
                return;
            }
            
            const step = steps[currentStep];
            this.log(`${step.agent}: ${step.message}`, 'agent');
            
            // Highlight agent in flow
            if (window.flowVisualizer) {
                window.flowVisualizer.highlightAgent(step.agent);
            }
            
            currentStep++;
            setTimeout(processStep, 1000);
        };
        
        processStep();
    }
    
    simulateInsuranceCheck() {
        this.log('Checking insurance eligibility...', 'system');
        
        setTimeout(() => {
            this.log('Insurance verification completed: Aetna coverage active, $25 copay', 'agent');
        }, 2000);
    }
    
    simulateReschedule() {
        this.log('Initiating reschedule process...', 'system');
        
        setTimeout(() => {
            this.log('Available reschedule slots: Monday 10:00 AM, Wednesday 4:00 PM', 'agent');
        }, 1500);
    }
    
    simulateCancellation() {
        this.log('Processing appointment cancellation...', 'system');
        
        setTimeout(() => {
            this.log('Appointment cancelled successfully. Cancellation confirmation sent.', 'agent');
        }, 1500);
    }
    
    updateAppointmentStatus(appointment) {
        const appointmentInfo = document.getElementById('appointmentInfo');
        appointmentInfo.innerHTML = `
            <div class="appointment-details">
                <div class="appointment-date">
                    <i class="fas fa-calendar"></i>
                    <strong>${appointment.date}</strong>
                </div>
                <div class="appointment-time">
                    <i class="fas fa-clock"></i>
                    <strong>${appointment.time}</strong>
                </div>
                <div class="appointment-provider">
                    <i class="fas fa-user-md"></i>
                    <strong>${appointment.provider}</strong>
                </div>
                <div class="appointment-location">
                    <i class="fas fa-map-marker-alt"></i>
                    <strong>${appointment.location}</strong>
                </div>
                <div class="appointment-duration">
                    <i class="fas fa-hourglass-half"></i>
                    <strong>${appointment.duration}</strong>
                </div>
            </div>
        `;
    }
    
    log(message, type = 'info') {
        const entry = document.createElement('div');
        entry.className = `conversation-entry ${type}`;
        
        const timestamp = new Date().toLocaleTimeString();
        const typeLabel = type.charAt(0).toUpperCase() + type.slice(1);
        
        entry.innerHTML = `
            <div class="entry-header">
                <span class="entry-type">${typeLabel}</span>
                <span class="entry-time">${timestamp}</span>
            </div>
            <div class="entry-content">${message}</div>
        `;
        
        this.conversationLog.appendChild(entry);
        this.conversationLog.scrollTop = this.conversationLog.scrollHeight;
        
        // Also log to system logs if available
        if (window.app && window.app.logger) {
            window.app.logger.log(`Voice: ${message}`, type);
        }
    }
    
    clearConversation() {
        this.conversationLog.innerHTML = `
            <div class="system-message">
                <i class="fas fa-info-circle"></i>
                Conversation cleared. Click "Start Voice Session" to begin a new conversation.
            </div>
        `;
    }
    
    // Public method to get current conversation state
    getConversationState() {
        return {
            isListening: this.isListening,
            conversationId: this.conversationId,
            currentStep: this.currentStep,
            messageCount: this.conversationLog.children.length
        };
    }
    
    // Public method to add external message
    addExternalMessage(message, type = 'system') {
        this.log(message, type);
    }
}

// Export for use in main app
window.VoiceInterface = VoiceInterface; 