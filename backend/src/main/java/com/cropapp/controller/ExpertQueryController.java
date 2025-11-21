package com.cropapp.controller;

import com.cropapp.dto.*;

import com.cropapp.entity.ExpertQuery;
import com.cropapp.entity.ExpertResponse;
import com.cropapp.entity.User;
import com.cropapp.repository.ExpertQueryRepository;
import com.cropapp.repository.ExpertResponseRepository;
import com.cropapp.repository.UserRepository;
import com.cropapp.security.JwtUtils;
import com.cropapp.service.NotificationService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import jakarta.validation.Valid;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/queries")
@CrossOrigin(origins = "*", maxAge = 3600)
public class ExpertQueryController {

    @Autowired
    private ExpertQueryRepository expertQueryRepository;
    
    @Autowired
    private ExpertResponseRepository expertResponseRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private JwtUtils jwtUtils;
    
    @Autowired
    private NotificationService notificationService;

    @GetMapping("/my")
    @PreAuthorize("hasRole('USER') or hasRole('ADMIN')")
    public ResponseEntity<?> getMyQueries(@RequestHeader("Authorization") String token,
                                        @RequestParam(defaultValue = "0") int page,
                                        @RequestParam(defaultValue = "20") int size) {
        try {
            String jwt = token.substring(7);
            String username = jwtUtils.getUserNameFromJwtToken(jwt);
            
            Optional<User> userOpt = userRepository.findByUsername(username);
            if (!userOpt.isPresent()) {
                return ResponseEntity.badRequest()
                    .body(new MessageResponse("Error: User not found!"));
            }

            User farmer = userOpt.get();
            Pageable pageable = PageRequest.of(page, size);
            Page<ExpertQuery> queriesPage = expertQueryRepository.findByFarmerOrderByCreatedAtDesc(farmer, pageable);
            
            List<ExpertQueryResponseDTO> queries = queriesPage.getContent().stream()
                .map(this::convertToResponseDTO)
                .collect(Collectors.toList());

            ExpertQueryListResponseDTO response = new ExpertQueryListResponseDTO();
            response.setQueries(queries);
            response.setTotalElements(queriesPage.getTotalElements());
            response.setTotalPages(queriesPage.getTotalPages());
            response.setCurrentPage(queriesPage.getNumber());
            response.setPageSize(queriesPage.getSize());
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                .body(new MessageResponse("Error: " + e.getMessage()));
        }
    }
    @GetMapping("/expert")
    @PreAuthorize("hasRole('EXPERT') or hasRole('ADMIN')")
    public ResponseEntity<?> getExpertQueries(@RequestHeader("Authorization") String token,
                                            @RequestParam(defaultValue = "0") int page,
                                            @RequestParam(defaultValue = "20") int size) {
        try {
            String jwt = token.substring(7);
            String username = jwtUtils.getUserNameFromJwtToken(jwt);
            
            Optional<User> userOpt = userRepository.findByUsername(username);
            if (!userOpt.isPresent()) {
                return ResponseEntity.badRequest()
                    .body(new MessageResponse("Error: User not found!"));
            }
            
            User currentExpert = userOpt.get();

            Pageable pageable = PageRequest.of(page, size);
            Page<ExpertQuery> queriesPage = expertQueryRepository.findAllOrderByUrgencyAndCreatedAt(pageable);
            
            List<ExpertQueryResponseDTO> queries = queriesPage.getContent().stream()
                .map(query -> convertToResponseDTO(query, currentExpert))
                .collect(Collectors.toList());

            ExpertQueryListResponseDTO response = new ExpertQueryListResponseDTO();
            response.setQueries(queries);
            response.setTotalElements(queriesPage.getTotalElements());
            response.setTotalPages(queriesPage.getTotalPages());
            response.setCurrentPage(queriesPage.getNumber());
            response.setPageSize(queriesPage.getSize()); // FIXED: Changed from setSize() to setPageSize()
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                .body(new MessageResponse("Error: " + e.getMessage()));
        }
    }

    private ExpertQueryResponseDTO convertToResponseDTO(ExpertQuery query) {
        ExpertQueryResponseDTO dto = new ExpertQueryResponseDTO();
        dto.setId(query.getId());
        dto.setTitle(query.getTitle());
        dto.setDescription(query.getDescription());
        dto.setCropType(query.getCropType());
        dto.setCategory(query.getCategory());
        dto.setUrgency(query.getUrgency());
        dto.setStatus(query.getStatus());
        dto.setHasImage(query.getHasImage());
        dto.setResponse(query.getResponse());
        dto.setResponseDate(query.getResponseDate());
        dto.setCreatedAt(query.getCreatedAt());
        dto.setUpdatedAt(query.getUpdatedAt());
        if (query.getImagePath() != null) {
            dto.setImageUrl("/api/images/" + query.getImagePath());
        }
        if (query.getFarmer() != null) {
            dto.setFarmerName(query.getFarmer().getFullName());
        }
        
        if (query.getExpert() != null) {
            dto.setExpertName(query.getExpert().getFullName());
        }
        
        return dto;
    }
    
    private ExpertQueryResponseDTO convertToResponseDTO(ExpertQuery query, User currentExpert) {
        ExpertQueryResponseDTO dto = convertToResponseDTO(query);
        
        // Check if current expert has responded to this query
        boolean hasResponded = expertResponseRepository.existsByQueryIdAndExpertId(
            query.getId(), 
            currentExpert.getId()
        );
        dto.setHasResponded(hasResponded);
        
        // Get response count
        long responseCount = expertResponseRepository.countByQueryId(query.getId());
        dto.setResponseCount((int) responseCount);
        
        return dto;
    }

 // Create a new query (Farmers only)
    @PostMapping("")
    @PreAuthorize("hasRole('USER') or hasRole('ROLE_ADMIN')")
    public ResponseEntity<?> createQuery(@Valid @RequestBody CreateQueryRequestDTO request,
                                       @RequestHeader("Authorization") String token) {
        try {
            System.out.println("🔐 Received token for createQuery");
            
            String jwt = token.substring(7);
            String username = jwtUtils.getUserNameFromJwtToken(jwt);
            System.out.println("👤 Extracted username: " + username);
            
            Optional<User> userOpt = userRepository.findByUsername(username);
            if (!userOpt.isPresent()) {
                System.out.println("❌ User not found for username: " + username);
                return ResponseEntity.badRequest()
                    .body(new MessageResponse("Error: User not found!"));
            }

            User farmer = userOpt.get();
            System.out.println("✅ Found user: " + farmer.getUsername() + " with role: " + farmer.getRole());
            
            ExpertQuery query = new ExpertQuery();
            query.setTitle(request.getTitle());
            query.setDescription(request.getDescription());
            query.setCropType(request.getCropType());
            query.setCategory(request.getCategory());
            query.setUrgency(request.getUrgency());
            query.setHasImage(request.getHasImage());
            query.setStatus("pending");
            query.setFarmer(farmer);
         
query.setImagePath(request.getImagePath());
            
            ExpertQuery savedQuery = expertQueryRepository.save(query);
            
            Map<String, Object> response = new HashMap<>();
            response.put("status", "success");
            response.put("message", "Query submitted successfully!");
            response.put("queryId", savedQuery.getId());
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            System.out.println("❌ Error in createQuery: " + e.getMessage());
            e.printStackTrace();
            return ResponseEntity.badRequest()
                .body(new MessageResponse("Error: " + e.getMessage()));
        }
    }
    
    
    
    @PostMapping("/respond")
    @PreAuthorize("hasRole('EXPERT') or hasRole('ADMIN')")
    public ResponseEntity<?> respondToQuery(@Valid @RequestBody RespondToQueryRequestDTO request,
                                          @RequestHeader("Authorization") String token) {
        try {
            System.out.println("📝 Received response submission request");
            System.out.println("📝 Query ID: " + request.getQueryId());
            System.out.println("📝 Response text: " + request.getResponse());
            System.out.println("📝 Status: " + request.getStatus());
            
            String jwt = token.substring(7);
            String username = jwtUtils.getUserNameFromJwtToken(jwt);
            System.out.println("📝 Expert username: " + username);
            
            Optional<User> userOpt = userRepository.findByUsername(username);
            if (!userOpt.isPresent()) {
                System.out.println("❌ Expert user not found: " + username);
                return ResponseEntity.badRequest()
                    .body(new MessageResponse("Error: User not found!"));
            }
            
            User expert = userOpt.get();
            
            // Check if expert is verified
            if (!expert.isVerified() || expert.getVerificationStatus() != User.VerificationStatus.APPROVED) {
                System.out.println("❌ Expert not verified: " + username + " (Status: " + expert.getVerificationStatus() + ")");
                return ResponseEntity.status(403)
                    .body(new MessageResponse("Error: Your expert account is not verified. Please wait for admin approval."));
            }

            Optional<ExpertQuery> queryOpt = expertQueryRepository.findById(request.getQueryId());
            if (!queryOpt.isPresent()) {
                System.out.println("❌ Query not found with ID: " + request.getQueryId());
                return ResponseEntity.badRequest()
                    .body(new MessageResponse("Error: Query not found!"));
            }

            ExpertQuery query = queryOpt.get();
            
            System.out.println("📝 Before update - Response: " + query.getResponse());
            System.out.println("📝 Before update - Status: " + query.getStatus());
            
            query.setResponse(request.getResponse());
            query.setStatus(request.getStatus());
            query.setExpert(expert);
            
            ExpertQuery savedQuery = expertQueryRepository.save(query);
            
            System.out.println("✅ After save - Response: " + savedQuery.getResponse());
            System.out.println("✅ After save - Status: " + savedQuery.getStatus());
            System.out.println("✅ After save - Response Date: " + savedQuery.getResponseDate());
            System.out.println("✅ After save - Expert: " + savedQuery.getExpert().getFullName());
            
            // Create notification for farmer
            notificationService.createQueryResponseNotification(query, expert);
            
            Map<String, Object> response = new HashMap<>();
            response.put("status", "success");
            response.put("message", "Response submitted successfully!");
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            System.out.println("❌ Error in respondToQuery: " + e.getMessage());
            e.printStackTrace();
            return ResponseEntity.badRequest()
                .body(new MessageResponse("Error: " + e.getMessage()));
        }
    }

    // Update query status
    @PutMapping("/status")
    @PreAuthorize("hasRole('EXPERT') or hasRole('ADMIN')")
    public ResponseEntity<?> updateQueryStatus(@RequestBody Map<String, Object> request,
                                             @RequestHeader("Authorization") String token) {
        try {
            Long queryId = Long.valueOf(request.get("queryId").toString());
            String status = request.get("status").toString();
            
            Optional<ExpertQuery> queryOpt = expertQueryRepository.findById(queryId);
            if (!queryOpt.isPresent()) {
                return ResponseEntity.badRequest()
                    .body(new MessageResponse("Error: Query not found!"));
            }

            ExpertQuery query = queryOpt.get();
            String oldStatus = query.getStatus();
            query.setStatus(status);
            
            expertQueryRepository.save(query);
            
            // Create notification for farmer if status changed
            if (!oldStatus.equals(status)) {
                notificationService.createQueryStatusNotification(query, status);
            }
            
            Map<String, Object> response = new HashMap<>();
            response.put("status", "success");
            response.put("message", "Query status updated successfully!");
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                .body(new MessageResponse("Error: " + e.getMessage()));
        }
    }
    
    // Add response to query (multiple experts can respond)
    @PostMapping("/{queryId}/responses")
    @PreAuthorize("hasRole('EXPERT') or hasRole('ADMIN')")
    public ResponseEntity<?> addResponseToQuery(
            @PathVariable Long queryId,
            @Valid @RequestBody AddResponseRequestDTO request,
            @RequestHeader("Authorization") String token) {
        try {
            System.out.println("📝 Adding response to query ID: " + queryId);
            System.out.println("📝 Response text: " + request.getResponse());
            
            String jwt = token.substring(7);
            String username = jwtUtils.getUserNameFromJwtToken(jwt);
            
            Optional<User> expertOpt = userRepository.findByUsername(username);
            if (!expertOpt.isPresent()) {
                return ResponseEntity.badRequest()
                    .body(new MessageResponse("Error: User not found!"));
            }
            
            User expert = expertOpt.get();
            
            // Check if expert is verified
            if (!expert.isVerified() || expert.getVerificationStatus() != User.VerificationStatus.APPROVED) {
                System.out.println("❌ Expert not verified: " + username);
                return ResponseEntity.status(403)
                    .body(new MessageResponse("Error: Your expert account is not verified. Please wait for admin approval."));
            }
            
            // Check if expert already responded
            if (expertResponseRepository.existsByQueryIdAndExpertId(queryId, expert.getId())) {
                return ResponseEntity.badRequest()
                    .body(new MessageResponse("Error: You have already responded to this query. You can edit your existing response."));
            }
            
            Optional<ExpertQuery> queryOpt = expertQueryRepository.findById(queryId);
            if (!queryOpt.isPresent()) {
                return ResponseEntity.badRequest()
                    .body(new MessageResponse("Error: Query not found!"));
            }
            
            ExpertQuery query = queryOpt.get();
            
            // Create new expert response
            ExpertResponse expertResponse = new ExpertResponse(query, expert, request.getResponse());
            expertResponseRepository.save(expertResponse);
            
            // Update query status to answered if it was pending
            if ("pending".equals(query.getStatus())) {
                query.setStatus("answered");
                expertQueryRepository.save(query);
            }
            
            // Create notification for farmer
            notificationService.createQueryResponseNotification(query, expert);
            
            System.out.println("✅ Response added by: " + expert.getFullName());
            
            Map<String, Object> response = new HashMap<>();
            response.put("status", "success");
            response.put("message", "Response submitted successfully!");
            response.put("responseId", expertResponse.getId());
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            System.out.println("❌ Error adding response: " + e.getMessage());
            e.printStackTrace();
            return ResponseEntity.badRequest()
                .body(new MessageResponse("Error: " + e.getMessage()));
        }
    }
    
    // Get all responses for a query
    @GetMapping("/{queryId}/responses")
    public ResponseEntity<?> getQueryResponses(@PathVariable Long queryId) {
        try {
            List<ExpertResponse> responses = expertResponseRepository.findByQueryIdOrderByCreatedAtDesc(queryId);
            
            List<ExpertResponseDTO> responseDTOs = responses.stream()
                .map(ExpertResponseDTO::new)
                .collect(Collectors.toList());
            
            Map<String, Object> response = new HashMap<>();
            response.put("responses", responseDTOs);
            response.put("total", responseDTOs.size());
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                .body(new MessageResponse("Error: " + e.getMessage()));
        }
    }
    
    // Update/Edit an expert's response
    @PutMapping("/responses/{responseId}")
    @PreAuthorize("hasRole('EXPERT') or hasRole('ADMIN')")
    public ResponseEntity<?> updateExpertResponse(
            @PathVariable Long responseId,
            @RequestBody Map<String, String> request,
            @RequestHeader("Authorization") String token) {
        try {
            String jwtToken = token.substring(7);
            String username = jwtUtils.getUserNameFromJwtToken(jwtToken);
            User expert = userRepository.findByUsername(username)
                .orElseThrow(() -> new RuntimeException("Expert not found"));
            
            // Find the response
            Optional<ExpertResponse> responseOpt = expertResponseRepository.findById(responseId);
            if (!responseOpt.isPresent()) {
                return ResponseEntity.badRequest()
                    .body(new MessageResponse("Error: Response not found"));
            }
            
            ExpertResponse expertResponse = responseOpt.get();
            
            // Check if the expert owns this response
            if (!expertResponse.getExpert().getId().equals(expert.getId())) {
                return ResponseEntity.status(HttpStatus.FORBIDDEN)
                    .body(new MessageResponse("Error: You can only edit your own responses"));
            }
            
            // Update the response
            String updatedText = request.get("response");
            if (updatedText == null || updatedText.trim().isEmpty()) {
                return ResponseEntity.badRequest()
                    .body(new MessageResponse("Error: Response text cannot be empty"));
            }
            
            expertResponse.setResponse(updatedText.trim());
            expertResponse.setUpdatedAt(LocalDateTime.now());
            expertResponseRepository.save(expertResponse);
            
            // Return updated response
            ExpertResponseDTO responseDTO = new ExpertResponseDTO(expertResponse);
            
            Map<String, Object> response = new HashMap<>();
            response.put("message", "Response updated successfully");
            response.put("response", responseDTO);
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                .body(new MessageResponse("Error: " + e.getMessage()));
        }
    }
}