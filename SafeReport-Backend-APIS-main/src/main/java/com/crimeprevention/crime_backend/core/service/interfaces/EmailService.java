package com.crimeprevention.crime_backend.core.service.interfaces;

public interface EmailService {
    
    void sendPasswordResetEmail(String to, String resetLink, String userName);
    
    void sendPasswordResetCode(String to, String code, String userName);
    
    void sendWelcomeEmail(String to, String userName);
    
    void sendAccountUpdateEmail(String to, String userName, String updateType);
    
    void sendPasswordChangeEmail(String to, String userName);
    
    void sendNewsNotification(String to, String userName, String newsTitle, String newsContent);
} 