package com.cropapp.dto;

import java.util.Map;
import java.util.HashMap;

public class AnalyticsResponseDTO {
    private Integer totalScans;
    private Integer diseasesDetected;
    private Integer healthyPlants;
    private Integer criticalIssues;
    private Integer treatmentSuccess;
    private String mostCommonDisease;
    private String riskLevel;
    private Double accuracyRate;
    private Map<String, Integer> diseaseDistribution;

    // Default constructor
    public AnalyticsResponseDTO() {}

    // Constructor with all fields
    public AnalyticsResponseDTO(Integer totalScans, Integer diseasesDetected, Integer healthyPlants,
                              Integer criticalIssues, Integer treatmentSuccess, String mostCommonDisease,
                              String riskLevel, Double accuracyRate) {
        this.totalScans = totalScans;
        this.diseasesDetected = diseasesDetected;
        this.healthyPlants = healthyPlants;
        this.criticalIssues = criticalIssues;
        this.treatmentSuccess = treatmentSuccess;
        this.mostCommonDisease = mostCommonDisease;
        this.riskLevel = riskLevel;
        this.accuracyRate = accuracyRate;
        this.diseaseDistribution = new HashMap<>();
    }

    // Static factory method for creating sample analytics
    public static AnalyticsResponseDTO createSampleAnalytics() {
        return new AnalyticsResponseDTO(
            70,          // totalScans
            36,          // diseasesDetected
            34,          // healthyPlants
            8,           // criticalIssues
            85,          // treatmentSuccess
            "Early Blight", // mostCommonDisease
            "Medium",    // riskLevel
            0.92         // accuracyRate
        );
    }

    // Getters and Setters
    public Integer getTotalScans() {
        return totalScans;
    }

    public void setTotalScans(Integer totalScans) {
        this.totalScans = totalScans;
    }

    public Integer getDiseasesDetected() {
        return diseasesDetected;
    }

    public void setDiseasesDetected(Integer diseasesDetected) {
        this.diseasesDetected = diseasesDetected;
    }

    public Integer getHealthyPlants() {
        return healthyPlants;
    }

    public void setHealthyPlants(Integer healthyPlants) {
        this.healthyPlants = healthyPlants;
    }

    public Integer getCriticalIssues() {
        return criticalIssues;
    }

    public void setCriticalIssues(Integer criticalIssues) {
        this.criticalIssues = criticalIssues;
    }

    public Integer getTreatmentSuccess() {
        return treatmentSuccess;
    }

    public void setTreatmentSuccess(Integer treatmentSuccess) {
        this.treatmentSuccess = treatmentSuccess;
    }

    public String getMostCommonDisease() {
        return mostCommonDisease;
    }

    public void setMostCommonDisease(String mostCommonDisease) {
        this.mostCommonDisease = mostCommonDisease;
    }

    public String getRiskLevel() {
        return riskLevel;
    }

    public void setRiskLevel(String riskLevel) {
        this.riskLevel = riskLevel;
    }

    public Double getAccuracyRate() {
        return accuracyRate;
    }

    public void setAccuracyRate(Double accuracyRate) {
        this.accuracyRate = accuracyRate;
    }

    public Map<String, Integer> getDiseaseDistribution() {
        return diseaseDistribution;
    }

    public void setDiseaseDistribution(Map<String, Integer> diseaseDistribution) {
        this.diseaseDistribution = diseaseDistribution;
    }
}
