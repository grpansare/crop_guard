package com.cropapp.dto;

import com.cropapp.entity.Notification;
import java.time.LocalDateTime;

public class NotificationResponseDTO {
    
    private Long id;
    private String title;
    private String message;
    private String type;
    private boolean isRead;
    private Long relatedId;
    private LocalDateTime createdAt;
    
    public NotificationResponseDTO() {}
    
    public NotificationResponseDTO(Notification notification) {
        this.id = notification.getId();
        this.title = notification.getTitle();
        this.message = notification.getMessage();
        this.type = notification.getType().name();
        this.isRead = notification.isRead();
        this.relatedId = notification.getRelatedId();
        this.createdAt = notification.getCreatedAt();
    }
    
    // Getters and Setters
    public Long getId() {
        return id;
    }
    
    public void setId(Long id) {
        this.id = id;
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
    
    public String getType() {
        return type;
    }
    
    public void setType(String type) {
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
