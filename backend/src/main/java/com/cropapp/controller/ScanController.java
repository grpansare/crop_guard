package com.cropapp.controller;

import com.cropapp.dto.MessageResponse;
import com.cropapp.dto.ScanHistoryResponseDTO;
import com.cropapp.dto.ScanResponseDTO;
import com.cropapp.entity.Scan;
import com.cropapp.entity.User;
import com.cropapp.repository.ScanRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.*;
import java.util.stream.Collectors;

@CrossOrigin(origins = "*", maxAge = 3600)
@RestController
@RequestMapping("/api/scans")
public class ScanController {

    @Autowired
    private ScanRepository scanRepository;

    @GetMapping("/history")
    public ResponseEntity<?> getScanHistory(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            Authentication authentication) {
        
        if (authentication == null) {
            return ResponseEntity.badRequest().body(new MessageResponse("User not authenticated"));
        }

        User user = (User) authentication.getPrincipal();
        
        try {
            // Create pageable object
            Pageable pageable = PageRequest.of(page, size);
            
            // Get paginated scans from database
            Page<Scan> scanPage = scanRepository.findByUserOrderByCreatedAtDesc(user, pageable);
            
            // Convert to DTOs
            List<ScanResponseDTO> scanDTOs = scanPage.getContent().stream()
                .map(ScanResponseDTO::new)
                .collect(Collectors.toList());

          

            // Create paginated response
            ScanHistoryResponseDTO response = new ScanHistoryResponseDTO(scanDTOs, scanPage);
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            return ResponseEntity.internalServerError()
                .body(new MessageResponse("Failed to fetch scan history: " + e.getMessage()));
        }
    }
    
    // Expert endpoint to get all scans from all users
    @GetMapping("/all")
    public ResponseEntity<?> getAllScans(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "100") int size,
            Authentication authentication) {
        
        if (authentication == null) {
            return ResponseEntity.badRequest().body(new MessageResponse("User not authenticated"));
        }

        User user = (User) authentication.getPrincipal();
        
        // Check if user is an expert
        if (!user.getRole().equals(User.Role.EXPERT)) {
            return ResponseEntity.badRequest().body(new MessageResponse("Access denied - Expert role required"));
        }
        
        try {
            // Create pageable object
            Pageable pageable = PageRequest.of(page, size);
            
            // Get all scans from database (system-wide for experts)
            Page<Scan> scanPage = scanRepository.findAll(pageable);
            
            System.out.println("DEBUG: Expert requesting all scans - Found " + scanPage.getTotalElements() + " total scans");
            
            // Convert to DTOs
            List<ScanResponseDTO> scanDTOs = scanPage.getContent().stream()
                .map(ScanResponseDTO::new)
                .collect(Collectors.toList());

            // Create paginated response
            ScanHistoryResponseDTO response = new ScanHistoryResponseDTO(scanDTOs, scanPage);
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            System.err.println("ERROR: Failed to fetch all scans: " + e.getMessage());
            e.printStackTrace();
            return ResponseEntity.internalServerError()
                .body(new MessageResponse("Failed to fetch all scans: " + e.getMessage()));
        }
    }

    @GetMapping("/{scanId}")
    public ResponseEntity<?> getScanDetails(@PathVariable String scanId, Authentication authentication) {
        if (authentication == null) {
            return ResponseEntity.badRequest().body(new MessageResponse("User not authenticated"));
        }

        try {
            Long id = Long.parseLong(scanId);
            Optional<Scan> scanOptional = scanRepository.findById(id);
            
            if (scanOptional.isPresent()) {
                Scan scan = scanOptional.get();
                ScanResponseDTO scanDetails = new ScanResponseDTO(scan);
                return ResponseEntity.ok(scanDetails);
            } else {
                // Return sample data if scan not found
                ScanResponseDTO sampleScan = createSampleScanDetails(scanId);
                return ResponseEntity.ok(sampleScan);
            }
        } catch (NumberFormatException e) {
            return ResponseEntity.badRequest().body(new MessageResponse("Invalid scan ID format"));
        } catch (Exception e) {
            return ResponseEntity.internalServerError()
                .body(new MessageResponse("Failed to fetch scan details: " + e.getMessage()));
        }
    }

    @PostMapping("")
    public ResponseEntity<?> createScan(@RequestBody Map<String, Object> scanData, Authentication authentication) {
        if (authentication == null) {
            return ResponseEntity.badRequest().body(new MessageResponse("User not authenticated"));
        }

        try {
            User user = (User) authentication.getPrincipal();
            
            // Create new scan entity
            Scan scan = new Scan();
            scan.setUser(user);
            scan.setPlantType((String) scanData.get("plantType"));
            scan.setDisease((String) scanData.get("disease"));
            scan.setConfidence(((Number) scanData.get("confidence")).doubleValue());
            scan.setSeverity((String) scanData.getOrDefault("severity", "Unknown"));
            scan.setStatus((String) scanData.getOrDefault("status", "Analyzed"));
            scan.setImagePath((String) scanData.get("imagePath"));
            scan.setRecommendations((String) scanData.get("recommendations"));
            scan.setSymptoms((String) scanData.get("symptoms"));
            
            // Save to database
            Scan savedScan = scanRepository.save(scan);
            
            // Return DTO response
            ScanResponseDTO response = new ScanResponseDTO(savedScan);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            return ResponseEntity.internalServerError()
                .body(new MessageResponse("Failed to create scan: " + e.getMessage()));
        }
    }

    @PutMapping("/{id}/review")
    public ResponseEntity<?> reviewScan(@PathVariable Long id, @RequestBody Map<String, Object> reviewData, Authentication authentication) {
        if (authentication == null) {
            return ResponseEntity.badRequest().body(new MessageResponse("User not authenticated"));
        }

        User user = (User) authentication.getPrincipal();
        if (!user.getRole().equals(User.Role.EXPERT)) {
            return ResponseEntity.badRequest().body(new MessageResponse("Access denied - Expert role required"));
        }

        try {
            Optional<Scan> scanOptional = scanRepository.findById(id);
            if (scanOptional.isEmpty()) {
                return ResponseEntity.notFound().build();
            }

            Scan scan = scanOptional.get();
            
            if (reviewData.containsKey("expertNotes")) {
                scan.setExpertNotes((String) reviewData.get("expertNotes"));
            }
            if (reviewData.containsKey("expertRating")) {
                scan.setExpertRating((Integer) reviewData.get("expertRating"));
            }
            if (reviewData.containsKey("status")) {
                scan.setStatus((String) reviewData.get("status"));
            }

            scanRepository.save(scan);
            
            return ResponseEntity.ok(new MessageResponse("Review submitted successfully"));
        } catch (Exception e) {
            return ResponseEntity.internalServerError()
                .body(new MessageResponse("Failed to submit review: " + e.getMessage()));
        }
    }

  

    private Scan createSampleScan(User user, String plantType, String disease, double confidence, String severity, String status) {
        Scan scan = new Scan(user, plantType, disease, confidence);
        scan.setSeverity(severity);
        scan.setStatus(status);
        scan.setRecommendations(String.join("|", getDefaultRecommendations(disease)));
        scan.setSymptoms(String.join("|", getDefaultSymptoms(disease)));
        return scan;
    }

    private ScanResponseDTO createSampleScanDetails(String scanId) {
        ScanResponseDTO sampleScan = new ScanResponseDTO();
        sampleScan.setId(scanId);
        sampleScan.setPlantType("Tomato");
        sampleScan.setDisease("Early Blight");
        sampleScan.setConfidence(0.92);
        sampleScan.setDate(LocalDateTime.now().toLocalDate().toString());
        sampleScan.setTime(LocalDateTime.now().toLocalTime().format(DateTimeFormatter.ofPattern("HH:mm")));
        sampleScan.setSeverity("Medium");
        sampleScan.setStatus("Treated");
        sampleScan.setRecommendations(getDefaultRecommendations("Early Blight"));
        sampleScan.setSymptoms(getDefaultSymptoms("Early Blight"));
        return sampleScan;
    }

    private List<String> getDefaultRecommendations(String disease) {
        switch (disease.toLowerCase()) {
            case "early blight":
                return Arrays.asList(
                    "Apply copper-based fungicide",
                    "Improve air circulation around plants",
                    "Remove affected leaves",
                    "Monitor for spread to other plants"
                );
            case "late blight":
                return Arrays.asList(
                    "Apply preventive fungicide immediately",
                    "Remove and destroy  plants",
                    "Avoid overhead watering",
                    "Ensure good drainage"
                );
            case "apple scab":
                return Arrays.asList(
                    "Apply fungicide during wet periods",
                    "Rake and dispose of fallen leaves",
                    "Prune for better air circulation",
                    "Choose resistant varieties for future planting"
                );
            default:
                return Arrays.asList(
                    "Monitor plant health regularly",
                    "Maintain proper watering schedule",
                    "Ensure adequate nutrition",
                    "Consult agricultural expert if needed"
                );
        }
    }

    private List<String> getDefaultSymptoms(String disease) {
        switch (disease.toLowerCase()) {
            case "early blight":
                return Arrays.asList(
                    "Dark spots on leaves",
                    "Yellowing around spots",
                    "Leaf drop in severe cases"
                );
            case "late blight":
                return Arrays.asList(
                    "Water-soaked lesions on leaves",
                    "White fuzzy growth on leaf undersides",
                    "Rapid plant collapse"
                );
            case "apple scab":
                return Arrays.asList(
                    "Olive-green to black spots on leaves",
                    "Scabby lesions on fruit",
                    "Premature leaf drop"
                );
            default:
                return Arrays.asList("No specific symptoms identified");
        }
    }
}
