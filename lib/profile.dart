import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'supabase.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  TextEditingController nameController = TextEditingController(text: 'Anuz Nowa');
  TextEditingController ageController = TextEditingController(text: '30');
  TextEditingController emailController = TextEditingController(text: 'anuz@example.com');
  TextEditingController phoneController = TextEditingController(text: '+1-800-123-4567');
  TextEditingController addressController = TextEditingController(text: '123 Health Street, Medical City');
  TextEditingController bloodTypeController = TextEditingController(text: 'O+');

  String? userUuid;
  bool isLoading = true;
  bool isEditMode = false;

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
      // Fallback: generate UUID without persistence
      print('SharedPreferences not available, generating new UUID: $e');
      userUuid = const Uuid().v4();
    }

    // Load user data from Supabase
    if (userUuid != null) {
      try {
        final userData = await SupabaseRepository().getUser(userUuid!);
        if (userData != null) {
          nameController.text = userData['fullname'] ?? '';
          ageController.text = userData['age'] ?? '';
          emailController.text = userData['email'] ?? '';
          phoneController.text = userData['phone'] ?? '';
          addressController.text = userData['address'] ?? '';
          bloodTypeController.text = userData['bloodtype'] ?? '';
        }
      } catch (e) {
        // User not found or error, keep default values
        print('Error loading user data: $e');
      }
    }

    setState(() {
      isLoading = false;
    });
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
          'My Profile',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: isDesktop ? 32 : 24,
          ),
        ),
        backgroundColor: Colors.teal,
        elevation: 2,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header Section
            Center(
              child: Column(
                children: [
                  Container(
                    width: isDesktop ? 180 : 140,
                    height: isDesktop ? 180 : 140,
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
                      radius: isDesktop ? 90 : 70,
                      backgroundColor: Colors.teal[100],
                      backgroundImage: AssetImage('assets/patient.jpg'),
                      child: null,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    nameController.text.isEmpty ? 'User' : nameController.text,
                    style: TextStyle(
                      fontSize: sectionTitleFontSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Health ID: ${userUuid ?? 'N/A'}',
                    style: TextStyle(
                      fontSize: labelFontSize - 2,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),

            // Edit Button
            Center(
              child: SizedBox(
                width: isDesktop ? 300 : double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      isEditMode = !isEditMode;
                    });
                  },
                  icon: Icon(isEditMode ? Icons.close : Icons.edit, color: Colors.white),
                  label: Text(
                    isEditMode ? 'Cancel Edit' : 'Edit Profile',
                    style: TextStyle(
                      fontSize: labelFontSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 30),

            // Personal Information Section
            Text(
              'Personal Information',
              style: TextStyle(
                fontSize: sectionTitleFontSize,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            SizedBox(height: 15),

            // Personal Info Fields
            isDesktop
                ? Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          label: 'Full Name',
                          controller: nameController,
                          icon: Icons.person,
                          enabled: isEditMode,
                        ),
                      ),
                      SizedBox(width: 20),
                      Expanded(
                        child: _buildTextField(
                          label: 'Age',
                          controller: ageController,
                          icon: Icons.cake,
                          enabled: isEditMode,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      _buildTextField(
                        label: 'Full Name',
                        controller: nameController,
                        icon: Icons.person,
                        enabled: isEditMode,
                      ),
                      SizedBox(height: 15),
                      _buildTextField(
                        label: 'Age',
                        controller: ageController,
                        icon: Icons.cake,
                        enabled: isEditMode,
                        keyboardType: TextInputType.number,
                      ),
                    ],
                  ),
            SizedBox(height: 15),

            // Contact Information Section
            Text(
              'Contact Information',
              style: TextStyle(
                fontSize: sectionTitleFontSize,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            SizedBox(height: 15),

            // Contact Fields
            isDesktop
                ? Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          label: 'Email',
                          controller: emailController,
                          icon: Icons.email,
                          enabled: isEditMode,
                          keyboardType: TextInputType.emailAddress,
                        ),
                      ),
                      SizedBox(width: 20),
                      Expanded(
                        child: _buildTextField(
                          label: 'Phone Number',
                          controller: phoneController,
                          icon: Icons.phone,
                          enabled: isEditMode,
                          keyboardType: TextInputType.phone,
                        ),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      _buildTextField(
                        label: 'Email',
                        controller: emailController,
                        icon: Icons.email,
                        enabled: isEditMode,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      SizedBox(height: 15),
                      _buildTextField(
                        label: 'Phone Number',
                        controller: phoneController,
                        icon: Icons.phone,
                        enabled: isEditMode,
                        keyboardType: TextInputType.phone,
                      ),
                    ],
                  ),
            SizedBox(height: 15),

            _buildTextField(
              label: 'Address',
              controller: addressController,
              icon: Icons.location_on,
              enabled: isEditMode,
              maxLines: 2,
            ),
            SizedBox(height: 15),

            // Medical Information Section
            Text(
              'Medical Information',
              style: TextStyle(
                fontSize: sectionTitleFontSize,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            SizedBox(height: 15),

            _buildTextField(
              label: 'Blood Type',
              controller: bloodTypeController,
              icon: Icons.bloodtype,
              enabled: isEditMode,
            ),
            SizedBox(height: 15),

            // Info Cards for Health Status
            isDesktop
                ? Row(
                    children: [
                      Expanded(
                        child: _buildInfoCard(
                          title: 'Last BP Reading',
                          value: '120/80 mmHg',
                          icon: Icons.favorite,
                          color: Colors.red,
                        ),
                      ),
                      SizedBox(width: 20),
                      Expanded(
                        child: _buildInfoCard(
                          title: 'Last Sugar Level',
                          value: '110 mg/dL',
                          icon: Icons.opacity,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      _buildInfoCard(
                        title: 'Last BP Reading',
                        value: '120/80 mmHg',
                        icon: Icons.favorite,
                        color: Colors.red,
                      ),
                      SizedBox(height: 15),
                      _buildInfoCard(
                        title: 'Last Sugar Level',
                        value: '110 mg/dL',
                        icon: Icons.opacity,
                        color: Colors.orange,
                      ),
                    ],
                  ),
            SizedBox(height: 30),

            // Save Button (only visible in edit mode)
            if (isEditMode)
              Column(
                children: [
                  Center(
                    child: SizedBox(
                      width: isDesktop ? 300 : double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          if (userUuid == null) return;

                          print('Saving profile for UUID: $userUuid');

                          try {
                            final existingUser = await SupabaseRepository().getUser(userUuid!);
                            print('Existing user: $existingUser');

                            if (existingUser != null) {
                              // Update existing user
                              print('Updating user...');
                              await SupabaseRepository().updateUser(
                                uuid: userUuid!,
                                fullname: nameController.text,
                                age: ageController.text,
                                email: emailController.text,
                                phone: phoneController.text,
                                address: addressController.text,
                                bloodtype: bloodTypeController.text,
                              );
                              print('User updated successfully');
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Profile updated successfully!'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            } else {
                              // Insert new user
                              print('Inserting new user...');
                              await SupabaseRepository().insertUser(
                                uuid: userUuid!,
                                fullname: nameController.text,
                                age: ageController.text,
                                email: emailController.text,
                                phone: phoneController.text,
                                address: addressController.text,
                                bloodtype: bloodTypeController.text,
                              );
                              print('User inserted successfully');
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Profile saved successfully!'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                            setState(() {
                              isEditMode = false;
                            });
                          } catch (e) {
                            print('Error saving profile: $e');
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Failed to save profile: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        icon: Icon(Icons.save, color: Colors.white),
                        label: Text(
                          'Save Changes',
                          style: TextStyle(
                            fontSize: labelFontSize,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),

            // Logout Button
            Center(
              child: SizedBox(
                width: isDesktop ? 300 : double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Logout'),
                        content: Text('Are you sure you want to logout?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              // Add logout logic here
                            },
                            child: Text('Logout', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: Icon(Icons.logout, color: Colors.white),
                  label: Text(
                    'Logout',
                    style: TextStyle(
                      fontSize: labelFontSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required bool enabled,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.teal),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.teal, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey[200]!, width: 1),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color, width: 2),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 40),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    ageController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    bloodTypeController.dispose();
    super.dispose();
  }
}
