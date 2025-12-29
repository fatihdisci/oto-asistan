import '../models/vehicle_model.dart';
import '../../core/services/firestore_service.dart';

class VehicleRepository {
  final FirestoreService _firestoreService = FirestoreService();

  Future<String> addVehicle(String userId, VehicleModel vehicle) async {
    final docRef = await _firestoreService
        .vehiclesCollection(userId)
        .add(vehicle.toFirestore());
    return docRef.id;
  }

  Future<void> updateVehicle(
    String userId,
    String vehicleId,
    VehicleModel vehicle,
  ) async {
    await _firestoreService
        .vehiclesCollection(userId)
        .doc(vehicleId)
        .update(vehicle.toFirestore());
  }

  Future<void> deleteVehicle(String userId, String vehicleId) async {
    await _firestoreService
        .vehiclesCollection(userId)
        .doc(vehicleId)
        .delete();
  }

  Stream<List<VehicleModel>> getVehiclesStream(String userId) {
    return _firestoreService.vehiclesCollection(userId).snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => VehicleModel.fromFirestore(doc))
              .toList(),
        );
  }

  Future<void> updateCurrentKm(
    String userId,
    String vehicleId,
    int newKm,
  ) async {
    await _firestoreService
        .vehiclesCollection(userId)
        .doc(vehicleId)
        .update({'currentKm': newKm});
  }

  Future<void> updateChronicIssues(
    String userId,
    String vehicleId,
    List<Map<String, dynamic>> issues,
  ) async {
    await _firestoreService
        .vehiclesCollection(userId)
        .doc(vehicleId)
        .update({'chronicIssues': issues});
  }
}