package com.cropapp.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

public class LoginRequest {
    
    @NotBlank(message = "Mobile number is required")
    @Size(min = 10, max = 15, message = "Mobile number must be between 10 and 15 digits")
    @Pattern(regexp = "^[0-9+]+", message = "Mobile number can only contain numbers and +")
    private String mobile;
    
    @NotBlank(message = "Password is required")
    private String password;
    
    // Constructors
    public LoginRequest() {}
    
    public LoginRequest(String mobile, String password) {
        this.mobile = mobile;
        this.password = password;
    }
    
    // Getters and Setters
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
}
