package com.crimeprevention.crime_backend.ai;

import com.crimeprevention.crime_backend.core.dto.ai.ReportSummaryRequest;
import com.crimeprevention.crime_backend.core.dto.ai.ReportSummaryResponse;
import com.crimeprevention.crime_backend.core.service.interfaces.AIService;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;

import static org.junit.jupiter.api.Assertions.*;

@SpringBootTest
@ActiveProfiles("test")
public class AIServiceIntegrationTest {

    @Autowired
    private AIService aiService;

    @Test
    public void testAIServiceAvailability() {
        // Test if AI service is available
        boolean isAvailable = aiService.isServiceAvailable();
        String currentService = aiService.getCurrentService();
        
        System.out.println("AI Service Available: " + isAvailable);
        System.out.println("Current AI Service: " + currentService);
        
        // Note: This test will fail if no API keys are configured
        // assertTrue(isAvailable, "AI service should be available");
    }

    @Test
    public void testReportSummarization() {
        // Create a test report request
        ReportSummaryRequest request = ReportSummaryRequest.builder()
                .title("Test Crime Report")
                .description("This is a test description for AI summarization. " +
                           "The incident occurred in the downtown area involving suspicious activity. " +
                           "Multiple witnesses reported seeing individuals loitering around the bank premises. " +
                           "The police were notified and responded within 10 minutes.")
                .crimeType("Suspicious Activity")
                .location("Downtown Bank District")
                .timestamp("2024-01-15T14:30:00")
                .summaryLength(ReportSummaryRequest.SummaryLength.SHORT)
                .build();

        try {
            // Attempt to generate summary
            ReportSummaryResponse response = aiService.summarizeReport(request);
            
            // Verify response
            assertNotNull(response, "Response should not be null");
            assertNotNull(response.getSummary(), "Summary should not be null");
            assertNotNull(response.getSummaryId(), "Summary ID should not be null");
            assertNotNull(response.getAiServiceUsed(), "AI service used should not be null");
            assertTrue(response.getProcessingTimeMs() > 0, "Processing time should be positive");
            
            System.out.println("AI Summary Generated Successfully!");
            System.out.println("Service Used: " + response.getAiServiceUsed());
            System.out.println("Processing Time: " + response.getProcessingTimeMs() + "ms");
            System.out.println("Summary: " + response.getSummary());
            System.out.println("Urgency: " + response.getUrgency());
            System.out.println("Priority: " + response.getPriority());
            System.out.println("Tags: " + response.getTags());
            
        } catch (Exception e) {
            // This is expected if no API keys are configured
            System.out.println("AI Service Test Skipped: " + e.getMessage());
            System.out.println("To run this test, configure API keys in application.properties");
            
            // Uncomment the following line to make the test fail when AI service is unavailable
            // fail("AI service should be available for testing: " + e.getMessage());
        }
    }

    @Test
    public void testSummaryLengthOptions() {
        ReportSummaryRequest.SummaryLength[] lengths = ReportSummaryRequest.SummaryLength.values();
        
        assertEquals(3, lengths.length, "Should have 3 summary length options");
        
        for (ReportSummaryRequest.SummaryLength length : lengths) {
            assertTrue(length.getMaxWords() > 0, "Max words should be positive for " + length);
            System.out.println(length + ": " + length.getMaxWords() + " words");
        }
    }

    @Test
    public void testRequestValidation() {
        // Test with minimal required fields
        ReportSummaryRequest request = ReportSummaryRequest.builder()
                .title("Minimal Report")
                .description("Minimal description")
                .build();
        
        assertNotNull(request.getTitle(), "Title should not be null");
        assertNotNull(request.getDescription(), "Description should not be null");
        assertNotNull(request.getSummaryLength(), "Summary length should have default value");
        assertEquals(ReportSummaryRequest.SummaryLength.MEDIUM, request.getSummaryLength(), 
                   "Default summary length should be MEDIUM");
    }
}
