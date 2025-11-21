package com.cropapp.dto;

import java.util.List;

public class NotificationListResponseDTO {
    
    private List<NotificationResponseDTO> notifications;
    private long totalElements;
    private int totalPages;
    private int currentPage;
    private int size;
    private long unreadCount;
    
    public NotificationListResponseDTO() {}
    
    public NotificationListResponseDTO(List<NotificationResponseDTO> notifications, 
                                     long totalElements, 
                                     int totalPages, 
                                     int currentPage, 
                                     int size,
                                     long unreadCount) {
        this.notifications = notifications;
        this.totalElements = totalElements;
        this.totalPages = totalPages;
        this.currentPage = currentPage;
        this.size = size;
        this.unreadCount = unreadCount;
    }
    
    // Getters and Setters
    public List<NotificationResponseDTO> getNotifications() {
        return notifications;
    }
    
    public void setNotifications(List<NotificationResponseDTO> notifications) {
        this.notifications = notifications;
    }
    
    public long getTotalElements() {
        return totalElements;
    }
    
    public void setTotalElements(long totalElements) {
        this.totalElements = totalElements;
    }
    
    public int getTotalPages() {
        return totalPages;
    }
    
    public void setTotalPages(int totalPages) {
        this.totalPages = totalPages;
    }
    
    public int getCurrentPage() {
        return currentPage;
    }
    
    public void setCurrentPage(int currentPage) {
        this.currentPage = currentPage;
    }
    
    public int getSize() {
        return size;
    }
    
    public void setSize(int size) {
        this.size = size;
    }
    
    public long getUnreadCount() {
        return unreadCount;
    }
    
    public void setUnreadCount(long unreadCount) {
        this.unreadCount = unreadCount;
    }
}
