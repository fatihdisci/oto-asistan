import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oto_asistan/presentation/viewmodels/wallet_viewmodel.dart';
import 'package:oto_asistan/presentation/providers/service_log_provider.dart';

final walletViewModelProvider = Provider<WalletViewModel>((ref) {
  return WalletViewModel();
});

// Wallet analizi provider'ı
final walletAnalysisProvider = Provider<WalletAnalysis>((ref) {
  // Artık service_log_provider.dart içinde tanımladığımız için hata vermeyecek
  final serviceLogsAsync = ref.watch(allServiceLogsProvider);
  final walletViewModel = ref.watch(walletViewModelProvider);

  return serviceLogsAsync.when(
    data: (serviceLogs) => walletViewModel.analyzeCosts(serviceLogs),
    loading: () => WalletAnalysis.empty(),
    error: (_, __) => WalletAnalysis.empty(),
  );
});