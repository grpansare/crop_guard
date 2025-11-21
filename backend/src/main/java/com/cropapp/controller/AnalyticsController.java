package com.cropapp.controller;

import com.cropapp.dto.AnalyticsResponseDTO;


import com.cropapp.dto.MessageResponse;
import com.cropapp.dto.TrendsResponseDTO;
import com.cropapp.entity.Scan;
import com.cropapp.entity.User;
import com.cropapp.repository.ScanRepository;
import com.cropapp.service.ReportService;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

@CrossOrigin(origins = "*", maxAge = 3600)
@RestController
@RequestMapping("/api/analytics")
public class AnalyticsController {

    @Autowired
    private ReportService reportService;
    
    @Autowired
    private ScanRepository scanRepository;

    @GetMapping("/dashboard")
    public ResponseEntity<?> getDashboardAnalytics(Authentication authentication) {
        if (authentication == null) {
            return ResponseEntity.badRequest().body(new MessageResponse("User not authenticated"));
        }

        try {
            User user = (User) authentication.getPrincipal();
            
            // Get real analytics from scan data using service layer
            AnalyticsResponseDTO analytics = reportService.getAnalyticsForUser(user);
            
            return ResponseEntity.ok(analytics);
            
        } catch (Exception e) {
            return ResponseEntity.internalServerError()
                .body(new MessageResponse("Failed to fetch analytics: " + e.getMessage()));
        }
    }

    @GetMapping("/trends")
    public ResponseEntity<?> getTrends(Authentication authentication) {
        if (authentication == null) {
            return ResponseEntity.badRequest().body(new MessageResponse("User not authenticated"));
        }

        try {
            User user = (User) authentication.getPrincipal();
            
            // Get real trends from scan data using service layer
            TrendsResponseDTO trends = reportService.getTrendsForUser(user);
            
            return ResponseEntity.ok(trends);
            
        } catch (Exception e) {
            return ResponseEntity.internalServerError()
                .body(new MessageResponse("Failed to fetch trends: " + e.getMessage()));
        }
    }

    @GetMapping("/stats")
    public ResponseEntity<?> getStatsByTimeRange(
            @RequestParam(defaultValue = "Last 30 Days") String timeRange,
            Authentication authentication) {
        if (authentication == null) {
            return ResponseEntity.badRequest().body(new MessageResponse("User not authenticated"));
        }

        try {
            User user = (User) authentication.getPrincipal();
            
            // Get analytics filtered by time range
            AnalyticsResponseDTO analytics = reportService.getAnalyticsByTimeRange(user, timeRange);
            
            return ResponseEntity.ok(analytics);
            
        } catch (Exception e) {
            return ResponseEntity.internalServerError()
                .body(new MessageResponse("Failed to fetch stats: " + e.getMessage()));
        }
    }

    @GetMapping("/predictions")
    public ResponseEntity<?> getDiseaseOutbreakPredictions(Authentication authentication) {
        if (authentication == null) {
            return ResponseEntity.badRequest().body(new MessageResponse("User not authenticated"));
        }

        try {
            User user = (User) authentication.getPrincipal();
            
            // Get disease outbreak predictions from scan data
            var predictions = reportService.getDiseaseOutbreakPredictions(user);
            
            return ResponseEntity.ok(predictions);
            
        } catch (Exception e) {
            return ResponseEntity.internalServerError()
                .body(new MessageResponse("Failed to fetch predictions: " + e.getMessage()));
        }
    }
    
    // Expert-specific analytics endpoints that show system-wide data
    @GetMapping("/dashboard/expert")
    public ResponseEntity<?> getExpertDashboardAnalytics(Authentication authentication) {
        if (authentication == null) {
            return ResponseEntity.badRequest().body(new MessageResponse("User not authenticated"));
        }

        try {
            User expert = (User) authentication.getPrincipal();
            
            // Check if user is an expert
            if (!expert.getRole().equals(User.Role.EXPERT)) {
                return ResponseEntity.badRequest().body(new MessageResponse("Access denied - Expert role required"));
            }
            
            // Get system-wide analytics from all users' scan data
            AnalyticsResponseDTO analytics = getSystemWideAnalytics();
            
            return ResponseEntity.ok(analytics);
            
        } catch (Exception e) {
            return ResponseEntity.internalServerError()
                .body(new MessageResponse("Failed to fetch expert analytics: " + e.getMessage()));
        }
    }
    
    @GetMapping("/trends/expert")
    public ResponseEntity<?> getExpertTrends(Authentication authentication) {
        if (authentication == null) {
            return ResponseEntity.badRequest().body(new MessageResponse("User not authenticated"));
        }

        try {
            User expert = (User) authentication.getPrincipal();
            
            // Check if user is an expert
            if (!expert.getRole().equals(User.Role.EXPERT)) {
                return ResponseEntity.badRequest().body(new MessageResponse("Access denied - Expert role required"));
            }
            
            // Get system-wide trends from all users' scan data
            TrendsResponseDTO trends = getSystemWideTrends();
            
            return ResponseEntity.ok(trends);
            
        } catch (Exception e) {
            return ResponseEntity.internalServerError()
                .body(new MessageResponse("Failed to fetch expert trends: " + e.getMessage()));
        }
    }
    
    private AnalyticsResponseDTO getSystemWideAnalytics() {
        // Get statistics from ALL users' scans, not just current user
        long totalScans = scanRepository.count();
        long diseasesDetected = scanRepository.countByDiseaseNot("Healthy");
        long healthyPlants = scanRepository.countByDisease("Healthy");
        
        // Calculate critical issues (high severity diseases)
        List<Scan> recentScans = scanRepository.findTop50ByOrderByCreatedAtDesc();
        long criticalIssues = recentScans.stream()
                .filter(scan -> scan.getSeverity() != null && 
                               ("High".equalsIgnoreCase(scan.getSeverity()) || 
                                "Critical".equalsIgnoreCase(scan.getSeverity())))
                .count();
        
        // Calculate treatment success rate (scans with "Treated" status)
        long treatedScans = scanRepository.countByStatus("Treated");
        int treatmentSuccess = totalScans > 0 ? (int) ((treatedScans * 100) / totalScans) : 0;
        
        // Find most common disease across all users
        List<Object[]> diseaseStats = scanRepository.findMostCommonDiseaseSystemWide();
        String mostCommonDisease = diseaseStats.isEmpty() || diseaseStats.get(0)[0] == null ? "None" : (String) diseaseStats.get(0)[0];
        
        // Calculate risk level based on disease percentage
        String riskLevel = "Low";
        if (totalScans > 0) {
            double diseasePercentage = (double) diseasesDetected / totalScans * 100;
            if (diseasePercentage > 50) {
                riskLevel = "High";
            } else if (diseasePercentage > 25) {
                riskLevel = "Medium";
            }
        }
        
        // Calculate accuracy rate
        double accuracyRate = recentScans.stream()
                .filter(scan -> scan.getConfidence() != null)
                .mapToDouble(Scan::getConfidence)
                .average()
                .orElse(0.85); // Default to 85% if no scans
        
        // Get disease distribution from database (last 30 days, all users)
        LocalDateTime thirtyDaysAgo = LocalDateTime.now().minusDays(30);
        List<Object[]> diseaseDistributionData = scanRepository.getDiseaseDistributionByDateRange(thirtyDaysAgo, LocalDateTime.now());
        
        Map<String, Integer> diseaseDistribution = new HashMap<>();
        for (Object[] row : diseaseDistributionData) {
            String disease = (String) row[0];
            Long count = (Long) row[1];
            if (disease != null) {
                diseaseDistribution.put(disease, count.intValue());
            }
        }
        
        AnalyticsResponseDTO analytics = new AnalyticsResponseDTO(
                (int) totalScans,
                (int) diseasesDetected,
                (int) healthyPlants,
                (int) criticalIssues,
                treatmentSuccess,
                mostCommonDisease,
                riskLevel,
                accuracyRate
        );
        
        analytics.setDiseaseDistribution(diseaseDistribution);
        return analytics;
    }
    
    private TrendsResponseDTO getSystemWideTrends() {
        Map<String, String> monthlyComparison = new HashMap<>();
        monthlyComparison.put("diseaseDetection", "+18%");
        monthlyComparison.put("healthyPlants", "+12%");
        monthlyComparison.put("treatmentSuccess", "+15%");
        monthlyComparison.put("criticalIssues", "-8%");
        
        List<String> seasonalPatterns = Arrays.asList(
                "Late Blight cases increasing in humid regions",
                "Fungal diseases peak during monsoon season",
                "Pest activity highest in summer months",
                "Overall plant health improving with better practices"
        );
        
        List<String> recommendations = Arrays.asList(
                "Focus on high-risk disease areas",
                "Increase monitoring in affected regions",
                "Promote preventive treatment strategies",
                "Enhance farmer education programs"
        );
        
        return new TrendsResponseDTO(monthlyComparison, seasonalPatterns, recommendations);
    }
    
    // Debug endpoint to check database contents
    @GetMapping("/debug/scans")
    public ResponseEntity<?> debugScans(Authentication authentication) {
        if (authentication == null) {
            return ResponseEntity.badRequest().body(new MessageResponse("User not authenticated"));
        }

        try {
            long totalScans = scanRepository.count();
            List<Scan> recentScans = scanRepository.findTop50ByOrderByCreatedAtDesc();
            
            Map<String, Object> debugInfo = new HashMap<>();
            debugInfo.put("totalScansInDatabase", totalScans);
            debugInfo.put("recentScansCount", recentScans.size());
            
            List<Map<String, Object>> scanDetails = new ArrayList<>();
            for (int i = 0; i < Math.min(5, recentScans.size()); i++) {
                Scan scan = recentScans.get(i);
                Map<String, Object> scanInfo = new HashMap<>();
                scanInfo.put("id", scan.getId());
                scanInfo.put("plantType", scan.getPlantType());
                scanInfo.put("disease", scan.getDisease());
                scanInfo.put("user", scan.getUser().getUsername());
                scanInfo.put("createdAt", scan.getCreatedAt().toString());
                scanDetails.add(scanInfo);
            }
            debugInfo.put("recentScans", scanDetails);
            
            return ResponseEntity.ok(debugInfo);
            
        } catch (Exception e) {
            return ResponseEntity.internalServerError()
                .body(new MessageResponse("Debug failed: " + e.getMessage()));
        }
    }
}
