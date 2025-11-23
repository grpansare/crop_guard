package com.cropapp.controller;

import com.cropapp.dto.AgriStoreDTO;
import com.cropapp.dto.MessageResponse;
import com.cropapp.entity.User;
import com.cropapp.repository.UserRepository;
import com.cropapp.security.JwtUtils;
import com.cropapp.service.AgriStoreService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api")
@CrossOrigin(origins = "*", maxAge = 3600)
public class AgriStoreController {
    
    @Autowired
    private AgriStoreService agriStoreService;
    
    @Autowired
    private JwtUtils jwtUtils;
    
    @Autowired
    private UserRepository userRepository;
    
    // ==================== ADMIN ENDPOINTS ====================
    
    /**
     * Create a new agri store (Admin only)
     */
    @PostMapping("/admin/agri-stores")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<?> createStore(
            @Valid @RequestBody AgriStoreDTO storeDTO,
            @RequestHeader("Authorization") String token) {
        try {
            String jwt = token.substring(7);
            String username = jwtUtils.getUserNameFromJwtToken(jwt);
            
            Optional<User> adminOpt = userRepository.findByUsername(username);
            if (!adminOpt.isPresent()) {
                return ResponseEntity.badRequest()
                        .body(new MessageResponse("Error: Admin not found!"));
            }
            
            Long adminId = adminOpt.get().getId();
            AgriStoreDTO createdStore = agriStoreService.createStore(storeDTO, adminId);
            
            Map<String, Object> response = new HashMap<>();
            response.put("status", "success");
            response.put("message", "Agri store created successfully!");
            response.put("store", createdStore);
            
            System.out.println("✅ Agri store created: " + createdStore.getName() + " by admin: " + username);
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            System.err.println("Error creating agri store: " + e.getMessage());
            return ResponseEntity.badRequest()
                    .body(new MessageResponse("Error: " + e.getMessage()));
        }
    }
    
    /**
     * Update an existing agri store (Admin only)
     */
    @PutMapping("/admin/agri-stores/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<?> updateStore(
            @PathVariable Long id,
            @Valid @RequestBody AgriStoreDTO storeDTO,
            @RequestHeader("Authorization") String token) {
        try {
            AgriStoreDTO updatedStore = agriStoreService.updateStore(id, storeDTO);
            
            Map<String, Object> response = new HashMap<>();
            response.put("status", "success");
            response.put("message", "Agri store updated successfully!");
            response.put("store", updatedStore);
            
            System.out.println("✅ Agri store updated: " + updatedStore.getName());
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            System.err.println("Error updating agri store: " + e.getMessage());
            return ResponseEntity.badRequest()
                    .body(new MessageResponse("Error: " + e.getMessage()));
        }
    }
    
    /**
     * Delete an agri store (Admin only) - Soft delete
     */
    @DeleteMapping("/admin/agri-stores/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<?> deleteStore(
            @PathVariable Long id,
            @RequestHeader("Authorization") String token) {
        try {
            agriStoreService.deleteStore(id);
            
            Map<String, Object> response = new HashMap<>();
            response.put("status", "success");
            response.put("message", "Agri store deleted successfully!");
            
            System.out.println("✅ Agri store deleted: ID " + id);
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            System.err.println("Error deleting agri store: " + e.getMessage());
            return ResponseEntity.badRequest()
                    .body(new MessageResponse("Error: " + e.getMessage()));
        }
    }
    
    /**
     * Get all agri stores (Admin only) - includes inactive stores
     */
    @GetMapping("/admin/agri-stores")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<?> getAllStores(@RequestHeader("Authorization") String token) {
        try {
            List<AgriStoreDTO> stores = agriStoreService.getAllStores();
            
            Map<String, Object> response = new HashMap<>();
            response.put("stores", stores);
            response.put("total", stores.size());
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            System.err.println("Error fetching agri stores: " + e.getMessage());
            return ResponseEntity.badRequest()
                    .body(new MessageResponse("Error: " + e.getMessage()));
        }
    }
    
    // ==================== FARMER/PUBLIC ENDPOINTS ====================
    
    /**
     * Get nearby agri stores within a radius
     * Accessible to all authenticated users
     */
    @GetMapping("/agri-stores/nearby")
    @PreAuthorize("hasAnyRole('USER', 'EXPERT', 'ADMIN')")
    public ResponseEntity<?> getNearbyStores(
            @RequestParam Double lat,
            @RequestParam Double lng,
            @RequestParam(defaultValue = "10.0") Double radius,
            @RequestHeader("Authorization") String token) {
        try {
            // Validate coordinates
            if (lat < -90 || lat > 90) {
                return ResponseEntity.badRequest()
                        .body(new MessageResponse("Error: Invalid latitude. Must be between -90 and 90."));
            }
            if (lng < -180 || lng > 180) {
                return ResponseEntity.badRequest()
                        .body(new MessageResponse("Error: Invalid longitude. Must be between -180 and 180."));
            }
            if (radius <= 0 || radius > 100) {
                return ResponseEntity.badRequest()
                        .body(new MessageResponse("Error: Invalid radius. Must be between 0 and 100 km."));
            }
            
            List<AgriStoreDTO> nearbyStores = agriStoreService.getNearbyStores(lat, lng, radius);
            
            Map<String, Object> response = new HashMap<>();
            response.put("stores", nearbyStores);
            response.put("total", nearbyStores.size());
            response.put("searchLocation", Map.of("latitude", lat, "longitude", lng));
            response.put("radiusKm", radius);
            
            System.out.println("📍 Found " + nearbyStores.size() + " stores within " + radius + "km of (" + lat + ", " + lng + ")");
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            System.err.println("Error fetching nearby stores: " + e.getMessage());
            return ResponseEntity.badRequest()
                    .body(new MessageResponse("Error: " + e.getMessage()));
        }
    }
    
    /**
     * Get a single agri store by ID
     * Accessible to all authenticated users
     */
    @GetMapping("/agri-stores/{id}")
    @PreAuthorize("hasAnyRole('USER', 'EXPERT', 'ADMIN')")
    public ResponseEntity<?> getStoreById(
            @PathVariable Long id,
            @RequestHeader("Authorization") String token) {
        try {
            AgriStoreDTO store = agriStoreService.getStoreById(id);
            return ResponseEntity.ok(store);
        } catch (Exception e) {
            System.err.println("Error fetching agri store: " + e.getMessage());
            return ResponseEntity.badRequest()
                    .body(new MessageResponse("Error: " + e.getMessage()));
        }
    }
    
    /**
     * Get all active agri stores
     * Accessible to all authenticated users
     */
    @GetMapping("/agri-stores")
    @PreAuthorize("hasAnyRole('USER', 'EXPERT', 'ADMIN')")
    public ResponseEntity<?> getActiveStores(@RequestHeader("Authorization") String token) {
        try {
            List<AgriStoreDTO> stores = agriStoreService.getActiveStores();
            
            Map<String, Object> response = new HashMap<>();
            response.put("stores", stores);
            response.put("total", stores.size());
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            System.err.println("Error fetching active stores: " + e.getMessage());
            return ResponseEntity.badRequest()
                    .body(new MessageResponse("Error: " + e.getMessage()));
        }
    }
    
    /**
     * Get agri stores by type
     * Accessible to all authenticated users
     */
    @GetMapping("/agri-stores/type/{storeType}")
    @PreAuthorize("hasAnyRole('USER', 'EXPERT', 'ADMIN')")
    public ResponseEntity<?> getStoresByType(
            @PathVariable String storeType,
            @RequestHeader("Authorization") String token) {
        try {
            List<AgriStoreDTO> stores = agriStoreService.getStoresByType(storeType.toUpperCase());
            
            Map<String, Object> response = new HashMap<>();
            response.put("stores", stores);
            response.put("total", stores.size());
            response.put("storeType", storeType.toUpperCase());
            
            return ResponseEntity.ok(response);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest()
                    .body(new MessageResponse("Error: Invalid store type. Valid types: SEEDS, FERTILIZERS, PESTICIDES, EQUIPMENT, GENERAL"));
        } catch (Exception e) {
            System.err.println("Error fetching stores by type: " + e.getMessage());
            return ResponseEntity.badRequest()
                    .body(new MessageResponse("Error: " + e.getMessage()));
        }
    }
}
