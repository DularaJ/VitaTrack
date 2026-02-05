import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'supabase.dart';

class SugarChartPage extends StatefulWidget {
  const SugarChartPage({super.key});

  @override
  State<SugarChartPage> createState() => _SugarChartPageState();
}

class _SugarChartPageState extends State<SugarChartPage> {
  List<Map<String, dynamic>> records = [];
  List<FlSpot> chartSpots = [];
  bool isLoading = true;
  String? errorMessage;
  
  // Cached statistics
  int totalRecords = 0;
  double highestValue = 0;
  double averageValue = 0;
  
  DateTime? startDate;
  DateTime? endDate;
  final TextEditingController startDateController = TextEditingController();
  final TextEditingController endDateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  @override
  void dispose() {
    startDateController.dispose();
    endDateController.dispose();
    super.dispose();
  }

  Future<void> _loadRecords() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      int? userId = prefs.getInt('user_id');
      String? userUuid = prefs.getString('user_uuid');
      
      if (userId == null && userUuid != null) {
        final userData = await SupabaseRepository().getUser(userUuid);
        if (userData != null) {
          userId = userData['id'];
          await prefs.setInt('user_id', userId!);
        }
      }
      
      if (userId != null) {
        print('Loading sugar records for user_id: $userId');
        final data = await SupabaseRepository().getSugarRecords(
          userId,
          startDate: startDate,
          endDate: endDate,
        );
        print('Loaded ${data.length} sugar records');
        
        // Pre-calculate chart spots and statistics
        _calculateChartSpots(data);
        _calculateStatistics(data);
        
        setState(() {
          records = data;
        });
      } else {
        setState(() {
          errorMessage = 'Please sign in to view your records';
        });
      }
    } catch (e) {
      print('Error loading sugar records: $e');
      setState(() {
        errorMessage = 'Error loading records: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _calculateChartSpots(List<Map<String, dynamic>> data) {
    final List<FlSpot> spots = [];
    for (int i = 0; i < data.length; i++) {
      final record = data[i];
      final value = record['value'];
      if (value != null) {
        // Use index for x-axis for proper spacing, y-axis is the value
        spots.add(FlSpot(i.toDouble(), value.toDouble()));
      }
    }
    chartSpots = spots;
  }

  void _calculateStatistics(List<Map<String, dynamic>> data) {
    final values = data.map((r) => r['value'] as double?).where((v) => v != null).toList();
    totalRecords = values.length;
    
    if (values.isNotEmpty) {
      highestValue = values.fold<double>(0, (a, b) => a! > b! ? a : b)!;
      averageValue = values.fold<double>(0, (a, b) => a! + b!) / values.length;
    } else {
      highestValue = 0;
      averageValue = 0;
    }
  }

  Future<void> _selectStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        startDate = picked;
        startDateController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
      _loadRecords();
    }
  }

  Future<void> _selectEndDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: endDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        endDate = picked;
        endDateController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
      _loadRecords();
    }
  }

  void _clearFilters() {
    setState(() {
      startDate = null;
      endDate = null;
      startDateController.clear();
      endDateController.clear();
    });
    _loadRecords();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width >= 900;
    final bool isTablet = MediaQuery.of(context).size.width >= 600 && MediaQuery.of(context).size.width < 900;
    final double horizontalPadding = isDesktop ? 60 : (isTablet ? 40 : 20);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Blood Sugar History',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.orange,
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadRecords,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date Filter Section
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Filter by Date',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: startDateController,
                            decoration: InputDecoration(
                              labelText: 'Start Date',
                              hintText: 'DD/MM/YYYY',
                              prefixIcon: const Icon(Icons.date_range, color: Colors.orange),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              filled: true,
                              fillColor: Colors.orange[50],
                            ),
                            readOnly: true,
                            onTap: _selectStartDate,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            controller: endDateController,
                            decoration: InputDecoration(
                              labelText: 'End Date',
                              hintText: 'DD/MM/YYYY',
                              prefixIcon: const Icon(Icons.date_range, color: Colors.orange),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              filled: true,
                              fillColor: Colors.orange[50],
                            ),
                            readOnly: true,
                            onTap: _selectEndDate,
                          ),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton.icon(
                          onPressed: _clearFilters,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                          ),
                          icon: const Icon(Icons.clear, color: Colors.white),
                          label: const Text(
                            'Clear',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Error message
            if (errorMessage != null)
              Card(
                color: Colors.orange[100],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.error, color: Colors.orange),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          errorMessage!,
                          style: TextStyle(color: Colors.orange),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            
            // Loading indicator
            if (isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                ),
              ),
            
            // Statistics Card
            if (!isLoading && records.isNotEmpty)
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          const Text(
                            'Total Records',
                            style: TextStyle(color: Colors.grey),
                          ),
                          Text(
                            '$totalRecords',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          const Text(
                            'Highest',
                            style: TextStyle(color: Colors.grey),
                          ),
                          Text(
                            '${highestValue.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          const Text(
                            'Average',
                            style: TextStyle(color: Colors.grey),
                          ),
                          Text(
                            '${averageValue.toStringAsFixed(1)}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 20),
            
            // Chart Section
            if (!isLoading)
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Blood Sugar Trend',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 300,
                        child: records.isEmpty
                            ? Center(
                                child: Text(
                                  errorMessage ?? 'No records found',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              )
                            : LineChart(
                                LineChartData(
                                  minX: 0,
                                  maxX: chartSpots.isNotEmpty ? (chartSpots.length - 1).toDouble() : 0,
                                  gridData: FlGridData(
                                    show: true,
                                    drawVerticalLine: true,
                                    horizontalInterval: 20,
                                    verticalInterval: 1,
                                  ),
                                  titlesData: FlTitlesData(
                                    show: true,
                                    rightTitles: const AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                    topTitles: const AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        interval: 1,
                                        getTitlesWidget: (value, meta) {
                                          final index = value.toInt();
                                          if (index >= 0 && index < records.length) {
                                            final time = records[index]['time'];
                                            if (time != null) {
                                              final dateTime = DateTime.parse(time);
                                              return Text(
                                                '${dateTime.day}/${dateTime.month}',
                                                style: const TextStyle(fontSize: 10, color: Colors.grey),
                                              );
                                            }
                                          }
                                          return const Text('', style: TextStyle(fontSize: 10));
                                        },
                                      ),
                                    ),
                                    leftTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        interval: 20,
                                        getTitlesWidget: (value, meta) {
                                          return Text(
                                            '${value.toInt()}',
                                            style: const TextStyle(fontSize: 10, color: Colors.grey),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  borderData: FlBorderData(
                                    show: true,
                                    border: Border.all(color: Colors.grey[300]!),
                                  ),
                                  lineBarsData: [
                                    LineChartBarData(
                                      spots: chartSpots,
                                      isCurved: false,
                                      color: Colors.orange,
                                      barWidth: 2,
                                      dotData: FlDotData(
                                        show: true,
                                        getDotPainter: (spot, percent, barData, index) {
                                          return FlDotCirclePainter(
                                            radius: 4,
                                            color: Colors.orange,
                                            strokeColor: Colors.white,
                                            strokeWidth: 2,
                                          );
                                        },
                                      ),
                                      belowBarData: BarAreaData(
                                        show: true,
                                        color: Colors.orange.withOpacity(0.1),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 20),
            
            // History List
            if (!isLoading && records.isNotEmpty)
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'History',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: records.length,
                        itemBuilder: (context, index) {
                          final record = records[index];
                          final time = record['time'];
                          final value = record['value'];
                          final comment = record['comment'];
                          
                          String dateStr = '';
                          if (time != null) {
                            final dateTime = DateTime.parse(time);
                            dateStr = '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
                          }
                          
                          return ListTile(
                            leading: const Icon(Icons.opacity, color: Colors.orange),
                            title: Text(
                              value != null ? '$value mg/dL' : 'N/A',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(dateStr),
                                if (comment != null && comment.isNotEmpty)
                                  Text('Comment: $comment'),
                              ],
                            ),
                            trailing: Text(
                              '#${record['id']}',
                              style: const TextStyle(color: Colors.grey),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
