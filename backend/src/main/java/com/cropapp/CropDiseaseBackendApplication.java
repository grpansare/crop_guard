package com.cropapp;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableAsync;

@SpringBootApplication
@EnableAsync
public class CropDiseaseBackendApplication {

    public static void main(String[] args) {
        SpringApplication.run(CropDiseaseBackendApplication.class, args);
    }

}
