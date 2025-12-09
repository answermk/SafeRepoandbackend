package com.crimeprevention.crime_backend.core.service.impl;

import com.crimeprevention.crime_backend.core.service.interfaces.EmailService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Service;

@Service
@Slf4j
public class EmailServiceImpl implements EmailService {

    @Autowired(required = false)
    private JavaMailSender mailSender;
    
    @Value("${app.email.from:}")
    private String fromEmail;
    
    @Value("${app.email.from-name:Crime Prevention System}")
    private String fromName;
    
    @Value("${app.email.enabled:false}")
    private boolean emailEnabled;

    @Override
    public void sendPasswordResetEmail(String to, String resetLink, String userName) {
        if (!emailEnabled || mailSender == null) {
            log.warn("⚠️ Email service is disabled. Password reset email not sent to {}. Reset link: {}", to, resetLink);
            throw new RuntimeException("Email service is not configured. Please contact administrator.");
        }
        
        try {
            SimpleMailMessage message = new SimpleMailMessage();
            message.setFrom(fromEmail);
            message.setTo(to);
            message.setSubject("Password Reset Request - Crime Prevention System");
            message.setText(
                "Hello " + userName + ",\n\n" +
                "You have requested a password reset for your account.\n\n" +
                "Click the following link to reset your password:\n" +
                resetLink + "\n\n" +
                "This link will expire in 24 hours.\n\n" +
                "If you didn't request this, please ignore this email.\n\n" +
                "Best regards,\nCrime Prevention Team"
            );
            
            mailSender.send(message);
            log.info("📧 Password reset email sent to {} for user {}", to, userName);
            
        } catch (Exception e) {
            log.error("Failed to send password reset email to {}: {}", to, e.getMessage());
            log.warn("⚠️ Password reset email failed. User may need to use alternative method.");
            throw new RuntimeException("Failed to send email", e);
        }
    }

    @Override
    public void sendPasswordResetCode(String to, String code, String userName) {
        if (!emailEnabled || mailSender == null) {
            log.warn("⚠️ Email service is disabled. Password reset code not sent to {}.", to);
            log.info("🔑 DEVELOPMENT MODE: Password reset code for {} is: {}", to, code);
            log.warn("⚠️ In production, email service must be configured for password reset to work.");
            throw new RuntimeException("Email service is not configured. Please contact administrator.");
        }
        
        try {
            SimpleMailMessage message = new SimpleMailMessage();
            message.setFrom(fromEmail);
            message.setTo(to);
            message.setSubject("Password Reset Code - Crime Prevention System");
            message.setText(
                "Hello " + userName + ",\n\n" +
                "You have requested a password reset for your account.\n\n" +
                "Your verification code is: " + code + "\n\n" +
                "Enter this code in the app to reset your password.\n\n" +
                "This code will expire in 15 minutes.\n\n" +
                "If you didn't request this, please ignore this email.\n\n" +
                "Best regards,\nCrime Prevention Team"
            );
            
            mailSender.send(message);
            log.info("📧 Password reset code sent to {} for user {}", to, userName);
            
        } catch (Exception e) {
            log.error("Failed to send password reset code to {}: {}", to, e.getMessage());
            log.warn("⚠️ Password reset code failed. User may need to use alternative method.");
            throw new RuntimeException("Failed to send email", e);
        }
    }

    @Override
    public void sendWelcomeEmail(String to, String userName) {
        if (!emailEnabled || mailSender == null) {
            log.debug("📧 Email service is disabled. Welcome email not sent to {}. User registration continues.", to);
            return; // Don't throw - registration should succeed even without email
        }
        
        try {
            SimpleMailMessage message = new SimpleMailMessage();
            message.setFrom(fromEmail);
            message.setTo(to);
            message.setSubject("Welcome to Crime Prevention System");
            message.setText(
                "Hello " + userName + ",\n\n" +
                "Welcome to the Crime Prevention System!\n\n" +
                "Your account has been created successfully. You can now:\n" +
                "- Report crimes and suspicious activities\n" +
                "- Join neighborhood watch groups\n" +
                "- Communicate with law enforcement\n" +
                "- Stay updated with community safety alerts\n\n" +
                "Login to your account to get started.\n\n" +
                "Best regards,\nCrime Prevention Team"
            );
            
            mailSender.send(message);
            log.info("📧 Welcome email sent to {} for user {}", to, userName);
            
        } catch (Exception e) {
            log.error("Failed to send welcome email to {}: {}", to, e.getMessage());
            log.warn("⚠️ User registration will continue despite email failure. Check email configuration if needed.");
            // Don't throw exception - email failure shouldn't block user registration
        }
    }

    @Override
    public void sendAccountUpdateEmail(String to, String userName, String updateType) {
        if (!emailEnabled || mailSender == null) {
            log.debug("📧 Email service is disabled. Account update email not sent to {}.", to);
            return;
        }
        
        try {
            SimpleMailMessage message = new SimpleMailMessage();
            message.setFrom(fromEmail);
            message.setTo(to);
            message.setSubject("Account Updated - Crime Prevention System");
            message.setText(
                "Hello " + userName + ",\n\n" +
                "Your account has been updated successfully.\n\n" +
                "Update Details:\n" +
                "- " + updateType + " has been modified\n\n" +
                "If you didn't make this change, please contact support immediately.\n\n" +
                "Best regards,\nCrime Prevention Team"
            );
            
            mailSender.send(message);
            log.info("📧 Account update email sent to {} for user {}: {}", to, userName, updateType);
            
        } catch (Exception e) {
            log.error("Failed to send account update email to {}: {}", to, e.getMessage());
            // Don't throw exception - email failure shouldn't block account updates
        }
    }

    @Override
    public void sendPasswordChangeEmail(String to, String userName) {
        if (!emailEnabled || mailSender == null) {
            log.debug("📧 Email service is disabled. Password change email not sent to {}.", to);
            return;
        }
        
        try {
            SimpleMailMessage message = new SimpleMailMessage();
            message.setFrom(fromEmail);
            message.setTo(to);
            message.setSubject("Password Changed - Crime Prevention System");
            message.setText(
                "Hello " + userName + ",\n\n" +
                "Your password has been changed successfully.\n\n" +
                "If you didn't make this change, please contact support immediately.\n\n" +
                "Best regards,\nCrime Prevention Team"
            );
            
            mailSender.send(message);
            log.info("📧 Password change email sent to {} for user {}", to, userName);
            
        } catch (Exception e) {
            log.error("Failed to send password change email to {}: {}", to, e.getMessage());
            // Don't throw exception - email failure shouldn't block password changes
        }
    }

    @Override
    public void sendNewsNotification(String to, String userName, String newsTitle, String newsContent) {
        if (!emailEnabled || mailSender == null) {
            log.debug("📧 Email service is disabled. News notification email not sent to {}.", to);
            return;
        }
        
        try {
            SimpleMailMessage message = new SimpleMailMessage();
            message.setFrom(fromEmail);
            message.setTo(to);
            message.setSubject("News Update: " + newsTitle + " - Crime Prevention System");
            message.setText(
                "Hello " + userName + ",\n\n" +
                "You have a new news update from the Crime Prevention System.\n\n" +
                "Title: " + newsTitle + "\n\n" +
                "Content:\n" + newsContent + "\n\n" +
                "Stay informed and stay safe!\n\n" +
                "Best regards,\nCrime Prevention Team"
            );
            
            mailSender.send(message);
            log.info("📧 News notification email sent to {} for user {}: {}", to, userName, newsTitle);
            
        } catch (Exception e) {
            log.error("Failed to send news notification email to {}: {}", to, e.getMessage());
            // Don't throw exception - email failure shouldn't block notifications
        }
    }
} 