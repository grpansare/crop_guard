package com.cropapp.controller;

import com.cropapp.dto.*;
import com.cropapp.entity.User;
import com.cropapp.repository.UserRepository;
import com.cropapp.security.JwtUtils;
import com.cropapp.service.OtpService;
import com.cropapp.service.EmailService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.File;
import java.io.FileOutputStream;
import java.util.Base64;

@CrossOrigin(origins = "*", maxAge = 3600)
@RestController
@RequestMapping("/api/auth")
public class AuthController {
    private static final Logger logger = LoggerFactory.getLogger(AuthController.class);

    @Autowired
    AuthenticationManager authenticationManager;

    @Autowired
    UserRepository userRepository;

    @Autowired
    PasswordEncoder encoder;

    @Autowired
    EmailService emailService;

    @Autowired
    JwtUtils jwtUtils;
    
    @PostMapping("/signin")
    public ResponseEntity<?> authenticateUser(@Valid @RequestBody LoginRequest loginRequest) {
        try {
            // The authentication manager will use our updated UserDetailsServiceImpl
            // which now supports both username and mobile login
            Authentication authentication = authenticationManager.authenticate(
                    new UsernamePasswordAuthenticationToken(
                            loginRequest.getMobile(), // Using mobile as the username
                            loginRequest.getPassword()
                    )
            );
            
            SecurityContextHolder.getContext().setAuthentication(authentication);
            String jwt = jwtUtils.generateJwtToken(authentication);
            
            User userDetails = (User) authentication.getPrincipal();
            
            // Check verification status for experts
            if (userDetails.getRole() == User.Role.EXPERT) {
                if (userDetails.getVerificationStatus() == User.VerificationStatus.PENDING) {
                    return ResponseEntity
                            .badRequest()
                            .body(new MessageResponse("Error: Your expert account is pending approval. Please wait for admin verification."));
                } else if (userDetails.getVerificationStatus() == User.VerificationStatus.REJECTED) {
                    return ResponseEntity
                            .badRequest()
                            .body(new MessageResponse("Error: Your expert account has been rejected."));
                } else if (userDetails.getVerificationStatus() == User.VerificationStatus.SUSPENDED) {
                    return ResponseEntity
                            .badRequest()
                            .body(new MessageResponse("Error: Your expert account has been suspended."));
                }
            }
            
            return ResponseEntity.ok(new JwtResponse(
                    jwt,
                    userDetails.getId(),
                    userDetails.getUsername(),
                    userDetails.getMobile(),
                    userDetails.getFullName(),
                    userDetails.getRole().name()
            ));
        } catch (Exception e) {
            logger.error("Failed signin attempt for mobile {}: {}", loginRequest.getMobile(), e.getMessage());
            return ResponseEntity
                    .badRequest()
                    .body(new MessageResponse("Error: Invalid mobile number or password"));
        }
    }
    
    @PostMapping("/signup")
    public ResponseEntity<?> registerUser(@Valid @RequestBody SignupRequest signUpRequest) {
        // Auto-generate username from mobile if not provided
        String username = signUpRequest.getUsername();
        if (username == null || username.trim().isEmpty()) {
            // Use mobile as username if not provided
            username = "user_" + signUpRequest.getMobile();
        }
        
        // Check if generated username already exists
        if (userRepository.existsByUsername(username)) {
            return ResponseEntity
                    .badRequest()
                    .body(new MessageResponse("Error: An account with this mobile number already exists!"));
        }
        
        if (userRepository.existsByMobile(signUpRequest.getMobile())) {
            return ResponseEntity
                    .badRequest()
                    .body(new MessageResponse("Error: Mobile number is already in use!"));
        }
        
        // Create new user's account
        User user = new User(username,
                signUpRequest.getMobile(),
                encoder.encode(signUpRequest.getPassword()),
                signUpRequest.getFullName(),
                signUpRequest.getSpecialization());
        
        // set email if provided
        if (signUpRequest.getEmail() != null && !signUpRequest.getEmail().trim().isEmpty()) {
            user.setEmail(signUpRequest.getEmail().trim());
        }
        
        // Process role and set verification status
        if (signUpRequest.getRole() != null && !signUpRequest.getRole().isEmpty()) {
            try {
                User.Role role = User.Role.valueOf(signUpRequest.getRole().toUpperCase());
                user.setRole(role);
                
                // Validate specialization for experts
                if (role == User.Role.EXPERT && (signUpRequest.getSpecialization() == null || signUpRequest.getSpecialization().trim().isEmpty())) {
                    return ResponseEntity
                            .badRequest()
                            .body(new MessageResponse("Error: Specialization is required for experts!"));
                }
                
                // Set verification status for experts
                if (role == User.Role.EXPERT) {
                    user.setVerified(false);
                    user.setVerificationStatus(User.VerificationStatus.PENDING);
                } else {
                    // Non-experts don't need verification
                    user.setSpecialization(null);
                    user.setVerified(true);
                    user.setVerificationStatus(User.VerificationStatus.APPROVED);
                }
                
            } catch (IllegalArgumentException e) {
                // Invalid role provided, default to USER
                user.setRole(User.Role.USER);
                user.setSpecialization(null);
                user.setVerified(true);
                user.setVerificationStatus(User.VerificationStatus.APPROVED);
            }
        } else {
            user.setRole(User.Role.USER);
            user.setSpecialization(null);
            user.setVerified(true);
            user.setVerificationStatus(User.VerificationStatus.APPROVED);
        }
        
        // First save: user without document (to get userId)
        userRepository.save(user);
        
        // If the registered user is an expert, handle document and send notification email
        if (user.getRole() == User.Role.EXPERT) {
            // Decode and save Base64 document if provided
            if (signUpRequest.getVerificationDocument() != null && !signUpRequest.getVerificationDocument().trim().isEmpty()) {
                try {
                    String documentPath = saveVerificationDocument(user.getId(), signUpRequest.getVerificationDocument());
                    user.setVerificationDocument(documentPath);
                    // Second save: update user with document path
                    userRepository.save(user);
                    logger.info("Verification document saved for expert userId={}: {}", user.getId(), documentPath);
                } catch (Exception e) {
                    logger.error("Failed to save verification document for expert userId={}: {}", user.getId(), e.getMessage());
                    // Log but don't fail registration
                }
            }
            
            // Send notification email in background thread (non-blocking)
            String to = user.getEmail();
            if (to != null && !to.trim().isEmpty()) {
                new Thread(() -> {
                    try {
                        emailService.sendExpertPending(to, user.getFullName() == null ? user.getUsername() : user.getFullName());
                    } catch (Exception e) {
                        logger.error("Error sending expert pending email in background thread: {}", e.getMessage());
                    }
                }).start();
            } else {
                logger.info("Expert registered without email: userId={}", user.getId());
            }
        }
        
        return ResponseEntity.ok(new MessageResponse("User registered successfully!"));
    }
    
    /**
     * Decode Base64 document and save it to the uploads directory
     * @param userId User ID to create a unique document path
     * @param base64Document Base64 encoded document string
     * @return Path to the saved document file
     */
    private String saveVerificationDocument(Long userId, String base64Document) throws Exception {
        // Create uploads directory if it doesn't exist
        String uploadDir = "uploads/documents";
        File dir = new File(uploadDir);
        if (!dir.exists()) {
            dir.mkdirs();
        }
        
        // Decode Base64
        byte[] decodedBytes = Base64.getDecoder().decode(base64Document);
        
        // Try to detect file extension from magic bytes (file signature)
        String extension = detectFileExtension(decodedBytes);
        
        // Create unique filename with proper extension
        String filename = "expert_" + userId + "_" + System.currentTimeMillis() + extension;
        File file = new File(uploadDir, filename);
        
        // Write decoded bytes to file
        try (FileOutputStream fos = new FileOutputStream(file)) {
            fos.write(decodedBytes);
        }
        
        logger.info("Document saved successfully: {}", file.getAbsolutePath());
        return uploadDir + "/" + filename;
    }
    
    /**
     * Detect file extension from magic bytes (file signature)
     */
    private String detectFileExtension(byte[] bytes) {
        if (bytes == null || bytes.length < 4) {
            return ".bin"; // Default if too short
        }
        
        // Check JPEG
        if (bytes[0] == (byte) 0xFF && bytes[1] == (byte) 0xD8 && bytes[2] == (byte) 0xFF) {
            return ".jpg";
        }
        
        // Check PNG
        if (bytes[0] == (byte) 0x89 && bytes[1] == 0x50 && bytes[2] == 0x4E && bytes[3] == 0x47) {
            return ".png";
        }
        
        // Check GIF
        if (bytes[0] == 0x47 && bytes[1] == 0x49 && bytes[2] == 0x46) {
            return ".gif";
        }
        
        // Check PDF
        if (bytes[0] == 0x25 && bytes[1] == 0x50 && bytes[2] == 0x44 && bytes[3] == 0x46) {
            return ".pdf";
        }
        
        // Check DOCX / XLSX (ZIP magic bytes)
        if (bytes[0] == 0x50 && bytes[1] == 0x4B && bytes[2] == 0x03 && bytes[3] == 0x04) {
            return ".docx";
        }
        
        // Default to binary if unknown
        return ".bin";
    }
    
    
    @GetMapping("/profile")
    public ResponseEntity<?> getUserProfile(Authentication authentication) {
        if (authentication == null) {
            return ResponseEntity.badRequest().body(new MessageResponse("User not authenticated"));
        }
        User user = (User) authentication.getPrincipal();
        return ResponseEntity.ok(new JwtResponse(null,
                user.getId(),
                user.getUsername(),
                user.getMobile(),
                user.getFullName(),
                user.getRole().name()));
    }
}
