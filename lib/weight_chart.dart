import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'supabase.dart';

class WeightChartPage extends StatefulWidget {
  const WeightChartPage({super.key});

  @override
  State<WeightChartPage> createState() => _WeightChartPageState();
}

class _WeightChartPageState extends State<WeightChartPage> {
  List<Map<String, dynamic>> records = [];
  List<FlSpot> chartSpots = [];
  bool isLoading = true;
  String? errorMessage;
  
  // Cached statistics
  int totalRecords = 0;
  double highestValue = 0;
  double lowestValue = 0;
  double averageValue = 0;
  double averageBMI = 0;
  
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
        print('Loading weight records for user_id: $userId');
        final data = await SupabaseRepository().getWeightRecords(
          userId,
          startDate: startDate,
          endDate: endDate,
        );
        print('Loaded ${data.length} weight records');
        
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
      print('Error loading weight records: $e');
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
    chartSpots.clear();
    if (data.isEmpty) return;

    for (int i = 0; i < data.length; i++) {
      double? weight = data[i]['weight']?.toDouble();
      if (weight != null) {
        chartSpots.add(FlSpot(i.toDouble(), weight));
      }
    }

    // Sort by index to ensure proper ordering
    chartSpots.sort((a, b) => a.x.compareTo(b.x));
  }

  void _calculateStatistics(List<Map<String, dynamic>> data) {
    if (data.isEmpty) {
      totalRecords = 0;
      highestValue = 0;
      lowestValue = 0;
      averageValue = 0;
      averageBMI = 0;
      return;
    }

    totalRecords = data.length;
    
    List<double> weights = data
        .map((r) => (r['weight'] as num?)?.toDouble())
        .whereType<double>()
        .toList();
    
    List<double> bmis = data
        .map((r) => (r['bmi'] as num?)?.toDouble())
        .whereType<double>()
        .toList();

    if (weights.isNotEmpty) {
      highestValue = weights.reduce((a, b) => a > b ? a : b);
      lowestValue = weights.reduce((a, b) => a < b ? a : b);
      averageValue = weights.reduce((a, b) => a + b) / weights.length;
    }

    if (bmis.isNotEmpty) {
      averageBMI = bmis.reduce((a, b) => a + b) / bmis.length;
    }
  }

  String _getBMIStatus(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }

  Color _getBMIColor(double bmi) {
    if (bmi < 18.5) return Colors.blue;
    if (bmi < 25) return Colors.green;
    if (bmi < 30) return Colors.orange;
    return Colors.red;
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        startDate = picked.start;
        endDate = picked.end;
        startDateController.text = 
            '${picked.start.year}-${picked.start.month.toString().padLeft(2, '0')}-${picked.start.day.toString().padLeft(2, '0')}';
        endDateController.text = 
            '${picked.end.year}-${picked.end.month.toString().padLeft(2, '0')}-${picked.end.day.toString().padLeft(2, '0')}';
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

  void _deleteRecord(int id) async {
    try {
      await SupabaseRepository().deleteWeight(id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Record deleted successfully')),
      );
      _loadRecords();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting record: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weight & BMI Tracking'),
        backgroundColor: Colors.blue[800],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(child: Text(errorMessage!))
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Date range filter
                        Card(
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: startDateController,
                                        readOnly: true,
                                        decoration: InputDecoration(
                                          hintText: 'Start Date',
                                          prefixIcon: const Icon(Icons.calendar_today),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: TextField(
                                        controller: endDateController,
                                        readOnly: true,
                                        decoration: InputDecoration(
                                          hintText: 'End Date',
                                          prefixIcon: const Icon(Icons.calendar_today),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: _selectDateRange,
                                        icon: const Icon(Icons.filter_alt),
                                        label: const Text('Filter'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blue[800],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: _clearFilters,
                                        icon: const Icon(Icons.clear),
                                        label: const Text('Clear'),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Statistics cards
                        if (records.isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Statistics',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    _StatCard(
                                      title: 'Total Records',
                                      value: '$totalRecords',
                                      color: Colors.blue,
                                    ),
                                    const SizedBox(width: 10),
                                    _StatCard(
                                      title: 'Highest',
                                      value: '${highestValue.toStringAsFixed(1)} kg',
                                      color: Colors.red,
                                    ),
                                    const SizedBox(width: 10),
                                    _StatCard(
                                      title: 'Lowest',
                                      value: '${lowestValue.toStringAsFixed(1)} kg',
                                      color: Colors.green,
                                    ),
                                    const SizedBox(width: 10),
                                    _StatCard(
                                      title: 'Average',
                                      value: '${averageValue.toStringAsFixed(1)} kg',
                                      color: Colors.purple,
                                    ),
                                    const SizedBox(width: 10),
                                    _StatCard(
                                      title: 'Avg BMI',
                                      value: averageBMI.toStringAsFixed(1),
                                      color: Colors.orange,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),

                        // Chart
                        if (chartSpots.isNotEmpty)
                          Card(
                            elevation: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Weight Trend',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  SizedBox(
                                    height: 300,
                                    child: LineChart(
                                      LineChartData(
                                        gridData: FlGridData(
                                          show: true,
                                          drawVerticalLine: true,
                                          horizontalInterval: 10,
                                          verticalInterval: chartSpots.length > 1
                                              ? (chartSpots.length / 5).ceil().toDouble()
                                              : 1,
                                        ),
                                        titlesData: FlTitlesData(
                                          show: true,
                                          topTitles: const AxisTitles(
                                            sideTitles: SideTitles(showTitles: false),
                                          ),
                                          rightTitles: const AxisTitles(
                                            sideTitles: SideTitles(showTitles: false),
                                          ),
                                          bottomTitles: AxisTitles(
                                            sideTitles: SideTitles(
                                              showTitles: true,
                                              reservedSize: 30,
                                              interval: (chartSpots.length / 5).ceil().toDouble(),
                                              getTitlesWidget: (value, meta) {
                                                int index = value.toInt();
                                                if (index < 0 || index >= records.length) {
                                                  return const Text('');
                                                }
                                                final date = records[index]['time'];
                                                if (date == null) return const Text('');
                                                final dateTime = DateTime.parse(date);
                                                return Text(
                                                  '${dateTime.month}/${dateTime.day}',
                                                  style: const TextStyle(fontSize: 10),
                                                );
                                              },
                                            ),
                                          ),
                                          leftTitles: AxisTitles(
                                            sideTitles: SideTitles(
                                              showTitles: true,
                                              reservedSize: 40,
                                              getTitlesWidget: (value, meta) {
                                                return Text(
                                                  '${value.toInt()}',
                                                  style: const TextStyle(fontSize: 10),
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                        borderData: FlBorderData(show: true),
                                        lineBarsData: [
                                          LineChartBarData(
                                            spots: chartSpots,
                                            isCurved: true,
                                            color: Colors.blue,
                                            barWidth: 3,
                                            isStrokeCapRound: true,
                                            dotData: const FlDotData(show: true),
                                            belowBarData: BarAreaData(
                                              show: true,
                                              color: Colors.blue.withOpacity(0.3),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20.0),
                              child: Text('No weight records found'),
                            ),
                          ),

                        const SizedBox(height: 20),

                        // Records list
                        if (records.isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Recent Records',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: records.length,
                                itemBuilder: (context, index) {
                                  final record = records[index];
                                  final weight = record['weight']?.toDouble() ?? 0.0;
                                  final bmi = record['bmi']?.toDouble() ?? 0.0;
                                  final comment = record['comment'] ?? 'No comment';
                                  final time = record['time'] ?? 'Unknown';
                                  
                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 10),
                                    child: ListTile(
                                      title: Text('${weight.toStringAsFixed(1)} kg'),
                                      subtitle: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('BMI: ${bmi.toStringAsFixed(1)} - ${_getBMIStatus(bmi)}'),
                                          Text('Date: $time'),
                                          Text('Note: $comment'),
                                        ],
                                      ),
                                      trailing: IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        onPressed: () => _deleteRecord(record['id']),
                                      ),
                                      tileColor: _getBMIColor(bmi).withOpacity(0.1),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
    );
  }
}

class LineBarData {
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
