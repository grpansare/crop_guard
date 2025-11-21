package com.cropapp.service;

import com.cropapp.entity.User;
import com.cropapp.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class UserDetailsServiceImpl implements UserDetailsService {
    
    @Autowired
    private UserRepository userRepository;
    
    @Override
    @Transactional
    public UserDetails loadUserByUsername(String usernameOrMobile) throws UsernameNotFoundException {
        // First try to find by mobile number
        User user = userRepository.findByMobile(usernameOrMobile)
                .orElseGet(() -> {
                    // If not found by mobile, try by username
                    return userRepository.findByUsername(usernameOrMobile)
                            .orElseThrow(() -> new UsernameNotFoundException("User not found with mobile/username: " + usernameOrMobile));
                });
        
        return user;
    }
    
    @Transactional
    public UserDetails loadUserByMobile(String mobile) throws UsernameNotFoundException {
        return userRepository.findByMobile(mobile)
                .orElseThrow(() -> new UsernameNotFoundException("User not found with mobile: " + mobile));
    }
}
