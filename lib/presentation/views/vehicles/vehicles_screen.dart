import 'package:flutter/material.dart';
import 'highway_calculator_screen.dart';
import 'traffic_fines_screen.dart';

class VehiclesScreen extends StatelessWidget {
  const VehiclesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Yol Asistanı')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            leading: const Icon(Icons.route, color: Colors.blue),
            title: const Text('Otoyol Ücret Hesapla'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HighwayCalculatorScreen())),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.gavel, color: Colors.red),
            title: const Text('Trafik Cezaları'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TrafficFinesScreen())),
          ),
        ],
      ),
    );
  }
}