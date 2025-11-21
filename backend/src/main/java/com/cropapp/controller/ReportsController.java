package com.cropapp.controller;
import java.util.Optional;
import com.cropapp.dto.MessageResponse;
import com.cropapp.dto.ReportResponseDTO;
import com.cropapp.dto.ReportsListResponseDTO;
import com.cropapp.entity.User;
import com.cropapp.service.ReportService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.*;

@CrossOrigin(origins = "*", maxAge = 3600)
@RestController
@RequestMapping("/api/reports")
public class ReportsController {

    @Autowired
    private ReportService reportService;

    @GetMapping("")
    public ResponseEntity<?> getReports(Authentication authentication) {
        if (authentication == null) {
            return ResponseEntity.badRequest().body(new MessageResponse("User not authenticated"));
        }

        try {
            User user = (User) authentication.getPrincipal();
            
            // Fetch real reports from database using service layer
            ReportsListResponseDTO response = reportService.getReportsForUser(user);
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            return ResponseEntity.internalServerError()
                .body(new MessageResponse("Failed to fetch reports: " + e.getMessage()));
        }
    }
    @PostMapping("/generate")
    public ResponseEntity<?> generateReport(@RequestBody Map<String, Object> reportRequest, Authentication authentication) {
        if (authentication == null) {
            return ResponseEntity.badRequest().body(new MessageResponse("User not authenticated"));
        }

        try {
            User user = (User) authentication.getPrincipal();
            String reportType = (String) reportRequest.get("type");
            
            if (reportType == null || reportType.trim().isEmpty()) {
                return ResponseEntity.badRequest()
                    .body(new MessageResponse("Report type is required"));
            }
            
            // Generate real report based on scan data
            ReportResponseDTO generatedReport = reportService.generateReport(user, reportType);
            
            return ResponseEntity.ok(generatedReport);
            
        } catch (Exception e) {
            return ResponseEntity.internalServerError()
                .body(new MessageResponse("Failed to generate report: " + e.getMessage()));
        }
    }

    @GetMapping("/{reportId}")
    public ResponseEntity<?> getReportDetails(@PathVariable String reportId, Authentication authentication) {
        if (authentication == null) {
            return ResponseEntity.badRequest().body(new MessageResponse("User not authenticated"));
        }

        try {
            User user = (User) authentication.getPrincipal();
            Long id = Long.parseLong(reportId);
            
            // Fetch real report from database
            Optional<ReportResponseDTO> report = reportService.getReportById(id, user);
            
            if (report.isPresent()) {
                return ResponseEntity.ok(report.get());
            } else {
                return ResponseEntity.notFound().build();
            }
            
        } catch (NumberFormatException e) {
            return ResponseEntity.badRequest()
                .body(new MessageResponse("Invalid report ID format"));
        } catch (Exception e) {
            return ResponseEntity.internalServerError()
                .body(new MessageResponse("Failed to fetch report details: " + e.getMessage()));
        }
    }

    @DeleteMapping("/{reportId}")
    public ResponseEntity<?> deleteReport(@PathVariable String reportId, Authentication authentication) {
        if (authentication == null) {
            return ResponseEntity.badRequest().body(new MessageResponse("User not authenticated"));
        }

        try {
            User user = (User) authentication.getPrincipal();
            Long id = Long.parseLong(reportId);
            
            // Delete real report from database
            boolean deleted = reportService.deleteReport(id, user);
            
            if (deleted) {
                return ResponseEntity.ok(new MessageResponse("Report deleted successfully"));
            } else {
                return ResponseEntity.notFound().build();
            }
            
        } catch (NumberFormatException e) {
            return ResponseEntity.badRequest()
                .body(new MessageResponse("Invalid report ID format"));
        } catch (Exception e) {
            return ResponseEntity.internalServerError()
                .body(new MessageResponse("Failed to delete report: " + e.getMessage()));
        }
    }



}