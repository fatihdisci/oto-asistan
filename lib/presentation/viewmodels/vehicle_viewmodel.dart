import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../../data/repositories/vehicle_repository.dart';
import '../../data/models/vehicle_model.dart';
// Yeni servisi import et
import '../../core/services/gemini_service.dart';

class VehicleViewModel extends StateNotifier<VehicleState> {
  final VehicleRepository _vehicleRepository;
  final GeminiService? _geminiService; // Değişken adı güncellendi

  VehicleViewModel({
    required VehicleRepository vehicleRepository,
    GeminiService? geminiService, // Parametre adı güncellendi
  })  : _vehicleRepository = vehicleRepository,
        _geminiService = geminiService,
        super(VehicleState.initial());

  /// Güvenli State Güncelleme (Dispose hatasını önler)
  @override
  bool get mounted => super.mounted;

  void _safeSetState(VehicleState newState) {
    if (mounted) {
      state = newState;
    }
  }

  Future<String?> addVehicle({
    required String make,
    required String model,
    required int year,
    required String engine,
    required String plate,
    required int currentKm,
    int? maintenanceIntervalKm,
    int? maintenanceIntervalMonths,
  }) async {
    _safeSetState(state.copyWith(isLoading: true, error: null));

    try {
      // 1. KULLANICIYI BUL
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        final userCredential = await FirebaseAuth.instance.signInAnonymously();
        currentUser = userCredential.user;
      }

      if (currentUser == null) throw Exception("Kullanıcı kimliği alınamadı.");
      final String userId = currentUser.uid;

      // 2. MODELİ HAZIRLA
      final vehicle = VehicleModel(
        make: make,
        model: model,
        year: year,
        engine: engine,
        plate: plate,
        currentKm: currentKm,
        maintenanceIntervalKm: maintenanceIntervalKm ?? 15000,
        maintenanceIntervalMonths: maintenanceIntervalMonths ?? 12,
        lastServiceDate: DateTime.now(),
        lastServiceKm: currentKm,
      );

      // 3. FIREBASE KAYIT
      final vehicleId = await _vehicleRepository.addVehicle(userId, vehicle);

      // 4. GEMINI 2.5 FLASH ANALİZİ
      if (_geminiService != null) {
        _safeSetState(state.copyWith(isAnalyzingAI: true));
        try {
          final chronicIssues = await _geminiService!.getChronicIssues(
            make: make,
            model: model,
            year: year,
            engine: engine,
          );
          await _vehicleRepository.updateChronicIssues(userId, vehicleId, chronicIssues);
        } catch (aiError) {
          debugPrint("Gemini Analiz Hatası: $aiError");
        }
      }

      _safeSetState(state.copyWith(isLoading: false, isAnalyzingAI: false));
      return vehicleId;
    } catch (e) {
      _safeSetState(state.copyWith(isLoading: false, isAnalyzingAI: false, error: e.toString()));
      return null;
    }
  }

  Future<void> updateCurrentKm(String vehicleId, int newKm) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      await _vehicleRepository.updateCurrentKm(user.uid, vehicleId, newKm);
    } catch (e) {
      _safeSetState(state.copyWith(error: e.toString()));
    }
  }
}

class VehicleState {
  final bool isLoading;
  final bool isAnalyzingAI;
  final String? error;

  VehicleState({required this.isLoading, this.isAnalyzingAI = false, this.error});

  factory VehicleState.initial() => VehicleState(isLoading: false);

  VehicleState copyWith({bool? isLoading, bool? isAnalyzingAI, String? error}) =>
      VehicleState(
        isLoading: isLoading ?? this.isLoading,
        isAnalyzingAI: isAnalyzingAI ?? this.isAnalyzingAI,
        error: error,
      );
}