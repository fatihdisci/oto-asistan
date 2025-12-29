import 'package:cloud_firestore/cloud_firestore.dart';

class TrafficFineModel {
  final String? id;
  final String title;
  final double amount;
  final DateTime date;
  final bool isPaid;

  TrafficFineModel({
    this.id,
    required this.title,
    required this.amount,
    required this.date,
    this.isPaid = false,
  });

  factory TrafficFineModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TrafficFineModel(
      id: doc.id,
      title: data['title'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      date: (data['date'] as Timestamp).toDate(),
      isPaid: data['isPaid'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'amount': amount,
      'date': Timestamp.fromDate(date),
      'isPaid': isPaid,
    };
  }
}