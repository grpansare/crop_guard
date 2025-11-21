package com.cropapp.repository;

import com.cropapp.entity.Report;
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
public interface ReportRepository extends JpaRepository<Report, Long> {
    
    // Find all reports for a specific user, ordered by generation date (newest first)
    List<Report> findByUserOrderByGeneratedAtDesc(User user);
    
    // Find reports for a user with pagination
    Page<Report> findByUserOrderByGeneratedAtDesc(User user, Pageable pageable);
    
    // Find reports by user and type
    List<Report> findByUserAndTypeOrderByGeneratedAtDesc(User user, String type);
    
    // Find reports by user and status
    List<Report> findByUserAndStatusOrderByGeneratedAtDesc(User user, String status);
    
    // Find reports by user within a date range
    List<Report> findByUserAndGeneratedAtBetweenOrderByGeneratedAtDesc(User user, LocalDateTime startDate, LocalDateTime endDate);
    
    // Count total reports for a user
    long countByUser(User user);
    
    // Count reports by status for a user
    long countByUserAndStatus(User user, String status);
    
    // Find recent reports for a user
    List<Report> findTop5ByUserOrderByGeneratedAtDesc(User user);
    
    // Find reports by period
    List<Report> findByUserAndPeriodStartBetweenOrderByGeneratedAtDesc(User user, LocalDateTime startDate, LocalDateTime endDate);
    
    // Custom query to get report statistics
    @Query("SELECT " +
           "COUNT(r) as totalReports, " +
           "COUNT(CASE WHEN r.status = 'Completed' THEN 1 END) as completedReports, " +
           "COUNT(CASE WHEN r.status = 'Generated' THEN 1 END) as generatedReports " +
           "FROM Report r WHERE r.user = :user")
    Object[] getReportStatisticsByUser(@Param("user") User user);
    
    // Find reports with critical issues
    @Query("SELECT r FROM Report r WHERE r.user = :user AND r.criticalIssues > 0 ORDER BY r.criticalIssues DESC, r.generatedAt DESC")
    List<Report> findReportsWithCriticalIssues(@Param("user") User user);
    
    // Get monthly report count for trends
    @Query("SELECT YEAR(r.generatedAt), MONTH(r.generatedAt), COUNT(r) " +
           "FROM Report r WHERE r.user = :user " +
           "GROUP BY YEAR(r.generatedAt), MONTH(r.generatedAt) " +
           "ORDER BY YEAR(r.generatedAt) DESC, MONTH(r.generatedAt) DESC")
    List<Object[]> getMonthlyReportCounts(@Param("user") User user);
}
