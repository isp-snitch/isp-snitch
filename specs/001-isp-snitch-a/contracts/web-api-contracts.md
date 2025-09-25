# ISP Snitch - Web API Contracts

**Feature ID:** 001  
**Branch:** 001-isp-snitch-a  
**Generated:** 2024-12-19  
**Status:** Web API Contracts Complete

## Overview

This document defines the web API contracts for ISP Snitch, including REST endpoints, WebSocket connections, and response formats.

## Base URL
```
http://localhost:8080/api
```

## Authentication
Currently no authentication required (local access only).

## REST API Endpoints

### 1. Service Status
```http
GET /api/status
```

**Description:** Get current service status and connectivity information.

**Response:**
```json
{
  "serviceStatus": {
    "id": "uuid",
    "status": "running",
    "lastHeartbeat": "2024-12-19T14:30:25Z",
    "uptimeSeconds": 8130,
    "totalTests": 1250,
    "successfulTests": 1245,
    "failedTests": 5,
    "successRate": 0.996,
    "createdAt": "2024-12-19T12:15:00Z",
    "updatedAt": "2024-12-19T14:30:25Z"
  },
  "currentConnectivity": [
    {
      "id": "uuid",
      "timestamp": "2024-12-19T14:30:25Z",
      "testType": "ping",
      "target": "8.8.8.8",
      "latency": 0.024,
      "success": true,
      "errorMessage": null,
      "errorCode": 0,
      "networkInterface": "en1",
      "systemContext": {
        "cpuUsage": 0.8,
        "memoryUsage": 42.0,
        "networkInterfaceStatus": "active",
        "batteryLevel": 85.0
      },
      "pingData": {
        "latency": 0.024,
        "packetLoss": 0.0,
        "ttl": 117,
        "statistics": {
          "minLatency": 0.024,
          "avgLatency": 0.024,
          "maxLatency": 0.024,
          "stdDev": 0.0,
          "packetsTransmitted": 1,
          "packetsReceived": 1
        }
      }
    }
  ],
  "systemMetrics": {
    "id": "uuid",
    "timestamp": "2024-12-19T14:30:25Z",
    "cpuUsage": 0.8,
    "memoryUsage": 42.0,
    "networkInterface": "en0",
    "networkInterfaceStatus": "active",
    "batteryLevel": 85.0
  },
  "uptime": "2h 15m 30s",
  "lastUpdate": "2024-12-19T14:30:25Z"
}
```

### 2. Historical Reports
```http
GET /api/reports?days=N&format=json&testType=TYPE&target=TARGET
```

**Description:** Get historical connectivity reports.

**Query Parameters:**
- `days` (optional): Number of days to include (default: 1)
- `format` (optional): Response format (json, csv) (default: json)
- `testType` (optional): Filter by test type
- `target` (optional): Filter by specific target
- `successOnly` (optional): Show only successful tests (true/false)
- `failedOnly` (optional): Show only failed tests (true/false)

**Response:**
```json
{
  "records": [
    {
      "id": "uuid",
      "timestamp": "2024-12-19T14:30:25Z",
      "testType": "ping",
      "target": "8.8.8.8",
      "latency": 0.012,
      "success": true,
      "errorMessage": null,
      "networkInterface": "en0",
      "systemContext": {
        "cpuUsage": 0.8,
        "memoryUsage": 42.0,
        "networkInterfaceStatus": "active",
        "batteryLevel": 85.0
      }
    }
  ],
  "summary": {
    "totalTests": 2880,
    "successfulTests": 2875,
    "failedTests": 5,
    "averageLatency": 0.023,
    "minLatency": 0.008,
    "maxLatency": 0.156,
    "successRate": 0.998,
    "testTypeBreakdown": [
      {
        "testType": "ping",
        "totalTests": 1440,
        "successfulTests": 1439,
        "failedTests": 1,
        "averageLatency": 0.015,
        "successRate": 0.999
      }
    ]
  },
  "generatedAt": "2024-12-19T14:30:25Z",
  "timeRange": {
    "start": "2024-12-18T14:30:00Z",
    "end": "2024-12-19T14:30:00Z",
    "duration": 86400
  }
}
```

### 3. Configuration Management

#### Get Configuration
```http
GET /api/config
```

**Response:**
```json
{
  "id": "uuid",
  "name": "default",
  "pingTargets": ["8.8.8.8", "1.1.1.1"],
  "httpTargets": ["https://google.com", "https://cloudflare.com"],
  "dnsTargets": ["google.com", "cloudflare.com"],
  "testInterval": 30.0,
  "timeout": 10.0,
  "retryCount": 3,
  "webPort": 8080,
  "dataRetentionDays": 30,
  "enableNotifications": true,
  "enableWebInterface": true,
  "isActive": true,
  "createdAt": "2024-12-19T12:15:00Z",
  "updatedAt": "2024-12-19T14:30:25Z"
}
```

#### Update Configuration
```http
POST /api/config
Content-Type: application/json
```

**Request Body:**
```json
{
  "pingTargets": ["8.8.8.8", "1.1.1.1", "9.9.9.9"],
  "testInterval": 60.0,
  "enableNotifications": false
}
```

**Response:**
```json
{
  "success": true,
  "message": "Configuration updated successfully",
  "config": {
    "id": "uuid",
    "name": "default",
    "pingTargets": ["8.8.8.8", "1.1.1.1", "9.9.9.9"],
    "httpTargets": ["https://google.com", "https://cloudflare.com"],
    "dnsTargets": ["google.com", "cloudflare.com"],
    "testInterval": 60.0,
    "timeout": 10.0,
    "retryCount": 3,
    "webPort": 8080,
    "dataRetentionDays": 30,
    "enableNotifications": false,
    "enableWebInterface": true,
    "isActive": true,
    "createdAt": "2024-12-19T12:15:00Z",
    "updatedAt": "2024-12-19T14:30:25Z"
  }
}
```

### 4. Data Export
```http
GET /api/export?format=json&days=N&testType=TYPE&target=TARGET&includeSystemMetrics=true
```

**Description:** Export connectivity data in various formats.

**Query Parameters:**
- `format` (required): Export format (json, csv, html)
- `days` (optional): Number of days to export (default: 30)
- `testType` (optional): Filter by test type
- `target` (optional): Filter by specific target
- `includeSystemMetrics` (optional): Include system metrics (true/false)

**Response:**
```json
{
  "data": "exported_data_content",
  "format": "json",
  "recordCount": 86400,
  "generatedAt": "2024-12-19T14:30:25Z",
  "timeRange": {
    "start": "2024-11-19T14:30:00Z",
    "end": "2024-12-19T14:30:00Z",
    "duration": 2592000
  }
}
```

### 5. Health Check
```http
GET /api/health
```

**Description:** Simple health check endpoint.

**Response:**
```json
{
  "status": "healthy",
  "timestamp": "2024-12-19T14:30:25Z",
  "uptime": 8130,
  "version": "1.0.0"
}
```

### 6. Performance Metrics
```http
GET /api/metrics
```

**Description:** Get performance metrics for the service.

**Response:**
```json
{
  "serviceMetrics": {
    "uptimeSeconds": 8130,
    "totalRequests": 1250,
    "averageResponseTime": 0.045,
    "errorRate": 0.002,
    "memoryUsage": 42.0,
    "cpuUsage": 0.8
  },
  "networkMetrics": {
    "totalTests": 1250,
    "successfulTests": 1245,
    "failedTests": 5,
    "averageLatency": 0.023,
    "testTypes": {
      "ping": {
        "count": 500,
        "averageLatency": 0.015,
        "successRate": 0.999
      },
      "http": {
        "count": 100,
        "averageLatency": 0.045,
        "successRate": 0.99
      },
      "dns": {
        "count": 400,
        "averageLatency": 0.012,
        "successRate": 0.998
      }
    }
  },
  "systemMetrics": {
    "cpuUsage": 0.8,
    "memoryUsage": 42.0,
    "networkInterface": "en0",
    "networkInterfaceStatus": "active",
    "batteryLevel": 85.0
  },
  "timestamp": "2024-12-19T14:30:25Z"
}
```

## WebSocket API

### Real-time Updates
```javascript
const ws = new WebSocket('ws://localhost:8080/ws/realtime');
```

**Connection Events:**
- `connect`: Connection established
- `disconnect`: Connection lost
- `error`: Connection error

**Message Types:**

#### 1. Connectivity Update
```json
{
  "type": "connectivity_update",
  "data": {
    "id": "uuid",
    "timestamp": "2024-12-19T14:30:25Z",
    "testType": "ping",
    "target": "8.8.8.8",
    "latency": 0.012,
    "success": true,
    "errorMessage": null,
    "networkInterface": "en0",
    "systemContext": {
      "cpuUsage": 0.8,
      "memoryUsage": 42.0,
      "networkInterfaceStatus": "active",
      "batteryLevel": 85.0
    }
  }
}
```

#### 2. Service Status Update
```json
{
  "type": "service_status_update",
  "data": {
    "status": "running",
    "uptimeSeconds": 8130,
    "totalTests": 1250,
    "successfulTests": 1245,
    "failedTests": 5,
    "successRate": 0.996
  }
}
```

#### 3. System Metrics Update
```json
{
  "type": "system_metrics_update",
  "data": {
    "cpuUsage": 0.8,
    "memoryUsage": 42.0,
    "networkInterface": "en0",
    "networkInterfaceStatus": "active",
    "batteryLevel": 85.0
  }
}
```

#### 4. Error Notification
```json
{
  "type": "error_notification",
  "data": {
    "errorType": "network_error",
    "message": "Failed to connect to target 8.8.8.8",
    "timestamp": "2024-12-19T14:30:25Z",
    "severity": "warning"
  }
}
```

## Error Responses

### Standard Error Format
```json
{
  "error": {
    "code": "ERROR_CODE",
    "message": "Human readable error message",
    "details": "Additional error details",
    "timestamp": "2024-12-19T14:30:25Z"
  }
}
```

### HTTP Status Codes
- `200 OK`: Success
- `400 Bad Request`: Invalid request parameters
- `404 Not Found`: Resource not found
- `500 Internal Server Error`: Server error
- `503 Service Unavailable`: Service temporarily unavailable

### Error Codes
- `INVALID_PARAMETER`: Invalid request parameter
- `CONFIG_ERROR`: Configuration error
- `SERVICE_ERROR`: Service error
- `NETWORK_ERROR`: Network error
- `DATABASE_ERROR`: Database error
- `PERMISSION_ERROR`: Permission error
- `VALIDATION_ERROR`: Validation error

## Rate Limiting

### Limits
- REST API: 100 requests per minute per IP
- WebSocket: 10 connections per IP
- Export API: 10 requests per hour per IP

### Headers
```
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 95
X-RateLimit-Reset: 1640000000
```

## CORS Configuration

### Allowed Origins
- `http://localhost:*`
- `http://127.0.0.1:*`
- `http://*.local:*`

### Allowed Methods
- GET, POST, PUT, DELETE, OPTIONS

### Allowed Headers
- Content-Type, Authorization, X-Requested-With

## Performance Requirements

### Response Times
- Status endpoint: < 100ms
- Reports endpoint: < 500ms for 24 hours of data
- Config endpoints: < 50ms
- Export endpoint: < 1s for 30 days of data
- WebSocket latency: < 50ms

### Concurrent Connections
- Support up to 10 concurrent WebSocket connections
- Support up to 100 concurrent HTTP requests

### Data Limits
- Maximum 1MB response size
- Maximum 10,000 records per request
- Maximum 30 days of data per export request
