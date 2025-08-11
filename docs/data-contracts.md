# Data Contracts

This document defines all the data contracts used in the Medical Appointment Booking System.

## Vapi → n8n (Intake & Updates)

### Primary Intake Contract
```json
{
  "conversation_id": "vapi-123",
  "intent": "book_appointment",
  "caller": {
    "name": "Casey Li",
    "phone": "+18015551234",
    "email": "casey.li@email.com"
  },
  "symptoms": "knee pain after running",
  "requested_start_iso": "2025-08-12T16:00:00-06:00",
  "duration_min": 30,
  "insurance": {
    "payer": "Aetna",
    "memberId": "AET12345",
    "dob": "1985-03-15"
  },
  "context": {
    "locale": "en-US",
    "tz": "America/Denver"
  },
  "chosen_start_iso": null
}
```

### Field Descriptions

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `conversation_id` | string | ✅ | Unique identifier for the conversation |
| `intent` | string | ✅ | Always "book_appointment" for this system |
| `caller.name` | string | ✅ | Patient's full name |
| `caller.phone` | string | ✅ | Patient's phone number (E.164 format) |
| `caller.email` | string | ❌ | Patient's email address |
| `symptoms` | string | ❌ | Description of symptoms or reason for visit |
| `requested_start_iso` | string | ❌ | Preferred appointment time (ISO 8601) |
| `duration_min` | number | ❌ | Preferred appointment duration in minutes |
| `insurance.payer` | string | ❌ | Insurance company name |
| `insurance.memberId` | string | ❌ | Insurance member ID |
| `insurance.dob` | string | ❌ | Date of birth (YYYY-MM-DD) |
| `context.locale` | string | ❌ | Language/locale preference |
| `context.tz` | string | ✅ | Timezone (e.g., "America/Denver") |
| `chosen_start_iso` | string/null | ❌ | Selected appointment time from suggestions |

### Update Contracts

#### Choose Slot
```json
{
  "conversation_id": "vapi-123",
  "chosen_start_iso": "2025-08-12T17:00:00-06:00",
  "context": {
    "tz": "America/Denver"
  }
}
```

#### Supply Missing Field
```json
{
  "conversation_id": "vapi-123",
  "missing_field": "insurance.dob",
  "field_value": "1985-03-15",
  "context": {
    "tz": "America/Denver"
  }
}
```

## n8n → Vapi (Responses)

### Response Types

#### 1. Ask Question
```json
{
  "action": "ask",
  "question": "What is your date of birth?",
  "conversation_id": "vapi-123"
}
```

#### 2. Suggest Slots
```json
{
  "status": "suggest",
  "options": [
    "2025-08-12T17:00:00-06:00",
    "2025-08-13T09:30:00-06:00",
    "2025-08-13T11:00:00-06:00"
  ],
  "conversation_id": "vapi-123"
}
```

#### 3. Confirm Appointment
```json
{
  "status": "confirmed",
  "provider": "Dr. Jensen",
  "start": "2025-08-12T16:00:00-06:00",
  "end": "2025-08-12T16:30:00-06:00",
  "location": "Main Clinic",
  "copay_estimate": 35,
  "conversation_id": "vapi-123"
}
```

### Response Field Descriptions

#### Ask Question
| Field | Type | Description |
|-------|------|-------------|
| `action` | string | Always "ask" |
| `question` | string | The question to ask the user |
| `conversation_id` | string | Echo of the original conversation ID |

#### Suggest Slots
| Field | Type | Description |
|-------|------|-------------|
| `status` | string | Always "suggest" |
| `options` | array | Array of available appointment times (ISO 8601) |
| `conversation_id` | string | Echo of the original conversation ID |

#### Confirm Appointment
| Field | Type | Description |
|-------|------|-------------|
| `status` | string | Always "confirmed" |
| `provider` | string | Doctor's name |
| `start` | string | Appointment start time (ISO 8601) |
| `end` | string | Appointment end time (ISO 8601) |
| `location` | string | Clinic location |
| `copay_estimate` | number | Estimated copay amount |
| `conversation_id` | string | Echo of the original conversation ID |

## Internal n8n Data Flow

### State Object
```json
{
  "state": {
    "conversation_id": "vapi-123",
    "caller": {
      "name": "Casey Li",
      "phone": "+18015551234"
    },
    "intent": "book_appointment",
    "symptoms": "knee pain after running",
    "requested_start_iso": "2025-08-12T16:00:00-06:00",
    "duration_min": 30,
    "insurance": {
      "payer": "Aetna",
      "memberId": "AET12345"
    },
    "context": {
      "tz": "America/Denver"
    }
  }
}
```

### Triage Output
```json
{
  "triage": {
    "urgency": "routine",
    "visitType": "new_patient_consult",
    "specialty": "orthopedics",
    "minDurationMin": 30,
    "prep": "Wear comfortable clothing"
  }
}
```

### Scheduler Output
```json
{
  "scheduler": {
    "status": "booked",
    "eventId": "calendar_event_123",
    "start": "2025-08-12T16:00:00-06:00",
    "end": "2025-08-12T16:30:00-06:00",
    "provider": "Dr. Jensen",
    "location": "Main Clinic"
  }
}
```

### Insurance Output
```json
{
  "insurance": {
    "eligible": true,
    "copay_estimate": 35,
    "plan": "PPO 2500"
  }
}
```

## Error Handling

### Error Response Format
```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Missing required field: caller.name",
    "conversation_id": "vapi-123"
  }
}
```

### Common Error Codes
- `VALIDATION_ERROR`: Missing or invalid required fields
- `SCHEDULING_ERROR`: Unable to schedule appointment
- `INSURANCE_ERROR`: Insurance verification failed
- `SYSTEM_ERROR`: Internal system error

## Data Validation Rules

### Required Fields
- `conversation_id`: Must be unique string
- `caller.name`: Non-empty string
- `caller.phone`: Valid E.164 phone number format
- `context.tz`: Valid timezone identifier

### Format Requirements
- Phone numbers: E.164 format (+1XXXXXXXXXX)
- Dates: ISO 8601 format (YYYY-MM-DD)
- Times: ISO 8601 format with timezone
- Duration: Positive integer in minutes
- Member ID: Alphanumeric string

### Business Rules
- Appointment duration: Minimum 15 minutes, maximum 120 minutes
- Scheduling window: Up to 90 days in advance
- Insurance verification: Required before confirmation
- Urgent cases: May override normal scheduling constraints 