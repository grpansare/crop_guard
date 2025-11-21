package com.cropapp.dto;

import java.util.List;

public class ReportsListResponseDTO {
    private List<ReportResponseDTO> reports;
    private long totalElements;
    private int totalPages;
    private int currentPage;
    private int size;
    private boolean hasNext;
    private boolean hasPrevious;

    // Default constructor
    public ReportsListResponseDTO() {}

    // Constructor for non-paginated results
    public ReportsListResponseDTO(List<ReportResponseDTO> reports) {
        this.reports = reports;
        this.totalElements = reports.size();
        this.totalPages = 1;
        this.currentPage = 0;
        this.size = reports.size();
        this.hasNext = false;
        this.hasPrevious = false;
    }

    // Constructor with pagination info
    public ReportsListResponseDTO(List<ReportResponseDTO> reports, long totalElements, 
                                int totalPages, int currentPage, int size, 
                                boolean hasNext, boolean hasPrevious) {
        this.reports = reports;
        this.totalElements = totalElements;
        this.totalPages = totalPages;
        this.currentPage = currentPage;
        this.size = size;
        this.hasNext = hasNext;
        this.hasPrevious = hasPrevious;
    }

    // Getters and Setters
    public List<ReportResponseDTO> getReports() {
        return reports;
    }

    public void setReports(List<ReportResponseDTO> reports) {
        this.reports = reports;
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
