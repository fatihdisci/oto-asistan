import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/validators.dart';
import '../../../routes/app_router.dart';
import '../../providers/vehicle_provider.dart';

class AddVehicleWizardScreen extends ConsumerStatefulWidget {
  const AddVehicleWizardScreen({super.key});
  @override
  ConsumerState<AddVehicleWizardScreen> createState() => _AddVehicleWizardScreenState();
}

class _AddVehicleWizardScreenState extends ConsumerState<AddVehicleWizardScreen> {
  int _currentStep = 0;
  // Her adım için ayrı kontrol anahtarı
  final List<GlobalKey<FormState>> _formKeys = [
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
  ];

  final _makeController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _engineController = TextEditingController();
  final _plateController = TextEditingController();
  final _currentKmController = TextEditingController();

  Future<void> _addVehicle() async {
    // Son adımın validasyonu
    if (!_formKeys[2].currentState!.validate()) return;

    // Klavyeyi kapat
    FocusScope.of(context).unfocus();

    // İşlemi başlat
    final vehicleId = await ref.read(vehicleViewModelProvider.notifier).addVehicle(
          make: _makeController.text.trim(),
          model: _modelController.text.trim(),
          year: int.parse(_yearController.text.trim()),
          engine: _engineController.text.trim(),
          plate: _plateController.text.trim(),
          currentKm: int.parse(_currentKmController.text.trim()),
        );

    // Eğer ID gelmediyse bir sorun var demektir
    if (vehicleId == null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kayıt Başarısız! Oturum açılmamış veya veritabanı hatası.'),
          backgroundColor: Colors.red,
        ),
      );
    } else if (mounted) {
      // Başarılı
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Araç başarıyla eklendi!'), backgroundColor: Colors.green),
      );
      Navigator.of(context).pushNamedAndRemoveUntil(AppRouter.dashboard, (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vehicleState = ref.watch(vehicleViewModelProvider);

    // HATA DİNLEYİCİSİ: Firebase'den gelen hatayı ekrana basar
    ref.listen(vehicleViewModelProvider, (previous, next) {
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: ${next.error}'), backgroundColor: Colors.red),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Araç Ekle')),
      body: vehicleState.isAnalyzingAI
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('AI Kronik Sorunları Analiz Ediyor...', style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : Stepper(
              currentStep: _currentStep,
              onStepContinue: () {
                if (_formKeys[_currentStep].currentState!.validate()) {
                  if (_currentStep < 2) {
                    setState(() => _currentStep++);
                  } else {
                    _addVehicle();
                  }
                }
              },
              onStepCancel: () => _currentStep > 0 ? setState(() => _currentStep--) : Navigator.pop(context),
              steps: [
                Step(
                  title: const Text('Marka/Model'),
                  isActive: _currentStep >= 0,
                  content: Form(
                    key: _formKeys[0],
                    child: Column(children: [
                      TextFormField(controller: _makeController, decoration: const InputDecoration(labelText: 'Marka'), validator: (v) => v!.isEmpty ? 'Gerekli' : null),
                      TextFormField(controller: _modelController, decoration: const InputDecoration(labelText: 'Model'), validator: (v) => v!.isEmpty ? 'Gerekli' : null),
                      TextFormField(controller: _yearController, decoration: const InputDecoration(labelText: 'Yıl'), keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? 'Gerekli' : null),
                    ]),
                  ),
                ),
                Step(
                  title: const Text('Detaylar'),
                  isActive: _currentStep >= 1,
                  content: Form(
                    key: _formKeys[1],
                    child: Column(children: [
                      TextFormField(controller: _engineController, decoration: const InputDecoration(labelText: 'Motor'), validator: (v) => v!.isEmpty ? 'Gerekli' : null),
                      TextFormField(controller: _plateController, decoration: const InputDecoration(labelText: 'Plaka'), validator: Validators.validatePlate),
                    ]),
                  ),
                ),
                Step(
                  title: const Text('Mesafe'),
                  isActive: _currentStep >= 2,
                  content: Form(
                    key: _formKeys[2],
                    child: TextFormField(controller: _currentKmController, decoration: const InputDecoration(labelText: 'Mevcut KM'), keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? 'Gerekli' : null),
                  ),
                ),
              ],
            ),
    );
  }
}