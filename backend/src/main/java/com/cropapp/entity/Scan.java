package com.cropapp.entity;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "scans")
public class Scan {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Column(name = "plant_type", nullable = false)
    private String plantType;

    @Column(name = "disease", nullable = false)
    private String disease;

    @Column(name = "confidence", nullable = false)
    private Double confidence;

    @Column(name = "severity")
    private String severity;

    @Column(name = "status")
    private String status;

    @Column(name = "image_path")
    private String imagePath;

    @Column(name = "recommendations", columnDefinition = "TEXT")
    private String recommendations;

    @Column(name = "symptoms", columnDefinition = "TEXT")
    private String symptoms;

    @Column(name = "expert_notes", columnDefinition = "TEXT")
    private String expertNotes;

    @Column(name = "expert_rating")
    private Integer expertRating;

    @Column(name = "created_at", nullable = false)
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    // Constructors
    public Scan() {
        this.createdAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
    }

    public Scan(User user, String plantType, String disease, Double confidence) {
        this();
        this.user = user;
        this.plantType = plantType;
        this.disease = disease;
        this.confidence = confidence;
    }

    // Getters and Setters
    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public User getUser() {
        return user;
    }

    public void setUser(User user) {
        this.user = user;
    }

    public String getPlantType() {
        return plantType;
    }

    public void setPlantType(String plantType) {
        this.plantType = plantType;
    }

    public String getDisease() {
        return disease;
    }

    public void setDisease(String disease) {
        this.disease = disease;
    }

    public Double getConfidence() {
        return confidence;
    }

    public void setConfidence(Double confidence) {
        this.confidence = confidence;
    }

    public String getSeverity() {
        return severity;
    }

    public void setSeverity(String severity) {
        this.severity = severity;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getImagePath() {
        return imagePath;
    }

    public void setImagePath(String imagePath) {
        this.imagePath = imagePath;
    }

    public String getRecommendations() {
        return recommendations;
    }

    public void setRecommendations(String recommendations) {
        this.recommendations = recommendations;
    }

    public String getSymptoms() {
        return symptoms;
    }

    public void setSymptoms(String symptoms) {
        this.symptoms = symptoms;
    }

    public String getExpertNotes() {
        return expertNotes;
    }

    public void setExpertNotes(String expertNotes) {
        this.expertNotes = expertNotes;
    }

    public Integer getExpertRating() {
        return expertRating;
    }

    public void setExpertRating(Integer expertRating) {
        this.expertRating = expertRating;
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

    @PreUpdate
    public void preUpdate() {
        this.updatedAt = LocalDateTime.now();
    }
}
