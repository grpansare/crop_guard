package com.cropapp.controller;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.http.ResponseEntity.BodyBuilder;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.core.io.Resource;
import org.springframework.core.io.UrlResource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

@CrossOrigin(origins = "*", maxAge = 3600)
@RestController
@RequestMapping("/api/images")
public class ImageController {

    // Upload directory paths - you can configure this in application.properties
    private final String uploadDir = "uploads/images/";
    private final String documentsDir = "uploads/documents/";

    @PostMapping("/upload")
    public ResponseEntity<?> uploadImage(@RequestParam("image") MultipartFile file) {
        try {
            // Validate file
            if (file.isEmpty()) {
                return ResponseEntity.badRequest()
                    .body(Map.of("error", "Please select a file to upload"));
            }

            // Validate file type
            String contentType = file.getContentType();
            if (contentType == null || !contentType.startsWith("image/")) {
                return ResponseEntity.badRequest()
                    .body(Map.of("error", "Only image files are allowed"));
            }

            // Validate file size (max 5MB)
            if (file.getSize() > 5 * 1024 * 1024) {
                return ResponseEntity.badRequest()
                    .body(Map.of("error", "File size must be less than 5MB"));
            }

            // Create upload directory if it doesn't exist
            Path uploadPath = Paths.get(uploadDir);
            if (!Files.exists(uploadPath)) {
                Files.createDirectories(uploadPath);
            }

            // Generate unique filename
            String originalFilename = file.getOriginalFilename();
            String fileExtension = "";
            if (originalFilename != null && originalFilename.contains(".")) {
                fileExtension = originalFilename.substring(originalFilename.lastIndexOf("."));
            }
            String uniqueFilename = UUID.randomUUID().toString() + "_" + System.currentTimeMillis() + fileExtension;

            // Save file
            Path filePath = uploadPath.resolve(uniqueFilename);
            Files.copy(file.getInputStream(), filePath, StandardCopyOption.REPLACE_EXISTING);

            // Return success response
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("imagePath", uniqueFilename);
            response.put("message", "Image uploaded successfully");
            
            return ResponseEntity.ok(response);

        } catch (IOException e) {
            return ResponseEntity.internalServerError()
                .body(Map.of("error", "Failed to upload image: " + e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.internalServerError()
                .body(Map.of("error", "Unexpected error: " + e.getMessage()));
        }
    }

    @GetMapping("/{filename}")
    public ResponseEntity<Resource> getImage(@PathVariable String filename) {
        try {
            Path filePath = Paths.get(uploadDir).resolve(filename).normalize();
            Resource resource = new UrlResource(filePath.toUri());

            if (resource.exists() && resource.isReadable()) {
                // Determine content type
                String contentType = Files.probeContentType(filePath);
                if (contentType == null) {
                    contentType = "application/octet-stream";
                }

                return ResponseEntity.ok()
                    .contentType(MediaType.parseMediaType(contentType))
                    .header(HttpHeaders.CONTENT_DISPOSITION, "inline; filename=\"" + filename + "\"")
                    .body(resource);
            } else {
                return ResponseEntity.notFound().build();
            }
        } catch (Exception e) {
            return ResponseEntity.internalServerError().build();
        }
    }

    @DeleteMapping("/{filename}")
    public ResponseEntity<?> deleteImage(@PathVariable String filename) {
        try {
            Path filePath = Paths.get(uploadDir).resolve(filename).normalize();
            
            if (Files.exists(filePath)) {
                Files.delete(filePath);
                return ResponseEntity.ok(Map.of("message", "Image deleted successfully"));
            } else {
                return ((BodyBuilder) ResponseEntity.notFound())
                    .body(Map.of("error", "Image not found"));
            }
        } catch (Exception e) {
            return ResponseEntity.internalServerError()
                .body(Map.of("error", "Failed to delete image: " + e.getMessage()));
        }
    }
    
    // Upload verification document (certificate, license, etc.)
    @PostMapping("/upload-document")
    public ResponseEntity<?> uploadDocument(@RequestParam("document") MultipartFile file) {
        try {
            // Validate file
            if (file.isEmpty()) {
                return ResponseEntity.badRequest()
                    .body(Map.of("error", "Please select a file to upload"));
            }

            // Validate file type (allow images and PDFs)
            String contentType = file.getContentType();
            if (contentType == null || 
                (!contentType.startsWith("image/") && !contentType.equals("application/pdf"))) {
                return ResponseEntity.badRequest()
                    .body(Map.of("error", "Only image files and PDFs are allowed"));
            }

            // Validate file size (max 10MB for documents)
            if (file.getSize() > 10 * 1024 * 1024) {
                return ResponseEntity.badRequest()
                    .body(Map.of("error", "File size must be less than 10MB"));
            }

            // Create upload directory if it doesn't exist
            Path uploadPath = Paths.get(documentsDir);
            if (!Files.exists(uploadPath)) {
                Files.createDirectories(uploadPath);
            }

            // Generate unique filename
            String originalFilename = file.getOriginalFilename();
            String fileExtension = "";
            if (originalFilename != null && originalFilename.contains(".")) {
                fileExtension = originalFilename.substring(originalFilename.lastIndexOf("."));
            }
            String uniqueFilename = UUID.randomUUID().toString() + "_" + System.currentTimeMillis() + fileExtension;

            // Save file
            Path filePath = uploadPath.resolve(uniqueFilename);
            Files.copy(file.getInputStream(), filePath, StandardCopyOption.REPLACE_EXISTING);

            System.out.println("📄 Document uploaded: " + uniqueFilename);

            // Return success response
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("documentPath", uniqueFilename);
            response.put("message", "Document uploaded successfully");
            
            return ResponseEntity.ok(response);

        } catch (IOException e) {
            return ResponseEntity.internalServerError()
                .body(Map.of("error", "Failed to upload document: " + e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.internalServerError()
                .body(Map.of("error", "Unexpected error: " + e.getMessage()));
        }
    }
    
    // Get verification document
    @GetMapping("/documents/{filename}")
    public ResponseEntity<Resource> getDocument(@PathVariable String filename) {
        try {
            Path filePath = Paths.get(documentsDir).resolve(filename).normalize();
            Resource resource = new UrlResource(filePath.toUri());

            if (resource.exists() && resource.isReadable()) {
                // Determine content type
                String contentType = Files.probeContentType(filePath);
                if (contentType == null) {
                    contentType = "application/octet-stream";
                }

                return ResponseEntity.ok()
                    .contentType(MediaType.parseMediaType(contentType))
                    .header(HttpHeaders.CONTENT_DISPOSITION, "inline; filename=\"" + filename + "\"")
                    .body(resource);
            } else {
                return ResponseEntity.notFound().build();
            }
        } catch (Exception e) {
            return ResponseEntity.internalServerError().build();
        }
    }
}