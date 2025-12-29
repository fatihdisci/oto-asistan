import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  final String apiKey;

  // DÜZELTME: Google'ın şu an yayındaki en güçlü modeli "gemini-1.5-pro"dur.
  // "2.5-pro" henüz yayınlanmadığı için uygulama çökmesin diye 1.5-pro ayarlandı.
  // Google yeni sürümü yayınladığında sadece burayı 'gemini-2.5-pro' yapman yeterli.
  static const String _modelName = 'gemini-2.5-flash';

  GeminiService({required this.apiKey});

  /// Araç için kronik sorunları Gemini Pro modeli ile detaylı analiz eder.
  /// ViewModel'den gelen 'currentKm' parametresi eklendi (Projeye Uyum).
  Future<List<Map<String, dynamic>>> getChronicIssues({
    required String make,
    required String model,
    required int year,
    required String engine,
    required int currentKm, // EKLENDİ: ViewModel bu veriyi gönderiyor, burası eksikti.
  }) async {
    try {
      final modelInstance = GenerativeModel(
        model: _modelName,
        apiKey: apiKey,
        // SENIOR TOUCH: AI'ı JSON formatında yanıt vermeye zorluyoruz (Daha güvenli)
        generationConfig: GenerationConfig(
          responseMimeType: 'application/json',
          temperature: 0.3, // Daha tutarlı ve teknik cevaplar için düşük sıcaklık
        ),
      );

      final prompt = '''
      Sen uzman bir otomotiv başmühendisisin. Aşağıdaki aracı analiz et:
      Araç: $year $make $model
      Motor: $engine
      Mevcut KM: $currentKm
      
      GÖREV:
      Bu aracın özellikle şu anki kilometresinde ($currentKm km) karşılaşabileceği kronik arızaları ve bakım risklerini belirle.
      
      ÇIKTI FORMATI:
      Aşağıdaki JSON şemasına tam olarak uyan bir Array listesi döndür:
      [
        {
          "title": "Sorun Başlığı (Örn: Triger Zinciri Sesi)",
          "description": "Teknik açıklama ve neden bu kilometrede riskli olduğu.",
          "riskLevel": "Yüksek", 
          "solution": "Uzman çözüm önerisi (Örn: Değişim veya Kontrol)"
        }
      ]
      ''';

      final content = [Content.text(prompt)];
      final response = await modelInstance.generateContent(content);

      if (response.text == null) return [];

      // Temizlik: Bazen AI markdown formatında (```json ... ```) gönderir.
      String cleanJson = response.text!.trim();
      if (cleanJson.startsWith('```')) {
         // Regex ile baştaki ve sondaki markdown işaretlerini temizle
         cleanJson = cleanJson.replaceAll(RegExp(r'^```json?|```$'), '').trim();
      }

      final List<dynamic> decoded = jsonDecode(cleanJson);
      return decoded.cast<Map<String, dynamic>>();

    } catch (e) {
      debugPrint('Gemini Pro Analiz Hatası: $e');
      return [];
    }
  }
}