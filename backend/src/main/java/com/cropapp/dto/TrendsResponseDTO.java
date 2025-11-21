package com.cropapp.dto;

import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class TrendsResponseDTO {
    private Map<String, String> monthlyComparison;
    private List<String> seasonalPatterns;
    private List<String> recommendations;

    // Default constructor
    public TrendsResponseDTO() {}

    // Constructor with all fields
    public TrendsResponseDTO(Map<String, String> monthlyComparison, 
                           List<String> seasonalPatterns, 
                           List<String> recommendations) {
        this.monthlyComparison = monthlyComparison;
        this.seasonalPatterns = seasonalPatterns;
        this.recommendations = recommendations;
    }

    // Static factory method for creating sample trends
    public static TrendsResponseDTO createSampleTrends() {
        Map<String, String> monthlyComparison = new HashMap<>();
        monthlyComparison.put("diseaseDetection", "+15%");
        monthlyComparison.put("healthyPlants", "+8%");
        monthlyComparison.put("treatmentSuccess", "+12%");
        monthlyComparison.put("criticalIssues", "-5%");

        List<String> seasonalPatterns = Arrays.asList(
            "Early Blight peaks in humid conditions",
            "Fungal diseases increase during monsoon",
            "Pest activity highest in summer months",
            "Plant health improves with proper irrigation"
        );

        List<String> recommendations = Arrays.asList(
            "Monitor potato crops more frequently for early blight symptoms",
            "Consider preventive fungicide application in high-risk areas",
            "Implement better drainage systems for monsoon season",
            "Schedule regular irrigation during dry periods"
        );

        return new TrendsResponseDTO(monthlyComparison, seasonalPatterns, recommendations);
    }

    // Getters and Setters
    public Map<String, String> getMonthlyComparison() {
        return monthlyComparison;
    }

    public void setMonthlyComparison(Map<String, String> monthlyComparison) {
        this.monthlyComparison = monthlyComparison;
    }

    public List<String> getSeasonalPatterns() {
        return seasonalPatterns;
    }

    public void setSeasonalPatterns(List<String> seasonalPatterns) {
        this.seasonalPatterns = seasonalPatterns;
    }

    public List<String> getRecommendations() {
        return recommendations;
    }

    public void setRecommendations(List<String> recommendations) {
        this.recommendations = recommendations;
    }
}
