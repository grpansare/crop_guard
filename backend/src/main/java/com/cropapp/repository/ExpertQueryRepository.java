package com.cropapp.repository;

import com.cropapp.entity.ExpertQuery;
import java.time.LocalDateTime;
import com.cropapp.entity.User;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ExpertQueryRepository extends JpaRepository<ExpertQuery, Long> {
    
    // Find queries by farmer
    Page<ExpertQuery> findByFarmerOrderByCreatedAtDesc(User farmer, Pageable pageable);
    
    // Find queries by farmer and status
    Page<ExpertQuery> findByFarmerAndStatusOrderByCreatedAtDesc(User farmer, String status, Pageable pageable);
    
    // Find all queries for experts (ordered by urgency and creation date)
    @Query("SELECT q FROM ExpertQuery q ORDER BY " +
           "CASE q.urgency " +
           "WHEN 'critical' THEN 1 " +
           "WHEN 'high' THEN 2 " +
           "WHEN 'medium' THEN 3 " +
           "WHEN 'low' THEN 4 " +
           "ELSE 5 END, " +
           "q.createdAt ASC")
    Page<ExpertQuery> findAllOrderByUrgencyAndCreatedAt(Pageable pageable);
    
    // Find queries by status for experts
    @Query("SELECT q FROM ExpertQuery q WHERE q.status = :status ORDER BY " +
           "CASE q.urgency " +
           "WHEN 'critical' THEN 1 " +
           "WHEN 'high' THEN 2 " +
           "WHEN 'medium' THEN 3 " +
           "WHEN 'low' THEN 4 " +
           "ELSE 5 END, " +
           "q.createdAt ASC")
    Page<ExpertQuery> findByStatusOrderByUrgencyAndCreatedAt(@Param("status") String status, Pageable pageable);
    
    // Find queries assigned to a specific expert
    Page<ExpertQuery> findByExpertOrderByCreatedAtDesc(User expert, Pageable pageable);
    
    
    
    // Count queries by farmer
    long countByFarmer(User farmer);
    
    // Count queries by farmer and status
    long countByFarmerAndStatus(User farmer, String status);
    
    // Find recent queries (last 7 days)
    @Query("SELECT q FROM ExpertQuery q WHERE q.createdAt >= :date ORDER BY q.createdAt DESC")
    List<ExpertQuery> findRecentQueries(@Param("date") java.time.LocalDateTime date);

    Page<ExpertQuery> findByUrgencyOrderByCreatedAtDesc(String urgency, Pageable pageable);
    
    
    
    
 // Add these methods to ExpertQueryRepository interface:

    long countByUrgencyAndCreatedAtBetween(String urgency, LocalDateTime startDate, LocalDateTime endDate);

    @Query("SELECT eq.cropType, COUNT(eq) FROM ExpertQuery eq WHERE eq.createdAt BETWEEN :startDate AND :endDate GROUP BY eq.cropType ORDER BY COUNT(eq) DESC")
    List<Object[]> getTopAffectedCrops(@Param("startDate") LocalDateTime startDate, @Param("endDate") LocalDateTime endDate, Pageable pageable);

    @Query("SELECT eq.category, COUNT(eq) FROM ExpertQuery eq WHERE eq.createdAt BETWEEN :startDate AND :endDate GROUP BY eq.category ORDER BY COUNT(eq) DESC")
    List<Object[]> getTopDiseaseCategories(@Param("startDate") LocalDateTime startDate, @Param("endDate") LocalDateTime endDate);

    @Query("SELECT eq.urgency, COUNT(eq) FROM ExpertQuery eq WHERE eq.createdAt BETWEEN :startDate AND :endDate GROUP BY eq.urgency")
    List<Object[]> getUrgencyDistribution(@Param("startDate") LocalDateTime startDate, @Param("endDate") LocalDateTime endDate);

    @Query("SELECT DATE(eq.createdAt) as queryDate, COUNT(eq) as dailyQueries FROM ExpertQuery eq WHERE eq.createdAt BETWEEN :startDate AND :endDate GROUP BY DATE(eq.createdAt) ORDER BY DATE(eq.createdAt)")
    List<Object[]> getDailyQueryCounts(@Param("startDate") LocalDateTime startDate, @Param("endDate") LocalDateTime endDate);

    @Query("SELECT eq.cropType, eq.category, COUNT(eq) FROM ExpertQuery eq WHERE eq.createdAt BETWEEN :startDate AND :endDate AND eq.urgency IN ('high', 'critical') GROUP BY eq.cropType, eq.category ORDER BY COUNT(eq) DESC")
    List<Object[]> getHighPriorityCropDiseases(@Param("startDate") LocalDateTime startDate, @Param("endDate") LocalDateTime endDate);

    @Query("SELECT COUNT(eq) FROM ExpertQuery eq WHERE eq.createdAt BETWEEN :startDate AND :endDate AND eq.status = 'pending'")
    long countPendingQueriesByDateRange(@Param("startDate") LocalDateTime startDate, @Param("endDate") LocalDateTime endDate);

    @Query("SELECT AVG(TIMESTAMPDIFF(HOUR, eq.createdAt, eq.updatedAt)) FROM ExpertQuery eq WHERE eq.createdAt BETWEEN :startDate AND :endDate AND eq.status = 'answered'")
    Double getAverageResponseTimeHours(@Param("startDate") LocalDateTime startDate, @Param("endDate") LocalDateTime endDate);



    // Analytics methods for ExpertAnalyticsController
Long countByExpert(User expert);
Long countByCategory(String category);

Long countByCropType(String cropType);
Long countByCreatedAtAfter(LocalDateTime date);
Long countByExpertAndUpdatedAtAfter(User expert, LocalDateTime date);
Long countByExpertAndUpdatedAtBetween(User expert, LocalDateTime start, LocalDateTime end);
Long countByCreatedAtBetween(LocalDateTime start, LocalDateTime end);

// Additional methods for expert dashboard
List<ExpertQuery> findTop5ByExpertOrderByUpdatedAtDesc(User expert);
long countByStatus(String status);
long countByUrgency(String urgency);
}
