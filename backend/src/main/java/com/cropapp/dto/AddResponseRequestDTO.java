package com.cropapp.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public class AddResponseRequestDTO {
    
    @NotBlank(message = "Response is required")
    @Size(min = 10, max = 2000, message = "Response must be between 10 and 2000 characters")
    private String response;

    // Constructors
    public AddResponseRequestDTO() {}

    public AddResponseRequestDTO(String response) {
        this.response = response;
    }

    // Getters and Setters
    public String getResponse() {
        return response;
    }

    public void setResponse(String response) {
        this.response = response;
    }
}
