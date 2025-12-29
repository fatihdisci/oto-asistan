import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // .env desteği eklendi

// Konfigürasyon ve Rotalar
import 'core/config/firebase_options.dart';
import 'core/constants/app_constants.dart';
import 'routes/app_router.dart';

// Provider ve Ekranlar
import 'presentation/providers/auth_provider.dart';
import 'presentation/views/main_bottom_nav_screen.dart';
import 'presentation/views/onboarding/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. .env dosyasını yükle (API anahtarını okumak için şart)
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint(".env dosyası yüklenemedi: $e");
  }
  
  // 2. Firebase Başlatma
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 3. Tarih formatını Türkçe'ye ayarla
  await initializeDateFormatting('tr_TR', null);

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Kullanıcının giriş durumunu anlık takip et
    final authState = ref.watch(authStateChangesProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppConstants.appName,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2196F3)),
      ),
      // Auth durumuna göre yönlendirme
      home: authState.when(
        data: (user) {
          if (user != null) {
            return const MainBottomNavScreen();
          }
          return const OnboardingScreen();
        },
        loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
        error: (e, st) => const OnboardingScreen(),
      ),
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}