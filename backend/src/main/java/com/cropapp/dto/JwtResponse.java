package com.cropapp.dto;

public class JwtResponse {
    
    private String token;
    private String type = "Bearer";
    private Long id;
    private String username;
    private String mobile;
    private String fullName;
    private String role;
    
    // Constructors
    public JwtResponse() {}
    
    public JwtResponse(String accessToken, Long id, String username, String mobile, String fullName) {
        this.token = accessToken;
        this.id = id;
        this.username = username;
        this.mobile = mobile;
        this.fullName = fullName;
    }
    
    public JwtResponse(String accessToken, Long id, String username, String mobile, String fullName, String role) {
        this.token = accessToken;
        this.id = id;
        this.username = username;
        this.mobile = mobile;
        this.fullName = fullName;
        this.role = role;
    }
    
    // Getters and Setters
    public String getToken() {
        return token;
    }
    
    public void setToken(String token) {
        this.token = token;
    }
    
    public String getType() {
        return type;
    }
    
    public void setType(String type) {
        this.type = type;
    }
    
    public Long getId() {
        return id;
    }
    
    public void setId(Long id) {
        this.id = id;
    }
    
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
}
