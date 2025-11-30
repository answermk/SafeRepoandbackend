package com.crimeprevention.crime_backend.core.service.interfaces;

import java.util.UUID;

public interface PasswordResetService {
    
    /**
     * Request password reset for a user
     * @param email User's email address
     * @return true if reset email was sent, false otherwise
     */
    boolean requestPasswordReset(String email);
    
    /**
     * Reset password using reset token
     * @param token Reset token from email
     * @param newPassword New password
     * @return true if password was reset successfully, false otherwise
     */
    boolean resetPassword(String token, String newPassword);
    
    /**
     * Validate reset token
     * @param token Reset token to validate
     * @return true if token is valid, false otherwise
     */
    boolean validateResetToken(String token);
    
    /**
     * Get user ID from reset token
     * @param token Reset token
     * @return User ID if token is valid, null otherwise
     */
    UUID getUserIdFromToken(String token);
    
    /**
     * Clean up expired tokens
     */
    void cleanupExpiredTokens();
} 