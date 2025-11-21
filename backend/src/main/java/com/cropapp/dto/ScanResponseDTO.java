package com.cropapp.dto;

import com.cropapp.entity.Scan;
import java.time.format.DateTimeFormatter;
import java.util.Arrays;
import java.util.List;

public class ScanResponseDTO {
    private String id;
    private String plantType;
    private String disease;
    private Double confidence;
    private String date;
    private String time;
    private String severity;
    private String status;
    private String imageUrl;
    private List<String> recommendations;
    private List<String> symptoms;
    private String expertNotes;
    private Integer expertRating;

    // Default constructor
    public ScanResponseDTO() {}

    // Constructor from Scan entity
    public ScanResponseDTO(Scan scan) {
        this.id = scan.getId().toString();
        this.plantType = scan.getPlantType();
        this.disease = scan.getDisease();
        this.confidence = scan.getConfidence();
        this.date = scan.getCreatedAt().toLocalDate().toString();
        this.time = scan.getCreatedAt().toLocalTime().format(DateTimeFormatter.ofPattern("HH:mm"));
        this.severity = scan.getSeverity() != null ? scan.getSeverity() : "Unknown";
        this.status = scan.getStatus() != null ? scan.getStatus() : "Analyzed";
        this.imageUrl = scan.getImagePath();
        
        // Parse recommendations and symptoms from pipe-separated strings
        if (scan.getRecommendations() != null && !scan.getRecommendations().isEmpty()) {
            this.recommendations = Arrays.asList(scan.getRecommendations().split("\\|"));
        }
        
        if (scan.getSymptoms() != null && !scan.getSymptoms().isEmpty()) {
            this.symptoms = Arrays.asList(scan.getSymptoms().split("\\|"));
        }
        this.expertNotes = scan.getExpertNotes();
        this.expertRating = scan.getExpertRating();
    }

    // Getters and Setters
    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
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

    public String getDate() {
        return date;
    }

    public void setDate(String date) {
        this.date = date;
    }

    public String getTime() {
        return time;
    }

    public void setTime(String time) {
        this.time = time;
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

    public String getImageUrl() {
        return imageUrl;
    }

    public void setImageUrl(String imageUrl) {
        this.imageUrl = imageUrl;
    }

    public List<String> getRecommendations() {
        return recommendations;
    }

    public void setRecommendations(List<String> recommendations) {
        this.recommendations = recommendations;
    }

    public List<String> getSymptoms() {
        return symptoms;
    }

    public void setSymptoms(List<String> symptoms) {
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
}
