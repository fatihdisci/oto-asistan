import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// DÜZELTİLMİŞ IMPORTLAR (Package formatı):
import 'package:oto_asistan/presentation/providers/service_log_provider.dart';
import 'package:oto_asistan/presentation/widgets/service_card_widget.dart';
import 'package:oto_asistan/data/models/vehicle_model.dart';
import 'package:oto_asistan/routes/app_router.dart';
// Silme işlemi için gerekli viewmodel:

class ServiceHistoryScreen extends ConsumerWidget {
  final Object? vehicle; // Router'dan Object olarak gelir

  const ServiceHistoryScreen({super.key, required this.vehicle});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Gelen argümanı VehicleModel'e dönüştürüyoruz
    if (vehicle == null || vehicle is! VehicleModel) {
      return const Scaffold(body: Center(child: Text("Araç verisi bulunamadı")));
    }
    final vehicleModel = vehicle as VehicleModel;

    // Logları çekiyoruz
    final logsAsync = ref.watch(vehicleServiceLogsProvider(vehicleModel.id!));

    return Scaffold(
      appBar: AppBar(title: Text('${vehicleModel.make} Geçmişi')),
      body: logsAsync.when(
        data: (logs) {
          if (logs.isEmpty) {
            return const Center(child: Text('Henüz kayıt bulunmuyor.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: logs.length,
            itemBuilder: (context, index) => ServiceCardWidget(
              serviceLog: logs[index],
              onDelete: () async {
                 // Silme işlemi
                 await ref.read(serviceLogViewModelProvider.notifier)
                    .deleteServiceLog(vehicleModel.id!, logs[index].id!);
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Hata: $e')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(
          context,
          AppRouter.addServiceLog,
          arguments: {'vehicleId': vehicleModel.id, 'vehiclePlate': vehicleModel.plate}
        ),
        label: const Text('Kayıt Ekle'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}