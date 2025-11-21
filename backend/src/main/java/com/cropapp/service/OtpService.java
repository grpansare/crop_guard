package com.cropapp.service;

import com.cropapp.entity.OtpEntity;
import com.cropapp.repository.OtpRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.security.SecureRandom;
import java.time.LocalDateTime;
import java.util.Optional;

@Service
public class OtpService {
    private static final Logger logger = LoggerFactory.getLogger(OtpService.class);

    @Autowired
    private OtpRepository otpRepository;

    @Autowired
    private SmsService smsService;

    private static final int OTP_LENGTH = 6;
    private static final int OTP_EXPIRY_MINUTES = 5;
    private static final int MAX_ATTEMPTS = 3;

    private final SecureRandom random = new SecureRandom();

    @Transactional
    public boolean generateAndSendOtp(String mobile) {
        try {
            // Clean up expired OTPs
            otpRepository.deleteExpiredOtps(LocalDateTime.now());

            // Generate 6-digit OTP
            String otp = generateOtp();

            // Set expiry time (5 minutes from now)
            LocalDateTime expiresAt = LocalDateTime.now().plusMinutes(OTP_EXPIRY_MINUTES);

            // Save OTP to database
            OtpEntity otpEntity = new OtpEntity(mobile, otp, expiresAt);
            otpRepository.save(otpEntity);

            // Send SMS (for development, we'll just log it)
            boolean smsSent = smsService.sendOtp(mobile, otp);

            if (!smsSent) {
                logger.warn("Failed to send SMS to: {}", mobile);
                // In production, you might want to delete the OTP if SMS fails
                // For development, we'll keep it for testing
            }

            return true;
        } catch (Exception e) {
            logger.error("Error generating OTP for mobile: {}, Error: {}", mobile, e.getMessage());
            return false;
        }
    }

    @Transactional
    public boolean verifyOtp(String mobile, String otp) {
        try {
            // Find valid OTP for the mobile number
            Optional<OtpEntity> otpEntityOpt = otpRepository.findValidOtpByMobile(mobile, LocalDateTime.now());

            if (otpEntityOpt.isEmpty()) {
                logger.info("No valid OTP found for mobile: {}", mobile);
                return false;
            }

            OtpEntity otpEntity = otpEntityOpt.get();

            // Check if max attempts exceeded
            if (otpEntity.getAttempts() >= MAX_ATTEMPTS) {
                logger.info("Max OTP attempts exceeded for mobile: {}", mobile);
                return false;
            }

            // Increment attempts
            otpEntity.incrementAttempts();
            otpRepository.save(otpEntity);

            // Verify OTP
            if (otpEntity.getOtp().equals(otp)) {
                // Mark OTP as verified
                otpEntity.setVerified(true);
                otpRepository.save(otpEntity);
                logger.info("OTP verified successfully for mobile: {}", mobile);
                return true;
            } else {
                logger.info("Invalid OTP for mobile: {}", mobile);
                return false;
            }

        } catch (Exception e) {
            logger.error("Error verifying OTP for mobile: {}, Error: {}", mobile, e.getMessage());
            return false;
        }
    }

    private String generateOtp() {
        StringBuilder otp = new StringBuilder();
        for (int i = 0; i < OTP_LENGTH; i++) {
            otp.append(random.nextInt(10));
        }
        return otp.toString();
    }

    @Transactional
    public void cleanupExpiredOtps() {
        otpRepository.deleteExpiredOtps(LocalDateTime.now());
    }
}
