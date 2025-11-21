package com.cropapp.service;

import jakarta.annotation.PostConstruct;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.io.ClassPathResource;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.stereotype.Service;
import org.springframework.scheduling.annotation.Async;

import jakarta.mail.internet.MimeMessage;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.util.HashMap;
import java.util.Map;

@Service
public class EmailService {

    private static final Logger logger = LoggerFactory.getLogger(EmailService.class);

    @Autowired
    private JavaMailSender mailSender;

    private String expertPendingTemplate;
    private String expertApprovedTemplate;

    @PostConstruct
    private void loadTemplates() {
        try {
            ClassPathResource res = new ClassPathResource("templates/expert_pending.html");
            byte[] bytes = Files.readAllBytes(res.getFile().toPath());
            expertPendingTemplate = new String(bytes, StandardCharsets.UTF_8);
        } catch (Exception e) {
            logger.warn("Could not load expert_pending email template; will use plaintext fallback: {}", e.getMessage());
            expertPendingTemplate = null;
        }

        try {
            ClassPathResource res = new ClassPathResource("templates/expert_approved.html");
            byte[] bytes = Files.readAllBytes(res.getFile().toPath());
            expertApprovedTemplate = new String(bytes, StandardCharsets.UTF_8);
        } catch (Exception e) {
            logger.warn("Could not load expert_approved email template; will use plaintext fallback: {}", e.getMessage());
            expertApprovedTemplate = null;
        }
    }


    @Async
    public void sendExpertPending(String to, String name) {
        if (to == null || to.trim().isEmpty()) return;

        String subject = "Your expert account is pending approval";
        try {
            MimeMessage message = mailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(message, MimeMessageHelper.MULTIPART_MODE_MIXED_RELATED, StandardCharsets.UTF_8.name());

            String displayName = (name == null || name.trim().isEmpty()) ? "Applicant" : name;

            String htmlBody;
            if (expertPendingTemplate != null) {
                htmlBody = expertPendingTemplate.replace("{{name}}", escapeHtml(displayName));
            } else {
                htmlBody = "<p>Hello " + escapeHtml(displayName) + ",</p>"
                        + "<p>Thank you for registering as an expert on CropApp. Your account is pending review and will be approved by an administrator shortly.</p>"
                        + "<p>Regards,<br/>CropApp Team</p>";
            }

            helper.setTo(to);
            helper.setSubject(subject);
            helper.setText(htmlBody, true);

            mailSender.send(message);
            logger.info("Sent expert-pending email to {}", to);
        } catch (Exception e) {
            logger.error("Failed to send expert pending email to {}: {}", to, e.getMessage());
        }
    }

    @Async
    public void sendExpertApproved(String to, String name) {
        if (to == null || to.trim().isEmpty()) return;

        String subject = "Your expert account has been approved!";
        try {
            MimeMessage message = mailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(message, MimeMessageHelper.MULTIPART_MODE_MIXED_RELATED, StandardCharsets.UTF_8.name());

            String displayName = (name == null || name.trim().isEmpty()) ? "Expert" : name;

            String htmlBody;
            if (expertApprovedTemplate != null) {
                htmlBody = expertApprovedTemplate.replace("{{name}}", escapeHtml(displayName));
            } else {
                htmlBody = "<p>Hello " + escapeHtml(displayName) + ",</p>"
                        + "<p>Congratulations! Your expert account on CropApp has been approved by our administrators.</p>"
                        + "<p>You can now log in to your account and access all expert features.</p>"
                        + "<p>Thank you for joining our community of agricultural experts.</p>"
                        + "<p>Best regards,<br/>CropApp Team</p>";
            }

            helper.setTo(to);
            helper.setSubject(subject);
            helper.setText(htmlBody, true);

            mailSender.send(message);
            logger.info("Sent expert-approved email to {}", to);
        } catch (Exception e) {
            logger.error("Failed to send expert approved email to {}: {}", to, e.getMessage());
        }
    }


    private String escapeHtml(String input) {
        if (input == null) return "";
        return input.replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#x27;");
    }

}
