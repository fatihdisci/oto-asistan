import 'package:cloud_firestore/cloud_firestore.dart';

class VehicleModel {
  final String? id;
  final String make;
  final String model;
  final int year;
  final String engine;
  final String plate;
  final int currentKm;
  final int maintenanceIntervalKm;
  final int maintenanceIntervalMonths;
  final DateTime? lastServiceDate;
  final int lastServiceKm;
  final List<Map<String, dynamic>> chronicIssues;

  VehicleModel({
    this.id,
    required this.make,
    required this.model,
    required this.year,
    required this.engine,
    required this.plate,
    this.currentKm = 0,
    this.maintenanceIntervalKm = 15000,
    this.maintenanceIntervalMonths = 12,
    this.lastServiceDate,
    this.lastServiceKm = 0,
    this.chronicIssues = const [],
  });

  factory VehicleModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return VehicleModel(
      id: doc.id,
      make: data['make'] ?? '',
      model: data['model'] ?? '',
      year: data['year'] ?? 0,
      engine: data['engine'] ?? '',
      plate: data['plate'] ?? '',
      currentKm: data['currentKm'] ?? 0,
      maintenanceIntervalKm: data['maintenanceIntervalKm'] ?? 15000,
      maintenanceIntervalMonths: data['maintenanceIntervalMonths'] ?? 12,
      lastServiceDate: (data['lastServiceDate'] as Timestamp?)?.toDate(),
      lastServiceKm: data['lastServiceKm'] ?? 0,
      chronicIssues: List<Map<String, dynamic>>.from(data['chronicIssues'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'make': make,
      'model': model,
      'year': year,
      'engine': engine,
      'plate': plate,
      'currentKm': currentKm,
      'maintenanceIntervalKm': maintenanceIntervalKm,
      'maintenanceIntervalMonths': maintenanceIntervalMonths,
      'lastServiceDate': lastServiceDate != null
          ? Timestamp.fromDate(lastServiceDate!)
          : null,
      'lastServiceKm': lastServiceKm,
      'chronicIssues': chronicIssues,
    };
  }

  // Bakım hesaplamaları
  int get nextServiceKm => lastServiceKm + maintenanceIntervalKm;
  
  DateTime? get nextServiceDate {
    if (lastServiceDate == null) return null;
    return DateTime(
      lastServiceDate!.year,
      lastServiceDate!.month + maintenanceIntervalMonths,
      lastServiceDate!.day,
    );
  }

  int get remainingKm => (nextServiceKm - currentKm).clamp(0, double.infinity).toInt();
  
  int? get remainingDays {
    if (nextServiceDate == null) return null;
    final now = DateTime.now();
    final difference = nextServiceDate!.difference(now).inDays;
    return difference.clamp(0, double.infinity).toInt();
  }
}