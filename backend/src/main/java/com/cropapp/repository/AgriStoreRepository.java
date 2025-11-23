package com.cropapp.repository;

import com.cropapp.entity.AgriStore;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface AgriStoreRepository extends JpaRepository<AgriStore, Long> {
    
    /**
     * Find all active stores
     */
    List<AgriStore> findByIsActiveTrue();
    
    /**
     * Find stores by type
     */
    List<AgriStore> findByStoreTypeAndIsActiveTrue(AgriStore.StoreType storeType);
    
    /**
     * Find nearby stores using Haversine formula
     * Returns stores within the specified radius (in kilometers)
     * 
     * Haversine formula:
     * a = sin²(Δφ/2) + cos φ1 ⋅ cos φ2 ⋅ sin²(Δλ/2)
     * c = 2 ⋅ atan2( √a, √(1−a) )
     * d = R ⋅ c
     * 
     * where φ is latitude, λ is longitude, R is earth's radius (6371 km)
     */
    @Query(value = "SELECT *, " +
            "(6371 * acos(cos(radians(:latitude)) * cos(radians(latitude)) * " +
            "cos(radians(longitude) - radians(:longitude)) + " +
            "sin(radians(:latitude)) * sin(radians(latitude)))) AS distance " +
            "FROM agri_stores " +
            "WHERE is_active = true " +
            "HAVING distance <= :radiusKm " +
            "ORDER BY distance", 
            nativeQuery = true)
    List<Object[]> findNearbyStores(
            @Param("latitude") Double latitude,
            @Param("longitude") Double longitude,
            @Param("radiusKm") Double radiusKm
    );
    
    /**
     * Find stores created by a specific admin
     */
    List<AgriStore> findByCreatedBy(Long adminId);
}
