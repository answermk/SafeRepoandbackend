package com.crimeprevention.crime_backend.core.service.impl;

import com.crimeprevention.crime_backend.core.service.interfaces.SmsService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

@Service
@Slf4j
public class SmsServiceImpl implements SmsService {

    private static final String SMS_SEPARATOR = "=".repeat(80);

    @Override
    public void sendPasswordResetSms(String phoneNumber, String resetCode, String userName) {
        log.info(SMS_SEPARATOR);
        log.info("📱 PASSWORD RESET SMS");
        log.info("📱 To: {}", phoneNumber);
        log.info("📱 User: {}", userName);
        log.info("📱 Code: {}", resetCode);
        log.info("📱 Time: {}", LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")));
        log.info("📱 Message: Your password reset code is: {}. Valid for 10 minutes.", resetCode);
        log.info(SMS_SEPARATOR);
        // TODO: Integrate with actual SMS service (Twilio, AWS SNS, etc.)
    }

    @Override
    public void sendWelcomeSms(String phoneNumber, String userName) {
        log.info(SMS_SEPARATOR);
        log.info("📱 WELCOME SMS");
        log.info("📱 To: {}", phoneNumber);
        log.info("📱 User: {}", userName);
        log.info("📱 Time: {}", LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")));
        log.info("📱 Message: Welcome {}! Your Crime Prevention System account has been created successfully.", userName);
        log.info(SMS_SEPARATOR);
        // TODO: Integrate with actual SMS service
    }

    @Override
    public void sendAccountUpdateSms(String phoneNumber, String userName, String updateType) {
        log.info(SMS_SEPARATOR);
        log.info("📱 ACCOUNT UPDATE SMS");
        log.info("📱 To: {}", phoneNumber);
        log.info("📱 User: {}", userName);
        log.info("📱 Update: {}", updateType);
        log.info("📱 Time: {}", LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")));
        log.info("📱 Message: Hi {}, your account has been updated: {}. Contact support if this wasn't you.", userName, updateType);
        log.info(SMS_SEPARATOR);
        // TODO: Integrate with actual SMS service
    }

    @Override
    public void sendPasswordChangeSms(String phoneNumber, String userName) {
        log.info(SMS_SEPARATOR);
        log.info("📱 PASSWORD CHANGE SMS");
        log.info("📱 To: {}", phoneNumber);
        log.info("📱 User: {}", userName);
        log.info("📱 Time: {}", LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")));
        log.info("📱 Message: Hi {}, your password has been changed successfully. Contact support immediately if this wasn't you.", userName);
        log.info(SMS_SEPARATOR);
        // TODO: Integrate with actual SMS service
    }

    @Override
    public void sendNewsNotificationSms(String phoneNumber, String userName, String newsTitle) {
        log.info(SMS_SEPARATOR);
        log.info("📱 NEWS NOTIFICATION SMS");
        log.info("📱 To: {}", phoneNumber);
        log.info("📱 User: {}", userName);
        log.info("📱 News: {}", newsTitle);
        log.info("📱 Time: {}", LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")));
        log.info("📱 Message: Hi {}, you have a new alert: {}. Check the Crime Prevention System for details.", userName, newsTitle);
        log.info(SMS_SEPARATOR);
        // TODO: Integrate with actual SMS service
    }

    // Additional SMS methods for comprehensive testing
    public void sendEmergencyAlertSms(String phoneNumber, String userName, String alertTitle, String alertMessage) {
        log.info(SMS_SEPARATOR);
        log.info("🚨 EMERGENCY ALERT SMS");
        log.info("📱 To: {}", phoneNumber);
        log.info("📱 User: {}", userName);
        log.info("📱 Alert: {}", alertTitle);
        log.info("📱 Time: {}", LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")));
        log.info("📱 Message: 🚨 EMERGENCY: {}. {}. Take immediate action.", alertTitle, alertMessage);
        log.info(SMS_SEPARATOR);
    }

    public void sendCaseUpdateSms(String phoneNumber, String userName, String caseTitle, String updateMessage) {
        log.info(SMS_SEPARATOR);
        log.info("📋 CASE UPDATE SMS");
        log.info("📱 To: {}", phoneNumber);
        log.info("📱 User: {}", userName);
        log.info("📱 Case: {}", caseTitle);
        log.info("📱 Time: {}", LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")));
        log.info("📱 Message: Hi {}, your case '{}' has been updated: {}. Check the system for details.", userName, caseTitle, updateMessage);
        log.info(SMS_SEPARATOR);
    }
} 