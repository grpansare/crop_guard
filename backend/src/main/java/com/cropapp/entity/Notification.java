package com.cropapp.entity;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "notifications")
public class Notification {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;
    
    @Column(nullable = false)
    private String title;
    
    @Column(columnDefinition = "TEXT")
    private String message;
    
    @Enumerated(EnumType.STRING)
    private NotificationType type;
    
    @Column(name = "is_read")
    private boolean isRead = false;
    
    @Column(name = "related_id")
    private Long relatedId; // ID of related entity (e.g., query ID)
    
    @Column(name = "created_at")
    private LocalDateTime createdAt;
    
    public enum NotificationType {
        QUERY_RESPONSE, QUERY_STATUS_UPDATE, SYSTEM_NOTIFICATION
    }
    
    // Constructors
    public Notification() {
        this.createdAt = LocalDateTime.now();
    }
    
    public Notification(User user, String title, String message, NotificationType type) {
        this();
        this.user = user;
        this.title = title;
        this.message = message;
        this.type = type;
    }
    
    public Notification(User user, String title, String message, NotificationType type, Long relatedId) {
        this(user, title, message, type);
        this.relatedId = relatedId;
    }
    
    // Getters and Setters
    public Long getId() {
        return id;
    }
    
    public void setId(Long id) {
        this.id = id;
    }
    
    public User getUser() {
        return user;
    }
    
    public void setUser(User user) {
        this.user = user;
    }
    
    public String getTitle() {
        return title;
    }
    
    public void setTitle(String title) {
        this.title = title;
    }
    
    public String getMessage() {
        return message;
    }
    
    public void setMessage(String message) {
        this.message = message;
    }
    
    public NotificationType getType() {
        return type;
    }
    
    public void setType(NotificationType type) {
        this.type = type;
    }
    
    public boolean isRead() {
        return isRead;
    }
    
    public void setRead(boolean read) {
        isRead = read;
    }
    
    public Long getRelatedId() {
        return relatedId;
    }
    
    public void setRelatedId(Long relatedId) {
        this.relatedId = relatedId;
    }
    
    public LocalDateTime getCreatedAt() {
        return createdAt;
    }
    
    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }
}
