import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/services/auth_service.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/models/user_model.dart';

class AuthViewModel extends StateNotifier<AuthState> {
  final AuthService _authService;
  final UserRepository _userRepository;

  AuthViewModel({
    required AuthService authService,
    required UserRepository userRepository,
  })  : _authService = authService,
        _userRepository = userRepository,
        super(AuthState.initial());

  User? get currentUser => _authService.currentUser;

  Future<void> signIn(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final userCredential = await _authService.signInWithEmailAndPassword(email, password);
      final userDoc = await _userRepository.getUser(userCredential.user!.uid);
      if (userDoc == null) {
        await _userRepository.createUser(
          UserModel(uid: userCredential.user!.uid, email: userCredential.user!.email ?? email, isProMember: false),
        );
      }
      state = state.copyWith(isLoading: false);
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message ?? 'Giriş yapılamadı');
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> signUp(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final userCredential = await _authService.signUpWithEmailAndPassword(email, password);
      await _userRepository.createUser(UserModel(uid: userCredential.user!.uid, email: email, isProMember: false));
      state = state.copyWith(isLoading: false);
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message ?? 'Kayıt olunamadı');
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> signOut() async => await _authService.signOut();

  Future<void> resetPassword(String email) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _authService.resetPassword(email);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void clearError() => state = state.copyWith(error: null);
}

class AuthState {
  final bool isLoading;
  final String? error;
  AuthState({required this.isLoading, this.error});
  factory AuthState.initial() => AuthState(isLoading: false);
  AuthState copyWith({bool? isLoading, String? error}) => AuthState(isLoading: isLoading ?? this.isLoading, error: error ?? this.error);
}