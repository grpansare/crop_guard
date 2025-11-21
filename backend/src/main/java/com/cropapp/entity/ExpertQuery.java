package com.cropapp.entity;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "expert_queries")
public class ExpertQuery {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String title;

    @Column(columnDefinition = "TEXT")
    private String description;

    @Column(name = "crop_type")
    private String cropType;

    @Column(nullable = false)
    private String category;

    @Column(nullable = false)
    private String urgency;
    @Column(name = "image_path")
private String imagePath;

    @Column(nullable = false)
    private String status = "pending";

    @Column(name = "has_image")
    private Boolean hasImage = false;

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    @Column(name = "response_date")
    private LocalDateTime responseDate;

    @Column(columnDefinition = "TEXT")
    private String response;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "farmer_id", nullable = false)
    private User farmer;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "expert_id")
    private User expert;

    // Constructors
    public ExpertQuery() {}

    public ExpertQuery(String title, String description, String cropType, String category, 
                      String urgency, User farmer) {
        this.title = title;
        this.description = description;
        this.cropType = cropType;
        this.category = category;
        this.urgency = urgency;
        this.farmer = farmer;
        this.createdAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
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

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
        this.updatedAt = LocalDateTime.now();
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

    public String getImagePath() {
    return imagePath;
}

public void setImagePath(String imagePath) {
    this.imagePath = imagePath;
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
        this.responseDate = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
    }

    public User getFarmer() {
        return farmer;
    }

    public void setFarmer(User farmer) {
        this.farmer = farmer;
    }

    public User getExpert() {
        return expert;
    }

    public void setExpert(User expert) {
        this.expert = expert;
    }

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
    }

    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }
}
