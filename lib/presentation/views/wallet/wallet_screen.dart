import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
// Tam yol importları:
import 'package:oto_asistan/presentation/providers/wallet_provider.dart';
import 'package:oto_asistan/presentation/viewmodels/wallet_viewmodel.dart';
import 'package:oto_asistan/presentation/providers/service_log_provider.dart';

class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analysis = ref.watch(walletAnalysisProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cüzdan'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(allServiceLogsProvider);
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTotalCostCards(context, analysis),
              const SizedBox(height: 24),
              _buildMonthlyChart(context, analysis),
              const SizedBox(height: 24),
              _buildYearlyChart(context, analysis),
              const SizedBox(height: 24),
              _buildCategoryChart(context, analysis),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTotalCostCards(BuildContext context, WalletAnalysis analysis) {
    return Column(
      children: [
        Card(
          color: Theme.of(context).colorScheme.primaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text(
                  'Toplam Harcama',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${analysis.totalCost.toStringAsFixed(2)} ₺',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildMiniCard(context, 'Bakım', analysis.totalMaintenance.toStringAsFixed(2), Colors.green),
                    _buildMiniCard(context, 'Arıza', analysis.totalRepair.toStringAsFixed(2), Colors.red),
                    _buildMiniCard(context, 'Servis', analysis.totalServiceCount.toString(), Colors.blue),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildInfoCard('Bu Ay', '${analysis.thisMonthCost.toStringAsFixed(2)} ₺'),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildInfoCard('Ortalama/Ay', '${analysis.avgMonthlyCost.toStringAsFixed(2)} ₺'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoCard(String title, String value) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniCard(BuildContext context, String label, String value, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            // withOpacity yerine withValues kullanıldı (Düzeltme)
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.circle, color: color, size: 16),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[600])),
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildMonthlyChart(BuildContext context, WalletAnalysis analysis) {
    if (analysis.monthlyCosts.isEmpty) return _buildEmptyChart(context, 'Aylık Harcama Grafiği');

    final sortedMonths = analysis.monthlyCosts.keys.toList()..sort();
    final spots = sortedMonths.asMap().entries.map((entry) {
      final value = analysis.monthlyCosts[entry.value] ?? 0.0;
      return FlSpot(entry.key.toDouble(), value);
    }).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Son 12 Ay Harcama Trendi', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40, getTitlesWidget: (v, m) => Text('${v.toInt()}₺', style: const TextStyle(fontSize: 10)))),
                    bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30, getTitlesWidget: (v, m) {
                       if (v.toInt() >= sortedMonths.length) return const Text('');
                       return Text(sortedMonths[v.toInt()].substring(5), style: const TextStyle(fontSize: 10));
                    })),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: Theme.of(context).colorScheme.primary,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true, 
                        // withOpacity yerine withValues (Düzeltme)
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2)
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildYearlyChart(BuildContext context, WalletAnalysis analysis) {
    if (analysis.yearlyCosts.isEmpty) return const SizedBox.shrink(); // Veri yoksa gösterme

    final sortedYears = analysis.yearlyCosts.keys.toList()..sort();
    // Sıralı yılları kullanarak bir liste oluşturuyoruz
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Yıllık Harcamalar', 
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)
            ),
            const SizedBox(height: 16),
            ...sortedYears.map((year) {
              final amount = analysis.yearlyCosts[year] ?? 0;
              final percentage = (amount / analysis.totalCost * 100);
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(year, style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text('${amount.toStringAsFixed(0)} ₺'),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: percentage / 100, 
                      backgroundColor: Colors.grey[200],
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChart(BuildContext context, WalletAnalysis analysis) {
    if (analysis.categoryCosts.isEmpty) return _buildEmptyChart(context, 'Kategori Bazlı Harcamalar');

    final sortedCategories = analysis.categoryCosts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final colors = [Colors.blue, Colors.green, Colors.orange, Colors.red, Colors.purple];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Kategori Bazlı Harcamalar', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            ...sortedCategories.asMap().entries.map((entry) {
              final percentage = (entry.value.value / analysis.totalCost * 100);
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(entry.value.key),
                        Text('${entry.value.value.toStringAsFixed(0)} ₺ (%${percentage.toStringAsFixed(1)})'),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(value: percentage / 100, color: colors[entry.key % colors.length], backgroundColor: Colors.grey[200]),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyChart(BuildContext context, String title) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.bar_chart, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              const Text('Henüz veri yok', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}