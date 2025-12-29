import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../providers/vehicle_provider.dart'; 
import '../../widgets/maintenance_counter_widget.dart';
import '../../widgets/chronic_issue_card_widget.dart';
import '../../../routes/app_router.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehiclesAsync = ref.watch(userVehiclesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('OtoAsistan Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authViewModelProvider.notifier).signOut(),
          ),
        ],
      ),
      body: vehiclesAsync.when(
        data: (vehicles) {
          if (vehicles.isEmpty) {
            return Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text("İlk Aracını Ekle"),
                onPressed: () => Navigator.pushNamed(context, AppRouter.addVehicle),
              ),
            );
          }
          
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: vehicles.length,
            itemBuilder: (context, index) {
              final vehicle = vehicles[index];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MaintenanceCounterWidget(vehicle: vehicle),
                  
                  // AI Analiz Bölümü
                  if (vehicle.chronicIssues.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.fromLTRB(4, 16, 0, 8),
                      child: Row(
                        children: [
                          Icon(Icons.auto_awesome, color: Colors.deepPurple),
                          SizedBox(width: 8),
                          Text('AI Uzman Analizi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                    ),
                    ...vehicle.chronicIssues.map((issue) => ChronicIssueCardWidget(issue: issue)),
                  ] else ...[
                     // Analiz henüz gelmediyse veya boşsa
                     const Padding(
                       padding: EdgeInsets.all(8.0),
                       child: Text("Analiz verisi bekleniyor veya sorun bulunamadı...", style: TextStyle(color: Colors.grey, fontSize: 12)),
                     )
                  ],
                  const SizedBox(height: 24),
                ],
              );
            },
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