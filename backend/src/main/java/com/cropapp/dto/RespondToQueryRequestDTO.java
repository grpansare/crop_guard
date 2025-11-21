package com.cropapp.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

public class RespondToQueryRequestDTO {
    
    @NotNull(message = "Query ID is required")
    private Long queryId;
    
    @NotBlank(message = "Response is required")
    @Size(min = 10, max = 2000, message = "Response must be between 10 and 2000 characters")
    private String response;
    
    private String status = "answered";

    // Constructors
    public RespondToQueryRequestDTO() {}

    public RespondToQueryRequestDTO(Long queryId, String response, String status) {
        this.queryId = queryId;
        this.response = response;
        this.status = status;
    }

    // Getters and Setters
    public Long getQueryId() {
        return queryId;
    }

    public void setQueryId(Long queryId) {
        this.queryId = queryId;
    }

    public String getResponse() {
        return response;
    }

    public void setResponse(String response) {
        this.response = response;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }
}
