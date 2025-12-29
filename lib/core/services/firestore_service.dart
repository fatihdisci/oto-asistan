import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  FirebaseFirestore get instance => _firestore;
  FirebaseFirestore get firestore => _firestore;

  // Koleksiyon Referansları
  CollectionReference get usersCollection => _firestore.collection('users');
  
  CollectionReference vehiclesCollection(String userId) =>
      _firestore.collection('users').doc(userId).collection('vehicles');
      
  CollectionReference serviceLogsCollection(String userId, String vehicleId) =>
      _firestore
          .collection('users')
          .doc(userId)
          .collection('vehicles')
          .doc(vehicleId)
          .collection('service_logs');
}