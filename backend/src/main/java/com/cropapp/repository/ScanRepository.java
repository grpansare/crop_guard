package com.cropapp.repository;

import com.cropapp.entity.Scan;
import com.cropapp.entity.User;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Repository
public interface ScanRepository extends JpaRepository<Scan, Long> {
    
    // Find all scans for a specific user, ordered by creation date (newest first)
    List<Scan> findByUserOrderByCreatedAtDesc(User user);
    
    // Find scans for a user with pagination
    Page<Scan> findByUserOrderByCreatedAtDesc(User user, Pageable pageable);
    
    // Find scans by user and disease type
    List<Scan> findByUserAndDiseaseOrderByCreatedAtDesc(User user, String disease);
    
    // Find scans by user and plant type
    List<Scan> findByUserAndPlantTypeOrderByCreatedAtDesc(User user, String plantType);
    
    // Find scans by user within a date range
    List<Scan> findByUserAndCreatedAtBetweenOrderByCreatedAtDesc(User user, LocalDateTime startDate, LocalDateTime endDate);
    
    // Count total scans for a user
    long countByUser(User user);
    
    // Count scans with diseases detected for a user
    @Query("SELECT COUNT(s) FROM Scan s WHERE s.user = :user AND s.disease != 'Healthy'")
    long countDiseasesDetectedByUser(@Param("user") User user);
    
    // Count healthy scans for a user
    @Query("SELECT COUNT(s) FROM Scan s WHERE s.user = :user AND s.disease = 'Healthy'")
    long countHealthyScansByUser(@Param("user") User user);
    
    // Find most common disease for a user
    @Query("SELECT s.disease, COUNT(s) as count FROM Scan s WHERE s.user = :user AND s.disease != 'Healthy' GROUP BY s.disease ORDER BY count DESC")
    List<Object[]> findMostCommonDiseaseByUser(@Param("user") User user);
    
    // Find recent scans for activity feed
    List<Scan> findTop10ByUserOrderByCreatedAtDesc(User user);
    
    // Find scans by status
    List<Scan> findByUserAndStatusOrderByCreatedAtDesc(User user, String status);
    // Count scans by user and status
long countByUserAndStatus(User user, String status);
    // Custom query to get scan statistics
    @Query("SELECT " +
           "COUNT(s) as totalScans, " +
           "COUNT(CASE WHEN s.disease != 'Healthy' THEN 1 END) as diseasesDetected, " +
           "COUNT(CASE WHEN s.disease = 'Healthy' THEN 1 END) as healthyPlants " +
           "FROM Scan s WHERE s.user = :user")
    Object[] getScanStatisticsByUser(@Param("user") User user);
    
    
    
    
    
    
    






//Add these methods to ScanRepository interface:

@Query("SELECT COUNT(s) FROM Scan s WHERE s.createdAt BETWEEN :startDate AND :endDate")
long countByCreatedAtBetween(@Param("startDate") LocalDateTime startDate, @Param("endDate") LocalDateTime endDate);

@Query("SELECT s.disease, COUNT(s) FROM Scan s WHERE s.createdAt BETWEEN :startDate AND :endDate GROUP BY s.disease")
List<Object[]> getDiseaseDistributionByDateRange(@Param("startDate") LocalDateTime startDate, @Param("endDate") LocalDateTime endDate);

@Query("SELECT MONTHNAME(s.createdAt) as month, COUNT(s) as scans, COUNT(CASE WHEN s.disease IS NOT NULL AND s.disease != 'Healthy' THEN 1 END) as diseases FROM Scan s WHERE s.createdAt BETWEEN :startDate AND :endDate GROUP BY MONTH(s.createdAt), MONTHNAME(s.createdAt) ORDER BY MONTH(s.createdAt)")
List<Object[]> getMonthlyScansCount(@Param("startDate") LocalDateTime startDate, @Param("endDate") LocalDateTime endDate);

@Query("SELECT s.disease, COUNT(s), AVG(s.confidence) FROM Scan s WHERE s.createdAt BETWEEN :startDate AND :endDate AND s.disease IS NOT NULL AND s.disease != 'Healthy' GROUP BY s.disease ORDER BY COUNT(s) DESC")
List<Object[]> getDiseaseStatsWithConfidence(@Param("startDate") LocalDateTime startDate, @Param("endDate") LocalDateTime endDate);

@Query("SELECT s.user.username, s.disease, COUNT(s) FROM Scan s WHERE s.createdAt BETWEEN :startDate AND :endDate AND s.disease = :disease GROUP BY s.user.username, s.disease")
List<Object[]> getDiseaseLocationDistribution(@Param("startDate") LocalDateTime startDate, @Param("endDate") LocalDateTime endDate, @Param("disease") String disease);

@Query("SELECT DATE(s.createdAt) as scanDate, COUNT(s) as dailyCount FROM Scan s WHERE s.createdAt BETWEEN :startDate AND :endDate AND s.disease = :disease GROUP BY DATE(s.createdAt) ORDER BY DATE(s.createdAt)")
List<Object[]> getDailyDiseaseCount(@Param("startDate") LocalDateTime startDate, @Param("endDate") LocalDateTime endDate, @Param("disease") String disease);

@Query("SELECT s.disease, COUNT(s) as currentCount FROM Scan s WHERE s.createdAt BETWEEN :startDate AND :endDate AND s.disease IS NOT NULL GROUP BY s.disease")
List<Object[]> getCurrentPeriodDiseaseCounts(@Param("startDate") LocalDateTime startDate, @Param("endDate") LocalDateTime endDate);

// Simplified accuracy rate based on confidence scores (since expert validation fields don't exist)
@Query("SELECT AVG(s.confidence) FROM Scan s WHERE s.createdAt BETWEEN :startDate AND :endDate AND s.confidence IS NOT NULL")
Double getAccuracyRateByDateRange(@Param("startDate") LocalDateTime startDate, @Param("endDate") LocalDateTime endDate);

// System-wide methods for expert analytics
long countByDiseaseNot(String disease);
long countByDisease(String disease);
long countByStatus(String status);

// Find recent scans across all users
List<Scan> findTop50ByOrderByCreatedAtDesc();

// Find most common disease across all users
@Query("SELECT s.disease, COUNT(s) as count FROM Scan s WHERE s.disease != 'Healthy' GROUP BY s.disease ORDER BY count DESC")
List<Object[]> findMostCommonDiseaseSystemWide();

// System-wide count methods for expert dashboard
@Query("SELECT COUNT(s) FROM Scan s WHERE s.disease != 'Healthy'")
long countDiseasesDetected();

@Query("SELECT COUNT(s) FROM Scan s WHERE s.disease = 'Healthy'")
long countHealthyScans();
}
