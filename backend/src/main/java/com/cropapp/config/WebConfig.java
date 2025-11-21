package com.cropapp.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
public class WebConfig implements WebMvcConfigurer {

    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
        // Serve files from the "uploads" directory
        // This maps URLs like http://localhost:8080/uploads/images/abc.jpg
        // to the local file system folder "uploads/images/abc.jpg"
        registry.addResourceHandler("/uploads/**")
                .addResourceLocations("file:uploads/");
    }
}
