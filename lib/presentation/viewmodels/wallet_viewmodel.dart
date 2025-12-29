// DÜZELTME: Kullanılmayan flutter_riverpod importu kaldırıldı.
import 'package:oto_asistan/data/models/service_log_model.dart';
import 'package:oto_asistan/core/constants/app_constants.dart';

class WalletViewModel {
  WalletAnalysis analyzeCosts(List<ServiceLogModel> logs) {
    if (logs.isEmpty) return WalletAnalysis.empty();

    double total = 0, maintenance = 0, repair = 0;
    final monthly = <String, double>{};
    final yearly = <String, double>{};
    final category = <String, double>{};

    for (var log in logs) {
      total += log.costTotal;
      if (log.type == AppConstants.maintenanceTypeMaintenance) {
        maintenance += log.costTotal;
      } else {
        repair += log.costTotal;
      }

      final monthKey = '${log.date.year}-${log.date.month}';
      monthly[monthKey] = (monthly[monthKey] ?? 0) + log.costTotal;

      final yearKey = '${log.date.year}';
      yearly[yearKey] = (yearly[yearKey] ?? 0) + log.costTotal;

      for (var op in log.operations) {
        final cat = _categorize(op.item);
        category[cat] = (category[cat] ?? 0) + op.price;
      }
      
      if (log.operations.isEmpty && log.costTotal > 0) {
         category['Genel'] = (category['Genel'] ?? 0) + log.costTotal;
      }
    }

    return WalletAnalysis(
      totalCost: total,
      totalMaintenance: maintenance,
      totalRepair: repair,
      monthlyCosts: monthly,
      yearlyCosts: yearly,
      categoryCosts: category,
      avgMonthlyCost: total / (monthly.isNotEmpty ? monthly.length : 1),
      thisMonthCost: monthly['${DateTime.now().year}-${DateTime.now().month}'] ?? 0,
      totalServiceCount: logs.length,
    );
  }

  String _categorize(String item) {
    final lower = item.toLowerCase();
    if (lower.contains('yağ') || lower.contains('filtre')) return 'Bakım Parçaları';
    if (lower.contains('lastik')) return 'Lastik';
    if (lower.contains('fren') || lower.contains('balata')) return 'Fren Sistemi';
    if (lower.contains('işçilik')) return 'İşçilik';
    if (lower.contains('akü')) return 'Akü / Elektrik';
    return 'Diğer';
  }
}

class WalletAnalysis {
  final double totalCost;
  final double totalMaintenance;
  final double totalRepair;
  final double avgMonthlyCost;
  final double thisMonthCost;
  final Map<String, double> monthlyCosts;
  final Map<String, double> yearlyCosts;
  final Map<String, double> categoryCosts;
  final int totalServiceCount;

  WalletAnalysis({
    required this.totalCost,
    required this.totalMaintenance,
    required this.totalRepair,
    required this.monthlyCosts,
    required this.yearlyCosts,
    required this.categoryCosts,
    required this.avgMonthlyCost,
    required this.thisMonthCost,
    required this.totalServiceCount,
  });

  factory WalletAnalysis.empty() => WalletAnalysis(
        totalCost: 0,
        totalMaintenance: 0,
        totalRepair: 0,
        monthlyCosts: {},
        yearlyCosts: {},
        categoryCosts: {},
        avgMonthlyCost: 0,
        thisMonthCost: 0,
        totalServiceCount: 0,
      );
}