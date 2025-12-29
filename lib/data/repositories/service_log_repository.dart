import '../models/service_log_model.dart';
import '../../core/services/firestore_service.dart';

class ServiceLogRepository {
  final FirestoreService _firestoreService = FirestoreService();

  Future<String> addServiceLog(
    String userId,
    String vehicleId,
    ServiceLogModel serviceLog,
  ) async {
    final docRef = await _firestoreService
        .serviceLogsCollection(userId, vehicleId)
        .add(serviceLog.toFirestore());
    return docRef.id;
  }

  Future<void> updateServiceLog(
    String userId,
    String vehicleId,
    String logId,
    ServiceLogModel serviceLog,
  ) async {
    await _firestoreService
        .serviceLogsCollection(userId, vehicleId)
        .doc(logId)
        .update(serviceLog.toFirestore());
  }

  Future<void> deleteServiceLog(
    String userId,
    String vehicleId,
    String logId,
  ) async {
    await _firestoreService
        .serviceLogsCollection(userId, vehicleId)
        .doc(logId)
        .delete();
  }

  Future<ServiceLogModel?> getServiceLog(
    String userId,
    String vehicleId,
    String logId,
  ) async {
    final doc = await _firestoreService
        .serviceLogsCollection(userId, vehicleId)
        .doc(logId)
        .get();
    if (doc.exists) {
      return ServiceLogModel.fromFirestore(doc);
    }
    return null;
  }

  Stream<List<ServiceLogModel>> getServiceLogsStream(
    String userId,
    String vehicleId,
  ) {
    return _firestoreService
        .serviceLogsCollection(userId, vehicleId)
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ServiceLogModel.fromFirestore(doc))
              .toList(),
        );
  }
}