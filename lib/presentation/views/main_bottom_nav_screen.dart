import 'package:flutter/material.dart';
import 'dashboard/dashboard_screen.dart';
import 'garage/garage_screen.dart';
import 'wallet/wallet_screen.dart';
import 'vehicles/vehicles_screen.dart';

class MainBottomNavScreen extends StatefulWidget {
  const MainBottomNavScreen({super.key});

  @override
  State<MainBottomNavScreen> createState() => _MainBottomNavScreenState();
}

class _MainBottomNavScreenState extends State<MainBottomNavScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const GarageScreen(),
    const WalletScreen(),
    const VehiclesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Panel'),
          BottomNavigationBarItem(icon: Icon(Icons.garage), label: 'Garajım'),
          BottomNavigationBarItem(icon: Icon(Icons.wallet), label: 'Cüzdan'),
          BottomNavigationBarItem(icon: Icon(Icons.directions_car), label: 'Asistan'),
        ],
      ),
    );
  }
}