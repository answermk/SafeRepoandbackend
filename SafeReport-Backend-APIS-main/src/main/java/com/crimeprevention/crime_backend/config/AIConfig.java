package com.crimeprevention.crime_backend.config;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

@Data
@Component
@ConfigurationProperties(prefix = "app.ai")
public class AIConfig {
    
    private boolean enabled = true;
    private boolean cacheEnabled = true;
    private int cacheTtl = 3600;
    private String service = "gemini";
    
    // OpenAI Configuration
    private String openaiApiKey;
    private String openaiBaseUrl = "https://api.openai.com/v1";
    private String openaiModel = "gpt-3.5-turbo";
    private int openaiMaxTokens = 150;
    private double openaiTemperature = 0.3;
    
    // Gemini Configuration
    private String geminiApiKey;
    private String geminiBaseUrl = "https://generativelanguage.googleapis.com/v1beta";
    private String geminiModel = "gemini-1.5-flash";
    private int geminiMaxTokens = 150;
    private double geminiTemperature = 0.3;
    
    // Helper methods for backward compatibility
    public String getOpenAI() {
        return openaiApiKey;
    }
    
    public String getGemini() {
        return geminiApiKey;
    }
}
