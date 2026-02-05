import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'second.dart';
import 'profile.dart';
import 'supabase.dart';

Future<void> main() async {
  await Supabase.initialize(
    url: 'https://pjvrtberjycotelairrz.supabase.co',
    anonKey: 'sb_publishable_z1vq4lTS61JBzwke_JVz5Q_m79n-NrB',
  );
  runApp(MyApp());
  print("supabase initialized");
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  TextEditingController bloodPressureController = TextEditingController();
  TextEditingController bloodSugarController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController timeController = TextEditingController();

  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();

  String? userUuid;
  bool isLoading = true;
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      userUuid = prefs.getString('user_uuid');
      if (userUuid == null) {
        userUuid = const Uuid().v4();
        await prefs.setString('user_uuid', userUuid!);
      }
    } catch (e) {
      userUuid = const Uuid().v4();
    }

    if (userUuid != null) {
      try {
        userData = await SupabaseRepository().getUser(userUuid!);
      } catch (e) {
        // Keep userData as null
      }
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        dateController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  Future<void> selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
        timeController.text = "${picked.hour}:${picked.minute.toString().padLeft(2, '0')}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width >= 900;
    final bool isTablet = MediaQuery.of(context).size.width >= 600 && MediaQuery.of(context).size.width < 900;
    final double horizontalPadding = isDesktop ? 60 : (isTablet ? 40 : 20);
    final double sectionTitleFontSize = isDesktop ? 28 : (isTablet ? 24 : 22);
    final double labelFontSize = isDesktop ? 18 : (isTablet ? 16 : 14);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'VitaTrack',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: isDesktop ? 32 : 24,
          ),
        ),
        backgroundColor: Colors.teal,
        elevation: 2,
        actions: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: IconButton(
              icon: Icon(Icons.account_circle, color: Colors.white, size: 30),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfilePage()),
                );
              },
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //Patient Info Section
            Center(
              child: Container(
                width: isDesktop ? 160 : 120,
                height: isDesktop ? 160 : 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.teal, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 3,
                      blurRadius: 7,
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: isDesktop ? 80 : 60,
                  backgroundColor: Colors.teal[100],
                  backgroundImage: AssetImage('assets/patient.jpg'),
                  child: null,
                ),
              ),
            ),
            SizedBox(height: 20),
            
            Text(
              'Patient Information',
              style: TextStyle(
                fontSize: sectionTitleFontSize,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            SizedBox(height: 15),
            
            //Display Name and Age in responsive grid
            isDesktop
                ? Row(
                    children: [
                      Expanded(child: _buildInfoCard(
                        icon: Icons.person,
                        label: 'Patient Name',
                        value: userData?['fullname'] ?? 'Anuz Nowa',
                        labelFontSize: labelFontSize,
                      )),
                      SizedBox(width: 20),
                      Expanded(child: _buildInfoCard(
                        icon: Icons.cake,
                        label: 'Age',
                        value: '${userData?['age'] ?? '30'} years',
                        labelFontSize: labelFontSize,
                      )),
                    ],
                  )
                : Column(
                    children: [
                      _buildInfoCard(
                        icon: Icons.person,
                        label: 'Patient Name',
                        value: userData?['fullname'] ?? 'Anuz Nowa',
                        labelFontSize: labelFontSize,
                      ),
                      SizedBox(height: 15),
                      _buildInfoCard(
                        icon: Icons.cake,
                        label: 'Age',
                        value: '${userData?['age'] ?? '30'} years',
                        labelFontSize: labelFontSize,
                      ),
                    ],
                  ),
            SizedBox(height: 30),
            
            // Two Column Layout for Desktop, Single for Mobile/Tablet
            isDesktop
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Blood Pressure Section
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Add Blood Pressure',
                              style: TextStyle(
                                fontSize: sectionTitleFontSize,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                            SizedBox(height: 15),
                            _buildDateTimeTextField(
                              controller: dateController,
                              label: 'Date',
                              hint: '28/01/2026',
                              icon: Icons.calendar_today,
                              onTap: selectDate,
                            ),
                            SizedBox(height: 15),
                            _buildDateTimeTextField(
                              controller: timeController,
                              label: 'Time',
                              hint: '10:30 AM',
                              icon: Icons.access_time,
                              onTap: selectTime,
                            ),
                            SizedBox(height: 15),
                            TextField(
                              controller: bloodPressureController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Blood Pressure (mmHg)',
                                hintText: 'e.g., 120/80',
                                prefixIcon: Icon(Icons.favorite, color: Colors.red),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: Colors.teal, width: 2),
                                ),
                              ),
                            ),
                            SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () async {
                                  if (userData == null || userUuid == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('User data not loaded')),
                                    );
                                    return;
                                  }

                                  String bp = bloodPressureController.text.trim();
                                  if (bp.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Please enter blood pressure')),
                                    );
                                    return;
                                  }

                                  String dateStr = dateController.text.trim();
                                  String timeStr = timeController.text.trim();
                                  if (dateStr.isEmpty || timeStr.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Please select date and time')),
                                    );
                                    return;
                                  }

                                  try {
                                    // Parse blood pressure (expecting format like "120/80")
                                    List<String> parts = bp.split('/');
                                    double? systolic = double.tryParse(parts[0]);
                                    if (systolic == null) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Invalid blood pressure format')),
                                      );
                                      return;
                                    }

                                    // Parse date and time
                                    List<String> dateParts = dateStr.split('/');
                                    List<String> timeParts = timeStr.split(':');
                                    DateTime dt = DateTime(
                                      int.parse(dateParts[2]), // year
                                      int.parse(dateParts[1]), // month
                                      int.parse(dateParts[0]), // day
                                      int.parse(timeParts[0]), // hour
                                      int.parse(timeParts[1]), // minute
                                    );
                                    String timestamp = dt.toIso8601String();

                                    // Save to database
                                    await SupabaseRepository().insertPressure(
                                      userId: userData!['id'],
                                      time: timestamp,
                                      comment: bp,
                                      value: systolic,
                                    );

                                    // Clear fields
                                    bloodPressureController.clear();
                                    dateController.clear();
                                    timeController.clear();

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Blood pressure record saved successfully!'),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Failed to save record: $e'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  padding: EdgeInsets.symmetric(vertical: 15),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: Text(
                                  'Save Blood Pressure Record',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 30),
                      // Blood Sugar Section
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Enter Blood Sugar Record',
                              style: TextStyle(
                                fontSize: sectionTitleFontSize,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange[700],
                              ),
                            ),
                            SizedBox(height: 15),
                            _buildDateTimeTextField(
                              controller: dateController,
                              label: 'Date',
                              hint: '28/01/2026',
                              icon: Icons.calendar_today,
                              onTap: selectDate,
                            ),
                            SizedBox(height: 15),
                            _buildDateTimeTextField(
                              controller: timeController,
                              label: 'Time',
                              hint: '10:30 AM',
                              icon: Icons.access_time,
                              onTap: selectTime,
                            ),
                            SizedBox(height: 15),
                            TextField(
                              controller: bloodSugarController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Blood Sugar (mg/dL)',
                                hintText: 'e.g., 110',
                                prefixIcon: Icon(Icons.opacity, color: Colors.orange),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: Colors.teal, width: 2),
                                ),
                              ),
                            ),
                            SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () async {
                                  if (userData == null || userUuid == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('User data not loaded')),
                                    );
                                    return;
                                  }

                                  String bs = bloodSugarController.text.trim();
                                  if (bs.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Please enter blood sugar level')),
                                    );
                                    return;
                                  }

                                  String dateStr = dateController.text.trim();
                                  String timeStr = timeController.text.trim();
                                  if (dateStr.isEmpty || timeStr.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Please select date and time')),
                                    );
                                    return;
                                  }

                                  try {
                                    // Parse blood sugar value
                                    double? sugarValue = double.tryParse(bs);
                                    if (sugarValue == null) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Invalid blood sugar format')),
                                      );
                                      return;
                                    }

                                    // Parse date and time
                                    List<String> dateParts = dateStr.split('/');
                                    List<String> timeParts = timeStr.split(':');
                                    DateTime dt = DateTime(
                                      int.parse(dateParts[2]), // year
                                      int.parse(dateParts[1]), // month
                                      int.parse(dateParts[0]), // day
                                      int.parse(timeParts[0]), // hour
                                      int.parse(timeParts[1]), // minute
                                    );
                                    String timestamp = dt.toIso8601String();

                                    // Save to database
                                    await SupabaseRepository().insertSugar(
                                      userId: userData!['id'],
                                      time: timestamp,
                                      comment: bs,
                                      value: sugarValue,
                                    );

                                    // Clear fields
                                    bloodSugarController.clear();
                                    dateController.clear();
                                    timeController.clear();

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Blood sugar record saved successfully!'),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Failed to save record: $e'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                  padding: EdgeInsets.symmetric(vertical: 15),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: Text(
                                  'Save Blood Sugar Record',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //Add Blood Pressure Section
                      Text(
                        'Add Blood Pressure',
                        style: TextStyle(
                          fontSize: sectionTitleFontSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      SizedBox(height: 15),
                      _buildDateTimeTextField(
                        controller: dateController,
                        label: 'Date',
                        hint: '28/01/2026',
                        icon: Icons.calendar_today,
                        onTap: selectDate,
                      ),
                      SizedBox(height: 15),
                      _buildDateTimeTextField(
                        controller: timeController,
                        label: 'Time',
                        hint: '10:30 AM',
                        icon: Icons.access_time,
                        onTap: selectTime,
                      ),
                      SizedBox(height: 15),
                      TextField(
                        controller: bloodPressureController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Blood Pressure (mmHg)',
                          hintText: 'e.g., 120/80',
                          prefixIcon: Icon(Icons.favorite, color: Colors.red),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.teal, width: 2),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (userData == null || userUuid == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('User data not loaded')),
                              );
                              return;
                            }

                            String bp = bloodPressureController.text.trim();
                            if (bp.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Please enter blood pressure')),
                              );
                              return;
                            }

                            String dateStr = dateController.text.trim();
                            String timeStr = timeController.text.trim();
                            if (dateStr.isEmpty || timeStr.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Please select date and time')),
                              );
                              return;
                            }

                            try {
                              // Parse blood pressure (expecting format like "120/80")
                              List<String> parts = bp.split('/');
                              double? systolic = double.tryParse(parts[0]);
                              if (systolic == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Invalid blood pressure format')),
                                );
                                return;
                              }

                              // Parse date and time
                              List<String> dateParts = dateStr.split('/');
                              List<String> timeParts = timeStr.split(':');
                              DateTime dt = DateTime(
                                int.parse(dateParts[2]), // year
                                int.parse(dateParts[1]), // month
                                int.parse(dateParts[0]), // day
                                int.parse(timeParts[0]), // hour
                                int.parse(timeParts[1]), // minute
                              );
                              String timestamp = dt.toIso8601String();

                              // Save to database
                              await SupabaseRepository().insertPressure(
                                userId: userData!['id'],
                                time: timestamp,
                                comment: bp,
                                value: systolic,
                              );

                              // Clear fields
                              bloodPressureController.clear();
                              dateController.clear();
                              timeController.clear();

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Blood pressure record saved successfully!'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Failed to save record: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            'Save Blood Pressure Record',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 30),
                      // Add Blood Sugar Section
                      Text(
                        'Enter Blood Sugar Record',
                        style: TextStyle(
                          fontSize: sectionTitleFontSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange[700],
                        ),
                      ),
                      SizedBox(height: 15),
                      _buildDateTimeTextField(
                        controller: dateController,
                        label: 'Date',
                        hint: '28/01/2026',
                        icon: Icons.calendar_today,
                        onTap: selectDate,
                      ),
                      SizedBox(height: 15),
                      _buildDateTimeTextField(
                        controller: timeController,
                        label: 'Time',
                        hint: '10:30 AM',
                        icon: Icons.access_time,
                        onTap: selectTime,
                      ),
                      SizedBox(height: 15),
                      TextField(
                        controller: bloodSugarController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Blood Sugar (mg/dL)',
                          hintText: 'e.g., 110',
                          prefixIcon: Icon(Icons.opacity, color: Colors.orange),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.teal, width: 2),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (userData == null || userUuid == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('User data not loaded')),
                              );
                              return;
                            }

                            String bs = bloodSugarController.text.trim();
                            if (bs.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Please enter blood sugar level')),
                              );
                              return;
                            }

                            String dateStr = dateController.text.trim();
                            String timeStr = timeController.text.trim();
                            if (dateStr.isEmpty || timeStr.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Please select date and time')),
                              );
                              return;
                            }

                            try {
                              // Parse blood sugar value
                              double? sugarValue = double.tryParse(bs);
                              if (sugarValue == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Invalid blood sugar format')),
                                );
                                return;
                              }

                              // Parse date and time
                              List<String> dateParts = dateStr.split('/');
                              List<String> timeParts = timeStr.split(':');
                              DateTime dt = DateTime(
                                int.parse(dateParts[2]), // year
                                int.parse(dateParts[1]), // month
                                int.parse(dateParts[0]), // day
                                int.parse(timeParts[0]), // hour
                                int.parse(timeParts[1]), // minute
                              );
                              String timestamp = dt.toIso8601String();

                              // Save to database
                              await SupabaseRepository().insertSugar(
                                userId: userData!['id'],
                                time: timestamp,
                                comment: bs,
                                value: sugarValue,
                              );

                              // Clear fields
                              bloodSugarController.clear();
                              dateController.clear();
                              timeController.clear();

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Blood sugar record saved successfully!'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Failed to save record: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            padding: EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            'Save Blood Sugar Record',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
            SizedBox(height: 30),
            
            Divider(thickness: 2, color: Colors.teal),
            SizedBox(height: 20),
            
            // View Records 
            Center(
              child: SizedBox(
                width: isDesktop ? 400 : double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SecondPage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'View All Records & Charts',
                    style: TextStyle(
                      fontSize: isDesktop ? 16 : 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    required double labelFontSize,
  }) {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.teal[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.teal, width: 2),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.teal, size: 30),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: labelFontSize - 2,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: labelFontSize + 6,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateTimeTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return TextField(
      controller: controller,
      readOnly: true,
      onTap: onTap,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.teal),
        suffixIcon: Icon(Icons.arrow_drop_down, color: Colors.teal),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.teal, width: 2),
        ),
      ),
    );
  }
}