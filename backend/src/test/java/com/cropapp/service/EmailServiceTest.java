package com.cropapp.service;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.mail.javamail.JavaMailSender;

import jakarta.mail.internet.MimeMessage;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

public class EmailServiceTest {

    private JavaMailSender mailSender;
    private EmailService emailService;

    @BeforeEach
    public void setup() throws Exception {
        mailSender = mock(JavaMailSender.class);
        // Provide a real MimeMessage so MimeMessageHelper can work
        MimeMessage mimeMessage = new jakarta.mail.internet.MimeMessage((jakarta.mail.Session) null);
        when(mailSender.createMimeMessage()).thenReturn(mimeMessage);

        emailService = new EmailService();
        // inject mock via reflection
        try {
            java.lang.reflect.Field f = EmailService.class.getDeclaredField("mailSender");
            f.setAccessible(true);
            f.set(emailService, mailSender);
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
        // Also ensure template field is set so service uses it (optional)
        try {
            java.lang.reflect.Field t = EmailService.class.getDeclaredField("expertPendingTemplate");
            t.setAccessible(true);
            t.set(emailService, "<p>Hi {{name}}, your account is pending.</p>");
        } catch (Exception ignored) {}
    }

    @Test
    public void testSendExpertPending_sendsMessage() {
        emailService.sendExpertPending("test@example.com", "Dr Test");

        verify(mailSender, times(1)).send(any(MimeMessage.class));
    }

    @Test
    public void testSendExpertPending_emptyRecipient_doesNotSend() {
        emailService.sendExpertPending("  ", "Dr Test");
        verify(mailSender, never()).send(any(MimeMessage.class));
    }
}
