# 🖥️ Medical Appointment Booking System - Web Dashboard

A modern, interactive web application that provides real-time visualization and control of the Medical Appointment Booking System's 5 agents.

## ✨ Features

### 🔄 **Dynamic Flow Visualization (Left Panel)**
- **Interactive Agent Nodes**: Click on any of the 5 agents to see details
- **Animated Flow**: Watch the data flow between agents in real-time
- **Play/Pause Controls**: Control the flow animation speed
- **Visual Feedback**: Nodes glow and connections animate during active processes

### 🎤 **Voice Command Interface (Right Panel)**
- **Simulated Voice Sessions**: Experience the complete appointment booking flow
- **Real-time Conversation Log**: See user inputs and agent responses
- **Quick Actions**: Test common scenarios with one-click buttons
- **Appointment Status**: View current booking details

### 📊 **System Monitoring (Bottom Panel)**
- **Live Activity Logs**: Real-time system events and agent activities
- **Log Filtering**: Filter by info, warning, or error levels
- **Export Functionality**: Download logs for analysis
- **Status Indicators**: Visual system health monitoring

## 🚀 Getting Started

### 1. **Open the Dashboard**
```bash
# Navigate to the webapp directory
cd webapp

# Open index.html in your browser
open index.html
```

### 2. **Explore the Interface**

#### **Flow Visualization**
- Click **"Play Flow"** to see the agent interactions animate
- Click on any agent node to see detailed information
- Use **"Reset"** to return to the initial state

#### **Voice Interface**
- Click **"Start Voice Session"** to begin a simulated appointment booking
- Watch the conversation unfold in real-time
- Use **Quick Actions** to test different scenarios

#### **System Monitoring**
- Monitor real-time system logs
- Filter logs by severity level
- Export logs for external analysis

## 🎯 **The 5 Agents Visualized**

### 1. **🔵 Orchestrator Agent**
- **Position**: Center of the flow
- **Purpose**: Central coordinator for all requests
- **Color**: Blue gradient

### 2. **🟣 Triage Agent**
- **Position**: Top-left
- **Purpose**: Symptom classification and urgency assessment
- **Color**: Purple gradient

### 3. **🔵 Scheduler Agent**
- **Position**: Top-right
- **Purpose**: Appointment booking and calendar management
- **Color**: Blue gradient

### 4. **🟢 Insurance Agent**
- **Position**: Bottom-left
- **Purpose**: Coverage verification and eligibility checks
- **Color**: Green gradient

### 5. **🟡 Reminder Agent**
- **Position**: Bottom-right
- **Purpose**: Notifications, confirmations, and logging
- **Color**: Yellow gradient

## ⌨️ **Keyboard Shortcuts**

- **Ctrl/Cmd + Enter**: Start voice session
- **Ctrl/Cmd + Space**: Play/pause flow animation
- **Escape**: Close modals

## 🔧 **Technical Details**

### **Technologies Used**
- **HTML5**: Semantic structure
- **CSS3**: Modern styling with gradients and animations
- **Vanilla JavaScript**: No frameworks, pure performance
- **D3.js**: SVG-based flow visualization
- **Font Awesome**: Icon library

### **Architecture**
- **Modular Design**: Separate classes for each component
- **Event-Driven**: Real-time updates and interactions
- **Responsive Layout**: Works on desktop and mobile devices
- **Cross-Browser Compatible**: Modern browser support

## 📱 **Responsive Design**

The dashboard automatically adapts to different screen sizes:
- **Desktop**: Full two-panel layout
- **Tablet**: Stacked panels for better mobile viewing
- **Mobile**: Optimized single-column layout

## 🧪 **Testing Scenarios**

### **Quick Appointment Booking**
1. Click **"Book Appointment"** quick action
2. Watch all 5 agents activate in sequence
3. See the complete flow from intake to confirmation

### **Insurance Verification**
1. Click **"Check Insurance"** quick action
2. Observe the insurance agent's verification process
3. View the results in the conversation log

### **Flow Animation**
1. Click **"Play Flow"** in the flow panel
2. Watch the connections animate between agents
3. See nodes highlight as they become active

## 🔍 **Troubleshooting**

### **Flow Not Animating**
- Ensure JavaScript is enabled
- Check browser console for errors
- Try refreshing the page

### **Voice Interface Not Responding**
- Check if the session is active
- Verify the conversation log is visible
- Try clearing and restarting the session

### **Logs Not Updating**
- Check the log level filter
- Ensure the system is running
- Try refreshing the page

## 🚀 **Next Steps**

1. **Integrate with Real n8n**: Connect to actual n8n workflows
2. **Add Real Voice**: Integrate with actual Vapi voice agent
3. **Live Data**: Connect to real appointment and insurance systems
4. **User Authentication**: Add login and role-based access
5. **Analytics Dashboard**: Add performance metrics and reporting

## 📞 **Support**

For technical support or feature requests:
- Check the system logs for error details
- Review the browser console for JavaScript errors
- Ensure all required files are present in the webapp directory

---

**🎉 Enjoy exploring your Medical Appointment Booking System!** 