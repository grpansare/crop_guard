package com.cropapp.controller;

import com.cropapp.dto.MessageResponse;
import com.cropapp.entity.User;
import com.cropapp.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;

import java.util.*;

@CrossOrigin(origins = "*", maxAge = 3600)
@RestController
@RequestMapping("/api/user")
public class UserController {

    @Autowired
    UserRepository userRepository;

    @Autowired
    PasswordEncoder encoder;

    @GetMapping("/settings")
    public ResponseEntity<?> getUserSettings(Authentication authentication) {
        if (authentication == null) {
            return ResponseEntity.badRequest().body(new MessageResponse("User not authenticated"));
        }

        User user = (User) authentication.getPrincipal();
        
        // TODO: Replace with actual user settings from database
        Map<String, Object> settings = new HashMap<>();
        settings.put("notificationsEnabled", true);
        settings.put("diseaseAlertsEnabled", true);
        settings.put("weeklyReportsEnabled", true);
        settings.put("autoSaveScans", true);
        settings.put("highQualityImages", false);
        settings.put("language", "English");
        settings.put("theme", "System");
        settings.put("userId", user.getId());
        
        return ResponseEntity.ok(settings);
    }

    @PutMapping("/settings")
    public ResponseEntity<?> updateUserSettings(@RequestBody Map<String, Object> settingsData, Authentication authentication) {
        if (authentication == null) {
            return ResponseEntity.badRequest().body(new MessageResponse("User not authenticated"));
        }

        User user = (User) authentication.getPrincipal();
        
        // TODO: Save settings to database
        // For now, just return success response
        Map<String, Object> response = new HashMap<>();
        response.put("message", "Settings updated successfully");
        response.put("userId", user.getId());
        response.put("timestamp", new Date().toString());
        
        return ResponseEntity.ok(response);
    }

    @PutMapping("/profile")
    public ResponseEntity<?> updateUserProfile(@RequestBody Map<String, Object> profileData, Authentication authentication) {
        if (authentication == null) {
            return ResponseEntity.badRequest().body(new MessageResponse("User not authenticated"));
        }

        try {
            User user = (User) authentication.getPrincipal();
            
            // Update user profile fields
            if (profileData.containsKey("fullName")) {
                user.setFullName((String) profileData.get("fullName"));
            }
            if (profileData.containsKey("mobile")) {
                String newMobile = (String) profileData.get("mobile");
                // Check if mobile is already in use by another user
                if (userRepository.existsByMobile(newMobile) && !newMobile.equals(user.getMobile())) {
                    return ResponseEntity.badRequest().body(new MessageResponse("Mobile number is already in use"));
                }
                user.setMobile(newMobile);
            }
            
            userRepository.save(user);
            
            Map<String, Object> response = new HashMap<>();
            response.put("message", "Profile updated successfully");
            response.put("user", createUserResponse(user));
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(new MessageResponse("Failed to update profile: " + e.getMessage()));
        }
    }

    @PostMapping("/change-password")
    public ResponseEntity<?> changePassword(@RequestBody Map<String, String> passwordData, Authentication authentication) {
        if (authentication == null) {
            return ResponseEntity.badRequest().body(new MessageResponse("User not authenticated"));
        }

        try {
            User user = (User) authentication.getPrincipal();
            String currentPassword = passwordData.get("currentPassword");
            String newPassword = passwordData.get("newPassword");

            if (currentPassword == null || newPassword == null) {
                return ResponseEntity.badRequest().body(new MessageResponse("Current password and new password are required"));
            }

            // Verify current password
            if (!encoder.matches(currentPassword, user.getPassword())) {
                return ResponseEntity.badRequest().body(new MessageResponse("Current password is incorrect"));
            }

            // Update password
            user.setPassword(encoder.encode(newPassword));
            userRepository.save(user);

            return ResponseEntity.ok(new MessageResponse("Password changed successfully"));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(new MessageResponse("Failed to change password: " + e.getMessage()));
        }
    }

    private Map<String, Object> createUserResponse(User user) {
        Map<String, Object> userResponse = new HashMap<>();
        userResponse.put("id", user.getId());
        userResponse.put("fullName", user.getFullName());
        userResponse.put("mobile", user.getMobile());
        userResponse.put("role", user.getRole());
        return userResponse;
    }
}
