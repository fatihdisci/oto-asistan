import "package:cloud_firestore/cloud_firestore.dart";

class UserModel {
  final String uid;
  final String email;
  final bool isProMember;
  final DateTime? createdAt;

  UserModel({required this.uid, required this.email, this.isProMember = false, this.createdAt});

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      email: data["email"] ?? "",
      isProMember: data["isProMember"] ?? false,
      createdAt: (data["createdAt"] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      "email": email,
      "isProMember": isProMember,
      "createdAt": createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    };
  }
}
