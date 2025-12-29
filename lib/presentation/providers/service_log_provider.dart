import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oto_asistan/data/repositories/service_log_repository.dart';
import 'package:oto_asistan/data/models/service_log_model.dart';
import 'package:oto_asistan/core/services/storage_service.dart';
import 'package:oto_asistan/presentation/viewmodels/service_log_viewmodel.dart';
import 'package:oto_asistan/presentation/providers/auth_provider.dart';
// Araçları çekmek için ekliyoruz:
import 'package:oto_asistan/presentation/providers/vehicle_provider.dart'; 

final serviceLogRepositoryProvider = Provider<ServiceLogRepository>((ref) {
  return ServiceLogRepository();
});

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

final serviceLogViewModelProvider =
    StateNotifierProvider<ServiceLogViewModel, ServiceLogState>((ref) {
  final user = ref.watch(authStateChangesProvider).value;
  return ServiceLogViewModel(
    serviceLogRepository: ref.watch(serviceLogRepositoryProvider),
    storageService: ref.watch(storageServiceProvider),
    userId: user?.uid,
  );
});

// Belirli bir aracın kayıtları
final vehicleServiceLogsProvider =
    StreamProvider.family<List<ServiceLogModel>, String>((ref, vehicleId) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) return Stream.value([]);
  return ref.watch(serviceLogRepositoryProvider).getServiceLogsStream(user.uid, vehicleId);
});

// EKSİK OLAN KISIM: Tüm araçların kayıtlarını getiren provider
final allServiceLogsProvider = StreamProvider<List<ServiceLogModel>>((ref) async* {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) {
    yield [];
    return;
  }
  
  // Önce kullanıcının araçlarını çekelim
  final vehicles = await ref.watch(userVehiclesProvider.future);
  
  if (vehicles.isEmpty) {
    yield [];
    return;
  }

  // Tüm araçların loglarını birleştiren basit bir çözüm:
  // (Not: Gerçek projelerde CollectionGroupQuery kullanılır ama şimdilik döngüyle yapıyoruz)
  final repository = ref.read(serviceLogRepositoryProvider);
  final List<Stream<List<ServiceLogModel>>> streams = [];
  
  for (var vehicle in vehicles) {
    streams.add(repository.getServiceLogsStream(user.uid, vehicle.id!));
  }

  // Stream'leri birleştir (rxdart olmadan basitçe son değerleri alıyoruz)
  // Pratik çözüm: Her araç için logları çekip tek listede birleştirelim
  // Burası dinamik güncellemeler için daha sonra rxdart CombineLatest ile geliştirilebilir.
  // Şimdilik sadece ilk yüklemeyi yapacak şekilde tasarlayalım:
  
  var allLogs = <ServiceLogModel>[];
  for (var vehicle in vehicles) {
     final logs = await repository.getServiceLogsStream(user.uid, vehicle.id!).first;
     allLogs.addAll(logs);
  }
  yield allLogs;
});