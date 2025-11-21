package com.cropapp.config;

import com.cropapp.entity.User;
import com.cropapp.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;

@Component
public class DataInitializer implements CommandLineRunner {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Override
    public void run(String... args) throws Exception {
        // Create default admin user if not exists
        if (!userRepository.existsByUsername("admin")) {
            User admin = new User();
            admin.setUsername("admin");
            admin.setMobile("9999999999");
            admin.setPassword(passwordEncoder.encode("admin123"));
            admin.setFullName("System Administrator");
            admin.setRole(User.Role.ADMIN);
            admin.setEnabled(true);
            admin.setVerified(true);
            admin.setVerificationStatus(User.VerificationStatus.APPROVED);
            admin.setCreatedAt(LocalDateTime.now());
            admin.setUpdatedAt(LocalDateTime.now());
            
            userRepository.save(admin);
            
            System.out.println("========================================");
            System.out.println("✅ DEFAULT ADMIN USER CREATED");
            System.out.println("========================================");
            System.out.println("Username: admin");
            System.out.println("Mobile: 9999999999");
            System.out.println("Password: admin123");
            System.out.println("========================================");
            System.out.println("⚠️  CHANGE PASSWORD AFTER FIRST LOGIN!");
            System.out.println("========================================");
        } else {
            System.out.println("ℹ️  Admin user already exists");
        }
        
        // Create a test expert user if not exists
        if (!userRepository.existsByUsername("expert_test")) {
            User expert = new User();
            expert.setUsername("expert_test");
            expert.setMobile("8888888888");
            expert.setPassword(passwordEncoder.encode("expert123"));
            expert.setFullName("Dr. Test Expert");
            expert.setRole(User.Role.EXPERT);
            expert.setSpecialization("Plant Pathology");
            expert.setEnabled(true);
            expert.setVerified(false);
            expert.setVerificationStatus(User.VerificationStatus.PENDING);
            expert.setLicenseNumber("EXP-2024-001");
            expert.setCreatedAt(LocalDateTime.now());
            expert.setUpdatedAt(LocalDateTime.now());
            
            userRepository.save(expert);
            
            System.out.println("========================================");
            System.out.println("✅ TEST EXPERT USER CREATED (PENDING)");
            System.out.println("========================================");
            System.out.println("Username: expert_test");
            System.out.println("Mobile: 8888888888");
            System.out.println("Password: expert123");
            System.out.println("Status: PENDING (needs admin approval)");
            System.out.println("========================================");
        }
        
        // Create a test farmer user if not exists
        if (!userRepository.existsByUsername("farmer_test")) {
            User farmer = new User();
            farmer.setUsername("farmer_test");
            farmer.setMobile("7777777777");
            farmer.setPassword(passwordEncoder.encode("farmer123"));
            farmer.setFullName("Test Farmer");
            farmer.setRole(User.Role.USER);
            farmer.setEnabled(true);
            farmer.setCreatedAt(LocalDateTime.now());
            farmer.setUpdatedAt(LocalDateTime.now());
            
            userRepository.save(farmer);
            
            System.out.println("========================================");
            System.out.println("✅ TEST FARMER USER CREATED");
            System.out.println("========================================");
            System.out.println("Username: farmer_test");
            System.out.println("Mobile: 7777777777");
            System.out.println("Password: farmer123");
            System.out.println("========================================");
        }
    }
}
