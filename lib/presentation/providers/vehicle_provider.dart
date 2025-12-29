import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../data/repositories/vehicle_repository.dart';
import '../../data/models/vehicle_model.dart';
// DİKKAT: Yeni dosya adını import ediyoruz
import '../../core/services/gemini_service.dart';
import '../viewmodels/vehicle_viewmodel.dart';
import '../viewmodels/dashboard_viewmodel.dart';
import 'auth_provider.dart';

final vehicleRepositoryProvider = Provider<VehicleRepository>((ref) {
  return VehicleRepository();
});

// İSİM GÜNCELLENDİ: Artık geminiServiceProvider
final geminiServiceProvider = Provider<GeminiService?>((ref) {
  final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
  if (apiKey.isEmpty) return null;
  return GeminiService(apiKey: apiKey);
});

final vehicleViewModelProvider =
    StateNotifierProvider<VehicleViewModel, VehicleState>((ref) {
  // Kullanıcı değişse bile provider'ı koru (Dispose hatasını önler)
  // ref.watch(authStateChangesProvider) KALDIRILDI.
  
  return VehicleViewModel(
    vehicleRepository: ref.watch(vehicleRepositoryProvider),
    geminiService: ref.watch(geminiServiceProvider), // Yeni isim
  );
});

final userVehiclesProvider = StreamProvider<List<VehicleModel>>((ref) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) return Stream.value([]);
  return ref.watch(vehicleRepositoryProvider).getVehiclesStream(user.uid);
});

final dashboardViewModelProvider = Provider<DashboardViewModel>((ref) {
  return DashboardViewModel();
});