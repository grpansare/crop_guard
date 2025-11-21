package com.cropapp.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

public class CreateQueryRequestDTO {
    
    @NotBlank(message = "Title is required")
    @Size(min = 5, max = 100, message = "Title must be between 5 and 100 characters")
    private String title;
    
    @NotBlank(message = "Description is required")
    @Size(min = 20, max = 1000, message = "Description must be between 20 and 1000 characters")
    private String description;
    
    @NotBlank(message = "Crop type is required")
    private String cropType;
    
    @NotBlank(message = "Category is required")
    private String category;
    
    @NotBlank(message = "Urgency is required")
    private String urgency;
    
    private Boolean hasImage = false;



private String imagePath;


    // Constructors
    public CreateQueryRequestDTO() {}

    public CreateQueryRequestDTO(String title, String description, String cropType, 
                                String category, String urgency, Boolean hasImage) {
        this.title = title;
        this.description = description;
        this.cropType = cropType;
        this.category = category;
        this.urgency = urgency;
        this.hasImage = hasImage;
    }

    // Getters and Setters
    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getCropType() {
        return cropType;
    }

    public void setCropType(String cropType) {
        this.cropType = cropType;
    }

    public String getCategory() {
        return category;
    }

    public void setCategory(String category) {
        this.category = category;
    }

    public String getUrgency() {
        return urgency;
    }

    public void setUrgency(String urgency) {
        this.urgency = urgency;
    }

    public Boolean getHasImage() {
        return hasImage;
    }



public String getImagePath() {
    return imagePath;
}

public void setImagePath(String imagePath) {
    this.imagePath = imagePath;
}

    public void setHasImage(Boolean hasImage) {
        this.hasImage = hasImage;
    }
}
