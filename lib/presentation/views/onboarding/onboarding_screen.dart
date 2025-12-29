import 'package:flutter/material.dart';
import '../../../routes/app_router.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.garage, size: 100, color: Colors.blue),
            const Text('OtoAsistan\'a Hoş Geldiniz!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const Padding(padding: EdgeInsets.all(16.0), child: Text('Araçlarınızın sağlığını takip etmeye başlamak için ilk aracınızı ekleyin.')),
            ElevatedButton(onPressed: () => Navigator.pushNamed(context, AppRouter.addVehicle), child: const Text('İlk Aracımı Ekle')),
          ],
        ),
      ),
    );
  }
}