package com.cropapp.repository;

import com.cropapp.entity.OtpEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.Optional;

@Repository
public interface OtpRepository extends JpaRepository<OtpEntity, Long> {
    
    Optional<OtpEntity> findByMobileAndVerifiedFalseOrderByCreatedAtDesc(String mobile);
    
    @Query("SELECT o FROM OtpEntity o WHERE o.mobile = :mobile AND o.verified = false AND o.expiresAt > :now ORDER BY o.createdAt DESC")
    Optional<OtpEntity> findValidOtpByMobile(@Param("mobile") String mobile, @Param("now") LocalDateTime now);
    
    @Modifying
    @Transactional
    @Query("DELETE FROM OtpEntity o WHERE o.expiresAt < :now")
    void deleteExpiredOtps(@Param("now") LocalDateTime now);
    
    @Modifying
    @Transactional
    @Query("UPDATE OtpEntity o SET o.verified = true WHERE o.mobile = :mobile AND o.otp = :otp")
    void markOtpAsVerified(@Param("mobile") String mobile, @Param("otp") String otp);
}
