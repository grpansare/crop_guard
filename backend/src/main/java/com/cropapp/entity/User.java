package com.cropapp.entity;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

import java.time.LocalDateTime;
import java.util.Collection;
import java.util.List;

@Entity
@Table(name = "users")
public class User implements UserDetails {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @NotBlank
    @Size(max = 50)
    private String username;
    
    @NotBlank
    @Size(min = 10, max = 15)
    private String mobile;
    
    @NotBlank
    @Size(max = 255)
    private String password;
    
    @Size(max = 100)
    private String fullName;
    
    @Size(max = 100)
    private String email;
    
    @Column(name = "created_at")
    private LocalDateTime createdAt;
    
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;
    
    private boolean enabled = true;
    
    @Enumerated(EnumType.STRING)
    private Role role = Role.USER;
    
    @Size(max = 200)
    private String specialization;
    
    // Expert verification fields
    @Column(name = "is_verified")
    private boolean isVerified = false;
    
    @Column(name = "verification_status")
    @Enumerated(EnumType.STRING)
    private VerificationStatus verificationStatus = VerificationStatus.PENDING;
    
    @Column(name = "verification_document")
    private String verificationDocument; // Path to uploaded certificate/ID
    
    @Column(name = "license_number")
    private String licenseNumber; // Professional license number
    
    @Column(name = "verified_at")
    private LocalDateTime verifiedAt;
    
    @Column(name = "verified_by")
    private Long verifiedBy; // Admin who verified
    
    public enum Role {
        USER, ADMIN, EXPERT
    }
    
    public enum VerificationStatus {
        PENDING,      // Waiting for admin review
        APPROVED,     // Verified expert
        REJECTED,     // Verification rejected
        SUSPENDED     // Temporarily suspended
    }
    
    // Constructors
    public User() {
        this.createdAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
    }
    
  public User(String username, String mobile, String password, String fullName, String specialization) {
    this();
    this.username = username;
    this.mobile = mobile;
    this.password = password;
    this.fullName = fullName;
    this.specialization = specialization;
}

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }
    
    // UserDetails implementation
    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        return List.of(new SimpleGrantedAuthority("ROLE_" + role.name()));
    }
    
    @Override
    public boolean isAccountNonExpired() {
        return true;
    }
    
    @Override
    public boolean isAccountNonLocked() {
        return true;
    }
    
    @Override
    public boolean isCredentialsNonExpired() {
        return true;
    }
   
    @Override
    public boolean isEnabled() {
        return enabled;
    }
    
    // Getters and Setters
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
    
    public LocalDateTime getCreatedAt() {
        return createdAt;
    }
    
    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }
    
    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }
    
    public void setUpdatedAt(LocalDateTime updatedAt) {
        this.updatedAt = updatedAt;
    }
    
    public void setEnabled(boolean enabled) {
        this.enabled = enabled;
    }
    
    public Role getRole() {
        return role;
    }
    
    public void setRole(Role role) {
        this.role = role;
    }
    
    public String getSpecialization() {
        return specialization;
    }
    
    public void setSpecialization(String specialization) {
        this.specialization = specialization;
    }
    
    public boolean isVerified() {
        return isVerified;
    }
    
    public void setVerified(boolean verified) {
        isVerified = verified;
    }
    
    public VerificationStatus getVerificationStatus() {
        return verificationStatus;
    }
    
    public void setVerificationStatus(VerificationStatus verificationStatus) {
        this.verificationStatus = verificationStatus;
    }
    
    public String getVerificationDocument() {
        return verificationDocument;
    }
    
    public void setVerificationDocument(String verificationDocument) {
        this.verificationDocument = verificationDocument;
    }
    
    public String getLicenseNumber() {
        return licenseNumber;
    }
    
    public void setLicenseNumber(String licenseNumber) {
        this.licenseNumber = licenseNumber;
    }
    
    public LocalDateTime getVerifiedAt() {
        return verifiedAt;
    }
    
    public void setVerifiedAt(LocalDateTime verifiedAt) {
        this.verifiedAt = verifiedAt;
    }
    
    public Long getVerifiedBy() {
        return verifiedBy;
    }
    
    public void setVerifiedBy(Long verifiedBy) {
        this.verifiedBy = verifiedBy;
    }
    
    @PreUpdate
    public void preUpdate() {
        this.updatedAt = LocalDateTime.now();
    }
}
