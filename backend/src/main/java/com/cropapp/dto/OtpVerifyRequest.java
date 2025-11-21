package com.cropapp.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

public class OtpVerifyRequest {
    @NotBlank(message = "Mobile number is required")
    @Pattern(regexp = "^[6-9]\\d{9}$", message = "Please enter a valid 10-digit mobile number")
    private String mobile;

    @NotBlank(message = "OTP is required")
    @Size(min = 6, max = 6, message = "OTP must be 6 digits")
    @Pattern(regexp = "\\d{6}", message = "OTP must contain only digits")
    private String otp;

    public OtpVerifyRequest() {}

    public OtpVerifyRequest(String mobile, String otp) {
        this.mobile = mobile;
        this.otp = otp;
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
}
