# AI Integration for Real-Time Crime Prevention System

This document provides comprehensive instructions for integrating AI features into your Spring Boot Crime Prevention System using free AI APIs.

## 🚀 Features Implemented

### Phase 1: Report Summarization ✅
- **Automatic Report Summarization**: Generate concise summaries of crime reports
- **Multi-AI Support**: OpenAI GPT-3.5-turbo and Google Gemini Pro
- **Smart Prompting**: Structured prompts for consistent output
- **Caching**: Redis-based caching for improved performance
- **Database Storage**: Persistent storage of AI-generated summaries

### Phase 2-5: Coming Soon
- **Pattern Analysis**: Detect crime patterns across time and location
- **Predictive Alerts**: Forecast potential crime hotspots
- **Anomaly Detection**: Identify unusual reporting patterns
- **Automated Recommendations**: Suggest optimal officer assignments

## 🛠️ Setup Instructions

### 1. API Keys Setup

#### OpenAI API (Free Tier)
1. Visit [OpenAI Platform](https://platform.openai.com/)
2. Create an account and verify your email
3. Navigate to API Keys section
4. Create a new API key
5. **Free Tier Limits**: $5 credit/month, ~1000 requests

#### Google Gemini API (Free Tier)
1. Visit [Google AI Studio](https://makersuite.google.com/app/apikey)
2. Sign in with your Google account
3. Create a new API key
4. **Free Tier Limits**: 15 requests/minute, 1000 requests/day

### 2. Configuration

Update your `application.properties`:

```properties
# AI Service Configuration
app.ai.openai.api-key=your-openai-api-key-here
app.ai.gemini.api-key=your-gemini-api-key-here
app.ai.service=openai  # or gemini, or hybrid
app.ai.enabled=true
app.ai.cache-enabled=true
```

### 3. Database Schema

The system automatically creates the required tables. Key tables:

```sql
-- AI-generated report summaries
CREATE TABLE report_summaries (
    id UUID PRIMARY KEY,
    report_id UUID REFERENCES reports(id),
    summary TEXT NOT NULL,
    key_points TEXT,
    urgency_level VARCHAR(20),
    priority_level VARCHAR(20),
    tags TEXT[],
    ai_service_used VARCHAR(50),
    confidence_score DOUBLE PRECISION,
    created_at TIMESTAMP DEFAULT NOW()
);
```

## 📡 API Endpoints

### Report Summarization

#### Generate Summary
```http
POST /api/ai/summarize
Content-Type: application/json
Authorization: Bearer <jwt-token>

{
  "title": "Suspicious Activity in Downtown",
  "description": "Multiple reports of suspicious individuals loitering around the bank area...",
  "crimeType": "Suspicious Activity",
  "location": "Downtown Bank District",
  "timestamp": "2024-01-15T14:30:00",
  "summaryLength": "MEDIUM"
}
```

**Response:**
```json
{
  "summaryId": "uuid-here",
  "summary": "AI-generated summary...",
  "keyPoints": "Key points extracted...",
  "urgency": "MEDIUM",
  "priority": "MEDIUM",
  "tags": ["suspicious", "downtown", "bank"],
  "aiServiceUsed": "openai",
  "confidence": 0.85,
  "processingTimeMs": 1250
}
```

#### Get Summary by Report ID
```http
POST /api/ai/summarize/{reportId}
Authorization: Bearer <jwt-token>
```

#### Test AI Service
```http
POST /api/ai/test
Authorization: Bearer <jwt-token>

{
  "prompt": "Test message for AI service"
}
```

#### Check AI Status
```http
GET /api/ai/status
```

## 💻 Code Examples

### 1. Java Service Call

```java
@Service
public class ReportService {
    
    @Autowired
    private AIService aiService;
    
    public ReportSummaryResponse generateSummary(CreateReportRequest reportRequest) {
        ReportSummaryRequest aiRequest = ReportSummaryRequest.builder()
            .title(reportRequest.getTitle())
            .description(reportRequest.getDescription())
            .crimeType(reportRequest.getCrimeType())
            .location(reportRequest.getLocation())
            .summaryLength(ReportSummaryRequest.SummaryLength.MEDIUM)
            .build();
            
        return aiService.summarizeReport(aiRequest);
    }
}
```

### 2. Frontend Integration (JavaScript)

```javascript
// Generate AI summary
async function generateAISummary(reportData) {
    try {
        const response = await fetch('/api/ai/summarize', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${token}`
            },
            body: JSON.stringify({
                title: reportData.title,
                description: reportData.description,
                crimeType: reportData.crimeType,
                location: reportData.location,
                summaryLength: 'MEDIUM'
            })
        });
        
        const summary = await response.json();
        displaySummary(summary);
        
    } catch (error) {
        console.error('Error generating summary:', error);
    }
}

// Display summary in UI
function displaySummary(summary) {
    const summaryContainer = document.getElementById('ai-summary');
    summaryContainer.innerHTML = `
        <div class="summary-card">
            <h4>AI Summary</h4>
            <p><strong>Summary:</strong> ${summary.summary}</p>
            <p><strong>Urgency:</strong> <span class="urgency-${summary.urgency.toLowerCase()}">${summary.urgency}</span></p>
            <p><strong>Priority:</strong> <span class="priority-${summary.priority.toLowerCase()}">${summary.priority}</span></p>
            <div class="tags">
                ${summary.tags.map(tag => `<span class="tag">${tag}</span>`).join('')}
            </div>
            <small>Generated by ${summary.aiServiceUsed} in ${summary.processingTimeMs}ms</small>
        </div>
    `;
}
```

### 3. cURL Examples

#### Test OpenAI
```bash
curl -X POST "http://localhost:8080/api/ai/summarize" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -d '{
    "title": "Test Crime Report",
    "description": "This is a test description for AI summarization",
    "summaryLength": "SHORT"
  }'
```

#### Test Gemini
```bash
# First, change service to gemini in application.properties
curl -X POST "http://localhost:8080/api/ai/test" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -d '{
    "prompt": "Test Gemini API integration"
  }'
```

## 🔧 Configuration Options

### AI Service Selection
```properties
# Use OpenAI
app.ai.service=openai

# Use Gemini
app.ai.service=gemini

# Use hybrid (fallback between services)
app.ai.service=hybrid
```

### Model Configuration
```properties
# OpenAI
app.ai.openai.model=gpt-3.5-turbo
app.ai.openai.max-tokens=150
app.ai.openai.temperature=0.3

# Gemini
app.ai.gemini.model=gemini-pro
app.ai.gemini.max-tokens=150
app.ai.gemini.temperature=0.3
```

### Caching Configuration
```properties
app.ai.cache-enabled=true
app.ai.cache-ttl=3600  # seconds
```

## 📊 Monitoring & Analytics

### Database Queries

```sql
-- Get summary statistics
SELECT 
    ai_service_used,
    COUNT(*) as total_summaries,
    AVG(confidence_score) as avg_confidence,
    AVG(processing_time_ms) as avg_processing_time
FROM report_summaries 
GROUP BY ai_service_used;

-- Get summaries by urgency
SELECT urgency_level, COUNT(*) 
FROM report_summaries 
GROUP BY urgency_level;

-- Get performance metrics
SELECT 
    DATE(created_at) as date,
    COUNT(*) as summaries_generated,
    AVG(processing_time_ms) as avg_processing_time
FROM report_summaries 
GROUP BY DATE(created_at)
ORDER BY date DESC;
```

### Log Analysis

The system logs all AI operations. Key log entries:

```log
INFO  - AI summary generated for report UUID in 1250ms using OpenAI
WARN  - OpenAI API failed, falling back to Gemini
ERROR - All AI services unavailable
```

## 🚨 Error Handling

### Common Issues & Solutions

#### 1. API Key Issues
```log
Error: OpenAI API error: 401 - Unauthorized
Solution: Verify API key in application.properties
```

#### 2. Rate Limiting
```log
Error: OpenAI API error: 429 - Too Many Requests
Solution: Implement exponential backoff or switch to Gemini
```

#### 3. Service Unavailable
```log
Error: All AI services are unavailable
Solution: Check network connectivity and API endpoints
```

### Fallback Strategy

The system implements a hybrid approach:
1. **Primary**: OpenAI (if configured)
2. **Fallback**: Gemini (if OpenAI fails)
3. **Graceful Degradation**: Return error with suggestions

## 🔒 Security Considerations

### API Key Security
- **Never commit API keys** to version control
- Use environment variables in production
- Implement key rotation policies

### Rate Limiting
- Monitor API usage to stay within free tier limits
- Implement client-side rate limiting
- Use caching to reduce API calls

### Data Privacy
- AI prompts may contain sensitive information
- Ensure compliance with data protection regulations
- Consider data anonymization for AI training

## 🚀 Next Steps

### Phase 2: Pattern Analysis
- Implement crime pattern detection algorithms
- Add geographic clustering analysis
- Create temporal pattern recognition

### Phase 3: Predictive Alerts
- Develop machine learning models
- Implement risk scoring algorithms
- Add real-time alert generation

### Phase 4: Anomaly Detection
- Statistical anomaly detection
- Behavioral pattern analysis
- Automated flagging system

### Phase 5: Recommendations
- Officer assignment optimization
- Resource allocation suggestions
- Strategic planning insights

## 📞 Support

For issues or questions:
1. Check the logs for detailed error messages
2. Verify API key configuration
3. Test with the `/api/ai/test` endpoint
4. Monitor API usage limits

## 📚 Additional Resources

- [OpenAI API Documentation](https://platform.openai.com/docs)
- [Google Gemini API Documentation](https://ai.google.dev/docs)
- [Spring Boot Caching](https://spring.io/guides/gs/caching/)
- [OkHttp Documentation](https://square.github.io/okhttp/)

---

**Note**: This implementation uses free tier APIs. For production use, consider upgrading to paid tiers for better reliability and higher rate limits.
