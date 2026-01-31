import 'package:flutter/material.dart';
import 'second.dart';

void main() {
  runApp(const MyApp());
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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'VitaTrack',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //Patient Info Section
            Center(
              child: Container(
                width: 120,
                height: 120,
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
                  radius: 60,
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
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            SizedBox(height: 15),
            
            //Display Name
            Container(
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.teal[50],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.teal, width: 2),
              ),
              child: Row(
                children: [
                  Icon(Icons.person, color: Colors.teal, size: 30),
                  SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Patient Name',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        'Anuz Nowa',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 15),
            
            //Display Age
            Container(
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.teal[50],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.teal, width: 2),
              ),
              child: Row(
                children: [
                  Icon(Icons.cake, color: Colors.teal, size: 30),
                  SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Age',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        '30 years',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),
            
            //Add Blood Pressure Section
            Text(
              'Add Blood Pressure',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            SizedBox(height: 15),
            
            //select date
            TextField(
              controller: dateController,
              readOnly: true,
              onTap: selectDate,
              decoration: InputDecoration(
                labelText: 'Date',
                hintText: '28/01/2026',
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
            
            //select time
            TextField(
              controller: timeController,
              readOnly: true,
              onTap: selectTime,
              decoration: InputDecoration(
                labelText: 'Time',
                hintText: '10:30 AM',
                prefixIcon: Icon(Icons.access_time, color: Colors.teal),
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
            
            //insert Blood Pressure
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
            
            // Save Blood Pressure
            Container(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Function will be added by backend developer
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
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.orange[700],
              ),
            ),
            SizedBox(height: 15),
            
            TextField(
              controller: dateController,
              readOnly: true,
              onTap: selectDate,
              decoration: InputDecoration(
                labelText: 'Date',
                hintText: '28/01/2026',
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
              controller: timeController,
              readOnly: true,
              onTap: selectTime,
              decoration: InputDecoration(
                labelText: 'Time',
                hintText: '10:30 AM',
                prefixIcon: Icon(Icons.access_time, color: Colors.teal),
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
            
            Container(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Function will be added by backend developer
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
            SizedBox(height: 30),
            
            Divider(thickness: 2, color: Colors.teal),
            SizedBox(height: 20),
            
            // View Records 
            Container(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (context) => SecondPage(),
                  //   ),
                  // );
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
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}