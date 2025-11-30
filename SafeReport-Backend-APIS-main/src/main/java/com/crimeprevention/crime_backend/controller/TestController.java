package com.crimeprevention.crime_backend.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/test")
public class TestController {

    @GetMapping("/public")
    public ResponseEntity<Map<String, String>> publicEndpoint() {
        return ResponseEntity.ok(Map.of("message", "Public endpoint works"));
    }

    @GetMapping("/protected")
    public ResponseEntity<Map<String, String>> protectedEndpoint() {
        return ResponseEntity.ok(Map.of("message", "Protected GET endpoint works"));
    }

    @PostMapping("/protected")
    public ResponseEntity<Map<String, String>> protectedPostEndpoint(@RequestBody Map<String, Object> body) {
        return ResponseEntity.ok(Map.of(
            "message", "Protected POST endpoint works",
            "receivedData", body.toString()
        ));
    }
}
