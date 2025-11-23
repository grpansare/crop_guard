package com.cropapp.service;

import com.cropapp.dto.AgriStoreDTO;
import com.cropapp.entity.AgriStore;
import com.cropapp.repository.AgriStoreRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
public class AgriStoreService {
    
    @Autowired
    private AgriStoreRepository agriStoreRepository;
    
    /**
     * Create a new agri store
     */
    public AgriStoreDTO createStore(AgriStoreDTO storeDTO, Long adminId) {
        AgriStore store = new AgriStore();
        store.setName(storeDTO.getName());
        store.setDescription(storeDTO.getDescription());
        store.setAddress(storeDTO.getAddress());
        store.setLatitude(storeDTO.getLatitude());
        store.setLongitude(storeDTO.getLongitude());
        store.setContactNumber(storeDTO.getContactNumber());
        store.setOwnerName(storeDTO.getOwnerName());
        
        if (storeDTO.getStoreType() != null) {
            store.setStoreType(AgriStore.StoreType.valueOf(storeDTO.getStoreType()));
        }
        
        store.setCreatedBy(adminId);
        
        AgriStore savedStore = agriStoreRepository.save(store);
        return new AgriStoreDTO(savedStore);
    }
    
    /**
     * Update an existing agri store
     */
    public AgriStoreDTO updateStore(Long storeId, AgriStoreDTO storeDTO) {
        Optional<AgriStore> storeOpt = agriStoreRepository.findById(storeId);
        
        if (!storeOpt.isPresent()) {
            throw new RuntimeException("Store not found with id: " + storeId);
        }
        
        AgriStore store = storeOpt.get();
        store.setName(storeDTO.getName());
        store.setDescription(storeDTO.getDescription());
        store.setAddress(storeDTO.getAddress());
        store.setLatitude(storeDTO.getLatitude());
        store.setLongitude(storeDTO.getLongitude());
        store.setContactNumber(storeDTO.getContactNumber());
        store.setOwnerName(storeDTO.getOwnerName());
        
        if (storeDTO.getStoreType() != null) {
            store.setStoreType(AgriStore.StoreType.valueOf(storeDTO.getStoreType()));
        }
        
        if (storeDTO.getIsActive() != null) {
            store.setActive(storeDTO.getIsActive());
        }
        
        AgriStore updatedStore = agriStoreRepository.save(store);
        return new AgriStoreDTO(updatedStore);
    }
    
    /**
     * Soft delete a store (set isActive to false)
     */
    public void deleteStore(Long storeId) {
        Optional<AgriStore> storeOpt = agriStoreRepository.findById(storeId);
        
        if (!storeOpt.isPresent()) {
            throw new RuntimeException("Store not found with id: " + storeId);
        }
        
        AgriStore store = storeOpt.get();
        store.setActive(false);
        agriStoreRepository.save(store);
    }
    
    /**
     * Get all stores (admin view)
     */
    public List<AgriStoreDTO> getAllStores() {
        List<AgriStore> stores = agriStoreRepository.findAll();
        return stores.stream()
                .map(AgriStoreDTO::new)
                .collect(Collectors.toList());
    }
    
    /**
     * Get all active stores
     */
    public List<AgriStoreDTO> getActiveStores() {
        List<AgriStore> stores = agriStoreRepository.findByIsActiveTrue();
        return stores.stream()
                .map(AgriStoreDTO::new)
                .collect(Collectors.toList());
    }
    
    /**
     * Get a single store by ID
     */
    public AgriStoreDTO getStoreById(Long storeId) {
        Optional<AgriStore> storeOpt = agriStoreRepository.findById(storeId);
        
        if (!storeOpt.isPresent()) {
            throw new RuntimeException("Store not found with id: " + storeId);
        }
        
        return new AgriStoreDTO(storeOpt.get());
    }
    
    /**
     * Get nearby stores within a radius
     * Uses Haversine formula to calculate distance
     */
    public List<AgriStoreDTO> getNearbyStores(Double latitude, Double longitude, Double radiusKm) {
        List<Object[]> results = agriStoreRepository.findNearbyStores(latitude, longitude, radiusKm);
        List<AgriStoreDTO> nearbyStores = new ArrayList<>();
        
        for (Object[] result : results) {
            AgriStore store = new AgriStore();
            
            // Map the result array to AgriStore object
            // Database returns columns in ALPHABETICAL order with SELECT *:
            // Index 0: id (Long)
            // Index 1: address (String)
            // Index 2: contact_number (String)
            // Index 3: created_at (Timestamp)
            // Index 4: created_by (Long)
            // Index 5: description (String)
            // Index 6: is_active (Boolean)
            // Index 7: latitude (Double)
            // Index 8: longitude (Double)
            // Index 9: name (String)
            // Index 10: owner_name (String)
            // Index 11: store_type (String)
            // Index 12: updated_at (Timestamp)
            // Index 13: distance (Double - calculated)
            
            store.setId(((Number) result[0]).longValue());
            store.setAddress((String) result[1]);
            store.setContactNumber((String) result[2]);
            
            // Handle created_at timestamp
            if (result[3] != null) {
                store.setCreatedAt(((java.sql.Timestamp) result[3]).toLocalDateTime());
            }
            
            // Handle created_by
            if (result[4] != null) {
                store.setCreatedBy(((Number) result[4]).longValue());
            }
            
            store.setDescription((String) result[5]);
            store.setActive((Boolean) result[6]);
            store.setLatitude((Double) result[7]);
            store.setLongitude((Double) result[8]);
            store.setName((String) result[9]);
            store.setOwnerName((String) result[10]);
            
            // Handle store_type
            if (result[11] != null) {
                store.setStoreType(AgriStore.StoreType.valueOf((String) result[11]));
            }
            
            // Handle updated_at timestamp
            if (result[12] != null) {
                store.setUpdatedAt(((java.sql.Timestamp) result[12]).toLocalDateTime());
            }
            
            AgriStoreDTO dto = new AgriStoreDTO(store);
            
            // Set the calculated distance
            if (result[13] != null) {
                Double distance = ((Number) result[13]).doubleValue();
                dto.setDistance(Math.round(distance * 100.0) / 100.0); // Round to 2 decimal places
            }
            
            nearbyStores.add(dto);
        }
        
        return nearbyStores;
    }
    
    /**
     * Get stores by type
     */
    public List<AgriStoreDTO> getStoresByType(String storeType) {
        AgriStore.StoreType type = AgriStore.StoreType.valueOf(storeType);
        List<AgriStore> stores = agriStoreRepository.findByStoreTypeAndIsActiveTrue(type);
        return stores.stream()
                .map(AgriStoreDTO::new)
                .collect(Collectors.toList());
    }
}
