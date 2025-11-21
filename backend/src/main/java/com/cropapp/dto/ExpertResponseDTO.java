package com.cropapp.dto;

import com.cropapp.entity.ExpertResponse;
import java.time.LocalDateTime;

public class ExpertResponseDTO {
    private Long id;
    private Long queryId;
    private Long expertId;
    private String expertName;
    private String response;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private boolean isVerified;
    
    // Constructors
    public ExpertResponseDTO() {}
    
    public ExpertResponseDTO(ExpertResponse expertResponse) {
        this.id = expertResponse.getId();
        this.queryId = expertResponse.getQuery().getId();
        this.expertId = expertResponse.getExpert().getId();
        this.expertName = expertResponse.getExpert().getFullName();
        this.response = expertResponse.getResponse();
        this.createdAt = expertResponse.getCreatedAt();
        this.updatedAt = expertResponse.getUpdatedAt();
        this.isVerified = expertResponse.getExpert().isVerified();
    }
    
    // Getters and Setters
    public Long getId() {
        return id;
    }
    
    public void setId(Long id) {
        this.id = id;
    }
    
    public Long getQueryId() {
        return queryId;
    }
    
    public void setQueryId(Long queryId) {
        this.queryId = queryId;
    }
    
    public Long getExpertId() {
        return expertId;
    }
    
    public void setExpertId(Long expertId) {
        this.expertId = expertId;
    }
    
    public String getExpertName() {
        return expertName;
    }
    
    public void setExpertName(String expertName) {
        this.expertName = expertName;
    }
    
    public String getResponse() {
        return response;
    }
    
    public void setResponse(String response) {
        this.response = response;
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
    
    public boolean isVerified() {
        return isVerified;
    }
    
    public void setVerified(boolean verified) {
        isVerified = verified;
    }
}
