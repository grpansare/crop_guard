package com.cropapp.service;

import com.cropapp.entity.ExpertQuery;
import com.cropapp.entity.Notification;
import com.cropapp.entity.User;
import com.cropapp.repository.NotificationRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;

@Service
@Transactional
public class NotificationService {
    
    @Autowired
    private NotificationRepository notificationRepository;
    
    /**
     * Create notification when expert responds to farmer's query
     */
    public void createQueryResponseNotification(ExpertQuery query, User expert) {
        String title = "Expert Response Received";
        String message = String.format("Expert %s has responded to your query: \"%s\"", 
                                     expert.getFullName() != null ? expert.getFullName() : expert.getUsername(),
                                     query.getTitle());
        
        Notification notification = new Notification(
            query.getFarmer(),
            title,
            message,
            Notification.NotificationType.QUERY_RESPONSE,
            query.getId()
        );
        
        notificationRepository.save(notification);
    }
    
    /**
     * Create notification when query status changes
     */
    public void createQueryStatusNotification(ExpertQuery query, String newStatus) {
        String title = "Query Status Updated";
        String message = String.format("Your query \"%s\" status has been updated to: %s", 
                                     query.getTitle(), 
                                     newStatus.replace("_", " ").toUpperCase());
        
        Notification notification = new Notification(
            query.getFarmer(),
            title,
            message,
            Notification.NotificationType.QUERY_STATUS_UPDATE,
            query.getId()
        );
        
        notificationRepository.save(notification);
    }
    
    /**
     * Create system notification
     */
    public void createSystemNotification(User user, String title, String message) {
        Notification notification = new Notification(
            user,
            title,
            message,
            Notification.NotificationType.SYSTEM_NOTIFICATION
        );
        
        notificationRepository.save(notification);
    }
    
    /**
     * Get notifications for a user
     */
    public Page<Notification> getUserNotifications(User user, Pageable pageable) {
        return notificationRepository.findByUserOrderByCreatedAtDesc(user, pageable);
    }
    
    /**
     * Get unread notifications for a user
     */
    public Page<Notification> getUnreadNotifications(User user, Pageable pageable) {
        return notificationRepository.findByUserAndIsReadFalseOrderByCreatedAtDesc(user, pageable);
    }
    
    /**
     * Get unread notification count
     */
    public long getUnreadCount(User user) {
        return notificationRepository.countByUserAndIsReadFalse(user);
    }
    
    /**
     * Mark notification as read
     */
    public void markAsRead(Long notificationId, User user) {
        notificationRepository.markAsReadByIdAndUser(notificationId, user);
    }
    
    /**
     * Mark all notifications as read for a user
     */
    public void markAllAsRead(User user) {
        notificationRepository.markAllAsReadByUser(user);
    }
    
    /**
     * Clean up old notifications (older than 30 days)
     */
    public void cleanupOldNotifications() {
        LocalDateTime cutoffDate = LocalDateTime.now().minusDays(30);
        notificationRepository.deleteOldNotifications(cutoffDate);
    }
}
