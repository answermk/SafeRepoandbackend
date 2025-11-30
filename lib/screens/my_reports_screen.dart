import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
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
  String sortBy = 'date'; // date, status, type
  bool sortAscending = false;
  final TextEditingController _searchController = TextEditingController();

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

  Future<void> _loadReports() async {
    print('Loading reports from backend...');
    print('Filter: ${_getFilterText()}');

    // Placeholder data - TODO: Replace with backend data
    setState(() {
      reports = [
        {
          'id': '1',
          'type': 'Suspicious Person',
          'status': 'REVIEWING',
          'location': '123 Main Street',
          'time': '2 hours ago',
          'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
          'desc': 'Individual loitering around school entrance...'
        },
        {
          'id': '2',
          'type': 'Vehicle Activity',
          'status': 'RESOLVED',
          'location': 'Oak Street',
          'time': 'Yesterday',
          'timestamp': DateTime.now().subtract(const Duration(days: 1)),
          'desc': 'Vehicle circling neighbourhood multiple times...'
        },
        {
          'id': '3',
          'type': 'Abandoned Package',
          'status': 'SUBMITTED',
          'location': 'City Park',
          'time': '3 days ago',
          'timestamp': DateTime.now().subtract(const Duration(days: 3)),
          'desc': 'Suspicious backpack left unattended...'
        },
        {
          'id': '4',
          'type': 'Vandalism',
          'status': 'REVIEWING',
          'location': 'Downtown',
          'time': '1 week ago',
          'timestamp': DateTime.now().subtract(const Duration(days: 7)),
          'desc': 'Graffiti on public property...'
        },
      ];
      _applyFiltersAndSort();
    });
  }

  void _applyFiltersAndSort() {
    // Apply status filter
    List<Map<String, dynamic>> temp = List.from(reports);

    if (_selectedFilter == 1) {
      temp = temp.where((r) => r['status'] == 'REVIEWING' || r['status'] == 'SUBMITTED').toList();
    } else if (_selectedFilter == 2) {
      temp = temp.where((r) => r['status'] == 'RESOLVED').toList();
    }

    // Apply search filter
    if (searchQuery.isNotEmpty) {
      temp = temp.where((r) {
        final type = (r['type'] as String).toLowerCase();
        final location = (r['location'] as String).toLowerCase();
        final desc = (r['desc'] as String).toLowerCase();
        final query = searchQuery.toLowerCase();
        return type.contains(query) || location.contains(query) || desc.contains(query);
      }).toList();
    }

    // Apply sorting
    temp.sort((a, b) {
      int comparison = 0;
      switch (sortBy) {
        case 'date':
          comparison = (a['timestamp'] as DateTime).compareTo(b['timestamp'] as DateTime);
          break;
        case 'status':
          comparison = (a['status'] as String).compareTo(b['status'] as String);
          break;
        case 'type':
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
    await _loadReports();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Reports refreshed'),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.green,
      ),
    );
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
                    value: 'date',
                    groupValue: sortBy,
                    activeColor: const Color(0xFF36599F),
                    onChanged: (value) {
                      setModalState(() => sortBy = value!);
                      setState(() {
                        sortBy = value!;
                        _applyFiltersAndSort();
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
                        _applyFiltersAndSort();
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text('Type'),
                    value: 'type',
                    groupValue: sortBy,
                    activeColor: const Color(0xFF36599F),
                    onChanged: (value) {
                      setModalState(() => sortBy = value!);
                      setState(() {
                        sortBy = value!;
                        _applyFiltersAndSort();
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

    switch (status) {
      case 'REVIEWING':
        statusColor = const Color(0xFF93C5FD);
        statusText = 'REVIEWING';
        statusTextColor = const Color(0xFF1E40AF);
        buttonText = 'View Details';
        buttonColor = const Color(0xFF36599F);
        buttonTextColor = const Color(0xFF36599F);
        break;
      case 'RESOLVED':
        statusColor = const Color(0xFF86EFAC);
        statusText = 'RESOLVED';
        statusTextColor = const Color(0xFF15803D);
        buttonText = 'View Resolution';
        buttonColor = const Color(0xFF10B981);
        buttonTextColor = const Color(0xFF10B981);
        break;
      case 'SUBMITTED':
        statusColor = const Color(0xFFFDE68A);
        statusText = 'SUBMITTED';
        statusTextColor = const Color(0xFF92400E);
        buttonText = 'Pending';
        buttonColor = const Color(0xFFEAB308);
        buttonTextColor = const Color(0xFFCA8A04);
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
                                builder: (context) => const ReportDetailsScreen(),
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