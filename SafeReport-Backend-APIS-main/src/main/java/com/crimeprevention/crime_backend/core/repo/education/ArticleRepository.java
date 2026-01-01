package com.crimeprevention.crime_backend.core.repo.education;

import com.crimeprevention.crime_backend.core.model.education.Article;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface ArticleRepository extends JpaRepository<Article, UUID> {
    
    // Find featured articles
    List<Article> findByIsFeaturedTrueAndIsPublishedTrueOrderByPublishedAtDesc();
    
    // Find articles by category
    Page<Article> findByCategoryAndIsPublishedTrue(String category, Pageable pageable);
    
    // Find all published articles
    Page<Article> findByIsPublishedTrueOrderByPublishedAtDesc(Pageable pageable);
    
    // Find articles by search term
    @Query("SELECT a FROM Article a WHERE a.isPublished = true AND " +
           "(LOWER(a.title) LIKE LOWER(CONCAT('%', :searchTerm, '%')) OR " +
           "LOWER(a.description) LIKE LOWER(CONCAT('%', :searchTerm, '%')) OR " +
           "LOWER(a.content) LIKE LOWER(CONCAT('%', :searchTerm, '%'))) " +
           "ORDER BY a.publishedAt DESC")
    Page<Article> searchArticles(@Param("searchTerm") String searchTerm, Pageable pageable);
    
    // Find articles by tags
    @Query("SELECT a FROM Article a WHERE a.isPublished = true AND " +
           "LOWER(a.tags) LIKE LOWER(CONCAT('%', :tag, '%')) " +
           "ORDER BY a.publishedAt DESC")
    List<Article> findByTag(@Param("tag") String tag);
}

