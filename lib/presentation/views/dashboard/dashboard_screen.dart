import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../providers/vehicle_provider.dart';
import '../../widgets/maintenance_counter_widget.dart';
import '../../widgets/chronic_issue_card_widget.dart'; // Bu widget'ın import edildiğinden emin ol
import '../../../routes/app_router.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Kullanıcının araçlarını veritabanından dinleyen provider
    final vehiclesAsync = ref.watch(userVehiclesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('OtoAsistan'),
        actions: [
          // Çıkış Yap Butonu
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.directions_car_outlined, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('Henüz araç eklenmemiş.'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, AppRouter.addVehicle),
                    child: const Text("İlk Aracını Ekle"),
                  )
                ],
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
                  // 1. Bakım Sayacı (KM ve Gün durumu)
                  MaintenanceCounterWidget(vehicle: vehicle),
                  
                  // 2. AI Analiz Sonuçları (Varsa göster)
                  if (vehicle.chronicIssues.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.fromLTRB(4, 16, 0, 8),
                      child: Row(
                        children: [
                          Icon(Icons.psychology, color: Colors.deepPurple),
                          SizedBox(width: 8),
                          Text(
                            'Uzman AI Analizi (Kronik Sorunlar)', 
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.deepPurple)
                          ),
                        ],
                      ),
                    ),
                    // Listeyi kartlara dönüştür
                    ...vehicle.chronicIssues.map((issue) => ChronicIssueCardWidget(issue: issue)),
                  ],
                  
                  // Araçlar arası boşluk
                  const SizedBox(height: 24),
                  const Divider(),
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