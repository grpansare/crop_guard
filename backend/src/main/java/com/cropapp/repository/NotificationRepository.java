package com.cropapp.repository;

import com.cropapp.entity.Notification;
import com.cropapp.entity.User;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

@Repository
public interface NotificationRepository extends JpaRepository<Notification, Long> {
    
    // Find notifications for a specific user, ordered by creation date (newest first)
    Page<Notification> findByUserOrderByCreatedAtDesc(User user, Pageable pageable);
    
    // Find unread notifications for a user
    Page<Notification> findByUserAndIsReadFalseOrderByCreatedAtDesc(User user, Pageable pageable);
    
    // Count unread notifications for a user
    long countByUserAndIsReadFalse(User user);
    
    // Mark all notifications as read for a user
    @Modifying
    @Query("UPDATE Notification n SET n.isRead = true WHERE n.user = :user AND n.isRead = false")
    void markAllAsReadByUser(@Param("user") User user);
    
    // Mark specific notification as read
    @Modifying
    @Query("UPDATE Notification n SET n.isRead = true WHERE n.id = :notificationId AND n.user = :user")
    void markAsReadByIdAndUser(@Param("notificationId") Long notificationId, @Param("user") User user);
    
    // Delete old notifications (older than 30 days)
    @Modifying
    @Query("DELETE FROM Notification n WHERE n.createdAt < :cutoffDate")
    void deleteOldNotifications(@Param("cutoffDate") java.time.LocalDateTime cutoffDate);
}
