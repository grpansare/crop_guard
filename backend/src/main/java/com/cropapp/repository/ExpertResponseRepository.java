package com.cropapp.repository;

import com.cropapp.entity.ExpertResponse;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ExpertResponseRepository extends JpaRepository<ExpertResponse, Long> {
    
    // Find all responses for a specific query
    List<ExpertResponse> findByQueryIdOrderByCreatedAtDesc(Long queryId);
    
    // Find all responses by a specific expert
    List<ExpertResponse> findByExpertIdOrderByCreatedAtDesc(Long expertId);
    
    // Count responses for a query
    long countByQueryId(Long queryId);
    
    // Check if expert already responded to a query
    boolean existsByQueryIdAndExpertId(Long queryId, Long expertId);
}
