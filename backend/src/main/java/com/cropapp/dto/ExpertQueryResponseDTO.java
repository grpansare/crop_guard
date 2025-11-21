package com.cropapp.dto;

import com.cropapp.entity.ExpertQuery;
import java.time.LocalDateTime;

public class ExpertQueryResponseDTO {
    private Long id;
    private String title;
    private String description;
    private String cropType;
    private String category;
    private String urgency;
    private String status;
    private Boolean hasImage;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private LocalDateTime responseDate;
    private String response;
    private String farmerName;
    private String expertName;
    private String imagePath;
    private String imageUrl;
    private Boolean hasResponded;
    private Integer responseCount;


    // Constructors
    public ExpertQueryResponseDTO() {}

    public ExpertQueryResponseDTO(ExpertQuery query) {
        this.id = query.getId();
        this.title = query.getTitle();
        this.description = query.getDescription();
        this.cropType = query.getCropType();
        this.category = query.getCategory();
        this.urgency = query.getUrgency();
        this.status = query.getStatus();
        this.hasImage = query.getHasImage();
        this.createdAt = query.getCreatedAt();
        this.updatedAt = query.getUpdatedAt();
        this.responseDate = query.getResponseDate();
        this.response = query.getResponse();
        this.imagePath = query.getImagePath();
        
        if (query.getFarmer() != null) {
            this.farmerName = query.getFarmer().getFullName();
        }
        
        if (query.getExpert() != null) {
            this.expertName = query.getExpert().getFullName();
        }
    }

    // Getters and Setters
    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getCropType() {
        return cropType;
    }

    public void setCropType(String cropType) {
        this.cropType = cropType;
    }

    public String getCategory() {
        return category;
    }

    public void setCategory(String category) {
        this.category = category;
    }

    public String getUrgency() {
        return urgency;
    }

    public void setUrgency(String urgency) {
        this.urgency = urgency;
    }


    public String getImagePath() {
        return imagePath;
    }

    public void setImagePath(String imagePath) {
        this.imagePath = imagePath;
    }

    public String getImageUrl() {
        return imageUrl;
    }

    public void setImageUrl(String imageUrl) {
        this.imageUrl = imageUrl;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Boolean getHasImage() {
        return hasImage;
    }

    public void setHasImage(Boolean hasImage) {
        this.hasImage = hasImage;
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

    public LocalDateTime getResponseDate() {
        return responseDate;
    }

    public void setResponseDate(LocalDateTime responseDate) {
        this.responseDate = responseDate;
    }

    public String getResponse() {
        return response;
    }

    public void setResponse(String response) {
        this.response = response;
    }

    public String getFarmerName() {
        return farmerName;
    }

    public void setFarmerName(String farmerName) {
        this.farmerName = farmerName;
    }

    public String getExpertName() {
        return expertName;
    }

    public void setExpertName(String expertName) {
        this.expertName = expertName;
    }

    public Boolean getHasResponded() {
        return hasResponded;
    }

    public void setHasResponded(Boolean hasResponded) {
        this.hasResponded = hasResponded;
    }

    public Integer getResponseCount() {
        return responseCount;
    }

    public void setResponseCount(Integer responseCount) {
        this.responseCount = responseCount;
    }
}
