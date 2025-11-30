package com.crimeprevention.crime_backend.util;

import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;

/**
 * Utility class to generate BCrypt password hashes for SQL scripts
 * Run this as a main method to generate hashes that will work with Spring Security
 */
public class PasswordHashGenerator {
    
    public static void main(String[] args) {
        BCryptPasswordEncoder encoder = new BCryptPasswordEncoder();
        
        // Generate hash for "password123"
        String password = "password123";
        String hash = encoder.encode(password);
        
        System.out.println("==========================================");
        System.out.println("BCrypt Password Hash Generator");
        System.out.println("==========================================");
        System.out.println("Password: " + password);
        System.out.println("Hash: " + hash);
        System.out.println("==========================================");
        System.out.println();
        System.out.println("SQL UPDATE statement:");
        System.out.println("UPDATE users SET password_hash = '" + hash + "' WHERE password_hash IS NOT NULL;");
        System.out.println();
        System.out.println("Verification (should be true):");
        System.out.println("Matches: " + encoder.matches(password, hash));
        System.out.println("==========================================");
        
        // Generate multiple hashes to show they're different but all work
        System.out.println("\nGenerating 3 more hashes (all should work):");
        for (int i = 1; i <= 3; i++) {
            String newHash = encoder.encode(password);
            boolean matches = encoder.matches(password, newHash);
            System.out.println("Hash " + i + ": " + newHash);
            System.out.println("  Matches: " + matches);
        }
    }
}

