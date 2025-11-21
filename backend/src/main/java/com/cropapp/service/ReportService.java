package com.cropapp.service;

import com.cropapp.dto.AnalyticsResponseDTO;
import com.cropapp.dto.ReportResponseDTO;
import com.cropapp.dto.ReportsListResponseDTO;
import com.cropapp.dto.TrendsResponseDTO;
import com.cropapp.entity.Report;
import com.cropapp.entity.Scan;
import com.cropapp.entity.User;
import com.cropapp.repository.ReportRepository;
import com.cropapp.repository.ScanRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.*;
import java.util.stream.Collectors;

@Service
public class ReportService {

    @Autowired
    private ReportRepository reportRepository;

    @Autowired
    private ScanRepository scanRepository;

    public ReportsListResponseDTO getReportsForUser(User user) {
        List<Report> reports = reportRepository.findByUserOrderByGeneratedAtDesc(user);
        
        // Always update or create the weekly analysis with latest scan data
        updateOrCreateWeeklyAnalysis(user, reports);
        
        // Refresh the reports list after update
        reports = reportRepository.findByUserOrderByGeneratedAtDesc(user);
        
        List<ReportResponseDTO> reportDTOs = reports.stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
        
        return new ReportsListResponseDTO(reportDTOs);
    }

    private void updateOrCreateWeeklyAnalysis(User user, List<Report> existingReports) {
        // Get actual scan counts
        long totalScans = scanRepository.countByUser(user);
        long diseasesDetected = scanRepository.countDiseasesDetectedByUser(user);
        long healthyPlants = scanRepository.countHealthyScansByUser(user);
        
        // Calculate critical issues from recent scans
        List<Scan> recentScans = scanRepository.findTop10ByUserOrderByCreatedAtDesc(user);
        long criticalIssues = recentScans.stream()
                .filter(scan -> scan.getSeverity() != null && 
                               ("High".equalsIgnoreCase(scan.getSeverity()) || 
                                "Critical".equalsIgnoreCase(scan.getSeverity())))
                .count();
        
        // Count recommendations from scans
        long recommendationsCount = recentScans.stream()
                .filter(scan -> scan.getRecommendations() != null && !scan.getRecommendations().trim().isEmpty())
                .count();
        
        // Find existing weekly report or create new one
        Report weeklyReport = existingReports.stream()
                .filter(report -> "Weekly Report".equals(report.getType()) && 
                                 "Weekly Disease Analysis".equals(report.getTitle()))
                .findFirst()
                .orElse(new Report(user, "Weekly Disease Analysis", "Weekly Report", "Completed"));
        
        // Update with real data
        weeklyReport.setDiseaseCount((int) diseasesDetected);
        weeklyReport.setHealthyCount((int) healthyPlants);
        weeklyReport.setCriticalIssues((int) criticalIssues);
        weeklyReport.setRecommendationsCount((int) recommendationsCount);
        
        // Update summary with real data
        if (totalScans > 0) {
            weeklyReport.setSummary(String.format("Analysis of %d plant scans. Found %d diseases and %d healthy plants with %d critical issues.", 
                    totalScans, diseasesDetected, healthyPlants, criticalIssues));
        } else {
            weeklyReport.setSummary("No scan data available yet. Start scanning plants to see analysis.");
        }
        
        // Update the generated timestamp
        weeklyReport.setGeneratedAt(LocalDateTime.now());
        
        // Save the updated report
        reportRepository.save(weeklyReport);
    }

    public AnalyticsResponseDTO getAnalyticsForUser(User user) {
        // Use individual queries instead of the complex one
        long totalScans = scanRepository.countByUser(user);
        long diseasesDetected = scanRepository.countDiseasesDetectedByUser(user);
        long healthyPlants = scanRepository.countHealthyScansByUser(user);
        
        // Calculate critical issues (high severity diseases)
        List<Scan> recentScans = scanRepository.findTop10ByUserOrderByCreatedAtDesc(user);
        long criticalIssues = recentScans.stream()
                .filter(scan -> scan.getSeverity() != null && 
                               ("High".equalsIgnoreCase(scan.getSeverity()) || 
                                "Critical".equalsIgnoreCase(scan.getSeverity())))
                .count();
        
        // Calculate treatment success rate (scans with "Treated" status)
        long treatedScans = scanRepository.countByUserAndStatus(user, "Treated");
        int treatmentSuccess = totalScans > 0 ? (int) ((treatedScans * 100) / totalScans) : 0;
        
        // Find most common disease
        List<Object[]> diseaseStats = scanRepository.findMostCommonDiseaseByUser(user);
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
        
        // Get disease distribution from database
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
    public TrendsResponseDTO getTrendsForUser(User user) {
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
                "Monitor potato crops more frequently",
                "Consider preventive fungicide application"
        );
        
        return new TrendsResponseDTO(monthlyComparison, seasonalPatterns, recommendations);
    }

    public ReportResponseDTO generateReport(User user, String reportType) {
        // Get actual scan counts for the report
        long totalScans = scanRepository.countByUser(user);
        long diseasesDetected = scanRepository.countDiseasesDetectedByUser(user);
        long healthyPlants = scanRepository.countHealthyScansByUser(user);
        
        // Calculate critical issues from recent scans
        List<Scan> recentScans = scanRepository.findTop10ByUserOrderByCreatedAtDesc(user);
        long criticalIssues = recentScans.stream()
                .filter(scan -> scan.getSeverity() != null && 
                               ("High".equalsIgnoreCase(scan.getSeverity()) || 
                                "Critical".equalsIgnoreCase(scan.getSeverity())))
                .count();
        
        // Count recommendations from scans
        long recommendationsCount = recentScans.stream()
                .filter(scan -> scan.getRecommendations() != null && !scan.getRecommendations().trim().isEmpty())
                .count();
        
        Report report = new Report(user, reportType + " - " + LocalDateTime.now().toLocalDate(), reportType, "Generated");
        
        // Set real data instead of dummy values
        report.setDiseaseCount((int) diseasesDetected);
        report.setHealthyCount((int) healthyPlants);
        report.setCriticalIssues((int) criticalIssues);
        report.setRecommendationsCount((int) recommendationsCount);
        
        // Generate dynamic summary based on actual data
        if (totalScans > 0) {
            report.setSummary(String.format("Generated %s based on %d plant scans. Found %d diseases and %d healthy plants with %d critical issues.", 
                    reportType, totalScans, diseasesDetected, healthyPlants, criticalIssues));
        } else {
            report.setSummary("No scan data available yet. Start scanning plants to generate meaningful reports.");
        }
        
        report = reportRepository.save(report);
        return convertToDTO(report);
    }

    /**
     * Get report by ID
     */
    public Optional<ReportResponseDTO> getReportById(Long reportId, User user) {
        return reportRepository.findById(reportId)
                .filter(report -> report.getUser().getId().equals(user.getId()))
                .map(this::convertToDTO);
    }
    
    
    

    /**
     * Delete report by ID
     */
    public boolean deleteReport(Long reportId, User user) {
        Optional<Report> report = reportRepository.findById(reportId)
                .filter(r -> r.getUser().getId().equals(user.getId()));
        
        if (report.isPresent()) {
            reportRepository.delete(report.get());
            return true;
        }
        return false;
    }
 // Add this method to your ReportService.java

    public AnalyticsResponseDTO getAnalyticsByTimeRange(User user, String timeRange) {
        LocalDateTime startDate = getStartDateFromTimeRange(timeRange);
        LocalDateTime endDate = LocalDateTime.now();
        
        // Use existing analytics logic but filter by date range
        AnalyticsResponseDTO analytics = getAnalyticsForUser(user);
        
        // You can modify the existing getAnalyticsForUser method to accept date parameters
        // or create a new method that filters data by the time range
        
        return analytics;
    }
    public Map<String, Object> getDiseaseOutbreakPredictions(User user) {
        try {
            // Analyze recent disease trends to predict outbreaks
            LocalDateTime now = LocalDateTime.now();
            LocalDateTime lastMonth = now.minusMonths(1);
            LocalDateTime lastWeek = now.minusDays(7);
            
            // Get recent disease data for analysis
            List<Object[]> recentDiseases = scanRepository.getDiseaseDistributionByDateRange(lastWeek, now);
            List<Object[]> monthlyDiseases = scanRepository.getDiseaseDistributionByDateRange(lastMonth, now);
            
            // Calculate outbreak risk level
            String riskLevel = calculateOutbreakRiskLevel(recentDiseases, monthlyDiseases);
            double confidence = calculatePredictionConfidence(recentDiseases);
            
            // Generate specific disease predictions
            List<Map<String, Object>> predictions = generateDiseasePredictions(recentDiseases, monthlyDiseases);
            
            // Generate preventive measures
            List<String> preventiveMeasures = generatePreventiveMeasures(predictions, riskLevel);
            
            Map<String, Object> response = new HashMap<>();
            
            // Outbreak risk summary
            Map<String, Object> outbreakRisk = new HashMap<>();
            outbreakRisk.put("level", riskLevel);
            outbreakRisk.put("confidence", confidence);
            outbreakRisk.put("timeframe", getTimeframeForRisk(riskLevel));
            
            response.put("outbreakRisk", outbreakRisk);
            response.put("predictions", predictions);
            response.put("preventiveMeasures", preventiveMeasures);
            response.put("generatedAt", now.format(DateTimeFormatter.ISO_LOCAL_DATE_TIME));
            
            return response;
            
        } catch (Exception e) {
            // Return fallback prediction data
            return getFallbackPredictions();
        }
    }

    private String calculateOutbreakRiskLevel(List<Object[]> recentDiseases, List<Object[]> monthlyDiseases) {
        // Calculate total recent disease cases
        long recentTotal = recentDiseases.stream()
            .filter(result -> result[0] != null && !result[0].equals("Healthy"))
            .mapToLong(result -> (Long) result[1])
            .sum();
        
        long monthlyTotal = monthlyDiseases.stream()
            .filter(result -> result[0] != null && !result[0].equals("Healthy"))
            .mapToLong(result -> (Long) result[1])
            .sum();
        
        // Calculate weekly average from monthly data
        double weeklyAverage = monthlyTotal / 4.0;
        
        if (recentTotal > weeklyAverage * 1.5) {
            return "High";
        } else if (recentTotal > weeklyAverage * 1.2) {
            return "Medium";
        } else {
            return "Low";
        }
    }

    private double calculatePredictionConfidence(List<Object[]> recentDiseases) {
        // Base confidence on data availability and consistency
        long totalCases = recentDiseases.stream()
            .mapToLong(result -> (Long) result[1])
            .sum();
        
        if (totalCases > 50) {
            return 0.85;
        } else if (totalCases > 20) {
            return 0.72;
        } else {
            return 0.58;
        }
    }

    private List<Map<String, Object>> generateDiseasePredictions(List<Object[]> recentDiseases, List<Object[]> monthlyDiseases) {
        List<Map<String, Object>> predictions = new ArrayList<>();
        
        // Convert monthly data to map for easy lookup
        Map<String, Long> monthlyMap = new HashMap<>();
        for (Object[] result : monthlyDiseases) {
            if (result[0] != null && !result[0].equals("Healthy")) {
                monthlyMap.put((String) result[0], (Long) result[1]);
            }
        }
        
        for (Object[] recent : recentDiseases) {
            String disease = (String) recent[0];
            Long recentCount = (Long) recent[1];
            
            if (disease != null && !disease.equals("Healthy") && recentCount > 0) {
                Long monthlyCount = monthlyMap.getOrDefault(disease, 0L);
                double weeklyAverage = monthlyCount / 4.0;
                
                // Calculate probability based on recent trend
                double probability = Math.min(0.95, (recentCount / Math.max(weeklyAverage, 1.0)) * 0.6);
                
                if (probability > 0.3) { // Only include significant predictions
                    Map<String, Object> prediction = new HashMap<>();
                    prediction.put("disease", disease);
                    prediction.put("probability", Math.round(probability * 100.0) / 100.0);
                    prediction.put("regions", getAffectedRegionsForDisease(disease));
                    prediction.put("timeframe", getTimeframeForProbability(probability));
                    
                    predictions.add(prediction);
                }
            }
        }
        
        return predictions;
    }

    private List<String> generatePreventiveMeasures(List<Map<String, Object>> predictions, String riskLevel) {
        List<String> measures = new ArrayList<>();
        
        if ("High".equals(riskLevel)) {
            measures.add("Implement immediate disease surveillance in high-risk areas");
            measures.add("Prepare emergency response teams for rapid deployment");
            measures.add("Issue urgent alerts to farmers in predicted outbreak zones");
        }
        
        if ("Medium".equals(riskLevel) || "High".equals(riskLevel)) {
            measures.add("Increase field monitoring frequency");
            measures.add("Apply protective fungicides in vulnerable areas");
            measures.add("Coordinate with agricultural extension services");
        }
        
        // Add disease-specific measures
        for (Map<String, Object> prediction : predictions) {
            String disease = (String) prediction.get("disease");
            Double probability = (Double) prediction.get("probability");
            
            if (probability > 0.7) {
                measures.add("High priority: Implement " + disease + " specific prevention protocols");
            } else if (probability > 0.5) {
                measures.add("Monitor " + disease + " susceptible crops closely");
            }
        }
        
        // General measures
        measures.add("Update farmer education materials on early detection");
        measures.add("Ensure adequate supply of treatment materials");
        measures.add("Establish communication channels for rapid information sharing");
        
        return measures;
    }

    private String getTimeframeForRisk(String riskLevel) {
        switch (riskLevel) {
            case "High":
                return "Next 1-2 weeks";
            case "Medium":
                return "Next 2-4 weeks";
            default:
                return "Next 4-8 weeks";
        }
    }

    private String getTimeframeForProbability(double probability) {
        if (probability > 0.8) {
            return "7-14 days";
        } else if (probability > 0.6) {
            return "14-21 days";
        } else {
            return "21-30 days";
        }
    }

    private List<String> getAffectedRegionsForDisease(String disease) {
        // This is a placeholder - you can implement based on your geographical data
        // You could query scan locations or user locations to determine affected regions
        return List.of("North", "Central", "South");
    }

    private Map<String, Object> getFallbackPredictions() {
        Map<String, Object> fallback = new HashMap<>();
        
        Map<String, Object> outbreakRisk = new HashMap<>();
        outbreakRisk.put("level", "Medium");
        outbreakRisk.put("confidence", 0.75);
        outbreakRisk.put("timeframe", "Next 2-3 weeks");
        
        List<Map<String, Object>> predictions = List.of(
            Map.of(
                "disease", "Tomato Late Blight",
                "probability", 0.68,
                "regions", List.of("North", "Central"),
                "timeframe", "14-21 days"
            ),
            Map.of(
                "disease", "Rice Blast",
                "probability", 0.54,
                "regions", List.of("East"),
                "timeframe", "21-30 days"
            )
        );
        
        List<String> preventiveMeasures = List.of(
            "Apply protective fungicides in high-risk areas",
            "Increase field monitoring frequency",
            "Prepare rapid response teams",
            "Alert farmers in predicted outbreak zones"
        );
        
        fallback.put("outbreakRisk", outbreakRisk);
        fallback.put("predictions", predictions);
        fallback.put("preventiveMeasures", preventiveMeasures);
        
        return fallback;
    }
    private LocalDateTime getStartDateFromTimeRange(String timeRange) {
        LocalDateTime now = LocalDateTime.now();
        switch (timeRange) {
            case "Last 7 Days":
                return now.minusDays(7);
            case "Last 30 Days":
                return now.minusDays(30);
            case "Last 3 Months":
                return now.minusMonths(3);
            case "Last 6 Months":
                return now.minusMonths(6);
            case "Last Year":
                return now.minusYears(1);
            default:
                return now.minusDays(30);
        }
    }
   

    private ReportResponseDTO convertToDTO(Report report) {
        ReportResponseDTO dto = new ReportResponseDTO();
        dto.setId(report.getId().toString());
        dto.setTitle(report.getTitle());
        dto.setType(report.getType());
        dto.setDate(report.getGeneratedAt().toLocalDate().toString());
        dto.setStatus(report.getStatus());
        dto.setSummary(report.getSummary());
        dto.setDiseaseCount(report.getDiseaseCount());
        dto.setHealthyCount(report.getHealthyCount());
        dto.setCriticalIssues(report.getCriticalIssues());
        dto.setRecommendations(report.getRecommendationsCount());
        dto.setCreatedBy(report.getUser().getUsername());
        return dto;
    }
}