import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'supabase.dart';

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
    }
  }

  Future<void> selectEndDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: endDate ?? DateTime.now(),
      firstDate: startDate ?? DateTime(2020),
      lastDate: DateTime.now(),
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
                            // Function will be added by backend developer
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
                            // Function will be added by backend developer
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
                    ],
                  )
                : Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // Function will be added by backend developer
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
                            // Function will be added by backend developer
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
                            backgroundColor: isFiltered ? Colors.grey : Colors.grey[400],
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
                            'Filter Records',
                            style: TextStyle(color: Colors.white, fontSize: buttonFontSize),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            padding: EdgeInsets.symmetric(vertical: 15),
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
                            backgroundColor: isFiltered ? Colors.grey : Colors.grey[400],
                            padding: EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
            SizedBox(height: 30),
            isDesktop
                ? Row(
                    children: [
                      Expanded(
                        child: _buildTab(
                          isSelected: selectedTab == 0,
                          icon: Icons.favorite,
                          label: 'Blood Pressure',
                          onTap: () => setState(() => selectedTab = 0),
                          fontSize: tabFontSize,
                          backgroundColor: Colors.red,
                        ),
                      ),
                      SizedBox(width: 15),
                      Expanded(
                        child: _buildTab(
                          isSelected: selectedTab == 1,
                          icon: Icons.opacity,
                          label: 'Blood Sugar',
                          onTap: () => setState(() => selectedTab = 1),
                          fontSize: tabFontSize,
                          backgroundColor: Colors.orange,
                        ),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildTab(
                              isSelected: selectedTab == 0,
                              icon: Icons.favorite,
                              label: 'Blood Pressure',
                              onTap: () => setState(() => selectedTab = 0),
                              fontSize: tabFontSize,
                              backgroundColor: Colors.red,
                            ),
                          ),
                          SizedBox(width: 15),
                          Expanded(
                            child: _buildTab(
                              isSelected: selectedTab == 1,
                              icon: Icons.opacity,
                              label: 'Blood Sugar',
                              onTap: () => setState(() => selectedTab = 1),
                              fontSize: tabFontSize,
                              backgroundColor: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
            SizedBox(height: 30),

            // Data Tables Section
            selectedTab == 0
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Blood Pressure Records',
                        style: TextStyle(
                          fontSize: sectionTitleFontSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      SizedBox(height: 15),
                      _buildBloodPressureTable(isDesktop),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Blood Sugar Records',
                        style: TextStyle(
                          fontSize: sectionTitleFontSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                      SizedBox(height: 15),
                      _buildBloodSugarTable(isDesktop),
                    ],
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildBloodPressureTable(bool isDesktop) {
    return Container(
      width: double.infinity,
      child: isDesktop
          ? DataTable(
              columnSpacing: 20,
              columns: const [
                DataColumn(label: Text('Count', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Pressure', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Date', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Time', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Comment', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
              ],
              rows: bloodPressureData
                  .asMap()
                  .entries
                  .map(
                    (entry) {
                      int index = entry.key;
                      var record = entry.value;
                      return DataRow(
                        cells: [
                          DataCell(Text(record['count'].toString())),
                          DataCell(
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.red[50],
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(color: Colors.red),
                              ),
                              child: Text(
                                record['pressure'],
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ),
                          DataCell(Text(record['date'])),
                          DataCell(Text(record['time'])),
                          DataCell(Text(record['comment'])),
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit, color: Colors.blue, size: 30),
                                  onPressed: () => _editBloodPressureRecord(index),
                                  tooltip: 'Edit',
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red, size: 30),
                                  onPressed: () => _deleteRecord(index, true),
                                  tooltip: 'Delete',
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  )
                  .toList(),
            )
          : Column(
              children: bloodPressureData
                  .asMap()
                  .entries
                  .map(
                    (entry) {
                      int index = entry.key;
                      var record = entry.value;
                      return _buildTableCard(
                        count: record['count'],
                        mainValue: record['pressure'],
                        date: record['date'],
                        time: record['time'],
                        comment: record['comment'],
                        color: Colors.red,
                        onEdit: () => _editBloodPressureRecord(index),
                        onDelete: () => _deleteRecord(index, true),
                      );
                    },
                  )
                  .toList(),
            ),
    );
  }

  Widget _buildBloodSugarTable(bool isDesktop) {
    return Container(
      width: double.infinity,
      child: isDesktop
          ? DataTable(
              columnSpacing: 20,
              columns: const [
                DataColumn(label: Text('Count', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Blood Sugar', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Date', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Time', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Comment', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
              ],
              rows: bloodSugarData
                  .asMap()
                  .entries
                  .map(
                    (entry) {
                      int index = entry.key;
                      var record = entry.value;
                      return DataRow(
                        cells: [
                          DataCell(Text(record['count'].toString())),
                          DataCell(
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.orange[50],
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(color: Colors.orange),
                              ),
                              child: Text(
                                record['blood'],
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange,
                                ),
                              ),
                            ),
                          ),
                          DataCell(Text(record['date'])),
                          DataCell(Text(record['time'])),
                          DataCell(Text(record['comment'])),
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit, color: Colors.blue, size: 30),
                                  onPressed: () => _editBloodSugarRecord(index),
                                  tooltip: 'Edit',
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red, size: 30),
                                  onPressed: () => _deleteRecord(index, false),
                                  tooltip: 'Delete',
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  )
                  .toList(),
            )
          : Column(
              children: bloodSugarData
                  .asMap()
                  .entries
                  .map(
                    (entry) {
                      int index = entry.key;
                      var record = entry.value;
                      return _buildTableCard(
                        count: record['count'],
                        mainValue: record['blood'],
                        date: record['date'],
                        time: record['time'],
                        comment: record['comment'],
                        color: Colors.orange,
                        onEdit: () => _editBloodSugarRecord(index),
                        onDelete: () => _deleteRecord(index, false),
                      );
                    },
                  )
                  .toList(),
            ),
    );
  }

  Widget _buildTableCard({
    required int count,
    required String mainValue,
    required String date,
    required String time,
    required String comment,
    required Color color,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Record #$count',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  mainValue,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 16, color: color),
              SizedBox(width: 5),
              Text(date, style: TextStyle(fontSize: 12)),
              SizedBox(width: 20),
              Icon(Icons.access_time, size: 16, color: color),
              SizedBox(width: 5),
              Text(time, style: TextStyle(fontSize: 12)),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.note, size: 16, color: color),
              SizedBox(width: 5),
              Expanded(
                child: Text(
                  'Comment: $comment',
                  style: TextStyle(fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton.icon(
                onPressed: onEdit,
                icon: Icon(Icons.edit, size: 16),
                label: Text('Edit'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  minimumSize: Size(0, 0),
                ),
              ),
              SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: onDelete,
                icon: Icon(Icons.delete, size: 16),
                label: Text('Delete'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  minimumSize: Size(0, 0),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTab({
    required bool isSelected,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required double fontSize,
    required Color backgroundColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: isSelected ? backgroundColor : Colors.grey[200],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey,
            ),
            SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: fontSize,
                color: isSelected ? Colors.white : Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    startDateController.dispose();
    endDateController.dispose();
    super.dispose();
  }
}