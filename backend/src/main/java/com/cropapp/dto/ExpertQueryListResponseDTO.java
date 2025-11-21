package com.cropapp.dto;

import java.util.List;

public class ExpertQueryListResponseDTO {
    private List<ExpertQueryResponseDTO> queries;
    private long totalElements;
    private int totalPages;
    private int currentPage;
    private int pageSize;

    // Constructors
    public ExpertQueryListResponseDTO() {}

    public ExpertQueryListResponseDTO(List<ExpertQueryResponseDTO> queries, long totalElements, 
                                     int totalPages, int currentPage, int pageSize) {
        this.queries = queries;
        this.totalElements = totalElements;
        this.totalPages = totalPages;
        this.currentPage = currentPage;
        this.pageSize = pageSize;
    }

    // Getters and Setters
    public List<ExpertQueryResponseDTO> getQueries() {
        return queries;
    }

    public void setQueries(List<ExpertQueryResponseDTO> queries) {
        this.queries = queries;
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

    public int getPageSize() {
        return pageSize;
    }

    public void setPageSize(int pageSize) {
        this.pageSize = pageSize;
    }
}
