package com.crimeprevention.crime_backend.core.service.interfaces;

public interface SmsService {
    
    void sendPasswordResetSms(String phoneNumber, String resetCode, String userName);
    
    void sendWelcomeSms(String phoneNumber, String userName);
    
    void sendAccountUpdateSms(String phoneNumber, String userName, String updateType);
    
    void sendPasswordChangeSms(String phoneNumber, String userName);
    
    void sendNewsNotificationSms(String phoneNumber, String userName, String newsTitle);
    
    // Additional SMS methods for comprehensive testing
    void sendEmergencyAlertSms(String phoneNumber, String userName, String alertTitle, String alertMessage);
    
    void sendCaseUpdateSms(String phoneNumber, String userName, String caseTitle, String updateMessage);
} 