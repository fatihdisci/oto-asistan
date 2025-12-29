import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  final String apiKey;

  GeminiService({required this.apiKey});

  /// Araç için kronik sorunları ve bakım önerilerini Gemini 2.5 Flash ile çeker
  /// [currentKm] parametresi, analizin aracın o anki durumuna özel olmasını sağlar.
  Future<List<Map<String, dynamic>>> getChronicIssues({
    required String make,
    required String model,
    required int year,
    required String engine,
    required int currentKm,
  }) async {
    try {
      // Aralık 2025 itibarıyla en verimli ve hızlı model
      final modelInstance = GenerativeModel(
        model: 'gemini-2.5-flash', 
        apiKey: apiKey,
      );
      
      final prompt = '''
      Sen bir kıdemli otomotiv arıza ve önleyici bakım uzmanısın. 
      Aşağıdaki özelliklere sahip aracın teknik geçmişini, kronik zayıflıklarını ve özellikle mevcut kilometresini analiz et:
      
      ARAÇ BİLGİLERİ:
      - Marka/Model: $make $model
      - Üretim Yılı: $year
      - Motor: $engine
      - Mevcut Mesafe: $currentKm km
      
      GÖREVİN:
      1. Bu aracın $currentKm km seviyesinde en çok karşılaşılan kronik arızalarını belirle.
      2. Aracın yaşına ve kilometresine bağlı olarak (örneğin 100k+ ise ağır bakım, 50k altı ise rodaj sonrası zayıflıklar) spesifik riskleri değerlendir.
      3. Bu kilometre bandında yapılması gereken "hayat kurtarıcı" önleyici bakım tavsiyelerini listele.
      
      ÇIKTI FORMATI:
      Sadece aşağıdaki JSON array yapısında cevap ver. Markdown (```json) kullanma.
      [
        {
          "title": "Sorun Başlığı (Örn: $currentKm km Zincir Değişimi Gerekliliği)",
          "description": "Neden bu kilometrede risk teşkil ettiğine dair teknik açıklama.",
          "riskLevel": "Düşük", "Orta" veya "Yüksek",
          "solution": "Uzman tavsiyesi: Hangi parçalar kontrol edilmeli veya değiştirilmeli?"
        }
      ]
      ''';

      final content = [Content.text(prompt)];
      final response = await modelInstance.generateContent(content);

      if (response.text != null) {
        // AI bazen markdown formatında atabilir, temizliyoruz
        final cleanJson = response.text!
            .replaceAll('```json', '')
            .replaceAll('```', '')
            .trim();
            
        final List<dynamic> issues = jsonDecode(cleanJson);
        return issues.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      debugPrint('Gemini Uzman Analiz Hatası: $e');
      return [];
    }
  }
}