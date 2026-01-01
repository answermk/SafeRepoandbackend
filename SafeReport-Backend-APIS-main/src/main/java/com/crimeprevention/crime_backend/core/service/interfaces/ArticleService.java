package com.crimeprevention.crime_backend.core.service.interfaces;

import com.crimeprevention.crime_backend.core.dto.education.ArticleResponse;
import com.crimeprevention.crime_backend.core.dto.education.CreateArticleRequest;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import java.util.List;
import java.util.UUID;

public interface ArticleService {
    ArticleResponse createArticle(CreateArticleRequest request);
    ArticleResponse getArticleById(UUID id);
    Page<ArticleResponse> getAllArticles(Pageable pageable);
    List<ArticleResponse> getFeaturedArticles();
    Page<ArticleResponse> getArticlesByCategory(String category, Pageable pageable);
    Page<ArticleResponse> searchArticles(String searchTerm, Pageable pageable);
    ArticleResponse updateArticle(UUID id, CreateArticleRequest request);
    void deleteArticle(UUID id);
    void incrementViews(UUID id);
}

