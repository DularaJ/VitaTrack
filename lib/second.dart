import 'package:flutter/material.dart';

class SecondPage extends StatefulWidget {
  const SecondPage({super.key});

  @override
  State<SecondPage> createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  String selectedFilter = 'All';
  int selectedTab = 0;

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

            //Tab Section
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
            SizedBox(height: 20),
          ],
        ),
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
}