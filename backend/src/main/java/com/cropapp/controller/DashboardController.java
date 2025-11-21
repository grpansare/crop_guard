package com.cropapp.controller;

import com.cropapp.dto.MessageResponse;
import com.cropapp.entity.User;
import com.cropapp.entity.Scan;
import com.cropapp.entity.ExpertQuery;
import com.cropapp.repository.ScanRepository;
import com.cropapp.repository.ExpertQueryRepository;
import com.cropapp.repository.UserRepository;
import com.cropapp.service.ReportService;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.*;

@CrossOrigin(origins = "*", maxAge = 3600)
@RestController
@RequestMapping("/api/dashboard")
public class DashboardController {

    @Autowired
    private ScanRepository scanRepository;
    
    @Autowired 
    private ReportService reportService;
    
    @Autowired
    private ExpertQueryRepository expertQueryRepository;
    
    @Autowired
    private UserRepository userRepository;

    @GetMapping("")
    public ResponseEntity<?> getDashboardData(Authentication authentication) {
        if (authentication == null) {
            return ResponseEntity.badRequest().body(new MessageResponse("User not authenticated"));
        }

        User user = (User) authentication.getPrincipal();
        
        try {
            // Get real statistics from database
            long totalScans = scanRepository.countByUser(user);
            long diseasesDetected = scanRepository.countDiseasesDetectedByUser(user);
            long healthyPlants = scanRepository.countHealthyScansByUser(user);
            
            Map<String, Object> dashboardData = new HashMap<>();
            dashboardData.put("totalScans", totalScans);
            dashboardData.put("diseasesDetected", diseasesDetected);
            dashboardData.put("healthyPlants", healthyPlants);
            dashboardData.put("criticalIssues", diseasesDetected > 0 ? Math.min(diseasesDetected / 3, 5) : 0);
            
            // Get last scan date
            List<Scan> recentScans = scanRepository.findTop10ByUserOrderByCreatedAtDesc(user);
            if (!recentScans.isEmpty()) {
                dashboardData.put("lastScanDate", recentScans.get(0).getCreatedAt().toLocalDate().toString());
            } else {
                dashboardData.put("lastScanDate", null);
            }
            
            // Calculate farm health score (percentage of healthy scans)
            int farmHealthScore = totalScans > 0 ? (int) ((healthyPlants * 100) / totalScans) : 100;
            dashboardData.put("farmHealthScore", farmHealthScore);
            
            return ResponseEntity.ok(dashboardData);
        } catch (Exception e) {
            // Fallback to sample data if database query fails
            Map<String, Object> dashboardData = new HashMap<>();
            dashboardData.put("totalScans", 0);
            dashboardData.put("diseasesDetected", 0);
            dashboardData.put("healthyPlants", 0);
            dashboardData.put("criticalIssues", 0);
            dashboardData.put("lastScanDate", null);
            dashboardData.put("farmHealthScore", 100);
            
            return ResponseEntity.ok(dashboardData);
        }
    }

    @GetMapping("/activity")
    public ResponseEntity<?> getRecentActivity(Authentication authentication) {
        if (authentication == null) {
            return ResponseEntity.badRequest().body(new MessageResponse("User not authenticated"));
        }

        User user = (User) authentication.getPrincipal();
        
        try {
            // Get real scan data from database only
            List<Scan> recentScans = scanRepository.findTop10ByUserOrderByCreatedAtDesc(user);
            List<Map<String, Object>> activities = new ArrayList<>();
            
            System.out.println("DEBUG: Found " + recentScans.size() + " scans for user " + user.getUsername());
            
        // Limit to only 3 most recent activities for dashboard display
int maxActivities = Math.min(3, recentScans.size());
for (int i = 0; i < maxActivities; i++) {
    Scan scan = recentScans.get(i);
    String title = scan.getPlantType() + " plant scanned";
    String subtitle = scan.getDisease();
    if (!scan.getDisease().equalsIgnoreCase("healthy")) {
        subtitle += " detected - " + (scan.getSeverity() != null ? scan.getSeverity() : "Unknown") + " severity";
    } else {
        subtitle = "No diseases detected";
    }
    
    String timeAgo = getTimeAgo(scan.getCreatedAt());
    activities.add(createActivity(title, subtitle, timeAgo, "scan"));
}
            
            // Only show welcome message if truly no scans exist
            if (activities.isEmpty()) {
                activities = Arrays.asList(
                    createActivity("No scan activity yet", "Start scanning plants to see your activity here", "Just now", "info")
                );
            }

            Map<String, Object> response = new HashMap<>();
   
response.put("activities", activities);
            response.put("total", activities.size());
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            System.err.println("Error in getRecentActivity: " + e.getMessage());
            e.printStackTrace();
            
            return ResponseEntity.internalServerError()
                .body(new MessageResponse("Failed to fetch activity: " + e.getMessage()));
        }
    }

    @GetMapping("/stats")
    public ResponseEntity<?> getQuickStats(Authentication authentication) {
        if (authentication == null) {
            return ResponseEntity.badRequest().body(new MessageResponse("User not authenticated"));
        }

        User user = (User) authentication.getPrincipal();
        
        try {
            // Get real statistics from database only
            long totalScans = scanRepository.countByUser(user);
            long diseasesDetected = scanRepository.countDiseasesDetectedByUser(user);
            long healthyPlants = scanRepository.countHealthyScansByUser(user);
            
            System.out.println("DEBUG: Stats for user " + user.getUsername() + 
                              " - Total: " + totalScans + 
                              ", Diseases: " + diseasesDetected + 
                              ", Healthy: " + healthyPlants);
            
            Map<String, Object> stats = new HashMap<>();
            stats.put("totalScans", totalScans);
            stats.put("diseasesDetected", diseasesDetected);
            stats.put("plantsScanned", totalScans);
            stats.put("healthyPlants", healthyPlants);
            stats.put("criticalIssues", diseasesDetected > 0 ? Math.min(diseasesDetected / 3, 5) : 0);
            
            // Calculate treatment success rate
            int treatmentSuccess = totalScans > 0 ? (int) ((healthyPlants * 100) / totalScans) : 0;
            stats.put("treatmentSuccess", treatmentSuccess);
            
            return ResponseEntity.ok(stats);
        } catch (Exception e) {
            System.err.println("Error in getQuickStats: " + e.getMessage());
            e.printStackTrace();
            
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
            
            // Get disease outbreak predictions from service layer
            Map<String, Object> predictions = reportService.getDiseaseOutbreakPredictions(user);
            
            return ResponseEntity.ok(predictions);
            
        } catch (Exception e) {
            return ResponseEntity.internalServerError()
                .body(new MessageResponse("Failed to fetch predictions: " + e.getMessage()));
        }
    }
    // Add this new method to create sample scan data
    private List<Scan> createSampleScanData(User user) {
        List<Scan> sampleScans = Arrays.asList(
            createSampleScan(user, "Tomato", "Early Blight", 0.92, "Medium", "Treated"),
            createSampleScan(user, "Potato", "Late Blight", 0.87, "High", "Under Treatment"),
            createSampleScan(user, "Corn", "Healthy", 0.95, "None", "Healthy"),
            createSampleScan(user, "Apple", "Apple Scab", 0.78, "Low", "Monitoring"),
            createSampleScan(user, "Wheat", "Healthy", 0.89, "None", "Healthy")
        );
        
        return scanRepository.saveAll(sampleScans);
    }

    private Scan createSampleScan(User user, String plantType, String disease, double confidence, String severity, String status) {
        Scan scan = new Scan();
        scan.setUser(user);
        scan.setPlantType(plantType);
        scan.setDisease(disease);
        scan.setConfidence(confidence);
        scan.setSeverity(severity);
        scan.setStatus(status);
        scan.setImagePath("/images/sample_" + plantType.toLowerCase() + ".jpg");
        scan.setRecommendations(generateRecommendations(disease));
        scan.setSymptoms(generateSymptoms(disease));
        scan.setCreatedAt(LocalDateTime.now().minusHours((long)(Math.random() * 72))); // Random time in last 3 days
        return scan;
    }

    private String generateRecommendations(String disease) {
        switch (disease.toLowerCase()) {
            case "early blight":
                return "Apply fungicide treatment. Remove affected leaves. Improve air circulation.";
            case "late blight":
                return "Immediate fungicide application required. Remove infected plants. Avoid overhead watering.";
            case "apple scab":
                return "Apply preventive fungicide. Prune for better air circulation. Remove fallen leaves.";
            case "healthy":
                return "Continue current care practices. Monitor regularly for any changes.";
            default:
                return "Monitor plant closely. Consult agricultural expert if symptoms persist.";
        }
    }

    private String generateSymptoms(String disease) {
        switch (disease.toLowerCase()) {
            case "early blight":
                return "Dark spots with concentric rings on leaves";
            case "late blight":
                return "Water-soaked lesions with white fuzzy growth";
            case "apple scab":
                return "Dark, scaly lesions on leaves and fruit";
            case "healthy":
                return "No visible symptoms detected";
            default:
                return "Various symptoms observed";
        }
    }

  

    private String getTimeAgo(java.time.LocalDateTime scanTime) {
        java.time.LocalDateTime now = java.time.LocalDateTime.now();
        java.time.Duration duration = java.time.Duration.between(scanTime, now);
        
        long days = duration.toDays();
        long hours = duration.toHours();
        long minutes = duration.toMinutes();
        
        if (days > 0) {
            return days == 1 ? "1 day ago" : days + " days ago";
        } else if (hours > 0) {
            return hours == 1 ? "1 hour ago" : hours + " hours ago";
        } else if (minutes > 0) {
            return minutes == 1 ? "1 minute ago" : minutes + " minutes ago";
        } else {
            return "Just now";
        }
    }

    private Map<String, Object> createActivity(String title, String subtitle, String time, String type) {
        Map<String, Object> activity = new HashMap<>();
        activity.put("title", title);
        activity.put("subtitle", subtitle);
        activity.put("time", time);
        activity.put("type", type);
        
        // Add icon and color based on type
        switch (type) {
            case "scan":
                activity.put("icon", "local_florist");
                activity.put("color", subtitle.contains("No diseases") || subtitle.contains("healthy") ? "green" : "orange");
                break;
            case "report":
                activity.put("icon", "article");
                activity.put("color", "blue");
                break;
            case "reminder":
                activity.put("icon", "notification_important");
                activity.put("color", "red");
                break;
            case "info":
                activity.put("icon", "info");
                activity.put("color", "blue");
                break;
            default:
                activity.put("icon", "info");
                activity.put("color", "grey");
        }
        
        return activity;
    }
    
    // Expert Dashboard Endpoints
    @GetMapping("/expert")
    public ResponseEntity<?> getExpertDashboardStats(Authentication authentication) {
        if (authentication == null) {
            return ResponseEntity.badRequest().body(new MessageResponse("User not authenticated"));
        }

        User expert = (User) authentication.getPrincipal();
        
        try {
            // Get expert statistics
            long totalQueries = expertQueryRepository.count();
long pendingQueries = expertQueryRepository.countByStatus("pending");
long criticalCases = expertQueryRepository.countByUrgency("critical");

long answeredQueries = expertQueryRepository.countByExpert(expert);
            long totalFarmers = userRepository.countByRole(User.Role.USER);
            
            // Get system-wide scan statistics for expert dashboard
            long totalScans = scanRepository.count();
            long diseasesDetected = scanRepository.countDiseasesDetected();
            long healthyPlants = scanRepository.countHealthyScans();
            
            Map<String, Object> stats = new HashMap<>();
            stats.put("totalQueries", totalQueries);
            stats.put("pendingQueries", pendingQueries);
            stats.put("answeredQueries", answeredQueries);
            stats.put("criticalCases", criticalCases);
            stats.put("totalFarmers", totalFarmers);
            stats.put("activeFarmers", totalFarmers); // Show actual total farmers
            
            // Add scan statistics
            stats.put("totalScans", totalScans);
            stats.put("diseasesDetected", diseasesDetected);
            stats.put("healthyPlants", healthyPlants);
            stats.put("plantsScanned", totalScans);
            
            stats.put("responseTime", answeredQueries > 0 ? "Available" : "No data yet");
            stats.put("satisfactionRating", answeredQueries > 0 ? "Available" : "No data yet");
            
            // Get recent expert activity
            List<ExpertQuery> recentQueries = expertQueryRepository.findTop5ByExpertOrderByUpdatedAtDesc(expert);
            List<Map<String, Object>> recentActivity = new ArrayList<>();
            
            for (ExpertQuery query : recentQueries) {
                Map<String, Object> activity = new HashMap<>();
                activity.put("type", "query_response");
                activity.put("title", "Responded to " + query.getCropType() + " query");
                activity.put("farmer", query.getFarmer().getFullName());
                activity.put("time", getTimeAgo(query.getUpdatedAt()));
                activity.put("status", "completed");
                recentActivity.add(activity);
            }
            
            stats.put("recentActivity", recentActivity);
            
            return ResponseEntity.ok(stats);
        } catch (Exception e) {
            // Return fallback data
            Map<String, Object> stats = new HashMap<>();
            // Query statistics
            stats.put("totalQueries", 0);
            stats.put("pendingQueries", 0);
            stats.put("answeredQueries", 0);
            stats.put("criticalCases", 0);
            stats.put("totalFarmers", 0);
            stats.put("activeFarmers", 0);
            
            // Scan statistics (system-wide)
            stats.put("totalScans", 0);
            stats.put("diseasesDetected", 0);
            stats.put("healthyPlants", 0);
            stats.put("plantsScanned", 0);
            stats.put("treatmentSuccess", 0);
            
            stats.put("responseTime", "N/A");
            stats.put("satisfactionRating", 0.0);
            stats.put("recentActivity", new ArrayList<>());
            
            return ResponseEntity.ok(stats);
        }
    }
    
    @GetMapping("/expert/performance")
    public ResponseEntity<?> getExpertPerformanceMetrics(Authentication authentication) {
        if (authentication == null) {
            return ResponseEntity.badRequest().body(new MessageResponse("User not authenticated"));
        }

        User expert = (User) authentication.getPrincipal();
        
        try {
            // Get performance metrics
            long totalResponses = expertQueryRepository.countByExpert(expert);
            long diseasesIdentified = totalResponses; // Mock - could be calculated from responses
            long treatmentsProvided = totalResponses;
            
            Map<String, Object> metrics = new HashMap<>();
            metrics.put("diseasesIdentified", diseasesIdentified);
            metrics.put("treatmentsProvided", treatmentsProvided);
            metrics.put("preventionTips", treatmentsProvided * 2); // Mock
            
            // Monthly query trends
            List<Map<String, Object>> monthlyData = new ArrayList<>();
            String[] months = {"Jan", "Feb", "Mar", "Apr", "May", "Jun"};
            for (int i = 0; i < months.length; i++) {
                Map<String, Object> monthData = new HashMap<>();
                monthData.put("month", months[i]);
                monthData.put("queries", 10 + (int)(Math.random() * 15));
                monthData.put("cases", 5 + (int)(Math.random() * 10));
                monthlyData.add(monthData);
            }
            metrics.put("monthlyQueries", monthlyData);
            
            // Top diseases (mock data)
            List<Map<String, Object>> topDiseases = Arrays.asList(
                createDiseaseData("Tomato Late Blight", 15, "High"),
                createDiseaseData("Wheat Rust", 12, "Medium"),
                createDiseaseData("Rice Blast", 9, "Critical"),
                createDiseaseData("Corn Leaf Spot", 7, "Low")
            );
            metrics.put("topDiseases", topDiseases);
            
            return ResponseEntity.ok(metrics);
        } catch (Exception e) {
            return ResponseEntity.internalServerError()
                .body(new MessageResponse("Failed to fetch performance metrics: " + e.getMessage()));
        }
    }
    
    private Map<String, Object> createDiseaseData(String name, int cases, String severity) {
        Map<String, Object> disease = new HashMap<>();
        disease.put("name", name);
        disease.put("cases", cases);
        disease.put("severity", severity);
        return disease;
    }
}
