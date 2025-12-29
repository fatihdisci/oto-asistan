import '../models/user_model.dart';
import '../../core/services/firestore_service.dart';

class UserRepository {
  final FirestoreService _firestoreService = FirestoreService();

  Future<void> createUser(UserModel user) async {
    await _firestoreService.usersCollection.doc(user.uid).set(
          user.toFirestore(),
        );
  }

  Future<UserModel?> getUser(String uid) async {
    final doc = await _firestoreService.usersCollection.doc(uid).get();
    if (doc.exists) {
      return UserModel.fromFirestore(doc);
    }
    return null;
  }

  Future<void> updateProMemberStatus(String uid, bool isPro) async {
    await _firestoreService.usersCollection.doc(uid).update({
      'isProMember': isPro,
    });
  }

  Stream<UserModel?> getUserStream(String uid) {
    return _firestoreService.usersCollection.doc(uid).snapshots().map(
          (doc) => doc.exists ? UserModel.fromFirestore(doc) : null,
        );
  }
}