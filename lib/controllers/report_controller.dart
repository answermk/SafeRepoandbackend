import 'dart:io';
import 'package:flutter/foundation.dart';
import '../services/report_service.dart';
import '../core/models/report_model.dart';

/// Report Controller
/// Manages report state and operations
class ReportController extends ChangeNotifier {
  List<ReportModel> _reports = [];
  bool _isLoading = false;
  String? _error;
  int _currentPage = 0;
  int _totalPages = 0;
  bool _hasMore = true;

  List<ReportModel> get reports => _reports;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  bool get hasMore => _hasMore;

  /// Load user's reports
  Future<void> loadReports({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 0;
      _reports = [];
      _hasMore = true;
    }

    if (!_hasMore || _isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await ReportService.getMyReports(
        page: _currentPage,
        size: 20,
      );

      if (result['success'] == true) {
        final data = result['data'] as List;
        final newReports = data.map((json) => ReportModel.fromJson(json)).toList();
        
        if (refresh) {
          _reports = newReports;
        } else {
          _reports.addAll(newReports);
        }

        _totalPages = result['totalPages'] ?? 0;
        _currentPage = result['currentPage'] ?? 0;
        _hasMore = _currentPage < _totalPages - 1;
        _isLoading = false;
        notifyListeners();
      } else {
        _error = result['error'] ?? 'Failed to load reports';
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      _error = 'An error occurred: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Create new report
  Future<bool> createReport({
    required String incidentType,
    required String description,
    required double latitude,
    required double longitude,
    String? address,
    bool isAnonymous = false,
    String? priority,
    List<File>? mediaFiles,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await ReportService.createReport(
        incidentType: incidentType,
        description: description,
        latitude: latitude,
        longitude: longitude,
        address: address,
        isAnonymous: isAnonymous,
        priority: priority,
        mediaFiles: mediaFiles,
      );

      if (result['success'] == true) {
        // Reload reports
        await loadReports(refresh: true);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = result['error'] ?? 'Failed to create report';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'An error occurred: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Delete report
  Future<bool> deleteReport(String reportId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await ReportService.deleteReport(reportId);

      if (result['success'] == true) {
        _reports.removeWhere((report) => report.id == reportId);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = result['error'] ?? 'Failed to delete report';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'An error occurred: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}

