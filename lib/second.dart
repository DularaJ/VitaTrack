import 'package:flutter/material.dart';

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

  // Sample Blood Pressure Data
  final List<Map<String, dynamic>> bloodPressureData = [
    {'pressure': '120/80', 'date': '28/01/2026', 'time': '10:30 AM', 'comment': 'Normal', 'count': 1},
    {'pressure': '125/85', 'date': '27/01/2026', 'time': '09:15 AM', 'comment': 'Slightly elevated', 'count': 2},
    {'pressure': '118/78', 'date': '26/01/2026', 'time': '02:45 PM', 'comment': 'Good', 'count': 3},
    {'pressure': '130/90', 'date': '25/01/2026', 'time': '11:00 AM', 'comment': 'Monitor closely', 'count': 4},
    {'pressure': '122/82', 'date': '24/01/2026', 'time': '08:30 AM', 'comment': 'Normal', 'count': 5},
  ];

  // Sample Blood Sugar Data
  final List<Map<String, dynamic>> bloodSugarData = [
    {'blood': '110 mg/dL', 'date': '28/01/2026', 'time': '10:30 AM', 'comment': 'Normal', 'count': 1},
    {'blood': '125 mg/dL', 'date': '27/01/2026', 'time': '09:15 AM', 'comment': 'Slightly high', 'count': 2},
    {'blood': '105 mg/dL', 'date': '26/01/2026', 'time': '02:45 PM', 'comment': 'Good', 'count': 3},
    {'blood': '135 mg/dL', 'date': '25/01/2026', 'time': '11:00 AM', 'comment': 'High', 'count': 4},
    {'blood': '100 mg/dL', 'date': '24/01/2026', 'time': '08:30 AM', 'comment': 'Optimal', 'count': 5},
  ];

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
                          onPressed: () {
                            // Filter logic here
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Filtering from ${startDateController.text} to ${endDateController.text}'),
                              ),
                            );
                          },
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
                          onPressed: () {
                            // Filter logic here
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Filtering from ${startDateController.text} to ${endDateController.text}'),
                              ),
                            );
                          },
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
              ],
              rows: bloodPressureData
                  .map(
                    (record) => DataRow(
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
                      ],
                    ),
                  )
                  .toList(),
            )
          : Column(
              children: bloodPressureData
                  .map(
                    (record) => _buildTableCard(
                      count: record['count'],
                      mainValue: record['pressure'],
                      date: record['date'],
                      time: record['time'],
                      comment: record['comment'],
                      color: Colors.red,
                    ),
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
              ],
              rows: bloodSugarData
                  .map(
                    (record) => DataRow(
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
                      ],
                    ),
                  )
                  .toList(),
            )
          : Column(
              children: bloodSugarData
                  .map(
                    (record) => _buildTableCard(
                      count: record['count'],
                      mainValue: record['blood'],
                      date: record['date'],
                      time: record['time'],
                      comment: record['comment'],
                      color: Colors.orange,
                    ),
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