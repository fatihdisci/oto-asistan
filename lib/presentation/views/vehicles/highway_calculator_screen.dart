import 'package:flutter/material.dart';
import '../../../core/utils/highway_calculator.dart';

class HighwayCalculatorScreen extends StatefulWidget {
  const HighwayCalculatorScreen({super.key});
  @override
  State<HighwayCalculatorScreen> createState() => _HighwayCalculatorScreenState();
}

class _HighwayCalculatorScreenState extends State<HighwayCalculatorScreen> {
  final _distController = TextEditingController();
  double? _result;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Otoyol Hesapla')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _distController, decoration: const InputDecoration(labelText: 'Mesafe (KM)'), keyboardType: TextInputType.number),
            ElevatedButton(
              onPressed: () => setState(() => _result = HighwayCalculator.calculateHighwayFee(distance: double.parse(_distController.text))),
              child: const Text('Hesapla'),
            ),
            if (_result != null) Text('Tahmini Ücret: ${_result!.toStringAsFixed(2)} ₺', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}