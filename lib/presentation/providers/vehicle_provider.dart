import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../data/repositories/vehicle_repository.dart';
import '../../data/models/vehicle_model.dart';
import '../../core/services/gemini_service.dart'; // Doğru servis import edildi
import '../viewmodels/vehicle_viewmodel.dart';
import '../viewmodels/dashboard_viewmodel.dart';
import 'auth_provider.dart';

final vehicleRepositoryProvider = Provider<VehicleRepository>((ref) {
  return VehicleRepository();
});

// Gemini API Sağlayıcısı - İsmi düzeltildi
final geminiServiceProvider = Provider<GeminiService?>((ref) {
  final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
  if (apiKey.isEmpty) return null;
  return GeminiService(apiKey: apiKey);
});

final vehicleViewModelProvider =
    StateNotifierProvider<VehicleViewModel, VehicleState>((ref) {
  // ViewModel'e doğru servisleri ve parametreleri geçiyoruz
  return VehicleViewModel(
    vehicleRepository: ref.watch(vehicleRepositoryProvider),
    geminiService: ref.watch(geminiServiceProvider),
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