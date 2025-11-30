package com.crimeprevention.crime_backend.core.dto.user;


import lombok.Data;

@Data
public class SignupRequest {
    private String email;
    private String username;
    private String password;
    private String phoneNumber;
    private String fullName;
}