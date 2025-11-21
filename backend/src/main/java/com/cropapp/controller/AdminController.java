package com.cropapp.controller;

import com.cropapp.dto.MessageResponse;
import com.cropapp.entity.User;
import com.cropapp.repository.UserRepository;
import com.cropapp.security.JwtUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/admin")
@CrossOrigin(origins = "*", maxAge = 3600)
public class AdminController {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private JwtUtils jwtUtils;

    @Autowired
    private com.cropapp.service.EmailService emailService;

    // Get all pending expert applications
    @GetMapping("/experts/pending")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<?> getPendingExperts(@RequestHeader("Authorization") String token) {
        try {
            List<User> pendingExperts = userRepository.findByRoleAndVerificationStatus(
                User.Role.EXPERT, 
                User.VerificationStatus.PENDING
            );

            List<Map<String, Object>> expertList = pendingExperts.stream()
                .map(this::convertToExpertDTO)
                .collect(Collectors.toList());

            Map<String, Object> response = new HashMap<>();
            response.put("experts", expertList);
            response.put("total", expertList.size());

            return ResponseEntity.ok(response);
        } catch (Exception e) {
            System.out.println("Error fetching pending experts: " + e.getMessage());
            return ResponseEntity.badRequest()
                .body(new MessageResponse("Error: " + e.getMessage()));
        }
    }

    // Get all experts with any status
    @GetMapping("/experts")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<?> getAllExperts(
            @RequestHeader("Authorization") String token,
            @RequestParam(required = false) String status) {
        try {
            List<User> experts;
            
            if (status != null && !status.isEmpty()) {
                User.VerificationStatus verificationStatus = User.VerificationStatus.valueOf(status.toUpperCase());
                experts = userRepository.findByRoleAndVerificationStatus(User.Role.EXPERT, verificationStatus);
            } else {
                experts = userRepository.findByRole(User.Role.EXPERT);
            }

            List<Map<String, Object>> expertList = experts.stream()
                .map(this::convertToExpertDTO)
                .collect(Collectors.toList());

            Map<String, Object> response = new HashMap<>();
            response.put("experts", expertList);
            response.put("total", expertList.size());

            return ResponseEntity.ok(response);
        } catch (Exception e) {
            System.out.println("Error fetching experts: " + e.getMessage());
            return ResponseEntity.badRequest()
                .body(new MessageResponse("Error: " + e.getMessage()));
        }
    }

    // Approve expert
    @PostMapping("/experts/{id}/approve")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<?> approveExpert(
            @PathVariable Long id,
            @RequestHeader("Authorization") String token) {
        try {
            String jwt = token.substring(7);
            String username = jwtUtils.getUserNameFromJwtToken(jwt);
            
            Optional<User> adminOpt = userRepository.findByUsername(username);
            if (!adminOpt.isPresent()) {
                return ResponseEntity.badRequest()
                    .body(new MessageResponse("Error: Admin not found!"));
            }

            Optional<User> expertOpt = userRepository.findById(id);
            if (!expertOpt.isPresent()) {
                return ResponseEntity.badRequest()
                    .body(new MessageResponse("Error: Expert not found!"));
            }

            User expert = expertOpt.get();
            User admin = adminOpt.get();

            expert.setVerified(true);
            expert.setVerificationStatus(User.VerificationStatus.APPROVED);
            expert.setVerifiedAt(LocalDateTime.now());
            expert.setVerifiedBy(admin.getId());

            userRepository.save(expert);

            System.out.println("✅ Expert approved: " + expert.getFullName() + " by admin: " + admin.getFullName());

            // Send approval email notification in background thread (non-blocking)
            String expertEmail = expert.getEmail();
            if (expertEmail != null && !expertEmail.trim().isEmpty()) {
                new Thread(() -> {
                    try {
                        emailService.sendExpertApproved(expertEmail, expert.getFullName() == null ? expert.getUsername() : expert.getFullName());
                        System.out.println("📧 Approval email sent to: " + expertEmail);
                    } catch (Exception e) {
                        System.err.println("❌ Error sending approval email in background thread: " + e.getMessage());
                    }
                }).start();
            } else {
                System.out.println("⚠️ Expert approved without email: userId=" + expert.getId());
            }

            Map<String, Object> response = new HashMap<>();
            response.put("status", "success");
            response.put("message", "Expert approved successfully!");
            response.put("expert", convertToExpertDTO(expert));

            return ResponseEntity.ok(response);
        } catch (Exception e) {
            System.out.println("Error approving expert: " + e.getMessage());
            return ResponseEntity.badRequest()
                .body(new MessageResponse("Error: " + e.getMessage()));
        }
    }

    // Reject expert
    @PostMapping("/experts/{id}/reject")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<?> rejectExpert(
            @PathVariable Long id,
            @RequestHeader("Authorization") String token,
            @RequestBody(required = false) Map<String, String> requestBody) {
        try {
            String jwt = token.substring(7);
            String username = jwtUtils.getUserNameFromJwtToken(jwt);
            
            Optional<User> adminOpt = userRepository.findByUsername(username);
            if (!adminOpt.isPresent()) {
                return ResponseEntity.badRequest()
                    .body(new MessageResponse("Error: Admin not found!"));
            }

            Optional<User> expertOpt = userRepository.findById(id);
            if (!expertOpt.isPresent()) {
                return ResponseEntity.badRequest()
                    .body(new MessageResponse("Error: Expert not found!"));
            }

            User expert = expertOpt.get();
            User admin = adminOpt.get();

            expert.setVerified(false);
            expert.setVerificationStatus(User.VerificationStatus.REJECTED);
            expert.setVerifiedBy(admin.getId());

            userRepository.save(expert);

            String reason = requestBody != null ? requestBody.get("reason") : "Not specified";
            System.out.println("❌ Expert rejected: " + expert.getFullName() + " by admin: " + admin.getFullName() + " Reason: " + reason);

            Map<String, Object> response = new HashMap<>();
            response.put("status", "success");
            response.put("message", "Expert rejected!");
            response.put("expert", convertToExpertDTO(expert));

            return ResponseEntity.ok(response);
        } catch (Exception e) {
            System.out.println("Error rejecting expert: " + e.getMessage());
            return ResponseEntity.badRequest()
                .body(new MessageResponse("Error: " + e.getMessage()));
        }
    }

    // Suspend expert
    @PostMapping("/experts/{id}/suspend")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<?> suspendExpert(
            @PathVariable Long id,
            @RequestHeader("Authorization") String token,
            @RequestBody(required = false) Map<String, String> requestBody) {
        try {
            Optional<User> expertOpt = userRepository.findById(id);
            if (!expertOpt.isPresent()) {
                return ResponseEntity.badRequest()
                    .body(new MessageResponse("Error: Expert not found!"));
            }

            User expert = expertOpt.get();

            expert.setVerified(false);
            expert.setVerificationStatus(User.VerificationStatus.SUSPENDED);

            userRepository.save(expert);

            String reason = requestBody != null ? requestBody.get("reason") : "Not specified";
            System.out.println("⚠️ Expert suspended: " + expert.getFullName() + " Reason: " + reason);

            Map<String, Object> response = new HashMap<>();
            response.put("status", "success");
            response.put("message", "Expert suspended!");
            response.put("expert", convertToExpertDTO(expert));

            return ResponseEntity.ok(response);
        } catch (Exception e) {
            System.out.println("Error suspending expert: " + e.getMessage());
            return ResponseEntity.badRequest()
                .body(new MessageResponse("Error: " + e.getMessage()));
        }
    }

    // Get expert details
    @GetMapping("/experts/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<?> getExpertDetails(
            @PathVariable Long id,
            @RequestHeader("Authorization") String token) {
        try {
            Optional<User> expertOpt = userRepository.findById(id);
            if (!expertOpt.isPresent()) {
                return ResponseEntity.badRequest()
                    .body(new MessageResponse("Error: Expert not found!"));
            }

            User expert = expertOpt.get();
            Map<String, Object> expertDetails = convertToExpertDTO(expert);

            return ResponseEntity.ok(expertDetails);
        } catch (Exception e) {
            System.out.println("Error fetching expert details: " + e.getMessage());
            return ResponseEntity.badRequest()
                .body(new MessageResponse("Error: " + e.getMessage()));
        }
    }

    private Map<String, Object> convertToExpertDTO(User expert) {
        Map<String, Object> dto = new HashMap<>();
        dto.put("id", expert.getId());
        dto.put("username", expert.getUsername());
        dto.put("mobile", expert.getMobile());
        dto.put("fullName", expert.getFullName());
        dto.put("specialization", expert.getSpecialization());
        dto.put("isVerified", expert.isVerified());
        dto.put("verificationStatus", expert.getVerificationStatus().name());
        dto.put("verificationDocument", expert.getVerificationDocument());
        dto.put("licenseNumber", expert.getLicenseNumber());
        dto.put("verifiedAt", expert.getVerifiedAt());
        dto.put("verifiedBy", expert.getVerifiedBy());
        dto.put("createdAt", expert.getCreatedAt());
        return dto;
    }
}
