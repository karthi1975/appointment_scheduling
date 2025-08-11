class FlowVisualizer {
    constructor(containerId) {
        this.container = document.getElementById(containerId);
        this.nodes = [];
        this.connections = [];
        this.currentStep = 0;
        this.isPlaying = false;
        this.animationSpeed = 2000; // milliseconds per step
        
        this.flowSteps = [
            { name: 'orchestrator', label: 'Orchestrator', x: 50, y: 50, description: 'Central coordinator' },
            { name: 'triage', label: 'Triage Agent', x: 25, y: 25, description: 'Symptom classification' },
            { name: 'scheduler', label: 'Scheduler Agent', x: 75, y: 25, description: 'Appointment booking' },
            { name: 'insurance', label: 'Insurance Agent', x: 25, y: 75, description: 'Coverage verification' },
            { name: 'reminder', label: 'Reminder Agent', x: 75, y: 75, description: 'Notifications & logging' }
        ];
        
        this.flowSequence = [
            { from: 'orchestrator', to: 'triage', label: 'Route to triage' },
            { from: 'triage', to: 'orchestrator', label: 'Return classification' },
            { from: 'orchestrator', to: 'scheduler', label: 'Route to scheduler' },
            { from: 'scheduler', to: 'orchestrator', label: 'Return availability' },
            { from: 'orchestrator', to: 'insurance', label: 'Route to insurance' },
            { from: 'insurance', to: 'orchestrator', label: 'Return verification' },
            { from: 'orchestrator', to: 'reminder', label: 'Route to reminder' },
            { from: 'reminder', to: 'orchestrator', label: 'Return confirmation' }
        ];
        
        this.init();
    }
    
    init() {
        this.createNodes();
        this.createConnections();
        this.setupEventListeners();
        this.log('Flow visualizer initialized', 'info');
    }
    
    createNodes() {
        this.flowSteps.forEach((step, index) => {
            const node = document.createElement('div');
            node.className = `flow-node ${step.name}`;
            node.id = `node-${step.name}`;
            node.style.left = `${step.x}%`;
            node.style.top = `${step.y}%`;
            node.innerHTML = `
                <div class="node-label">${step.label}</div>
                <div class="node-description">${step.description}</div>
            `;
            
            // Add tooltip
            node.title = `${step.label}: ${step.description}`;
            
            // Add click event for node details
            node.addEventListener('click', () => this.showNodeDetails(step));
            
            this.container.appendChild(node);
            this.nodes.push(node);
        });
    }
    
    createConnections() {
        const svg = document.createElementNS('http://www.w3.org/2000/svg', 'svg');
        svg.setAttribute('width', '100%');
        svg.setAttribute('height', '100%');
        svg.style.position = 'absolute';
        svg.style.top = '0';
        svg.style.left = '0';
        svg.style.pointerEvents = 'none';
        svg.id = 'flow-connections';
        
        this.container.appendChild(svg);
        
        this.flowSequence.forEach((connection, index) => {
            const line = document.createElementNS('http://www.w3.org/2000/svg', 'path');
            line.className = 'flow-connection';
            line.id = `connection-${index}`;
            line.setAttribute('marker-end', 'url(#arrowhead)');
            
            svg.appendChild(line);
            this.connections.push(line);
        });
        
        // Add arrow marker
        const defs = document.createElementNS('http://www.w3.org/2000/svg', 'defs');
        const marker = document.createElementNS('http://www.w3.org/2000/svg', 'marker');
        marker.setAttribute('id', 'arrowhead');
        marker.setAttribute('markerWidth', '10');
        marker.setAttribute('markerHeight', '7');
        marker.setAttribute('refX', '9');
        marker.setAttribute('refY', '3.5');
        marker.setAttribute('orient', 'auto');
        
        const polygon = document.createElementNS('http://www.w3.org/2000/svg', 'polygon');
        polygon.setAttribute('points', '0 0, 10 3.5, 0 7');
        polygon.setAttribute('fill', '#bdc3c7');
        
        marker.appendChild(polygon);
        defs.appendChild(marker);
        svg.appendChild(defs);
        
        this.updateConnections();
    }
    
    updateConnections() {
        this.flowSequence.forEach((connection, index) => {
            const fromNode = document.getElementById(`node-${connection.from}`);
            const toNode = document.getElementById(`node-${connection.to}`);
            const line = this.connections[index];
            
            if (fromNode && toNode && line) {
                const fromRect = fromNode.getBoundingClientRect();
                const toRect = toNode.getBoundingClientRect();
                const containerRect = this.container.getBoundingClientRect();
                
                const fromX = (fromRect.left + fromRect.width / 2 - containerRect.left) / containerRect.width * 100;
                const fromY = (fromRect.top + fromRect.height / 2 - containerRect.top) / containerRect.height * 100;
                const toX = (toRect.left + toRect.width / 2 - containerRect.left) / containerRect.width * 100;
                const toY = (toRect.top + toRect.height / 2 - containerRect.top) / containerRect.height * 100;
                
                // Create curved path
                const midX = (fromX + toX) / 2;
                const midY = (fromY + toY) / 2;
                const offset = 10;
                
                let path;
                if (Math.abs(fromX - toX) < 20) {
                    // Vertical connection
                    path = `M ${fromX} ${fromY} Q ${fromX + offset} ${midY} ${toX} ${toY}`;
                } else if (Math.abs(fromY - toY) < 20) {
                    // Horizontal connection
                    path = `M ${fromX} ${fromY} Q ${midX} ${fromY + offset} ${toX} ${toY}`;
                } else {
                    // Diagonal connection
                    path = `M ${fromX} ${fromY} Q ${midX} ${midY} ${toX} ${toY}`;
                }
                
                line.setAttribute('d', path);
            }
        });
    }
    
    setupEventListeners() {
        // Play button
        document.getElementById('playFlow').addEventListener('click', () => {
            if (this.isPlaying) {
                this.pauseFlow();
            } else {
                this.playFlow();
            }
        });
        
        // Reset button
        document.getElementById('resetFlow').addEventListener('click', () => {
            this.resetFlow();
        });
        
        // Window resize
        window.addEventListener('resize', () => {
            this.updateConnections();
        });
    }
    
    playFlow() {
        if (this.isPlaying) return;
        
        this.isPlaying = true;
        document.getElementById('playFlow').innerHTML = '<i class="fas fa-pause"></i> Pause Flow';
        document.getElementById('playFlow').classList.remove('btn-primary');
        document.getElementById('playFlow').classList.add('btn-warning');
        
        this.log('Starting flow animation', 'info');
        this.animateFlow();
    }
    
    pauseFlow() {
        this.isPlaying = false;
        document.getElementById('playFlow').innerHTML = '<i class="fas fa-play"></i> Play Flow';
        document.getElementById('playFlow').classList.remove('btn-warning');
        document.getElementById('playFlow').classList.add('btn-primary');
        
        this.log('Flow animation paused', 'info');
    }
    
    resetFlow() {
        this.pauseFlow();
        this.currentStep = 0;
        
        // Reset all nodes
        this.nodes.forEach(node => {
            node.classList.remove('active');
        });
        
        // Reset all connections
        this.connections.forEach(connection => {
            connection.classList.remove('active');
        });
        
        this.log('Flow reset to initial state', 'info');
    }
    
    animateFlow() {
        if (!this.isPlaying) return;
        
        if (this.currentStep >= this.flowSequence.length) {
            this.currentStep = 0;
        }
        
        const connection = this.flowSequence[this.currentStep];
        const connectionElement = this.connections[this.currentStep];
        
        // Activate connection
        connectionElement.classList.add('active');
        
        // Activate target node
        const targetNode = document.getElementById(`node-${connection.to}`);
        if (targetNode) {
            targetNode.classList.add('active');
        }
        
        // Log the step
        this.log(`Flow step: ${connection.from} → ${connection.to}`, 'info');
        
        // Deactivate previous connection after delay
        setTimeout(() => {
            if (connectionElement) {
                connectionElement.classList.remove('active');
            }
        }, this.animationSpeed * 0.8);
        
        // Move to next step
        this.currentStep++;
        
        // Schedule next step
        setTimeout(() => {
            if (this.isPlaying) {
                this.animateFlow();
            }
        }, this.animationSpeed);
    }
    
    showNodeDetails(step) {
        this.log(`Node clicked: ${step.label}`, 'info');
        
        // Create a simple alert for now (can be enhanced with modal)
        const details = `
Agent: ${step.label}
Purpose: ${step.description}
Status: Active
Last Activity: ${new Date().toLocaleTimeString()}
        `;
        
        alert(details);
    }
    
    log(message, level = 'info') {
        // This will be connected to the main logging system
        if (window.app && window.app.logger) {
            window.app.logger.log(message, level);
        }
    }
    
    // Public method to highlight a specific agent
    highlightAgent(agentName) {
        const node = document.getElementById(`node-${agentName}`);
        if (node) {
            node.classList.add('active');
            setTimeout(() => {
                node.classList.remove('active');
            }, 3000);
        }
    }
    
    // Public method to show flow progress
    showProgress(progress) {
        // Update progress indicator if needed
        this.log(`Flow progress: ${progress}%`, 'info');
    }
}

// Export for use in main app
window.FlowVisualizer = FlowVisualizer; 