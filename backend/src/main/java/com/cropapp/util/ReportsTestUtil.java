package com.cropapp.util;

import com.cropapp.dto.AnalyticsResponseDTO;
import com.cropapp.dto.ReportResponseDTO;
import com.cropapp.dto.ReportsListResponseDTO;
import com.cropapp.dto.TrendsResponseDTO;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.stereotype.Component;

import java.util.Arrays;
import java.util.List;

@Component
public class ReportsTestUtil {
    
    private final ObjectMapper objectMapper = new ObjectMapper();
    
    /**
     * Test method to verify the reports list response structure matches frontend expectations
     */
    public void testReportsListResponseStructure() {
        System.out.println("=== Testing Reports List Response Structure ===");
        
        // Create sample report data
        List<ReportResponseDTO> sampleReports = createSampleReports();
        
        // Create response DTO
        ReportsListResponseDTO response = new ReportsListResponseDTO(sampleReports);
        
        try {
            // Convert to JSON to verify structure
            String jsonResponse = objectMapper.writeValueAsString(response);
            System.out.println("Generated JSON Response:");
            System.out.println(jsonResponse);
            
            // Verify required fields are present
            boolean hasReports = jsonResponse.contains("\"reports\":");
            boolean hasTotalElements = jsonResponse.contains("\"totalElements\":");
            boolean hasTotalPages = jsonResponse.contains("\"totalPages\":");
            boolean hasCurrentPage = jsonResponse.contains("\"currentPage\":");
            
            System.out.println("\n=== Validation Results ===");
            System.out.println("Has 'reports' field: " + hasReports);
            System.out.println("Has 'totalElements' field: " + hasTotalElements);
            System.out.println("Has 'totalPages' field: " + hasTotalPages);
            System.out.println("Has 'currentPage' field: " + hasCurrentPage);
            
            boolean allFieldsPresent = hasReports && hasTotalElements && hasTotalPages && hasCurrentPage;
            System.out.println("All required fields present: " + allFieldsPresent);
            
            if (allFieldsPresent) {
                System.out.println("✅ SUCCESS: Reports response structure matches frontend expectations!");
            } else {
                System.out.println("❌ FAILURE: Reports response structure does not match frontend expectations!");
            }
            
        } catch (Exception e) {
            System.out.println("❌ ERROR: Failed to serialize response: " + e.getMessage());
        }
    }
    
    /**
     * Test method to verify analytics response structure
     */
    public void testAnalyticsResponseStructure() {
        System.out.println("\n=== Testing Analytics Response Structure ===");
        
        AnalyticsResponseDTO analytics = AnalyticsResponseDTO.createSampleAnalytics();
        
        try {
            String jsonResponse = objectMapper.writeValueAsString(analytics);
            System.out.println("Generated Analytics JSON:");
            System.out.println(jsonResponse);
            
            // Verify required fields
            boolean hasTotalScans = jsonResponse.contains("\"totalScans\":");
            boolean hasDiseasesDetected = jsonResponse.contains("\"diseasesDetected\":");
            boolean hasHealthyPlants = jsonResponse.contains("\"healthyPlants\":");
            boolean hasCriticalIssues = jsonResponse.contains("\"criticalIssues\":");
            boolean hasTreatmentSuccess = jsonResponse.contains("\"treatmentSuccess\":");
            boolean hasMostCommonDisease = jsonResponse.contains("\"mostCommonDisease\":");
            boolean hasRiskLevel = jsonResponse.contains("\"riskLevel\":");
            
            System.out.println("\n=== Analytics Validation Results ===");
            System.out.println("Has 'totalScans' field: " + hasTotalScans);
            System.out.println("Has 'diseasesDetected' field: " + hasDiseasesDetected);
            System.out.println("Has 'healthyPlants' field: " + hasHealthyPlants);
            System.out.println("Has 'criticalIssues' field: " + hasCriticalIssues);
            System.out.println("Has 'treatmentSuccess' field: " + hasTreatmentSuccess);
            System.out.println("Has 'mostCommonDisease' field: " + hasMostCommonDisease);
            System.out.println("Has 'riskLevel' field: " + hasRiskLevel);
            
            boolean allFieldsPresent = hasTotalScans && hasDiseasesDetected && hasHealthyPlants && 
                                     hasCriticalIssues && hasTreatmentSuccess && hasMostCommonDisease && hasRiskLevel;
            
            if (allFieldsPresent) {
                System.out.println("✅ SUCCESS: Analytics response structure is correct!");
            } else {
                System.out.println("❌ FAILURE: Analytics response structure is missing required fields!");
            }
            
        } catch (Exception e) {
            System.out.println("❌ ERROR: Failed to serialize analytics: " + e.getMessage());
        }
    }
    
    /**
     * Test method to verify trends response structure
     */
    public void testTrendsResponseStructure() {
        System.out.println("\n=== Testing Trends Response Structure ===");
        
        TrendsResponseDTO trends = TrendsResponseDTO.createSampleTrends();
        
        try {
            String jsonResponse = objectMapper.writeValueAsString(trends);
            System.out.println("Generated Trends JSON:");
            System.out.println(jsonResponse);
            
            // Verify required fields
            boolean hasMonthlyComparison = jsonResponse.contains("\"monthlyComparison\":");
            boolean hasSeasonalPatterns = jsonResponse.contains("\"seasonalPatterns\":");
            boolean hasRecommendations = jsonResponse.contains("\"recommendations\":");
            
            System.out.println("\n=== Trends Validation Results ===");
            System.out.println("Has 'monthlyComparison' field: " + hasMonthlyComparison);
            System.out.println("Has 'seasonalPatterns' field: " + hasSeasonalPatterns);
            System.out.println("Has 'recommendations' field: " + hasRecommendations);
            
            boolean allFieldsPresent = hasMonthlyComparison && hasSeasonalPatterns && hasRecommendations;
            
            if (allFieldsPresent) {
                System.out.println("✅ SUCCESS: Trends response structure is correct!");
            } else {
                System.out.println("❌ FAILURE: Trends response structure is missing required fields!");
            }
            
        } catch (Exception e) {
            System.out.println("❌ ERROR: Failed to serialize trends: " + e.getMessage());
        }
    }
    
    /**
     * Run all tests
     */
    public void runAllTests() {
        System.out.println("🧪 Starting Reports API Integration Tests...\n");
        testReportsListResponseStructure();
        testAnalyticsResponseStructure();
        testTrendsResponseStructure();
        System.out.println("\n🏁 Tests completed!");
    }
    
    private List<ReportResponseDTO> createSampleReports() {
        return Arrays.asList(
            ReportResponseDTO.createSampleReport("1", "Weekly Disease Analysis", "Weekly Report", 
                "Completed", "Analysis of 15 plant scans this week", 8, 7, 2, 5),
            ReportResponseDTO.createSampleReport("2", "Tomato Crop Assessment", "Crop Report", 
                "Completed", "Comprehensive analysis of tomato plants", 3, 12, 1, 3)
        );
    }
}
