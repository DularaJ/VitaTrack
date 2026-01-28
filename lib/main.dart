import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    home: MyHome(),
  ));
}

class MyHome extends StatelessWidget {
  const MyHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("VitaTrack"),
        backgroundColor: Colors.amber,
        centerTitle: false,
        actions: [
          Icon(Icons.personal_injury),
          Container(width: 20, height: 20, color: Colors.transparent),
        ],
      ),
    );
  }
}
