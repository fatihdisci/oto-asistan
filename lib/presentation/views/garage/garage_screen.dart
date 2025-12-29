import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Tam Yol Importları (Hata riskini sıfırlar):
import 'package:oto_asistan/presentation/providers/vehicle_provider.dart';
import 'package:oto_asistan/presentation/widgets/chronic_issue_card_widget.dart';
import 'package:oto_asistan/routes/app_router.dart';

class GarageScreen extends ConsumerWidget {
  const GarageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehiclesAsync = ref.watch(userVehiclesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Garajım')),
      body: vehiclesAsync.when(
        data: (vehicles) {
          if (vehicles.isEmpty) {
             return const Center(child: Text('Garajınız boş.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: vehicles.length,
            itemBuilder: (context, index) {
              final vehicle = vehicles[index];
              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 16),
                child: ExpansionTile(
                  leading: const Icon(Icons.directions_car, color: Colors.blue),
                  title: Text('${vehicle.make} ${vehicle.model}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(vehicle.plate),
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Align(
                        alignment: Alignment.centerLeft, 
                        child: Text("Kronik Sorunlar:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange))
                      ),
                    ),
                    if (vehicle.chronicIssues.isNotEmpty)
                      ...vehicle.chronicIssues.map((issue) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: ChronicIssueCardWidget(issue: issue),
                      ))
                    else
                      const Padding(
                        padding: EdgeInsets.all(16.0), 
                        child: Text('Bu araç için bilinen kronik sorun bulunamadı.', style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey))
                      ),
                    
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.history, color: Colors.green),
                      title: const Text('Servis Geçmişini Görüntüle'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.pushNamed(context, AppRouter.serviceHistory, arguments: vehicle),
                    ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Hata: $e')),
      ),
    );
  }
}