import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceOperation {
  final String item;
  final double price;

  ServiceOperation({
    required this.item,
    required this.price,
  });

  Map<String, dynamic> toMap() => {
        'item': item,
        'price': price,
      };

  factory ServiceOperation.fromMap(Map<String, dynamic> map) => ServiceOperation(
        item: map['item'] ?? '',
        price: (map['price'] ?? 0).toDouble(),
      );
}

class ServiceLogModel {
  final String? id;
  final String type; // "MAINTENANCE" veya "REPAIR"
  final DateTime date;
  final int kmAtService;
  final double costTotal;
  final List<ServiceOperation> operations;
  final String? complaint; // Sadece Arıza (REPAIR) için
  final String? diagnosis; // Sadece Arıza (REPAIR) için
  final String? mechanicName;
  final String? receiptImageUrl;

  ServiceLogModel({
    this.id,
    required this.type,
    required this.date,
    required this.kmAtService,
    required this.costTotal,
    this.operations = const [],
    this.complaint,
    this.diagnosis,
    this.mechanicName,
    this.receiptImageUrl,
  });

  factory ServiceLogModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ServiceLogModel(
      id: doc.id,
      type: data['type'] ?? 'MAINTENANCE',
      date: (data['date'] as Timestamp).toDate(),
      kmAtService: data['kmAtService'] ?? 0,
      costTotal: (data['costTotal'] ?? 0).toDouble(),
      operations: (data['operations'] as List<dynamic>?)
              ?.map((op) => ServiceOperation.fromMap(op as Map<String, dynamic>))
              .toList() ??
          [],
      complaint: data['complaint'],
      diagnosis: data['diagnosis'],
      mechanicName: data['mechanicName'],
      receiptImageUrl: data['receiptImageUrl'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'type': type,
      'date': Timestamp.fromDate(date),
      'kmAtService': kmAtService,
      'costTotal': costTotal,
      'operations': operations.map((op) => op.toMap()).toList(),
      'complaint': complaint,
      'diagnosis': diagnosis,
      'mechanicName': mechanicName,
      'receiptImageUrl': receiptImageUrl,
    };
  }
}
