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

    @Autowired
    private JavaMailSender mailSender;
    
    @Value("${app.email.from}")
    private String fromEmail;
    
    @Value("${app.email.from-name}")
    private String fromName;

    @Override
    public void sendPasswordResetEmail(String to, String resetLink, String userName) {
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
            log.info("📧 Real password reset email sent to {} for user {}", to, userName);
            
        } catch (Exception e) {
            log.error("Failed to send password reset email to {}: {}", to, e.getMessage());
            throw new RuntimeException("Failed to send email", e);
        }
    }

    @Override
    public void sendWelcomeEmail(String to, String userName) {
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
            log.info("📧 Real welcome email sent to {} for user {}", to, userName);
            
        } catch (Exception e) {
            log.error("Failed to send welcome email to {}: {}", to, e.getMessage());
            throw new RuntimeException("Failed to send email", e);
        }
    }

    @Override
    public void sendAccountUpdateEmail(String to, String userName, String updateType) {
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
            log.info("📧 Real account update email sent to {} for user {}: {}", to, userName, updateType);
            
        } catch (Exception e) {
            log.error("Failed to send account update email to {}: {}", to, e.getMessage());
            throw new RuntimeException("Failed to send email", e);
        }
    }

    @Override
    public void sendPasswordChangeEmail(String to, String userName) {
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
            log.info("📧 Real password change email sent to {} for user {}", to, userName);
            
        } catch (Exception e) {
            log.error("Failed to send password change email to {}: {}", to, e.getMessage());
            throw new RuntimeException("Failed to send email", e);
        }
    }

    @Override
    public void sendNewsNotification(String to, String userName, String newsTitle, String newsContent) {
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
            log.info("📧 Real news notification email sent to {} for user {}: {}", to, userName, newsTitle);
            
        } catch (Exception e) {
            log.error("Failed to send news notification email to {}: {}", to, e.getMessage());
            throw new RuntimeException("Failed to send email", e);
        }
    }
} 