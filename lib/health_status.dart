import 'package:flutter/material.dart';

class HealthStatus {
  // Blood Pressure ranges (mmHg)
  static const int BP_SYSTOLIC_NORMAL_MIN = 90;
  static const int BP_SYSTOLIC_NORMAL_MAX = 120;
  static const int BP_DIASTOLIC_NORMAL_MIN = 60;
  static const int BP_DIASTOLIC_NORMAL_MAX = 80;

  // Blood Sugar ranges (mg/dL fasting)
  static const int BLOOD_SUGAR_NORMAL_MIN = 70;
  static const int BLOOD_SUGAR_NORMAL_MAX = 100;
  static const int BLOOD_SUGAR_PREDIABETIC_MAX = 126;

  /// Determine Blood Pressure status and color
  static Map<String, dynamic> getBloodPressureStatus(double systolic,
      [double? diastolic]) {
    if (systolic < 90) {
      return {
        'status': 'Low',
        'color': Colors.blue,
        'icon': Icons.trending_down,
      };
    }
    if (systolic >= 90 && systolic <= 120) {
      return {
        'status': 'Normal',
        'color': Colors.green,
        'icon': Icons.check_circle,
      };
    }
    if (systolic > 120 && systolic < 140) {
      return {
        'status': 'Elevated',
        'color': Colors.amber,
        'icon': Icons.warning,
      };
    }
    return {
      'status': 'High',
      'color': Colors.red,
      'icon': Icons.error,
    };
  }

  /// Determine Blood Sugar status and color
  static Map<String, dynamic> getBloodSugarStatus(double value) {
    if (value < 70) {
      return {
        'status': 'Low',
        'color': Colors.blue,
        'icon': Icons.trending_down,
      };
    }
    if (value >= 70 && value <= 100) {
      return {
        'status': 'Normal',
        'color': Colors.green,
        'icon': Icons.check_circle,
      };
    }
    if (value > 100 && value < 126) {
      return {
        'status': 'Elevated',
        'color': Colors.amber,
        'icon': Icons.warning,
      };
    }
    return {
      'status': 'High',
      'color': Colors.red,
      'icon': Icons.error,
    };
  }
}
