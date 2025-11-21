package com.cropapp.entity;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "reports")
public class Report {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Column(name = "title", nullable = false)
    private String title;

    @Column(name = "type", nullable = false)
    private String type; // "Weekly Report", "Monthly Report", "Crop Report", etc.

    @Column(name = "status", nullable = false)
    private String status; // "Generated", "Completed", "In Progress"

    @Column(name = "summary", columnDefinition = "TEXT")
    private String summary;

    @Column(name = "disease_count")
    private Integer diseaseCount;

    @Column(name = "healthy_count")
    private Integer healthyCount;

    @Column(name = "critical_issues")
    private Integer criticalIssues;

    @Column(name = "recommendations_count")
    private Integer recommendationsCount;

    @Column(name = "report_data", columnDefinition = "TEXT")
    private String reportData; // JSON data for detailed report content

    @Column(name = "file_path")
    private String filePath; // Path to generated PDF/Excel file

    @Column(name = "generated_at", nullable = false)
    private LocalDateTime generatedAt;

    @Column(name = "period_start")
    private LocalDateTime periodStart; // Start date for report period

    @Column(name = "period_end")
    private LocalDateTime periodEnd; // End date for report period

    @Column(name = "created_at", nullable = false)
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    // Constructors
    public Report() {
        this.createdAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
        this.generatedAt = LocalDateTime.now();
    }

    public Report(User user, String title, String type, String status) {
        this();
        this.user = user;
        this.title = title;
        this.type = type;
        this.status = status;
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

    public Integer getRecommendationsCount() {
        return recommendationsCount;
    }

    public void setRecommendationsCount(Integer recommendationsCount) {
        this.recommendationsCount = recommendationsCount;
    }

    public String getReportData() {
        return reportData;
    }

    public void setReportData(String reportData) {
        this.reportData = reportData;
    }

    public String getFilePath() {
        return filePath;
    }

    public void setFilePath(String filePath) {
        this.filePath = filePath;
    }

    public LocalDateTime getGeneratedAt() {
        return generatedAt;
    }

    public void setGeneratedAt(LocalDateTime generatedAt) {
        this.generatedAt = generatedAt;
    }

    public LocalDateTime getPeriodStart() {
        return periodStart;
    }

    public void setPeriodStart(LocalDateTime periodStart) {
        this.periodStart = periodStart;
    }

    public LocalDateTime getPeriodEnd() {
        return periodEnd;
    }

    public void setPeriodEnd(LocalDateTime periodEnd) {
        this.periodEnd = periodEnd;
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
