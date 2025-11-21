package com.cropapp.entity;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "otp_verification")
public class OtpEntity {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, length = 10)
    private String mobile;

    @Column(nullable = false, length = 6)
    private String otp;

    @Column(nullable = false)
    private LocalDateTime createdAt;

    @Column(nullable = false)
    private LocalDateTime expiresAt;

    @Column(nullable = false)
    private boolean verified = false;

    @Column(nullable = false)
    private int attempts = 0;

    public OtpEntity() {}

    public OtpEntity(String mobile, String otp, LocalDateTime expiresAt) {
        this.mobile = mobile;
        this.otp = otp;
        this.createdAt = LocalDateTime.now();
        this.expiresAt = expiresAt;
    }

    // Getters and Setters
    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getMobile() {
        return mobile;
    }

    public void setMobile(String mobile) {
        this.mobile = mobile;
    }

    public String getOtp() {
        return otp;
    }

    public void setOtp(String otp) {
        this.otp = otp;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public LocalDateTime getExpiresAt() {
        return expiresAt;
    }

    public void setExpiresAt(LocalDateTime expiresAt) {
        this.expiresAt = expiresAt;
    }

    public boolean isVerified() {
        return verified;
    }

    public void setVerified(boolean verified) {
        this.verified = verified;
    }

    public int getAttempts() {
        return attempts;
    }

    public void setAttempts(int attempts) {
        this.attempts = attempts;
    }

    public void incrementAttempts() {
        this.attempts++;
    }

    public boolean isExpired() {
        return LocalDateTime.now().isAfter(expiresAt);
    }
}
