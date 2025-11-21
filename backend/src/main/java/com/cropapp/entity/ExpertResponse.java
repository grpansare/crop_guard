package com.cropapp.entity;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "expert_responses")
public class ExpertResponse {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "query_id", nullable = false)
    private ExpertQuery query;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "expert_id", nullable = false)
    private User expert;
    
    @Column(columnDefinition = "TEXT", nullable = false)
    private String response;
    
    @Column(name = "created_at")
    private LocalDateTime createdAt;
    
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;
    
    // Constructors
    public ExpertResponse() {
        this.createdAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
    }
    
    public ExpertResponse(ExpertQuery query, User expert, String response) {
        this();
        this.query = query;
        this.expert = expert;
        this.response = response;
    }
    
    // Getters and Setters
    public Long getId() {
        return id;
    }
    
    public void setId(Long id) {
        this.id = id;
    }
    
    public ExpertQuery getQuery() {
        return query;
    }
    
    public void setQuery(ExpertQuery query) {
        this.query = query;
    }
    
    public User getExpert() {
        return expert;
    }
    
    public void setExpert(User expert) {
        this.expert = expert;
    }
    
    public String getResponse() {
        return response;
    }
    
    public void setResponse(String response) {
        this.response = response;
        this.updatedAt = LocalDateTime.now();
    }
    
    public LocalDateTime getCreatedAt() {
        return createdAt;
    }
    
    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }
    
    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }
    
    public void setUpdatedAt(LocalDateTime updatedAt) {
        this.updatedAt = updatedAt;
    }
    
    @PreUpdate
    public void preUpdate() {
        this.updatedAt = LocalDateTime.now();
    }
}
