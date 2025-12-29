import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  final String apiKey;
  // DÜZELTME: Şu an çalışan en güncel ve hızlı model 'gemini-1.5-flash'tır.
  // Google 'gemini-2.5-flash'ı yayınladığında burayı güncelleyebilirsin.
  static const String _modelName = 'gemini-2.5-flash';

  GeminiService({required this.apiKey});

  Future<List<Map<String, dynamic>>> getChronicIssues({
    required String make,
    required String model,
    required int year,
    required String engine,
    required int currentKm,
  }) async {
    try {
      final modelInstance = GenerativeModel(
        model: _modelName,
        apiKey: apiKey,
      );

      final prompt = '''
      Sen uzman bir otomotiv teknisyenisin. Aşağıdaki aracın $currentKm km'deki durumunu analiz et:
      Araç: $year $make $model - Motor: $engine
      
      GÖREV:
      Bu kilometredeki bu araç için "Kronik Sorunlar" ve "Bakım Tavsiyeleri" üret.
      
      ÇIKTI FORMATI:
      SADECE geçerli bir JSON array döndür. Markdown (```json) kullanma.
      Örnek:
      [
        {
          "title": "Triger Kayışı Riski",
          "description": "Bu motorlarda 90.000 km'de triger değişimi kritiktir.",
          "riskLevel": "Yüksek",
          "solution": "Acilen triger setini kontrol ettirin."
        }
      ]
      ''';

      final content = [Content.text(prompt)];
      final response = await modelInstance.generateContent(content);

      if (response.text == null) return [];

      // SENIOR CLEANUP: AI bazen cevabı kirletir, temizliyoruz.
      String cleanJson = response.text!.trim();
      
      // Markdown temizliği
      cleanJson = cleanJson.replaceAll('```json', '').replaceAll('```', '');
      
      // Olası metin fazlalıklarını at (Sadece [ ile ] arasını al)
      final startIndex = cleanJson.indexOf('[');
      final endIndex = cleanJson.lastIndexOf(']');
      
      if (startIndex != -1 && endIndex != -1) {
        cleanJson = cleanJson.substring(startIndex, endIndex + 1);
      }

      final List<dynamic> decodedList = jsonDecode(cleanJson);
      return decodedList.cast<Map<String, dynamic>>();

    } catch (e) {
      debugPrint('Gemini Servis Hatası: $e');
      return [];
    }
  }
}