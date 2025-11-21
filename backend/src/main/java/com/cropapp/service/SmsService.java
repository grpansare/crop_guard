package com.cropapp.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

@Service
public class SmsService {
    private static final Logger logger = LoggerFactory.getLogger(SmsService.class);

    /**
     * Sends OTP via SMS to the given mobile number.
     * For development purposes, this will log the OTP to the application logger.
     * In production, integrate with SMS providers like Twilio, AWS SNS, or local SMS gateways.
     *
     * @param mobile The mobile number to send OTP to
     * @param otp The OTP to send
     * @return true if SMS was sent successfully, false otherwise
     */
    public boolean sendOtp(String mobile, String otp) {
        try {
            // For development - just log the OTP
            logger.info("SMS SERVICE - Sending OTP to mobile: {}", mobile);
            logger.info("OTP: {}", otp);
            logger.info("Message: Your Crop Disease App OTP is: {}. Valid for 5 minutes. Do not share this OTP with anyone.", otp);

            // TODO: In production, replace this with actual SMS integration
            // Example integrations:
            // 1. Twilio SMS API
            // 2. AWS SNS
            // 3. Firebase Cloud Messaging
            // 4. Local SMS gateway

            // Simulate SMS sending delay
            Thread.sleep(100);

            return true;
        } catch (Exception e) {
            logger.error("Error sending SMS to {}: {}", mobile, e.getMessage());
            return false;
        }
    }

    /**
     * For production use - integrate with actual SMS provider
     * Example method signature for Twilio integration (commented):
     */
    /*
    private boolean sendSmsViaTwilio(String mobile, String otp) {
        try {
            Twilio.init(ACCOUNT_SID, AUTH_TOKEN);

            Message message = Message.creator(
                new PhoneNumber("+91" + mobile), // To number
                new PhoneNumber(TWILIO_PHONE_NUMBER), // From number
                "Your Crop Disease App OTP is: " + otp + ". Valid for 5 minutes."
            ).create();

            return message.getSid() != null;
        } catch (Exception e) {
            logger.error("Twilio SMS error: {}", e.getMessage());
            return false;
        }
    }
    */
}
