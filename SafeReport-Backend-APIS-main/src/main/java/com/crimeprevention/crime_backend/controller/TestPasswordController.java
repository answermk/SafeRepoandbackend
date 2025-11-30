package com.crimeprevention.crime_backend.controller;

import com.crimeprevention.crime_backend.core.model.user.User;
import com.crimeprevention.crime_backend.core.repo.user.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

/**
 * Temporary controller to help fix password hashes
 * This should be removed or secured in production
 */
@RestController
@RequestMapping("/api/test/password")
@RequiredArgsConstructor
public class TestPasswordController {
    
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    
    /**
     * Generate a BCrypt hash for a password
     * GET /api/test/password/generate?password=password123
     */
    @GetMapping("/generate")
    public ResponseEntity<Map<String, String>> generateHash(@RequestParam String password) {
        String hash = passwordEncoder.encode(password);
        
        Map<String, String> response = new HashMap<>();
        response.put("password", password);
        response.put("hash", hash);
        response.put("sql", "UPDATE users SET password_hash = '" + hash + "' WHERE password_hash IS NOT NULL;");
        response.put("verification", String.valueOf(passwordEncoder.matches(password, hash)));
        
        return ResponseEntity.ok(response);
    }
    
    /**
     * Update a specific user's password hash
     * POST /api/test/password/update
     * Body: { "email": "admin@crimereport.gov.rw", "password": "password123" }
     */
    @PostMapping("/update")
    public ResponseEntity<Map<String, String>> updateUserPassword(@RequestBody Map<String, String> request) {
        String email = request.get("email");
        String password = request.get("password");
        
        User user = userRepository.findByEmail(email).orElse(null);
        if (user == null) {
            Map<String, String> error = new HashMap<>();
            error.put("error", "User not found with email: " + email);
            return ResponseEntity.badRequest().body(error);
        }
        
        String hash = passwordEncoder.encode(password);
        user.setPasswordHash(hash);
        userRepository.save(user);
        
        Map<String, String> response = new HashMap<>();
        response.put("email", email);
        response.put("username", user.getUsername());
        response.put("hash", hash);
        response.put("message", "Password hash updated successfully");
        response.put("verification", String.valueOf(passwordEncoder.matches(password, hash)));
        
        return ResponseEntity.ok(response);
    }
    
    /**
     * Update all users' password hashes to the same password
     * POST /api/test/password/update-all
     * Body: { "password": "password123" }
     */
    @PostMapping("/update-all")
    public ResponseEntity<Map<String, Object>> updateAllPasswords(@RequestBody Map<String, String> request) {
        String password = request.get("password");
        String hash = passwordEncoder.encode(password);
        
        int updated = 0;
        for (User user : userRepository.findAll()) {
            if (user.getPasswordHash() != null) {
                user.setPasswordHash(hash);
                userRepository.save(user);
                updated++;
            }
        }
        
        Map<String, Object> response = new HashMap<>();
        response.put("password", password);
        response.put("hash", hash);
        response.put("usersUpdated", updated);
        response.put("message", "All password hashes updated successfully");
        response.put("verification", String.valueOf(passwordEncoder.matches(password, hash)));
        response.put("sql", "UPDATE users SET password_hash = '" + hash + "' WHERE password_hash IS NOT NULL;");
        
        return ResponseEntity.ok(response);
    }
}

