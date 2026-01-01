package com.crimeprevention.crime_backend.controller;

import com.crimeprevention.crime_backend.core.dto.education.ArticleResponse;
import com.crimeprevention.crime_backend.core.dto.education.CreateArticleRequest;
import com.crimeprevention.crime_backend.core.service.interfaces.ArticleService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/articles")
@RequiredArgsConstructor
@Slf4j
public class ArticleController {
    
    private final ArticleService articleService;
    
    /**
     * Get all published articles with pagination
     */
    @GetMapping
    @PreAuthorize("hasAnyRole('CIVILIAN', 'POLICE_OFFICER', 'OFFICER', 'ADMIN')")
    public ResponseEntity<Page<ArticleResponse>> getAllArticles(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        Pageable pageable = PageRequest.of(page, size);
        Page<ArticleResponse> articles = articleService.getAllArticles(pageable);
        return ResponseEntity.ok(articles);
    }
    
    /**
     * Get featured articles
     */
    @GetMapping("/featured")
    @PreAuthorize("hasAnyRole('CIVILIAN', 'POLICE_OFFICER', 'OFFICER', 'ADMIN')")
    public ResponseEntity<List<ArticleResponse>> getFeaturedArticles() {
        log.info("Fetching featured articles");
        List<ArticleResponse> articles = articleService.getFeaturedArticles();
        return ResponseEntity.ok(articles);
    }
    
    /**
     * Get article by ID
     */
    @GetMapping("/{id}")
    @PreAuthorize("hasAnyRole('CIVILIAN', 'POLICE_OFFICER', 'OFFICER', 'ADMIN')")
    public ResponseEntity<ArticleResponse> getArticleById(@PathVariable UUID id) {
        ArticleResponse article = articleService.getArticleById(id);
        return ResponseEntity.ok(article);
    }
    
    /**
     * Get articles by category
     */
    @GetMapping("/category/{category}")
    @PreAuthorize("hasAnyRole('CIVILIAN', 'POLICE_OFFICER', 'OFFICER', 'ADMIN')")
    public ResponseEntity<Page<ArticleResponse>> getArticlesByCategory(
            @PathVariable String category,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        Pageable pageable = PageRequest.of(page, size);
        Page<ArticleResponse> articles = articleService.getArticlesByCategory(category, pageable);
        return ResponseEntity.ok(articles);
    }
    
    /**
     * Search articles
     */
    @GetMapping("/search")
    @PreAuthorize("hasAnyRole('CIVILIAN', 'POLICE_OFFICER', 'OFFICER', 'ADMIN')")
    public ResponseEntity<Page<ArticleResponse>> searchArticles(
            @RequestParam String q,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        Pageable pageable = PageRequest.of(page, size);
        Page<ArticleResponse> articles = articleService.searchArticles(q, pageable);
        return ResponseEntity.ok(articles);
    }
    
    /**
     * Create new article (Admin only)
     */
    @PostMapping
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ArticleResponse> createArticle(
            @Valid @RequestBody CreateArticleRequest request) {
        log.info("Creating new article: {}", request.getTitle());
        ArticleResponse article = articleService.createArticle(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(article);
    }
    
    /**
     * Update article (Admin only)
     */
    @PutMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ArticleResponse> updateArticle(
            @PathVariable UUID id,
            @Valid @RequestBody CreateArticleRequest request) {
        log.info("Updating article: {}", id);
        ArticleResponse article = articleService.updateArticle(id, request);
        return ResponseEntity.ok(article);
    }
    
    /**
     * Delete article (Admin only)
     */
    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Void> deleteArticle(@PathVariable UUID id) {
        log.info("Deleting article: {}", id);
        articleService.deleteArticle(id);
        return ResponseEntity.noContent().build();
    }
}

