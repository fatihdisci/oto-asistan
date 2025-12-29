import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import '../../data/repositories/service_log_repository.dart';
import '../../data/models/service_log_model.dart';
import '../../core/services/storage_service.dart';

class ServiceLogViewModel extends StateNotifier<ServiceLogState> {
  final ServiceLogRepository _serviceLogRepository;
  final StorageService _storageService;
  final String? _userId;

  ServiceLogViewModel({
    required ServiceLogRepository serviceLogRepository,
    required StorageService storageService,
    String? userId,
  })  : _serviceLogRepository = serviceLogRepository,
        _storageService = storageService,
        _userId = userId,
        super(ServiceLogState.initial());

  Future<String?> addServiceLog({
    required String vehicleId, required String type, required DateTime date,
    required int kmAtService, required double costTotal,
    required List<ServiceOperation> operations, String? complaint,
    String? diagnosis, String? mechanicName, File? receiptImage,
  }) async {
    if (_userId == null) return null;
    state = state.copyWith(isLoading: true);

    try {
      final log = ServiceLogModel(
        type: type, date: date, kmAtService: kmAtService, costTotal: costTotal,
        operations: operations, complaint: complaint, diagnosis: diagnosis, mechanicName: mechanicName,
      );

      final logId = await _serviceLogRepository.addServiceLog(_userId!, vehicleId, log);

      if (receiptImage != null) {
        final url = await _storageService.uploadReceiptImage(userId: _userId!, vehicleId: vehicleId, logId: logId, imageFile: receiptImage);
        await _serviceLogRepository.updateServiceLog(_userId!, vehicleId, logId, ServiceLogModel(
          type: type, date: date, kmAtService: kmAtService, costTotal: costTotal,
          operations: operations, complaint: complaint, diagnosis: diagnosis,
          mechanicName: mechanicName, receiptImageUrl: url,
        ));
      }

      state = state.copyWith(isLoading: false);
      return logId;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return null;
    }
  }

  Future<void> deleteServiceLog(String vehicleId, String logId) async {
    if (_userId == null) return;
    await _serviceLogRepository.deleteServiceLog(_userId!, vehicleId, logId);
  }
}

class ServiceLogState {
  final bool isLoading;
  final String? error;
  ServiceLogState({required this.isLoading, this.error});
  factory ServiceLogState.initial() => ServiceLogState(isLoading: false);
  ServiceLogState copyWith({bool? isLoading, String? error}) => ServiceLogState(isLoading: isLoading ?? this.isLoading, error: error ?? this.error);
}