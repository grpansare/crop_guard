package com.cropapp.controller;

import com.cropapp.dto.MessageResponse;
import com.cropapp.dto.NotificationListResponseDTO;
import com.cropapp.dto.NotificationResponseDTO;
import com.cropapp.entity.Notification;
import com.cropapp.entity.User;
import com.cropapp.repository.UserRepository;
import com.cropapp.security.JwtUtils;
import com.cropapp.service.NotificationService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/notifications")
@CrossOrigin(origins = "*", maxAge = 3600)
public class NotificationController {
    
    @Autowired
    private NotificationService notificationService;
    
    @Autowired
    private UserRepository userRepository;
    
    @Autowired
    private JwtUtils jwtUtils;
    
    // Get user's notifications
    @GetMapping("")
    @PreAuthorize("hasRole('USER') or hasRole('EXPERT') or hasRole('ADMIN')")
    public ResponseEntity<?> getNotifications(@RequestHeader("Authorization") String token,
                                            @RequestParam(defaultValue = "0") int page,
                                            @RequestParam(defaultValue = "20") int size,
                                            @RequestParam(defaultValue = "false") boolean unreadOnly) {
        try {
            String jwt = token.substring(7);
            String username = jwtUtils.getUserNameFromJwtToken(jwt);
            
            Optional<User> userOpt = userRepository.findByUsername(username);
            if (!userOpt.isPresent()) {
                return ResponseEntity.badRequest()
                    .body(new MessageResponse("Error: User not found!"));
            }
            
            User user = userOpt.get();
            Pageable pageable = PageRequest.of(page, size);
            Page<Notification> notificationPage;
            
            if (unreadOnly) {
                notificationPage = notificationService.getUnreadNotifications(user, pageable);
            } else {
                notificationPage = notificationService.getUserNotifications(user, pageable);
            }
            
            List<NotificationResponseDTO> notificationDTOs = notificationPage.getContent().stream()
                .map(NotificationResponseDTO::new)
                .collect(Collectors.toList());
            
            long unreadCount = notificationService.getUnreadCount(user);
            
            NotificationListResponseDTO response = new NotificationListResponseDTO(
                notificationDTOs,
                notificationPage.getTotalElements(),
                notificationPage.getTotalPages(),
                notificationPage.getNumber(),
                notificationPage.getSize(),
                unreadCount
            );
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                .body(new MessageResponse("Error: " + e.getMessage()));
        }
    }
    
    // Get unread notification count
    @GetMapping("/count")
    @PreAuthorize("hasRole('USER') or hasRole('EXPERT') or hasRole('ADMIN')")
    public ResponseEntity<?> getUnreadCount(@RequestHeader("Authorization") String token) {
        try {
            String jwt = token.substring(7);
            String username = jwtUtils.getUserNameFromJwtToken(jwt);
            
            Optional<User> userOpt = userRepository.findByUsername(username);
            if (!userOpt.isPresent()) {
                return ResponseEntity.badRequest()
                    .body(new MessageResponse("Error: User not found!"));
            }
            
            User user = userOpt.get();
            long unreadCount = notificationService.getUnreadCount(user);
            
            Map<String, Object> response = new HashMap<>();
            response.put("unreadCount", unreadCount);
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                .body(new MessageResponse("Error: " + e.getMessage()));
        }
    }
    
    // Mark notification as read
    @PutMapping("/{notificationId}/read")
    @PreAuthorize("hasRole('USER') or hasRole('EXPERT') or hasRole('ADMIN')")
    public ResponseEntity<?> markAsRead(@PathVariable Long notificationId,
                                      @RequestHeader("Authorization") String token) {
        try {
            String jwt = token.substring(7);
            String username = jwtUtils.getUserNameFromJwtToken(jwt);
            
            Optional<User> userOpt = userRepository.findByUsername(username);
            if (!userOpt.isPresent()) {
                return ResponseEntity.badRequest()
                    .body(new MessageResponse("Error: User not found!"));
            }
            
            User user = userOpt.get();
            notificationService.markAsRead(notificationId, user);
            
            Map<String, Object> response = new HashMap<>();
            response.put("status", "success");
            response.put("message", "Notification marked as read");
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                .body(new MessageResponse("Error: " + e.getMessage()));
        }
    }
    
    // Mark all notifications as read
    @PutMapping("/read-all")
    @PreAuthorize("hasRole('USER') or hasRole('EXPERT') or hasRole('ADMIN')")
    public ResponseEntity<?> markAllAsRead(@RequestHeader("Authorization") String token) {
        try {
            String jwt = token.substring(7);
            String username = jwtUtils.getUserNameFromJwtToken(jwt);
            
            Optional<User> userOpt = userRepository.findByUsername(username);
            if (!userOpt.isPresent()) {
                return ResponseEntity.badRequest()
                    .body(new MessageResponse("Error: User not found!"));
            }
            
            User user = userOpt.get();
            notificationService.markAllAsRead(user);
            
            Map<String, Object> response = new HashMap<>();
            response.put("status", "success");
            response.put("message", "All notifications marked as read");
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                .body(new MessageResponse("Error: " + e.getMessage()));
        }
    }
}
