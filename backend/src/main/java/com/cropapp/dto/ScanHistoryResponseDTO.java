package com.cropapp.dto;

import org.springframework.data.domain.Page;
import java.util.List;

public class ScanHistoryResponseDTO {
    private List<ScanResponseDTO> scans;
    private long totalElements;
    private int totalPages;
    private int currentPage;
    private int size;
    private boolean hasNext;
    private boolean hasPrevious;

    // Default constructor
    public ScanHistoryResponseDTO() {}

    // Constructor from Page and scan list
    public ScanHistoryResponseDTO(List<ScanResponseDTO> scans, Page<?> page) {
        this.scans = scans;
        this.totalElements = page.getTotalElements();
        this.totalPages = page.getTotalPages();
        this.currentPage = page.getNumber();
        this.size = page.getSize();
        this.hasNext = page.hasNext();
        this.hasPrevious = page.hasPrevious();
    }

    // Constructor for non-paginated results (fallback)
    public ScanHistoryResponseDTO(List<ScanResponseDTO> scans) {
        this.scans = scans;
        this.totalElements = scans.size();
        this.totalPages = 1;
        this.currentPage = 0;
        this.size = scans.size();
        this.hasNext = false;
        this.hasPrevious = false;
    }

    // Getters and Setters
    public List<ScanResponseDTO> getScans() {
        return scans;
    }

    public void setScans(List<ScanResponseDTO> scans) {
        this.scans = scans;
    }

    public long getTotalElements() {
        return totalElements;
    }

    public void setTotalElements(long totalElements) {
        this.totalElements = totalElements;
    }

    public int getTotalPages() {
        return totalPages;
    }

    public void setTotalPages(int totalPages) {
        this.totalPages = totalPages;
    }

    public int getCurrentPage() {
        return currentPage;
    }

    public void setCurrentPage(int currentPage) {
        this.currentPage = currentPage;
    }

    public int getSize() {
        return size;
    }

    public void setSize(int size) {
        this.size = size;
    }

    public boolean isHasNext() {
        return hasNext;
    }

    public void setHasNext(boolean hasNext) {
        this.hasNext = hasNext;
    }

    public boolean isHasPrevious() {
        return hasPrevious;
    }

    public void setHasPrevious(boolean hasPrevious) {
        this.hasPrevious = hasPrevious;
    }
}
