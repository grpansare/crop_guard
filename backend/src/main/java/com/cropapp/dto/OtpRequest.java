package com.cropapp.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;

public class OtpRequest {
    @NotBlank(message = "Mobile number is required")
    @Pattern(regexp = "^[6-9]\\d{9}$", message = "Please enter a valid 10-digit mobile number")
    private String mobile;

    public OtpRequest() {}

    public OtpRequest(String mobile) {
        this.mobile = mobile;
    }

    public String getMobile() {
        return mobile;
    }

    public void setMobile(String mobile) {
        this.mobile = mobile;
    }
}
