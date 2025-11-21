package com.cropapp.util;

import com.cropapp.dto.ScanHistoryResponseDTO;
import com.cropapp.dto.ScanResponseDTO;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.stereotype.Component;

import java.util.Arrays;
import java.util.List;

@Component
public class ScanHistoryTestUtil {
    
    private final ObjectMapper objectMapper = new ObjectMapper();
    
    /**
     * Test method to verify the scan history response structure matches frontend expectations
     */
    public void testScanHistoryResponseStructure() {
        System.out.println("=== Testing Scan History Response Structure ===");
        
        // Create sample scan data
        List<ScanResponseDTO> sampleScans = createSampleScanDTOs();
        
        // Create response DTO
        ScanHistoryResponseDTO response = new ScanHistoryResponseDTO(sampleScans);
        
        try {
            // Convert to JSON to verify structure
            String jsonResponse = objectMapper.writeValueAsString(response);
            System.out.println("Generated JSON Response:");
            System.out.println(jsonResponse);
            
            // Verify required fields are present
            boolean hasScans = jsonResponse.contains("\"scans\":");
            boolean hasTotalElements = jsonResponse.contains("\"totalElements\":");
            boolean hasTotalPages = jsonResponse.contains("\"totalPages\":");
            boolean hasCurrentPage = jsonResponse.contains("\"currentPage\":");
            
            System.out.println("\n=== Validation Results ===");
            System.out.println("Has 'scans' field: " + hasScans);
            System.out.println("Has 'totalElements' field: " + hasTotalElements);
            System.out.println("Has 'totalPages' field: " + hasTotalPages);
            System.out.println("Has 'currentPage' field: " + hasCurrentPage);
            
            boolean allFieldsPresent = hasScans && hasTotalElements && hasTotalPages && hasCurrentPage;
            System.out.println("All required fields present: " + allFieldsPresent);
            
            if (allFieldsPresent) {
                System.out.println("✅ SUCCESS: Response structure matches frontend expectations!");
            } else {
                System.out.println("❌ FAILURE: Response structure does not match frontend expectations!");
            }
            
        } catch (Exception e) {
            System.out.println("❌ ERROR: Failed to serialize response: " + e.getMessage());
        }
    }
    
    /**
     * Test method to verify individual scan DTO structure
     */
    public void testScanResponseDTOStructure() {
        System.out.println("\n=== Testing Scan Response DTO Structure ===");
        
        ScanResponseDTO scanDTO = createSampleScanDTO();
        
        try {
            String jsonResponse = objectMapper.writeValueAsString(scanDTO);
            System.out.println("Generated Scan DTO JSON:");
            System.out.println(jsonResponse);
            
            // Verify required fields
            boolean hasId = jsonResponse.contains("\"id\":");
            boolean hasPlantType = jsonResponse.contains("\"plantType\":");
            boolean hasDisease = jsonResponse.contains("\"disease\":");
            boolean hasConfidence = jsonResponse.contains("\"confidence\":");
            boolean hasDate = jsonResponse.contains("\"date\":");
            boolean hasTime = jsonResponse.contains("\"time\":");
            boolean hasSeverity = jsonResponse.contains("\"severity\":");
            boolean hasStatus = jsonResponse.contains("\"status\":");
            
            System.out.println("\n=== Scan DTO Validation Results ===");
            System.out.println("Has 'id' field: " + hasId);
            System.out.println("Has 'plantType' field: " + hasPlantType);
            System.out.println("Has 'disease' field: " + hasDisease);
            System.out.println("Has 'confidence' field: " + hasConfidence);
            System.out.println("Has 'date' field: " + hasDate);
            System.out.println("Has 'time' field: " + hasTime);
            System.out.println("Has 'severity' field: " + hasSeverity);
            System.out.println("Has 'status' field: " + hasStatus);
            
            boolean allFieldsPresent = hasId && hasPlantType && hasDisease && hasConfidence && 
                                     hasDate && hasTime && hasSeverity && hasStatus;
            
            if (allFieldsPresent) {
                System.out.println("✅ SUCCESS: Scan DTO structure is correct!");
            } else {
                System.out.println("❌ FAILURE: Scan DTO structure is missing required fields!");
            }
            
        } catch (Exception e) {
            System.out.println("❌ ERROR: Failed to serialize scan DTO: " + e.getMessage());
        }
    }
    
    /**
     * Run all tests
     */
    public void runAllTests() {
        System.out.println("🧪 Starting Scan History API Integration Tests...\n");
        testScanHistoryResponseStructure();
        testScanResponseDTOStructure();
        System.out.println("\n🏁 Tests completed!");
    }
    
    private List<ScanResponseDTO> createSampleScanDTOs() {
        return Arrays.asList(
            createSampleScanDTO(),
            createSampleScanDTO2()
        );
    }
    
    private ScanResponseDTO createSampleScanDTO() {
        ScanResponseDTO dto = new ScanResponseDTO();
        dto.setId("1");
        dto.setPlantType("Tomato");
        dto.setDisease("Early Blight");
        dto.setConfidence(0.92);
        dto.setDate("2025-09-26");
        dto.setTime("11:30");
        dto.setSeverity("Medium");
        dto.setStatus("Treated");
        dto.setRecommendations(Arrays.asList("Apply fungicide", "Remove affected leaves"));
        dto.setSymptoms(Arrays.asList("Dark spots on leaves", "Yellowing"));
        return dto;
    }
    
    private ScanResponseDTO createSampleScanDTO2() {
        ScanResponseDTO dto = new ScanResponseDTO();
        dto.setId("2");
        dto.setPlantType("Potato");
        dto.setDisease("Healthy");
        dto.setConfidence(0.95);
        dto.setDate("2025-09-25");
        dto.setTime("14:15");
        dto.setSeverity("None");
        dto.setStatus("Healthy");
        dto.setRecommendations(Arrays.asList("Continue monitoring"));
        dto.setSymptoms(Arrays.asList("No symptoms detected"));
        return dto;
    }
}
