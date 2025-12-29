import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/vehicle_model.dart';
import '../viewmodels/dashboard_viewmodel.dart';
import '../providers/vehicle_provider.dart'; // Provider'ı buradan çekeceğiz

class MaintenanceCounterWidget extends ConsumerWidget {
  final VehicleModel vehicle;
  const MaintenanceCounterWidget({super.key, required this.vehicle});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ViewModel'i provider üzerinden okuyoruz, böylece hata almayız
    final vm = ref.read(dashboardViewModelProvider);
    
    // Hesaplamaları yapıyoruz
    final status = vm.calculateMaintenanceStatus(vehicle);
    
    // Renk belirleme
    Color color;
    switch (status) {
      case MaintenanceStatus.ok:
        color = Colors.green;
        break;
      case MaintenanceStatus.warning:
        color = Colors.orange;
        break;
      case MaintenanceStatus.urgent:
      case MaintenanceStatus.overdue:
        color = Colors.red;
        break;
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              '${vehicle.make} ${vehicle.model}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text(vehicle.plate, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildInfo('KM Kalan', '${vehicle.remainingKm}', Icons.speed, color),
                Container(width: 1, height: 40, color: Colors.grey[300]), // Ayıraç
                _buildInfo('Gün Kalan', '${vehicle.remainingDays ?? "---"}', Icons.calendar_today, color),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfo(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }
}