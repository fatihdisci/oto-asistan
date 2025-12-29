import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../providers/vehicle_provider.dart';
import '../../widgets/maintenance_counter_widget.dart';
import '../../../routes/app_router.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehiclesAsync = ref.watch(userVehiclesProvider);
    final dashboardVM = ref.watch(dashboardViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('OtoAsistan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authViewModelProvider.notifier).signOut(),
          ),
        ],
      ),
      body: vehiclesAsync.when(
        data: (vehicles) {
          if (vehicles.isEmpty) return const Center(child: Text('Henüz araç eklenmemiş.'));
          
          final warnings = dashboardVM.getSeasonalWarnings();
          
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (warnings.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    children: warnings.map((w) => Text('⚠️ $w', style: const TextStyle(color: Colors.orange))).toList(),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              ...vehicles.map((v) => MaintenanceCounterWidget(vehicle: v)),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Hata: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, AppRouter.addVehicle),
        child: const Icon(Icons.add),
      ),
    );
  }
}