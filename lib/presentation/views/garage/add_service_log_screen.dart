import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oto_asistan/core/constants/app_constants.dart';
import 'package:oto_asistan/presentation/providers/service_log_provider.dart';

class AddServiceLogScreen extends ConsumerStatefulWidget {
  final String vehicleId;
  final String vehiclePlate;
  const AddServiceLogScreen({super.key, required this.vehicleId, required this.vehiclePlate});

  @override
  ConsumerState<AddServiceLogScreen> createState() => _AddServiceLogScreenState();
}

class _AddServiceLogScreenState extends ConsumerState<AddServiceLogScreen> {
  final _kmController = TextEditingController();
  final _costController = TextEditingController();
  late String _selectedType;

  @override
  void initState() {
    super.initState();
    _selectedType = AppConstants.maintenanceTypeMaintenance;
  }

  @override
  void dispose() {
    _kmController.dispose();
    _costController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Yeni Kayıt Ekle')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text('Araç: ${widget.vehiclePlate}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                // DÜZELTME: 'value' yerine 'initialValue' kullanıldı
                initialValue: _selectedType,
                decoration: const InputDecoration(labelText: 'İşlem Türü', border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: AppConstants.maintenanceTypeMaintenance, child: Text('Periyodik Bakım')),
                  DropdownMenuItem(value: AppConstants.maintenanceTypeRepair, child: Text('Arıza / Tamir')),
                ],
                onChanged: (v) => _selectedType = v!,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _kmController,
                decoration: const InputDecoration(labelText: 'İşlem Anındaki KM', border: OutlineInputBorder(), suffixText: 'km'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _costController,
                decoration: const InputDecoration(labelText: 'Toplam Maliyet', border: OutlineInputBorder(), suffixText: '₺'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _saveLog,
                  icon: const Icon(Icons.save),
                  label: const Text('KAYDET'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveLog() async {
    if (_kmController.text.isEmpty || _costController.text.isEmpty) return;
    
    final km = int.tryParse(_kmController.text);
    final cost = double.tryParse(_costController.text);
    
    if (km == null || cost == null) return;

    await ref.read(serviceLogViewModelProvider.notifier).addServiceLog(
      vehicleId: widget.vehicleId,
      type: _selectedType,
      date: DateTime.now(),
      kmAtService: km,
      costTotal: cost,
      operations: [],
    );

    if (mounted) Navigator.pop(context);
  }
}