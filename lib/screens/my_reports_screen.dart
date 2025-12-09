import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cross_file/cross_file.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../services/report_service.dart';
import 'dashboard_screen.dart';
import 'messages_screen.dart';
import 'profile_screen.dart';
import 'report_details_screen.dart';

class MyReportsScreen extends StatefulWidget {
  const MyReportsScreen({Key? key}) : super(key: key);

  @override
  State<MyReportsScreen> createState() => _MyReportsScreenState();
}

class _MyReportsScreenState extends State<MyReportsScreen> {
  int _selectedFilter = 0; // 0: All, 1: Active, 2: Resolved
  int _selectedIndex = 1;
  List<Map<String, dynamic>> reports = [];
  List<Map<String, dynamic>> filteredReports = [];
  List<String> selectedReportIds = [];
  bool isSelectionMode = false;
  String searchQuery = '';
  String sortBy = 'createdAt'; // createdAt, status, title
  bool sortAscending = false;
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';
  int _currentPage = 0;
  int _totalPages = 0;
  int _totalElements = 0;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadReports({bool showLoading = true}) async {
    if (showLoading) {
      setState(() {
        _isLoading = true;
        _hasError = false;
        _errorMessage = '';
      });
    }

    try {
      print('Loading reports from backend...');
      
      // Map sortBy to backend field names
      String backendSortBy = sortBy;
      if (sortBy == 'date') backendSortBy = 'createdAt';
      if (sortBy == 'type') backendSortBy = 'title';
      
      final result = await ReportService.getMyReports(
        page: _currentPage,
        size: 20,
        sortBy: backendSortBy,
        sortDir: sortAscending ? 'asc' : 'desc',
      );

      if (result['success'] == true) {
        final backendReports = result['data'] as List<dynamic>? ?? [];
        
        // Map backend reports to frontend format
        final mappedReports = backendReports.map((report) {
          final reportData = report as Map<String, dynamic>;
          final id = reportData['id']?.toString() ?? '';
          final title = reportData['title']?.toString() ?? 'Untitled Report';
          final description = reportData['description']?.toString() ?? '';
          final status = reportData['status']?.toString() ?? 'PENDING';
          final createdAt = reportData['createdAt']?.toString();
          final location = reportData['location'] as Map<String, dynamic>?;
          final address = location?['address']?.toString() ?? 
                         location?['city']?.toString() ?? 
                         'Unknown Location';
          
          DateTime? timestamp;
          if (createdAt != null) {
            try {
              timestamp = DateTime.parse(createdAt);
            } catch (e) {
              timestamp = DateTime.now();
            }
          } else {
            timestamp = DateTime.now();
          }

          return {
            'id': id,
            'type': title,
            'status': status,
            'location': address,
            'time': _formatTimeAgo(timestamp),
            'timestamp': timestamp,
            'desc': description,
            'rawData': reportData, // Keep raw data for details
          };
        }).toList();

        setState(() {
          reports = mappedReports;
          _totalPages = result['totalPages'] ?? 0;
          _totalElements = result['totalElements'] ?? 0;
          _isLoading = false;
          _hasError = false;
        });
        
        _applyFiltersAndSort();
      } else {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = result['error']?.toString() ?? 'Failed to load reports';
        });
      }
    } catch (e) {
      print('Error loading reports: $e');
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'Connection error: ${e.toString()}';
      });
    }
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 7) {
      return DateFormat('MMM d, y').format(dateTime);
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  void _applyFiltersAndSort() {
    // Apply status filter
    List<Map<String, dynamic>> temp = List.from(reports);

    if (_selectedFilter == 1) {
      // Active: PENDING, SUBMITTED, IN_PROGRESS, REVIEWING
      temp = temp.where((r) {
        final status = (r['status'] as String).toUpperCase();
        return status == 'PENDING' || 
               status == 'SUBMITTED' || 
               status == 'IN_PROGRESS' || 
               status == 'REVIEWING';
      }).toList();
    } else if (_selectedFilter == 2) {
      // Resolved: RESOLVED, CLOSED
      temp = temp.where((r) {
        final status = (r['status'] as String).toUpperCase();
        return status == 'RESOLVED' || status == 'CLOSED';
      }).toList();
    }

    // Apply search filter (client-side for now)
    if (searchQuery.isNotEmpty) {
      temp = temp.where((r) {
        final type = (r['type'] as String).toLowerCase();
        final location = (r['location'] as String).toLowerCase();
        final desc = (r['desc'] as String).toLowerCase();
        final query = searchQuery.toLowerCase();
        return type.contains(query) || location.contains(query) || desc.contains(query);
      }).toList();
    }

    // Apply sorting (client-side for filtered results)
    temp.sort((a, b) {
      int comparison = 0;
      switch (sortBy) {
        case 'date':
        case 'createdAt':
          comparison = (a['timestamp'] as DateTime).compareTo(b['timestamp'] as DateTime);
          break;
        case 'status':
          comparison = (a['status'] as String).compareTo(b['status'] as String);
          break;
        case 'type':
        case 'title':
          comparison = (a['type'] as String).compareTo(b['type'] as String);
          break;
      }
      return sortAscending ? comparison : -comparison;
    });

    setState(() {
      filteredReports = temp;
    });
  }

  String _getFilterText() {
    switch (_selectedFilter) {
      case 0: return 'all';
      case 1: return 'active';
      case 2: return 'resolved';
      default: return 'all';
    }
  }

  Future<void> _handleRefresh() async {
    _currentPage = 0;
    await _loadReports(showLoading: false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reports refreshed'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _toggleSelectionMode() {
    setState(() {
      isSelectionMode = !isSelectionMode;
      if (!isSelectionMode) {
        selectedReportIds.clear();
      }
    });
  }

  void _toggleReportSelection(String id) {
    setState(() {
      if (selectedReportIds.contains(id)) {
        selectedReportIds.remove(id);
      } else {
        selectedReportIds.add(id);
      }
    });
  }

  void _selectAll() {
    setState(() {
      if (selectedReportIds.length == filteredReports.length) {
        selectedReportIds.clear();
      } else {
        selectedReportIds = filteredReports.map((r) => r['id'] as String).toList();
      }
    });
  }

  Future<void> _exportSelectedToPDF() async {
    if (selectedReportIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No reports selected')),
      );
      return;
    }

    final selectedReports = reports.where((r) => selectedReportIds.contains(r['id'])).toList();

    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text('My Reports Export', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
          ),
          pw.SizedBox(height: 20),
          pw.Text('Generated on: ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())}'),
          pw.SizedBox(height: 20),
          ...selectedReports.map((report) {
            return pw.Container(
              margin: const pw.EdgeInsets.only(bottom: 20),
              padding: const pw.EdgeInsets.all(15),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey400),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    report['type'] as String,
                    style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text('Status: ${report['status']}'),
                  pw.Text('Location: ${report['location']}'),
                  pw.Text('Time: ${report['time']}'),
                  pw.SizedBox(height: 8),
                  pw.Text(report['desc'] as String),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());

    setState(() {
      isSelectionMode = false;
      selectedReportIds.clear();
    });
  }

  Future<void> _downloadReportPDF(Map<String, dynamic> report) async {
    pw.ImageProvider? logoImage;
    
    try {
      // Show loading indicator
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                ),
                SizedBox(width: 12),
                Text('Generating PDF...'),
              ],
            ),
            duration: Duration(seconds: 2),
          ),
        );
      }

      // Try to load logo image (supports JPG and PNG)
      try {
        final logoData = await rootBundle.load('assets/images/logo.jpg');
        final logoBytes = logoData.buffer.asUint8List();
        logoImage = pw.MemoryImage(logoBytes);
      } catch (e) {
        // Try PNG if JPG not found
        try {
          final logoData = await rootBundle.load('assets/images/logo.png');
          final logoBytes = logoData.buffer.asUint8List();
          logoImage = pw.MemoryImage(logoBytes);
        } catch (e2) {
          // Logo not found, will use placeholder
          print('Logo not found, using placeholder: $e2');
        }
      }

      final pdf = pw.Document();
      final rawData = report['rawData'] as Map<String, dynamic>? ?? {};
      
      // Extract report data
      final reportId = report['id']?.toString() ?? rawData['id']?.toString() ?? 'N/A';
      final title = report['type']?.toString() ?? rawData['title']?.toString() ?? 'Untitled Report';
      final description = report['desc']?.toString() ?? rawData['description']?.toString() ?? '';
      final status = report['status']?.toString() ?? rawData['status']?.toString() ?? 'PENDING';
      final priority = rawData['priority']?.toString() ?? 'NORMAL';
      final crimeType = rawData['crimeType']?.toString() ?? 'OTHER';
      final location = rawData['location'] as Map<String, dynamic>?;
      final address = location?['address']?.toString() ?? report['location']?.toString() ?? 'Unknown Location';
      final latitude = location?['latitude']?.toString() ?? '';
      final longitude = location?['longitude']?.toString() ?? '';
      final district = location?['district']?.toString() ?? '';
      final reporter = rawData['reporter'] as Map<String, dynamic>?;
      final reporterName = reporter?['fullName']?.toString() ?? (rawData['isAnonymous'] == true ? 'Anonymous' : 'Unknown');
      final reporterEmail = reporter?['email']?.toString() ?? '';
      final reporterPhone = reporter?['phoneNumber']?.toString() ?? '';
      final weatherCondition = rawData['weatherCondition']?.toString() ?? 'Not specified';
      final crimeRelationship = rawData['crimeRelationship']?.toString() ?? 'Not specified';
      final witnessInfo = rawData['witnessInfo']?.toString() ?? '';
      
      // Parse dates
      DateTime? submittedAt;
      DateTime? incidentDate;
      DateTime? updatedAt;
      
      try {
        if (rawData['submittedAt'] != null) {
          submittedAt = DateTime.parse(rawData['submittedAt'].toString());
        }
        if (rawData['date'] != null) {
          incidentDate = DateTime.parse(rawData['date'].toString());
        }
        if (rawData['updatedAt'] != null) {
          updatedAt = DateTime.parse(rawData['updatedAt'].toString());
        }
      } catch (e) {
        print('Error parsing dates: $e');
      }
      
      final now = DateTime.now();
      final generatedDate = DateFormat('MMMM dd, yyyy').format(now);
      final generatedTime = DateFormat('h:mm a').format(now);
      
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(50),
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header with Logo and Title
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Logo - use loaded image or placeholder
                    logoImage != null
                        ? pw.Image(
                            logoImage,
                            width: 60,
                            height: 60,
                            fit: pw.BoxFit.contain,
                          )
                        : pw.Container(
                            width: 60,
                            height: 60,
                            decoration: pw.BoxDecoration(
                              color: PdfColor.fromHex('#36599F'),
                              borderRadius: pw.BorderRadius.circular(8),
                            ),
                            child: pw.Center(
                              child: pw.Text(
                                'SR',
                                style: pw.TextStyle(
                                  color: PdfColors.white,
                                  fontSize: 24,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                    pw.SizedBox(width: 20),
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'OFFICIAL CASE REPORT',
                            style: pw.TextStyle(
                              fontSize: 24,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.black,
                            ),
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            'Safe Report System',
                            style: pw.TextStyle(
                              fontSize: 12,
                              color: PdfColors.grey700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          'Report Generated:',
                          style: pw.TextStyle(
                            fontSize: 10,
                            color: PdfColors.grey700,
                          ),
                        ),
                        pw.Text(
                          '$generatedDate at $generatedTime',
                          style: pw.TextStyle(
                            fontSize: 10,
                            color: PdfColors.grey700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 30),
                
                // Case ID and Status
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'Case ID:',
                          style: pw.TextStyle(
                            fontSize: 10,
                            color: PdfColors.grey700,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          reportId,
                          style: pw.TextStyle(
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.black,
                          ),
                        ),
                      ],
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: pw.BoxDecoration(
                        color: _getStatusColorWithOpacity(status, 0.2),
                        borderRadius: pw.BorderRadius.circular(4),
                      ),
                      child: pw.Text(
                        status,
                        style: pw.TextStyle(
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                          color: _getStatusColor(status),
                        ),
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 20),
                pw.Divider(color: PdfColor.fromHex('#36599F'), thickness: 2),
                pw.SizedBox(height: 20),
                
                // CASE INFORMATION
                pw.Text(
                  'CASE INFORMATION',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColor.fromHex('#36599F'),
                  ),
                ),
                pw.SizedBox(height: 15),
                
                _buildInfoRow('Date Reported:', _formatDateForPDF(submittedAt)),
                pw.SizedBox(height: 8),
                _buildInfoRow('Incident Date:', _formatDateForPDF(incidentDate)),
                pw.SizedBox(height: 8),
                pw.Row(
                  children: [
                    pw.Text('Priority: ', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: pw.BoxDecoration(
                        color: _getPriorityColorWithOpacity(priority, 0.2),
                        borderRadius: pw.BorderRadius.circular(4),
                      ),
                      child: pw.Text(
                        priority,
                        style: pw.TextStyle(
                          fontSize: 11,
                          fontWeight: pw.FontWeight.bold,
                          color: _getPriorityColor(priority),
                        ),
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 8),
                _buildInfoRow('Crime Type:', crimeType),
                pw.SizedBox(height: 8),
                _buildInfoRow('Location:', address),
                if (latitude.isNotEmpty && longitude.isNotEmpty) ...[
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'Coordinates: $latitude, $longitude',
                    style: pw.TextStyle(fontSize: 11, color: PdfColors.grey700),
                  ),
                ],
                if (district.isNotEmpty) ...[
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'District: $district',
                    style: pw.TextStyle(fontSize: 11, color: PdfColors.grey700),
                  ),
                ],
                pw.SizedBox(height: 20),
                pw.Divider(),
                pw.SizedBox(height: 20),
                
                // REPORTER INFORMATION
                pw.Text(
                  'REPORTER INFORMATION',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColor.fromHex('#36599F'),
                  ),
                ),
                pw.SizedBox(height: 15),
                _buildInfoRow('Reporter Name:', reporterName),
                pw.SizedBox(height: 8),
                if (reporterEmail.isNotEmpty) _buildInfoRow('Email:', reporterEmail),
                if (reporterEmail.isNotEmpty) pw.SizedBox(height: 8),
                if (reporterPhone.isNotEmpty) _buildInfoRow('Phone:', reporterPhone),
                pw.SizedBox(height: 20),
                pw.Divider(),
                pw.SizedBox(height: 20),
                
                // CASE DESCRIPTION
                pw.Text(
                  'CASE DESCRIPTION',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColor.fromHex('#36599F'),
                  ),
                ),
                pw.SizedBox(height: 15),
                pw.Container(
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey200,
                    borderRadius: pw.BorderRadius.circular(4),
                  ),
                  child: pw.Text(
                    description.isNotEmpty ? description : 'No description provided.',
                    style: pw.TextStyle(fontSize: 12),
                  ),
                ),
                
                if (witnessInfo.isNotEmpty) ...[
                  pw.SizedBox(height: 20),
                  pw.Divider(),
                  pw.SizedBox(height: 20),
                  pw.Text(
                    'WITNESS INFORMATION',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColor.fromHex('#36599F'),
                    ),
                  ),
                  pw.SizedBox(height: 15),
                  pw.Container(
                    padding: const pw.EdgeInsets.all(12),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.grey200,
                      borderRadius: pw.BorderRadius.circular(4),
                    ),
                    child: pw.Text(
                      witnessInfo,
                      style: pw.TextStyle(fontSize: 12),
                    ),
                  ),
                ],
                
                pw.SizedBox(height: 20),
                pw.Divider(),
                pw.SizedBox(height: 20),
                
                // ADDITIONAL INFORMATION
                pw.Text(
                  'ADDITIONAL INFORMATION',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColor.fromHex('#36599F'),
                  ),
                ),
                pw.SizedBox(height: 15),
                _buildInfoRow('Weather Condition:', weatherCondition),
                pw.SizedBox(height: 8),
                _buildInfoRow('Relationship to Crime:', crimeRelationship),
                if (updatedAt != null) ...[
                  pw.SizedBox(height: 8),
                  _buildInfoRow('Last Updated:', _formatDateForPDF(updatedAt)),
                ],
              ],
            );
          },
        ),
      );

      // Save to file
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'Official_Case_Report_${reportId}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File('${directory.path}/$fileName');
      final pdfBytes = await pdf.save();
      await file.writeAsBytes(pdfBytes);

      // Share the file
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Official Case Report: $title',
        subject: 'Case Report Export',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF downloaded successfully: $fileName'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e, stackTrace) {
      print('Error downloading PDF: $e');
      print('Stack trace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error downloading PDF: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () => _downloadReportPDF(report),
            ),
          ),
        );
      }
    }
  }
  
  pw.Widget _buildInfoRow(String label, String value) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: 120,
          child: pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.black,
            ),
          ),
        ),
        pw.Expanded(
          child: pw.Text(
            value,
            style: pw.TextStyle(fontSize: 12, color: PdfColors.black),
          ),
        ),
      ],
    );
  }
  
  String _formatDateForPDF(DateTime? date) {
    if (date == null) return 'Not available';
    try {
      return DateFormat('MMMM dd, yyyy \'at\' h:mm a').format(date);
    } catch (e) {
      return 'Invalid date';
    }
  }
  
  PdfColor _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return PdfColor.fromHex('#F59E0B'); // Orange
      case 'IN_PROGRESS':
      case 'REVIEWING':
        return PdfColor.fromHex('#8B5CF6'); // Purple
      case 'RESOLVED':
        return PdfColor.fromHex('#10B981'); // Green
      case 'CLOSED':
        return PdfColor.fromHex('#6B7280'); // Gray
      default:
        return PdfColor.fromHex('#6B7280');
    }
  }
  
  PdfColor _getStatusColorWithOpacity(String status, double opacity) {
    // Get the hex color for the status
    String hexColor;
    switch (status.toUpperCase()) {
      case 'PENDING':
        hexColor = '#F59E0B'; // Orange
        break;
      case 'IN_PROGRESS':
      case 'REVIEWING':
        hexColor = '#8B5CF6'; // Purple
        break;
      case 'RESOLVED':
        hexColor = '#10B981'; // Green
        break;
      case 'CLOSED':
        hexColor = '#6B7280'; // Gray
        break;
      default:
        hexColor = '#6B7280';
    }
    
    // Convert hex to RGB, blend with white, and create new color
    return _blendColorWithWhite(hexColor, opacity);
  }
  
  PdfColor _blendColorWithWhite(String hexColor, double opacity) {
    // Remove # if present
    String hex = hexColor.replaceAll('#', '');
    
    // Parse RGB values (0-255)
    int r = int.parse(hex.substring(0, 2), radix: 16);
    int g = int.parse(hex.substring(2, 4), radix: 16);
    int b = int.parse(hex.substring(4, 6), radix: 16);
    
    // Blend with white (255, 255, 255)
    // Formula: newColor = baseColor * opacity + white * (1 - opacity)
    double newR = (r * opacity + 255 * (1.0 - opacity)) / 255.0;
    double newG = (g * opacity + 255 * (1.0 - opacity)) / 255.0;
    double newB = (b * opacity + 255 * (1.0 - opacity)) / 255.0;
    
    // Clamp to 0-1 range and create PdfColor
    return PdfColor(
      newR.clamp(0.0, 1.0),
      newG.clamp(0.0, 1.0),
      newB.clamp(0.0, 1.0),
    );
  }
  
  PdfColor _getPriorityColor(String priority) {
    switch (priority.toUpperCase()) {
      case 'URGENT':
        return PdfColor.fromHex('#DC2626'); // Red
      case 'HIGH':
        return PdfColor.fromHex('#F59E0B'); // Orange
      case 'MEDIUM':
        return PdfColor.fromHex('#3B82F6'); // Blue
      case 'LOW':
        return PdfColor.fromHex('#10B981'); // Green
      default:
        return PdfColor.fromHex('#6B7280'); // Gray
    }
  }
  
  PdfColor _getPriorityColorWithOpacity(String priority, double opacity) {
    // Get the hex color for the priority
    String hexColor;
    switch (priority.toUpperCase()) {
      case 'URGENT':
        hexColor = '#DC2626'; // Red
        break;
      case 'HIGH':
        hexColor = '#F59E0B'; // Orange
        break;
      case 'MEDIUM':
        hexColor = '#3B82F6'; // Blue
        break;
      case 'LOW':
        hexColor = '#10B981'; // Green
        break;
      default:
        hexColor = '#6B7280'; // Gray
    }
    
    // Convert hex to RGB, blend with white, and create new color
    return _blendColorWithWhite(hexColor, opacity);
  }

  Future<void> _downloadReportDOCX(Map<String, dynamic> report) async {
    try {
      // Show loading indicator
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                ),
                SizedBox(width: 12),
                Text('Generating document...'),
              ],
            ),
            duration: Duration(seconds: 2),
          ),
        );
      }

      final rawData = report['rawData'] as Map<String, dynamic>? ?? {};
      
      // Extract report data
      final reportId = report['id']?.toString() ?? rawData['id']?.toString() ?? 'N/A';
      final title = report['type']?.toString() ?? rawData['title']?.toString() ?? 'Untitled Report';
      final description = report['desc']?.toString() ?? rawData['description']?.toString() ?? '';
      final status = report['status']?.toString() ?? rawData['status']?.toString() ?? 'PENDING';
      final priority = rawData['priority']?.toString() ?? 'NORMAL';
      final crimeType = rawData['crimeType']?.toString() ?? 'OTHER';
      final location = rawData['location'] as Map<String, dynamic>?;
      final address = location?['address']?.toString() ?? report['location']?.toString() ?? 'Unknown Location';
      final latitude = location?['latitude']?.toString() ?? '';
      final longitude = location?['longitude']?.toString() ?? '';
      final district = location?['district']?.toString() ?? '';
      final reporter = rawData['reporter'] as Map<String, dynamic>?;
      final reporterName = reporter?['fullName']?.toString() ?? (rawData['isAnonymous'] == true ? 'Anonymous' : 'Unknown');
      final reporterEmail = reporter?['email']?.toString() ?? '';
      final reporterPhone = reporter?['phoneNumber']?.toString() ?? '';
      final weatherCondition = rawData['weatherCondition']?.toString() ?? 'Not specified';
      final crimeRelationship = rawData['crimeRelationship']?.toString() ?? 'Not specified';
      final witnessInfo = rawData['witnessInfo']?.toString() ?? '';
      
      // Parse dates
      DateTime? submittedAt;
      DateTime? incidentDate;
      DateTime? updatedAt;
      
      try {
        if (rawData['submittedAt'] != null) {
          submittedAt = DateTime.parse(rawData['submittedAt'].toString());
        }
        if (rawData['date'] != null) {
          incidentDate = DateTime.parse(rawData['date'].toString());
        }
        if (rawData['updatedAt'] != null) {
          updatedAt = DateTime.parse(rawData['updatedAt'].toString());
        }
      } catch (e) {
        print('Error parsing dates: $e');
      }
      
      final now = DateTime.now();
      final generatedDate = DateFormat('MMMM dd, yyyy').format(now);
      final generatedTime = DateFormat('h:mm a').format(now);
      
      // Create formatted text document (DOCX alternative)
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'Official_Case_Report_${reportId}_${DateTime.now().millisecondsSinceEpoch}.txt';
      final file = File('${directory.path}/$fileName');
      
      final content = '''
═══════════════════════════════════════════════════════════════════════════════
                    OFFICIAL CASE REPORT
                          Safe Report System
═══════════════════════════════════════════════════════════════════════════════

Report Generated: $generatedDate at $generatedTime

Case ID: $reportId
Report Status: $status

───────────────────────────────────────────────────────────────────────────────
CASE INFORMATION
───────────────────────────────────────────────────────────────────────────────

Date Reported:     ${_formatDateForText(submittedAt)}
Incident Date:      ${_formatDateForText(incidentDate)}
Priority:           $priority
Crime Type:         $crimeType
Location:           $address
${latitude.isNotEmpty && longitude.isNotEmpty ? 'Coordinates:       $latitude, $longitude' : ''}
${district.isNotEmpty ? 'District:           $district' : ''}

───────────────────────────────────────────────────────────────────────────────
REPORTER INFORMATION
───────────────────────────────────────────────────────────────────────────────

Reporter Name:      $reporterName
${reporterEmail.isNotEmpty ? 'Email:              $reporterEmail' : ''}
${reporterPhone.isNotEmpty ? 'Phone:              $reporterPhone' : ''}

───────────────────────────────────────────────────────────────────────────────
CASE DESCRIPTION
───────────────────────────────────────────────────────────────────────────────

${description.isNotEmpty ? description : 'No description provided.'}

${witnessInfo.isNotEmpty ? '''
───────────────────────────────────────────────────────────────────────────────
WITNESS INFORMATION
───────────────────────────────────────────────────────────────────────────────

$witnessInfo
''' : ''}
───────────────────────────────────────────────────────────────────────────────
ADDITIONAL INFORMATION
───────────────────────────────────────────────────────────────────────────────

Weather Condition:      $weatherCondition
Relationship to Crime: $crimeRelationship
${updatedAt != null ? 'Last Updated:         ${_formatDateForText(updatedAt)}' : ''}

═══════════════════════════════════════════════════════════════════════════════
This is an official document generated by the Safe Report System.
═══════════════════════════════════════════════════════════════════════════════
''';
      
      await file.writeAsString(content);

      // Share the file
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Official Case Report: $title',
        subject: 'Case Report Export',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Document downloaded successfully: $fileName'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e, stackTrace) {
      print('Error downloading DOCX: $e');
      print('Stack trace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error downloading document: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () => _downloadReportDOCX(report),
            ),
          ),
        );
      }
    }
  }
  
  String _formatDateForText(DateTime? date) {
    if (date == null) return 'Not available';
    try {
      return DateFormat('MMMM dd, yyyy \'at\' h:mm a').format(date);
    } catch (e) {
      return 'Invalid date';
    }
  }

  Future<void> _shareSelectedReports() async {
    if (selectedReportIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No reports selected')),
      );
      return;
    }

    final selectedReports = reports.where((r) => selectedReportIds.contains(r['id'])).toList();

    String shareText = 'My Safety Reports\n\n';
    for (var report in selectedReports) {
      shareText += '${report['type']}\n';
      shareText += 'Location: ${report['location']}\n';
      shareText += 'Status: ${report['status']}\n';
      shareText += 'Description: ${report['desc']}\n';
      shareText += '---\n\n';
    }

    await Share.share(shareText, subject: 'Safety Reports');

    setState(() {
      isSelectionMode = false;
      selectedReportIds.clear();
    });
  }

  void _deleteSelectedReports() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Reports'),
        content: Text('Are you sure you want to delete ${selectedReportIds.length} report(s)?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                reports.removeWhere((r) => selectedReportIds.contains(r['id']));
                _applyFiltersAndSort();
                isSelectionMode = false;
                selectedReportIds.clear();
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Reports deleted'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Sort By',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF36599F),
                    ),
                  ),
                  const SizedBox(height: 20),
                  RadioListTile<String>(
                    title: const Text('Date'),
                    value: 'createdAt',
                    groupValue: sortBy,
                    activeColor: const Color(0xFF36599F),
                    onChanged: (value) {
                      setModalState(() => sortBy = value!);
                      setState(() {
                        sortBy = value!;
                        _loadReports();
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text('Status'),
                    value: 'status',
                    groupValue: sortBy,
                    activeColor: const Color(0xFF36599F),
                    onChanged: (value) {
                      setModalState(() => sortBy = value!);
                      setState(() {
                        sortBy = value!;
                        _loadReports();
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text('Type'),
                    value: 'title',
                    groupValue: sortBy,
                    activeColor: const Color(0xFF36599F),
                    onChanged: (value) {
                      setModalState(() => sortBy = value!);
                      setState(() {
                        sortBy = value!;
                        _loadReports();
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Ascending Order'),
                    value: sortAscending,
                    activeColor: const Color(0xFF36599F),
                    onChanged: (value) {
                      setModalState(() => sortAscending = value);
                      setState(() {
                        sortAscending = value;
                        _applyFiltersAndSort();
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF36599F),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Apply', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchBar(),
            const SizedBox(height: 12),
            _buildFilterAndSortRow(),
            const SizedBox(height: 15),
            if (isSelectionMode) _buildBulkActionBar(),
            Expanded(child: _buildReportList()),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF36599F),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(25),
          bottomRight: Radius.circular(25),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Reports',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 24,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Track your submissions',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              isSelectionMode ? Icons.close : Icons.checklist,
              color: Colors.white,
            ),
            onPressed: _toggleSelectionMode,
            tooltip: isSelectionMode ? 'Cancel' : 'Bulk Actions',
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(30, 20, 30, 0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search reports...',
          prefixIcon: const Icon(Icons.search, color: Color(0xFF36599F)),
          suffixIcon: searchQuery.isNotEmpty
              ? IconButton(
            icon: const Icon(Icons.clear, color: Colors.grey),
            onPressed: () {
              _searchController.clear();
              setState(() {
                searchQuery = '';
                _applyFiltersAndSort();
              });
            },
          )
              : null,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF36599F)),
          ),
        ),
        onChanged: (value) {
          setState(() {
            searchQuery = value;
            _applyFiltersAndSort();
          });
        },
      ),
    );
  }

  Widget _buildFilterAndSortRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterButton('All', 0),
                  const SizedBox(width: 12),
                  _buildFilterButton('Active', 1),
                  const SizedBox(width: 12),
                  _buildFilterButton('Resolved', 2),
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.sort, color: Color(0xFF36599F)),
            onPressed: _showSortOptions,
            tooltip: 'Sort',
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String label, int index) {
    final bool selected = _selectedFilter == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = index;
          _applyFiltersAndSort();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF36599F) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? const Color(0xFF36599F) : Colors.grey[300]!,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.grey[600],
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildBulkActionBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(30, 0, 30, 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF36599F).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Checkbox(
            value: selectedReportIds.length == filteredReports.length && filteredReports.isNotEmpty,
            onChanged: (value) => _selectAll(),
            activeColor: const Color(0xFF36599F),
          ),
          Text(
            '${selectedReportIds.length} selected',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf, size: 20),
            onPressed: _exportSelectedToPDF,
            tooltip: 'Export PDF',
          ),
          IconButton(
            icon: const Icon(Icons.share, size: 20),
            onPressed: _shareSelectedReports,
            tooltip: 'Share',
          ),
          IconButton(
            icon: const Icon(Icons.delete, size: 20, color: Colors.red),
            onPressed: _deleteSelectedReports,
            tooltip: 'Delete',
          ),
        ],
      ),
    );
  }

  Widget _buildReportList() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF36599F),
        ),
      );
    }

    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading reports',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _loadReports(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF36599F),
              ),
              child: const Text('Retry', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }

    if (filteredReports.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              searchQuery.isNotEmpty ? Icons.search_off : Icons.description_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              searchQuery.isNotEmpty ? 'No reports found' : 'No reports yet',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _handleRefresh,
      color: const Color(0xFF36599F),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
        itemCount: filteredReports.length,
        separatorBuilder: (_, __) => const SizedBox(height: 15),
        itemBuilder: (context, i) {
          final r = filteredReports[i];
          return _buildReportCard(r);
        },
      ),
    );
  }

  Widget _buildReportCard(Map<String, dynamic> report) {
    final String type = report['type'];
    final String status = report['status'];
    final String location = report['location'];
    final String time = report['time'];
    final String desc = report['desc'];
    final String id = report['id'];
    final bool isSelected = selectedReportIds.contains(id);

    Color statusColor;
    String statusText;
    Color statusTextColor;
    String buttonText;
    Color buttonColor;
    Color buttonTextColor;

    // Handle backend status values (PENDING, SUBMITTED, IN_PROGRESS, REVIEWING, RESOLVED, CLOSED)
    final statusUpper = status.toUpperCase();
    switch (statusUpper) {
      case 'PENDING':
      case 'SUBMITTED':
        statusColor = const Color(0xFFFDE68A);
        statusText = statusUpper;
        statusTextColor = const Color(0xFF92400E);
        buttonText = 'View Details';
        buttonColor = const Color(0xFFEAB308);
        buttonTextColor = const Color(0xFFCA8A04);
        break;
      case 'IN_PROGRESS':
      case 'REVIEWING':
        statusColor = const Color(0xFF93C5FD);
        statusText = statusUpper.replaceAll('_', ' ');
        statusTextColor = const Color(0xFF1E40AF);
        buttonText = 'View Details';
        buttonColor = const Color(0xFF36599F);
        buttonTextColor = const Color(0xFF36599F);
        break;
      case 'RESOLVED':
      case 'CLOSED':
        statusColor = const Color(0xFF86EFAC);
        statusText = statusUpper;
        statusTextColor = const Color(0xFF15803D);
        buttonText = 'View Resolution';
        buttonColor = const Color(0xFF10B981);
        buttonTextColor = const Color(0xFF10B981);
        break;
      default:
        statusColor = Colors.grey[300]!;
        statusText = status;
        statusTextColor = Colors.grey[600]!;
        buttonText = 'View';
        buttonColor = Colors.grey[500]!;
        buttonTextColor = Colors.grey[600]!;
    }

    return GestureDetector(
      onTap: isSelectionMode ? () => _toggleReportSelection(id) : null,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: isSelected ? const Color(0xFF36599F) : Colors.transparent,
            width: isSelected ? 2 : 0,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        if (isSelectionMode)
                          Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: Checkbox(
                              value: isSelected,
                              onChanged: (value) => _toggleReportSelection(id),
                              activeColor: const Color(0xFF36599F),
                            ),
                          ),
                        Expanded(
                          child: Text(
                            type,
                            style: const TextStyle(
                              color: Color(0xFF36599F),
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(
                        color: statusTextColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.location_on, color: Color(0xFFEF4444), size: 16),
                  const SizedBox(width: 6),
                  Text(
                    '$location • $time',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                desc,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[700],
                  height: 1.4,
                ),
              ),
              if (!isSelectionMode) ...[
                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 36,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ReportDetailsScreen(
                                  reportId: id,
                                  reportData: report['rawData'],
                                ),
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: buttonColor, width: 1.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                          ),
                          child: Text(
                            buttonText,
                            style: TextStyle(
                              color: buttonTextColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.download, size: 20),
                      tooltip: 'Download',
                      onSelected: (value) {
                        if (value == 'pdf') {
                          _downloadReportPDF(report);
                        } else if (value == 'docx') {
                          _downloadReportDOCX(report);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'pdf',
                          child: Row(
                            children: [
                              Icon(Icons.picture_as_pdf, size: 20, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Download as PDF'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'docx',
                          child: Row(
                            children: [
                              Icon(Icons.description, size: 20, color: Colors.blue),
                              SizedBox(width: 8),
                              Text('Download as DOCX'),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      icon: const Icon(Icons.share, size: 20),
                      onPressed: () async {
                        final shareText = '$type\nLocation: $location\nStatus: $status\n\n$desc';
                        await Share.share(shareText, subject: 'Report: $type');
                      },
                      tooltip: 'Share',
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      height: 90,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home, 'Home', 0, false, () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const DashboardScreen()),
            );
          }),
          _buildNavItem(Icons.description, 'Reports', 1, true, () {}),
          _buildNavItem(Icons.message, 'Messages', 2, false, () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MessagesScreen()),
            );
          }),
          _buildNavItem(Icons.person, 'Profile', 3, false, () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE0E7FF) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF36599F) : Colors.grey[600],
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? const Color(0xFF36599F) : Colors.grey[600],
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}