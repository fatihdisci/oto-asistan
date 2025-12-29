import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/vehicle_model.dart';

class DashboardViewModel extends StateNotifier<DashboardState> {
  DashboardViewModel() : super(DashboardState.initial());

  MaintenanceStatus calculateMaintenanceStatus(VehicleModel vehicle) {
    final remainingKm = vehicle.remainingKm;
    final remainingDays = vehicle.remainingDays;

    if (remainingDays == null) {
      if (remainingKm <= 0) return MaintenanceStatus.overdue;
      if (remainingKm <= 1000) return MaintenanceStatus.urgent;
      return MaintenanceStatus.ok;
    }

    // Basit bir tahmin: Günlük ortalama 40 km kullanım varsayılır
    final kmToDays = (remainingKm / 40).ceil();
    final effectiveRemainingDays = kmToDays < remainingDays ? kmToDays : remainingDays;

    if (effectiveRemainingDays <= 0) return MaintenanceStatus.overdue;
    if (effectiveRemainingDays <= 14) return MaintenanceStatus.urgent;
    if (effectiveRemainingDays <= 30) return MaintenanceStatus.warning;
    return MaintenanceStatus.ok;
  }

  List<String> getSeasonalWarnings() {
    final month = DateTime.now().month;
    if (month >= 11 || month <= 2) return ['Kış lastiği takılmalı', 'Antifriz kontrol edilmeli'];
    if (month >= 6 && month <= 8) return ['Klima bakımı yapılmalı', 'Motor soğutma suyu kontrol edilmeli'];
    return ['Genel sıvı seviyelerini kontrol edin'];
  }

  NextMaintenanceInfo getNextMaintenance(VehicleModel vehicle) {
    final remainingKm = vehicle.remainingKm;
    final remainingDays = vehicle.remainingDays;
    
    // KM mi yoksa zaman mı daha yakın?
    bool isKmCloser = remainingDays == null || (remainingKm / 40) < remainingDays;
    
    return NextMaintenanceInfo(
      type: isKmCloser ? MaintenanceType.km : MaintenanceType.date,
      value: isKmCloser ? remainingKm : (remainingDays ?? 0),
      isUrgent: isKmCloser ? remainingKm <= 1000 : (remainingDays <= 14),
    );
  }
}

enum MaintenanceStatus { ok, warning, urgent, overdue }
enum MaintenanceType { km, date }
class NextMaintenanceInfo {
  final MaintenanceType type;
  final int value;
  final bool isUrgent;
  NextMaintenanceInfo({required this.type, required this.value, required this.isUrgent});
}
class DashboardState {
  final bool isLoading;
  DashboardState({required this.isLoading});
  factory DashboardState.initial() => DashboardState(isLoading: false);
}