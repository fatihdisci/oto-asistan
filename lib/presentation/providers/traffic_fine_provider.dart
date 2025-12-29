import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/traffic_fine_repository.dart';
import '../../data/models/traffic_fine_model.dart';
import 'auth_provider.dart';

final trafficFineRepositoryProvider = Provider<TrafficFineRepository>((ref) {
  return TrafficFineRepository();
});

final vehicleTrafficFinesProvider =
    StreamProvider.family<List<TrafficFineModel>, String>((ref, vehicleId) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) return Stream.value([]);
  return ref.watch(trafficFineRepositoryProvider).getTrafficFinesStream(user.uid, vehicleId);
});