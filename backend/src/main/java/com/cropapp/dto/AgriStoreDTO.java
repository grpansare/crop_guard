package com.cropapp.dto;

import com.cropapp.entity.AgriStore;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

public class AgriStoreDTO {
    
    private Long id;
    
    @NotBlank(message = "Store name is required")
    @Size(max = 100, message = "Store name must not exceed 100 characters")
    private String name;
    
    @Size(max = 500, message = "Description must not exceed 500 characters")
    private String description;
    
    @NotBlank(message = "Address is required")
    @Size(max = 255, message = "Address must not exceed 255 characters")
    private String address;
    
    @NotNull(message = "Latitude is required")
    private Double latitude;
    
    @NotNull(message = "Longitude is required")
    private Double longitude;
    
    @Size(max = 15, message = "Contact number must not exceed 15 characters")
    private String contactNumber;
    
    @Size(max = 100, message = "Owner name must not exceed 100 characters")
    private String ownerName;
    
    private String storeType;
    
    private Boolean isActive;
    
    private String createdAt;
    
    private String updatedAt;
    
    private Long createdBy;
    
    // Additional field for nearby queries
    private Double distance;
    
    // Constructors
    public AgriStoreDTO() {
    }
    
    public AgriStoreDTO(AgriStore store) {
        this.id = store.getId();
        this.name = store.getName();
        this.description = store.getDescription();
        this.address = store.getAddress();
        this.latitude = store.getLatitude();
        this.longitude = store.getLongitude();
        this.contactNumber = store.getContactNumber();
        this.ownerName = store.getOwnerName();
        this.storeType = store.getStoreType() != null ? store.getStoreType().name() : null;
        this.isActive = store.isActive();
        this.createdAt = store.getCreatedAt() != null ? store.getCreatedAt().toString() : null;
        this.updatedAt = store.getUpdatedAt() != null ? store.getUpdatedAt().toString() : null;
        this.createdBy = store.getCreatedBy();
    }
    
    // Getters and Setters
    public Long getId() {
        return id;
    }
    
    public void setId(Long id) {
        this.id = id;
    }
    
    public String getName() {
        return name;
    }
    
    public void setName(String name) {
        this.name = name;
    }
    
    public String getDescription() {
        return description;
    }
    
    public void setDescription(String description) {
        this.description = description;
    }
    
    public String getAddress() {
        return address;
    }
    
    public void setAddress(String address) {
        this.address = address;
    }
    
    public Double getLatitude() {
        return latitude;
    }
    
    public void setLatitude(Double latitude) {
        this.latitude = latitude;
    }
    
    public Double getLongitude() {
        return longitude;
    }
    
    public void setLongitude(Double longitude) {
        this.longitude = longitude;
    }
    
    public String getContactNumber() {
        return contactNumber;
    }
    
    public void setContactNumber(String contactNumber) {
        this.contactNumber = contactNumber;
    }
    
    public String getOwnerName() {
        return ownerName;
    }
    
    public void setOwnerName(String ownerName) {
        this.ownerName = ownerName;
    }
    
    public String getStoreType() {
        return storeType;
    }
    
    public void setStoreType(String storeType) {
        this.storeType = storeType;
    }
    
    public Boolean getIsActive() {
        return isActive;
    }
    
    public void setIsActive(Boolean isActive) {
        this.isActive = isActive;
    }
    
    public String getCreatedAt() {
        return createdAt;
    }
    
    public void setCreatedAt(String createdAt) {
        this.createdAt = createdAt;
    }
    
    public String getUpdatedAt() {
        return updatedAt;
    }
    
    public void setUpdatedAt(String updatedAt) {
        this.updatedAt = updatedAt;
    }
    
    public Long getCreatedBy() {
        return createdBy;
    }
    
    public void setCreatedBy(Long createdBy) {
        this.createdBy = createdBy;
    }
    
    public Double getDistance() {
        return distance;
    }
    
    public void setDistance(Double distance) {
        this.distance = distance;
    }
}
