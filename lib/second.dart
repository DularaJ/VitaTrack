import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'supabase.dart';
import 'pressure_chart.dart';
import 'sugar_chart.dart';
import 'weight_chart.dart';

class SecondPage extends StatefulWidget {
  const SecondPage({super.key});

  @override
  State<SecondPage> createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  String selectedFilter = 'All';
  int selectedTab = 0;
  
  DateTime? startDate;
  DateTime? endDate;
  TextEditingController startDateController = TextEditingController();
  TextEditingController endDateController = TextEditingController();

  // User data
  Map<String, dynamic>? userData;
  String? userUuid;
  bool isLoading = true;

  // Database data
  List<Map<String, dynamic>> bloodPressureData = [];
  List<Map<String, dynamic>> bloodSugarData = [];
  
  // Original data for filtering
  List<Map<String, dynamic>> originalBloodPressureData = [];
  List<Map<String, dynamic>> originalBloodSugarData = [];
  
  // Filter state
  bool isFiltered = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      userUuid = prefs.getString('user_uuid');

      if (userUuid != null) {
        userData = await SupabaseRepository().getUser(userUuid!);
        if (userData != null) {
          await _loadRecords();
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load user data: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _loadRecords() async {
    if (userData == null) return;

    try {
      final pressureRecords = await SupabaseRepository().getPressureRecords(userData!['id']);
      final sugarRecords = await SupabaseRepository().getSugarRecords(userData!['id']);

      setState(() {
        originalBloodPressureData = pressureRecords.map((record) {
          final dateTime = DateTime.parse(record['time']);
          return {
            'id': record['id'],
            'pressure': '${record['value']?.toStringAsFixed(0) ?? 'N/A'} mmHg',
            'date': '${dateTime.day}/${dateTime.month}/${dateTime.year}',
            'time': '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}',
            'comment': record['comment'] ?? '',
            'count': pressureRecords.indexOf(record) + 1,
          };
        }).toList();

        originalBloodSugarData = sugarRecords.map((record) {
          final dateTime = DateTime.parse(record['time']);
          return {
            'id': record['id'],
            'blood': '${record['value']?.toStringAsFixed(1) ?? 'N/A'} mg/dL',
            'date': '${dateTime.day}/${dateTime.month}/${dateTime.year}',
            'time': '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}',
            'comment': record['comment'] ?? '',
            'count': sugarRecords.indexOf(record) + 1,
          };
        }).toList();

        // Initially show all records
        bloodPressureData = List.from(originalBloodPressureData);
        bloodSugarData = List.from(originalBloodSugarData);
        isFiltered = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load records: $e')),
      );
    }
  }

  // Filter records by date range
  void _filterRecords() {
    if (startDate == null && endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select at least one date to filter')),
      );
      return;
    }

    setState(() {
      // Filter blood pressure records
      bloodPressureData = originalBloodPressureData.where((record) {
        final recordDate = _parseDateString(record['date']);
        if (recordDate == null) return false;

        bool matchesStart = startDate == null || !recordDate.isBefore(DateTime(startDate!.year, startDate!.month, startDate!.day));
        bool matchesEnd = endDate == null || !recordDate.isAfter(DateTime(endDate!.year, endDate!.month, endDate!.day));

        return matchesStart && matchesEnd;
      }).toList();

      // Filter blood sugar records
      bloodSugarData = originalBloodSugarData.where((record) {
        final recordDate = _parseDateString(record['date']);
        if (recordDate == null) return false;

        bool matchesStart = startDate == null || !recordDate.isBefore(DateTime(startDate!.year, startDate!.month, startDate!.day));
        bool matchesEnd = endDate == null || !recordDate.isAfter(DateTime(endDate!.year, endDate!.month, endDate!.day));

        return matchesStart && matchesEnd;
      }).toList();

      // Update counts after filtering
      for (int i = 0; i < bloodPressureData.length; i++) {
        bloodPressureData[i]['count'] = i + 1;
      }
      for (int i = 0; i < bloodSugarData.length; i++) {
        bloodSugarData[i]['count'] = i + 1;
      }

      isFiltered = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Filtered records: ${bloodPressureData.length} pressure, ${bloodSugarData.length} sugar records found'),
        backgroundColor: Colors.green,
      ),
    );
  }

  // Clear filter and show all records
  void _clearFilter() {
    setState(() {
      bloodPressureData = List.from(originalBloodPressureData);
      bloodSugarData = List.from(originalBloodSugarData);
      isFiltered = false;
      startDate = null;
      endDate = null;
      startDateController.clear();
      endDateController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Filter cleared - showing all records')),
    );
  }

  // Helper method to parse date string (DD/MM/YYYY) to DateTime
  DateTime? _parseDateString(String dateStr) {
    try {
      final parts = dateStr.split('/');
      if (parts.length != 3) return null;
      return DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
    } catch (e) {
      return null;
    }
  }

  // Get the maximum date from all records
  DateTime _getMaxRecordDate() {
    DateTime maxDate = DateTime.now();
    
    // Check blood pressure records
    for (var record in originalBloodPressureData) {
      final recordDate = _parseDateString(record['date']);
      if (recordDate != null && recordDate.isAfter(maxDate)) {
        maxDate = recordDate;
      }
    }
    
    // Check blood sugar records
    for (var record in originalBloodSugarData) {
      final recordDate = _parseDateString(record['date']);
      if (recordDate != null && recordDate.isAfter(maxDate)) {
        maxDate = recordDate;
      }
    }
    
    return maxDate;
  }

  // Delete function
  void _deleteRecord(int index, bool isBloodPressure) async {
    if (userData == null) return;

    final record = isBloodPressure ? bloodPressureData[index] : bloodSugarData[index];
    final recordId = record['id'];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Record'),
          content: Text('Are you sure you want to delete this record?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  if (isBloodPressure) {
                    await SupabaseRepository().deletePressure(recordId);
                  } else {
                    await SupabaseRepository().deleteSugar(recordId);
                  }

                  // Reload records after deletion
                  await _loadRecords();

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Record deleted successfully')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to delete record: $e')),
                  );
                }
                Navigator.of(context).pop();
              },
              child: Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  // Edit function for Blood Pressure
  void _editBloodPressureRecord(int index) async {
    if (userData == null) return;

    final record = bloodPressureData[index];
    // Extract numeric value from the display string (remove ' mmHg')
    final currentValue = record['pressure'].replaceAll(' mmHg', '');
    TextEditingController pressureController = TextEditingController(text: currentValue);
    TextEditingController commentController = TextEditingController(text: record['comment']);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Blood Pressure Record'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: pressureController,
                  decoration: InputDecoration(
                    labelText: 'Blood Pressure Value (mmHg)',
                    hintText: 'e.g., 120.5',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
                SizedBox(height: 15),
                TextField(
                  controller: commentController,
                  decoration: InputDecoration(
                    labelText: 'Comment',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                pressureController.dispose();
                commentController.dispose();
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  double? pressureValue = double.tryParse(pressureController.text);
                  if (pressureValue == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Invalid pressure value')),
                    );
                    return;
                  }

                  await SupabaseRepository().updatePressure(
                    id: record['id'],
                    value: pressureValue,
                    comment: commentController.text.isEmpty ? null : commentController.text,
                  );

                  // Reload records after update
                  await _loadRecords();

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Record updated successfully')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to update record: $e')),
                  );
                }

                pressureController.dispose();
                commentController.dispose();
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // Edit function for Blood Sugar
  void _editBloodSugarRecord(int index) async {
    if (userData == null) return;

    final record = bloodSugarData[index];
    // Extract numeric value from the display string (remove ' mg/dL')
    final currentValue = record['blood'].replaceAll(' mg/dL', '');
    TextEditingController bloodSugarController = TextEditingController(text: currentValue);
    TextEditingController commentController = TextEditingController(text: record['comment']);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Blood Sugar Record'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: bloodSugarController,
                  decoration: InputDecoration(
                    labelText: 'Blood Sugar Value',
                    hintText: 'e.g., 110.5',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
                SizedBox(height: 15),
                TextField(
                  controller: commentController,
                  decoration: InputDecoration(
                    labelText: 'Comment',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                bloodSugarController.dispose();
                commentController.dispose();
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  double? sugarValue = double.tryParse(bloodSugarController.text);
                  if (sugarValue == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Invalid blood sugar value')),
                    );
                    return;
                  }

                  await SupabaseRepository().updateSugar(
                    id: record['id'],
                    value: sugarValue,
                    comment: commentController.text.isEmpty ? null : commentController.text,
                  );

                  // Reload records after update
                  await _loadRecords();

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Record updated successfully')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to update record: $e')),
                  );
                }

                bloodSugarController.dispose();
                commentController.dispose();
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> selectStartDate() async {
    final DateTime maxRecordDate = _getMaxRecordDate();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: maxRecordDate,
    );
    if (picked != null) {
      setState(() {
        startDate = picked;
        startDateController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  Future<void> selectEndDate() async {
    final DateTime maxRecordDate = _getMaxRecordDate();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: endDate ?? DateTime.now(),
      firstDate: startDate ?? DateTime(2020),
      lastDate: maxRecordDate,
    );
    if (picked != null) {
      setState(() {
        endDate = picked;
        endDateController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width >= 900;
    final bool isTablet = MediaQuery.of(context).size.width >= 600 && MediaQuery.of(context).size.width < 900;
    final double horizontalPadding = isDesktop ? 60 : (isTablet ? 40 : 20);
    final double sectionTitleFontSize = isDesktop ? 28 : (isTablet ? 24 : 22);
    final double buttonFontSize = isDesktop ? 16 : 14;
    final double tabFontSize = isDesktop ? 18 : 16;

    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'Health Records',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: isDesktop ? 32 : 24,
            ),
          ),
          backgroundColor: Colors.teal,
          elevation: 2,
        ),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Health Records',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: isDesktop ? 32 : 24,
          ),
        ),
        backgroundColor: Colors.teal,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //View Chart Button
            Text(
              'View Charts',
              style: TextStyle(
                fontSize: sectionTitleFontSize,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            SizedBox(height: 10),

            // Responsive Chart Buttons
            isDesktop
                ? Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => PressureChartPage()),
                            );
                          },
                          icon: Icon(Icons.show_chart, color: Colors.white),
                          label: Text(
                            'Blood Pressure\nChart',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white, fontSize: buttonFontSize),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: EdgeInsets.symmetric(vertical: 25),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 15),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => SugarChartPage()),
                            );
                          },
                          icon: Icon(Icons.analytics, color: Colors.white),
                          label: Text(
                            'Blood Sugar\nChart',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white, fontSize: buttonFontSize),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            padding: EdgeInsets.symmetric(vertical: 25),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 15),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => WeightChartPage()),
                            );
                          },
                          icon: Icon(Icons.monitor_weight, color: Colors.white),
                          label: Text(
                            'Weight\nChart',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white, fontSize: buttonFontSize),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple,
                            padding: EdgeInsets.symmetric(vertical: 25),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => PressureChartPage()),
                            );
                          },
                          icon: Icon(Icons.show_chart, color: Colors.white),
                          label: Text(
                            'Blood Pressure Chart',
                            style: TextStyle(color: Colors.white, fontSize: buttonFontSize),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: EdgeInsets.symmetric(vertical: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 15),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => SugarChartPage()),
                            );
                          },
                          icon: Icon(Icons.analytics, color: Colors.white),
                          label: Text(
                            'Blood Sugar Chart',
                            style: TextStyle(color: Colors.white, fontSize: buttonFontSize),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            padding: EdgeInsets.symmetric(vertical: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 15),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => WeightChartPage()),
                            );
                          },
                          icon: Icon(Icons.monitor_weight, color: Colors.white),
                          label: Text(
                            'Weight Chart',
                            style: TextStyle(color: Colors.white, fontSize: buttonFontSize),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple,
                            padding: EdgeInsets.symmetric(vertical: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
            SizedBox(height: 30),

            //Date Range Filter Section
            Text(
              'Filter by Date Range',
              style: TextStyle(
                fontSize: sectionTitleFontSize,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            SizedBox(height: 15),

            // Date Range Selection
            isDesktop
                ? Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: startDateController,
                          readOnly: true,
                          onTap: selectStartDate,
                          decoration: InputDecoration(
                            labelText: 'Start Date',
                            hintText: 'Select start date',
                            prefixIcon: Icon(Icons.calendar_today, color: Colors.teal),
                            suffixIcon: Icon(Icons.arrow_drop_down, color: Colors.teal),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.teal, width: 2),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 15),
                      Expanded(
                        child: TextField(
                          controller: endDateController,
                          readOnly: true,
                          onTap: selectEndDate,
                          decoration: InputDecoration(
                            labelText: 'End Date',
                            hintText: 'Select end date',
                            prefixIcon: Icon(Icons.calendar_today, color: Colors.teal),
                            suffixIcon: Icon(Icons.arrow_drop_down, color: Colors.teal),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.teal, width: 2),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 15),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _filterRecords,
                          icon: Icon(Icons.filter_list, color: Colors.white),
                          label: Text(
                            'Filter',
                            style: TextStyle(color: Colors.white, fontSize: buttonFontSize),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            padding: EdgeInsets.symmetric(vertical: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 15),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: isFiltered ? _clearFilter : null,
                          icon: Icon(Icons.clear, color: Colors.white),
                          label: Text(
                            'Clear Filter',
                            style: TextStyle(color: Colors.white, fontSize: buttonFontSize),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isFiltered ? Colors.red : Colors.grey,
                            padding: EdgeInsets.symmetric(vertical: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      TextField(
                        controller: startDateController,
                        readOnly: true,
                        onTap: selectStartDate,
                        decoration: InputDecoration(
                          labelText: 'Start Date',
                          hintText: 'Select start date',
                          prefixIcon: Icon(Icons.calendar_today, color: Colors.teal),
                          suffixIcon: Icon(Icons.arrow_drop_down, color: Colors.teal),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.teal, width: 2),
                          ),
                        ),
                      ),
                      SizedBox(height: 15),
                      TextField(
                        controller: endDateController,
                        readOnly: true,
                        onTap: selectEndDate,
                        decoration: InputDecoration(
                          labelText: 'End Date',
                          hintText: 'Select end date',
                          prefixIcon: Icon(Icons.calendar_today, color: Colors.teal),
                          suffixIcon: Icon(Icons.arrow_drop_down, color: Colors.teal),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.teal, width: 2),
                          ),
                        ),
                      ),
                      SizedBox(height: 15),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _filterRecords,
                          icon: Icon(Icons.filter_list, color: Colors.white),
                          label: Text(
                            'Filter',
                            style: TextStyle(color: Colors.white, fontSize: buttonFontSize),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            padding: EdgeInsets.symmetric(vertical: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 15),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: isFiltered ? _clearFilter : null,
                          icon: Icon(Icons.clear, color: Colors.white),
                          label: Text(
                            'Clear Filter',
                            style: TextStyle(color: Colors.white, fontSize: buttonFontSize),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isFiltered ? Colors.red : Colors.grey,
                            padding: EdgeInsets.symmetric(vertical: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
            SizedBox(height: 30),
            
            // Tabs for Blood Pressure and Blood Sugar
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedTab = 0;
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 15),
                        decoration: BoxDecoration(
                          color: selectedTab == 0 ? Colors.red : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'Blood Pressure',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: selectedTab == 0 ? Colors.white : Colors.red,
                            fontSize: tabFontSize,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedTab = 1;
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 15),
                        decoration: BoxDecoration(
                          color: selectedTab == 1 ? Colors.orange : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'Blood Sugar',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: selectedTab == 1 ? Colors.white : Colors.orange,
                            fontSize: tabFontSize,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedTab = 2;
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 15),
                        decoration: BoxDecoration(
                          color: selectedTab == 2 ? Colors.purple : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'Weight',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: selectedTab == 2 ? Colors.white : Colors.purple,
                            fontSize: tabFontSize,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            
            // Blood Pressure Tab Content
            if (selectedTab == 0) ...[
              bloodPressureData.isEmpty
                  ? Center(
                      child: Padding(
                        padding: EdgeInsets.all(30),
                        child: Text(
                          'No Blood Pressure records found',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: bloodPressureData.length,
                      itemBuilder: (context, index) {
                        return Card(
                          elevation: 2,
                          margin: EdgeInsets.only(bottom: 15),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.red[100],
                              child: Icon(Icons.favorite, color: Colors.red),
                            ),
                            title: Text(
                              bloodPressureData[index]['pressure'],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.red,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Date: ${bloodPressureData[index]['date']} | Time: ${bloodPressureData[index]['time']}',
                                  style: TextStyle(fontSize: 12),
                                ),
                                if (bloodPressureData[index]['comment'].isNotEmpty)
                                  Text(
                                    'Comment: ${bloodPressureData[index]['comment']}',
                                    style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                                  ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () => _editBloodPressureRecord(index),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _deleteRecord(index, true),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ],
            
            // Blood Sugar Tab Content
            if (selectedTab == 1) ...[
              bloodSugarData.isEmpty
                  ? Center(
                      child: Padding(
                        padding: EdgeInsets.all(30),
                        child: Text(
                          'No Blood Sugar records found',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: bloodSugarData.length,
                      itemBuilder: (context, index) {
                        return Card(
                          elevation: 2,
                          margin: EdgeInsets.only(bottom: 15),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.orange[100],
                              child: Icon(Icons.opacity, color: Colors.orange),
                            ),
                            title: Text(
                              bloodSugarData[index]['blood'],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.orange,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Date: ${bloodSugarData[index]['date']} | Time: ${bloodSugarData[index]['time']}',
                                  style: TextStyle(fontSize: 12),
                                ),
                                if (bloodSugarData[index]['comment'].isNotEmpty)
                                  Text(
                                    'Comment: ${bloodSugarData[index]['comment']}',
                                    style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                                  ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () => _editBloodSugarRecord(index),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _deleteRecord(index, false),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ],
            
            // Weight Tab Content
            if (selectedTab == 2) ...[
              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                  child: Column(
                    children: [
                      Text(
                        'View your Weight tracking chart',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => WeightChartPage(),
                            ),
                          );
                        },
                        icon: Icon(Icons.show_chart),
                        label: Text('Open Weight Chart'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                          padding: EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
