package com.cropapp.repository;

import com.cropapp.entity.User;
import java.time.LocalDateTime;
import com.cropapp.entity.User;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

import java.util.Optional;

@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    
    Optional<User> findByUsername(String username);
    
    Optional<User> findByMobile(String mobile);
    
    boolean existsByUsername(String username);
    
    boolean existsByMobile(String mobile);
    
    
 // Add these methods to UserRepository interface:

    @Query("SELECT u.role, COUNT(u) FROM User u GROUP BY u.role")
    List<Object[]> getUserRoleDistribution();

    @Query("SELECT COUNT(u) FROM User u WHERE u.role = :role AND u.createdAt BETWEEN :startDate AND :endDate")
    long countByRoleAndCreatedAtBetween(@Param("role") User.Role role, @Param("startDate") LocalDateTime startDate, @Param("endDate") LocalDateTime endDate);

    @Query("SELECT u FROM User u WHERE u.role = 'EXPERT' AND u.enabled = true")
    List<User> findActiveExperts();

    @Query("SELECT DATE(u.createdAt) as registrationDate, COUNT(u) as newUsers FROM User u WHERE u.createdAt BETWEEN :startDate AND :endDate GROUP BY DATE(u.createdAt) ORDER BY DATE(u.createdAt)")
    List<Object[]> getDailyUserRegistrations(@Param("startDate") LocalDateTime startDate, @Param("endDate") LocalDateTime endDate);
    
    // Count users by role
    long countByRole(User.Role role);
    
    // Find experts by verification status
    List<User> findByRoleAndVerificationStatus(User.Role role, User.VerificationStatus verificationStatus);
    
    // Find all users by role
    List<User> findByRole(User.Role role);
}
