package com.cropapp.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

public class SignupRequest {
    
    // Username is optional, will be auto-generated from mobile if not provided
    @Size(max = 50, message = "Username must not exceed 50 characters")
    private String username;
    
    @NotBlank(message = "Mobile number is required")
    @Size(min = 10, max = 15, message = "Mobile number must be between 10 and 15 digits")
    @Pattern(regexp = "^[0-9+]+", message = "Mobile number can only contain numbers and +")
    private String mobile;
    
    @NotBlank(message = "Password is required")
    @Size(min = 6, max = 40, message = "Password must be between 6 and 40 characters")
    private String password;
    
    @Size(max = 100, message = "Full name cannot exceed 100 characters")
    private String fullName;
    
    private String role; // USER, ADMIN, EXPERT
    @Size(max = 200, message = "Specialization cannot exceed 200 characters")
    private String specialization; // Expert specialization areas (only for EXPERT role)

    @Size(max = 100, message = "Email cannot exceed 100 characters")
    @Pattern(regexp = "^$|^\\S+@\\S+\\.\\S+$", message = "Email must be a valid email address")
    private String email; // Optional email; recommended for experts

    private String verificationDocument; // Base64 encoded document or path/URL (for EXPERT role)

    // Constructors
    public SignupRequest() {}
    
    public SignupRequest(String username, String mobile, String password, String fullName) {
        this.username = username;
        this.mobile = mobile;
        this.password = password;
        this.fullName = fullName;
    }
    
    // Getters and Setters
    public String getUsername() {
        return username;
    }
    
    public void setUsername(String username) {
        this.username = username;
    }
    
    public String getMobile() {
        return mobile;
    }
    
    public void setMobile(String mobile) {
        this.mobile = mobile;
    }
    
    public String getPassword() {
        return password;
    }
    
    public void setPassword(String password) {
        this.password = password;
    }
    
    public String getFullName() {
        return fullName;
    }
    
    public void setFullName(String fullName) {
        this.fullName = fullName;
    }
    
    public String getRole() {
        return role;
    }
    
    public void setRole(String role) {
        this.role = role;
    }
    // Add getter and setter after line 76:
public String getSpecialization() {
    return specialization;
}

public void setSpecialization(String specialization) {
    this.specialization = specialization;
}

public String getEmail() {
    return email;
}

public void setEmail(String email) {
    this.email = email;
}

public String getVerificationDocument() {
    return verificationDocument;
}

public void setVerificationDocument(String verificationDocument) {
    this.verificationDocument = verificationDocument;
}
}
