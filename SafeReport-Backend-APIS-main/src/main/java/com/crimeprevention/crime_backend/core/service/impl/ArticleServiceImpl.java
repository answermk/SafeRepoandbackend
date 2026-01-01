package com.crimeprevention.crime_backend.core.service.impl;

import com.crimeprevention.crime_backend.core.dto.education.ArticleResponse;
import com.crimeprevention.crime_backend.core.dto.education.CreateArticleRequest;
import com.crimeprevention.crime_backend.core.model.education.Article;
import com.crimeprevention.crime_backend.core.repo.education.ArticleRepository;
import com.crimeprevention.crime_backend.core.service.interfaces.ArticleService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
@Transactional
public class ArticleServiceImpl implements ArticleService {
    
    private final ArticleRepository articleRepository;
    
    @Override
    public ArticleResponse createArticle(CreateArticleRequest request) {
        log.info("Creating new article: {}", request.getTitle());
        
        Article article = Article.builder()
            .title(request.getTitle())
            .description(request.getDescription())
            .content(request.getContent())
            .category(request.getCategory())
            .readTimeMinutes(request.getReadTimeMinutes() != null 
                ? request.getReadTimeMinutes() 
                : calculateReadTime(request.getContent()))
            .isFeatured(request.getIsFeatured() != null ? request.getIsFeatured() : false)
            .imageUrl(request.getImageUrl())
            .author(request.getAuthor())
            .tags(request.getTags())
            .isPublished(true)
            .viewsCount(0L)
            .publishedAt(LocalDateTime.now())
            .build();
        
        article = articleRepository.save(article);
        log.info("Article created with ID: {}", article.getId());
        
        return mapToResponse(article);
    }
    
    @Override
    @Transactional(readOnly = true)
    public ArticleResponse getArticleById(UUID id) {
        Article article = articleRepository.findById(id)
            .orElseThrow(() -> new RuntimeException("Article not found with ID: " + id));
        
        // Increment views
        incrementViews(id);
        
        return mapToResponse(article);
    }
    
    @Override
    @Transactional(readOnly = true)
    public Page<ArticleResponse> getAllArticles(Pageable pageable) {
        return articleRepository.findByIsPublishedTrueOrderByPublishedAtDesc(pageable)
            .map(this::mapToResponse);
    }
    
    @Override
    @Transactional(readOnly = true)
    public List<ArticleResponse> getFeaturedArticles() {
        log.info("Fetching featured articles");
        return articleRepository.findByIsFeaturedTrueAndIsPublishedTrueOrderByPublishedAtDesc()
            .stream()
            .map(this::mapToResponse)
            .collect(Collectors.toList());
    }
    
    @Override
    @Transactional(readOnly = true)
    public Page<ArticleResponse> getArticlesByCategory(String category, Pageable pageable) {
        return articleRepository.findByCategoryAndIsPublishedTrue(category, pageable)
            .map(this::mapToResponse);
    }
    
    @Override
    @Transactional(readOnly = true)
    public Page<ArticleResponse> searchArticles(String searchTerm, Pageable pageable) {
        return articleRepository.searchArticles(searchTerm, pageable)
            .map(this::mapToResponse);
    }
    
    @Override
    public ArticleResponse updateArticle(UUID id, CreateArticleRequest request) {
        Article article = articleRepository.findById(id)
            .orElseThrow(() -> new RuntimeException("Article not found with ID: " + id));
        
        article.setTitle(request.getTitle());
        article.setDescription(request.getDescription());
        article.setContent(request.getContent());
        article.setCategory(request.getCategory());
        article.setReadTimeMinutes(request.getReadTimeMinutes() != null 
            ? request.getReadTimeMinutes() 
            : calculateReadTime(request.getContent()));
        if (request.getIsFeatured() != null) {
            article.setIsFeatured(request.getIsFeatured());
        }
        article.setImageUrl(request.getImageUrl());
        article.setAuthor(request.getAuthor());
        article.setTags(request.getTags());
        
        article = articleRepository.save(article);
        log.info("Article updated with ID: {}", id);
        
        return mapToResponse(article);
    }
    
    @Override
    public void deleteArticle(UUID id) {
        Article article = articleRepository.findById(id)
            .orElseThrow(() -> new RuntimeException("Article not found with ID: " + id));
        
        articleRepository.delete(article);
        log.info("Article deleted with ID: {}", id);
    }
    
    @Override
    @Transactional
    public void incrementViews(UUID id) {
        Article article = articleRepository.findById(id)
            .orElseThrow(() -> new RuntimeException("Article not found with ID: " + id));
        
        article.setViewsCount(article.getViewsCount() + 1);
        articleRepository.save(article);
    }
    
    private ArticleResponse mapToResponse(Article article) {
        return ArticleResponse.builder()
            .id(article.getId())
            .title(article.getTitle())
            .description(article.getDescription())
            .content(article.getContent())
            .category(article.getCategory())
            .readTimeMinutes(article.getReadTimeMinutes())
            .isFeatured(article.getIsFeatured())
            .imageUrl(article.getImageUrl())
            .author(article.getAuthor())
            .viewsCount(article.getViewsCount())
            .publishedAt(article.getPublishedAt())
            .tags(article.getTags())
            .createdAt(article.getCreatedAt() != null 
                ? LocalDateTime.ofInstant(article.getCreatedAt(), java.time.ZoneId.systemDefault())
                : null)
            .updatedAt(article.getUpdatedAt() != null 
                ? LocalDateTime.ofInstant(article.getUpdatedAt(), java.time.ZoneId.systemDefault())
                : null)
            .build();
    }
    
    private Integer calculateReadTime(String content) {
        if (content == null || content.isEmpty()) {
            return 1;
        }
        // Average reading speed: 200 words per minute
        int wordCount = content.split("\\s+").length;
        return Math.max(1, (wordCount / 200));
    }
}

