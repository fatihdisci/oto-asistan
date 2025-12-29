import '../models/traffic_fine_model.dart';
import '../../core/services/firestore_service.dart';

class TrafficFineRepository {
  final FirestoreService _firestoreService = FirestoreService();

  Future<String> addTrafficFine(
    String userId,
    String vehicleId,
    TrafficFineModel fine,
  ) async {
    final docRef = await _firestoreService
        .firestore
        .collection('users')
        .doc(userId)
        .collection('vehicles')
        .doc(vehicleId)
        .collection('traffic_fines')
        .add(fine.toFirestore());
    return docRef.id;
  }

  Future<void> deleteTrafficFine(
    String userId,
    String vehicleId,
    String fineId,
  ) async {
    await _firestoreService
        .firestore
        .collection('users')
        .doc(userId)
        .collection('vehicles')
        .doc(vehicleId)
        .collection('traffic_fines')
        .doc(fineId)
        .delete();
  }

  Stream<List<TrafficFineModel>> getTrafficFinesStream(
    String userId,
    String vehicleId,
  ) {
    return _firestoreService
        .firestore
        .collection('users')
        .doc(userId)
        .collection('vehicles')
        .doc(vehicleId)
        .collection('traffic_fines')
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => TrafficFineModel.fromFirestore(doc))
              .toList(),
        );
  }
}