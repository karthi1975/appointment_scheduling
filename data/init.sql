-- Medical Appointment Booking System Database Schema
-- This script initializes the database with required tables and sample data

-- Create appointments table
CREATE TABLE IF NOT EXISTS appointments (
    id SERIAL PRIMARY KEY,
    patient_name VARCHAR(255) NOT NULL,
    patient_phone VARCHAR(20),
    patient_email VARCHAR(255),
    appointment_date DATE NOT NULL,
    appointment_time TIME NOT NULL,
    provider VARCHAR(255),
    specialty VARCHAR(100),
    symptoms TEXT,
    urgency VARCHAR(50) DEFAULT 'routine',
    duration_minutes INTEGER DEFAULT 30,
    status VARCHAR(50) DEFAULT 'scheduled',
    insurance_provider VARCHAR(255),
    insurance_id VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create patients table
CREATE TABLE IF NOT EXISTS patients (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    email VARCHAR(255),
    date_of_birth DATE,
    insurance_provider VARCHAR(255),
    insurance_id VARCHAR(255),
    emergency_contact VARCHAR(255),
    emergency_phone VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create providers table
CREATE TABLE IF NOT EXISTS providers (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    specialty VARCHAR(100),
    location VARCHAR(255),
    phone VARCHAR(20),
    email VARCHAR(255),
    availability_hours TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create insurance_verifications table
CREATE TABLE IF NOT EXISTS insurance_verifications (
    id SERIAL PRIMARY KEY,
    patient_id INTEGER REFERENCES patients(id),
    insurance_provider VARCHAR(255),
    insurance_id VARCHAR(255),
    verification_status VARCHAR(50),
    coverage_details TEXT,
    copay_amount DECIMAL(10,2),
    deductible_amount DECIMAL(10,2),
    verified_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create conversation_logs table
CREATE TABLE IF NOT EXISTS conversation_logs (
    id SERIAL PRIMARY KEY,
    conversation_id VARCHAR(255),
    patient_name VARCHAR(255),
    agent_type VARCHAR(100),
    message TEXT,
    message_type VARCHAR(50),
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create system_logs table
CREATE TABLE IF NOT EXISTS system_logs (
    id SERIAL PRIMARY KEY,
    level VARCHAR(20),
    message TEXT,
    source VARCHAR(100),
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert sample providers
INSERT INTO providers (name, specialty, location, phone, email, availability_hours) VALUES
('Dr. Sarah Jensen', 'Orthopedics', 'Main Clinic - Orthopedics', '+1-555-0101', 'dr.jensen@clinic.com', 'Mon-Fri 9AM-5PM'),
('Dr. Michael Chen', 'Cardiology', 'Main Clinic - Cardiology', '+1-555-0102', 'dr.chen@clinic.com', 'Mon-Fri 8AM-4PM'),
('Dr. Emily Rodriguez', 'Pediatrics', 'Main Clinic - Pediatrics', '+1-555-0103', 'dr.rodriguez@clinic.com', 'Mon-Fri 9AM-6PM'),
('Dr. James Wilson', 'Dermatology', 'Main Clinic - Dermatology', '+1-555-0104', 'dr.wilson@clinic.com', 'Mon-Fri 10AM-6PM');

-- Insert sample patients
INSERT INTO patients (name, phone, email, date_of_birth, insurance_provider, insurance_id, emergency_contact, emergency_phone) VALUES
('John Doe', '+1-555-0123', 'john.doe@email.com', '1985-03-15', 'Aetna', 'AET12345', 'Jane Doe', '+1-555-0126'),
('Jane Smith', '+1-555-0124', 'jane.smith@email.com', '1990-07-22', 'Blue Cross', 'BC12345', 'John Smith', '+1-555-0127'),
('Mike Johnson', '+1-555-0125', 'mike.johnson@email.com', '1978-11-08', 'Cigna', 'CIG12345', 'Sarah Johnson', '+1-555-0128');

-- Insert sample appointments
INSERT INTO appointments (patient_name, patient_phone, patient_email, appointment_date, appointment_time, provider, specialty, symptoms, urgency, duration_minutes, status, insurance_provider, insurance_id) VALUES
('John Doe', '+1-555-0123', 'john.doe@email.com', '2024-08-15', '14:00:00', 'Dr. Sarah Jensen', 'Orthopedics', 'Knee pain after running', 'routine', 45, 'scheduled', 'Aetna', 'AET12345'),
('Jane Smith', '+1-555-0124', 'jane.smith@email.com', '2024-08-16', '10:30:00', 'Dr. Michael Chen', 'Cardiology', 'Annual checkup', 'routine', 30, 'scheduled', 'Blue Cross', 'BC12345'),
('Mike Johnson', '+1-555-0125', 'mike.johnson@email.com', '2024-08-17', '15:00:00', 'Dr. Emily Rodriguez', 'Pediatrics', 'Child wellness visit', 'routine', 30, 'scheduled', 'Cigna', 'CIG12345');

-- Insert sample insurance verifications
INSERT INTO insurance_verifications (patient_id, insurance_provider, insurance_id, verification_status, coverage_details, copay_amount, deductible_amount) VALUES
(1, 'Aetna', 'AET12345', 'verified', 'Coverage confirmed for orthopedic consultation', 25.00, 500.00),
(2, 'Blue Cross', 'BC12345', 'verified', 'Coverage confirmed for cardiology consultation', 30.00, 750.00),
(3, 'Cigna', 'CIG12345', 'verified', 'Coverage confirmed for pediatric consultation', 20.00, 400.00);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_appointments_date ON appointments(appointment_date);
CREATE INDEX IF NOT EXISTS idx_appointments_patient ON appointments(patient_name);
CREATE INDEX IF NOT EXISTS idx_appointments_provider ON appointments(provider);
CREATE INDEX IF NOT EXISTS idx_patients_insurance ON patients(insurance_provider);
CREATE INDEX IF NOT EXISTS idx_conversation_logs_conversation ON conversation_logs(conversation_id);
CREATE INDEX IF NOT EXISTS idx_system_logs_timestamp ON system_logs(timestamp);

-- Create updated_at trigger function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create triggers for updated_at
CREATE TRIGGER update_appointments_updated_at BEFORE UPDATE ON appointments FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_patients_updated_at BEFORE UPDATE ON patients FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_providers_updated_at BEFORE UPDATE ON providers FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Insert initial system log
INSERT INTO system_logs (level, message, source) VALUES
('info', 'Database initialized successfully', 'database_init'),
('info', 'Sample data loaded', 'database_init'),
('info', 'Medical Appointment Booking System ready', 'system_startup'); 