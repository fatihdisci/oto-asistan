import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // EKLENDİ
import '../../data/repositories/vehicle_repository.dart';
import '../../data/models/vehicle_model.dart';
import '../../core/services/openai_service.dart';
import '../viewmodels/vehicle_viewmodel.dart';
import '../viewmodels/dashboard_viewmodel.dart';
import 'auth_provider.dart';

final vehicleRepositoryProvider = Provider<VehicleRepository>((ref) {
  return VehicleRepository();
});

// Gemini API Sağlayıcısı
final openAIServiceProvider = Provider<OpenAIService?>((ref) {
  // DÜZELTME: Artık .env dosyasından okuyoruz
  final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
  
  // Anahtar yoksa null döner, böylece ViewModel AI'yı pas geçer
  if (apiKey.isEmpty) {
    print("UYARI: Gemini API Key bulunamadı!");
    return null;
  }
  return OpenAIService(apiKey: apiKey);
});

final vehicleViewModelProvider =
    StateNotifierProvider<VehicleViewModel, VehicleState>((ref) {
  final user = ref.watch(authStateChangesProvider).value;
  return VehicleViewModel(
    vehicleRepository: ref.watch(vehicleRepositoryProvider),
    openAIService: ref.watch(openAIServiceProvider),
    userId: user?.uid,
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