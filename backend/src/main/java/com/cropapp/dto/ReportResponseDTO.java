package com.cropapp.dto;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

public class ReportResponseDTO {
    private String id;
    private String title;
    private String type;
    private String date;
    private String status;
    private String summary;
    private Integer diseaseCount;
    private Integer healthyCount;
    private Integer criticalIssues;
    private Integer recommendations;
    private String createdBy;
    private String downloadUrl;

    // Default constructor
    public ReportResponseDTO() {}

    // Constructor with all fields
    public ReportResponseDTO(String id, String title, String type, String date, String status, 
                           String summary, Integer diseaseCount, Integer healthyCount, 
                           Integer criticalIssues, Integer recommendations) {
        this.id = id;
        this.title = title;
        this.type = type;
        this.date = date;
        this.status = status;
        this.summary = summary;
        this.diseaseCount = diseaseCount;
        this.healthyCount = healthyCount;
        this.criticalIssues = criticalIssues;
        this.recommendations = recommendations;
    }

    // Static factory method for creating sample reports
    public static ReportResponseDTO createSampleReport(String id, String title, String type, 
                                                     String status, String summary, 
                                                     Integer diseaseCount, Integer healthyCount, 
                                                     Integer criticalIssues, Integer recommendations) {
        ReportResponseDTO report = new ReportResponseDTO();
        report.setId(id);
        report.setTitle(title);
        report.setType(type);
        report.setDate(LocalDateTime.now().minusDays(Long.parseLong(id)).toLocalDate().toString());
        report.setStatus(status);
        report.setSummary(summary);
        report.setDiseaseCount(diseaseCount);
        report.setHealthyCount(healthyCount);
        report.setCriticalIssues(criticalIssues);
        report.setRecommendations(recommendations);
        return report;
    }

    // Getters and Setters
    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public String getDate() {
        return date;
    }

    public void setDate(String date) {
        this.date = date;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getSummary() {
        return summary;
    }

    public void setSummary(String summary) {
        this.summary = summary;
    }

    public Integer getDiseaseCount() {
        return diseaseCount;
    }

    public void setDiseaseCount(Integer diseaseCount) {
        this.diseaseCount = diseaseCount;
    }

    public Integer getHealthyCount() {
        return healthyCount;
    }

    public void setHealthyCount(Integer healthyCount) {
        this.healthyCount = healthyCount;
    }

    public Integer getCriticalIssues() {
        return criticalIssues;
    }

    public void setCriticalIssues(Integer criticalIssues) {
        this.criticalIssues = criticalIssues;
    }

    public Integer getRecommendations() {
        return recommendations;
    }

    public void setRecommendations(Integer recommendations) {
        this.recommendations = recommendations;
    }

    public String getCreatedBy() {
        return createdBy;
    }

    public void setCreatedBy(String createdBy) {
        this.createdBy = createdBy;
    }

    public String getDownloadUrl() {
        return downloadUrl;
    }

    public void setDownloadUrl(String downloadUrl) {
        this.downloadUrl = downloadUrl;
    }
}
