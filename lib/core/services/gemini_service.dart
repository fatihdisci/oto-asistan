import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService { // İsim OpenAI yerine GeminiService oldu
  final String apiKey;

  GeminiService({required this.apiKey});

  /// Araç için kronik sorunları Gemini 2.5 Flash modeli ile çeker
  Future<List<Map<String, dynamic>>> getChronicIssues({
    required String make,
    required String model,
    required int year,
    required String engine,
  }) async {
    try {
      // GÜNCELLEME: En yeni ve hızlı model olan gemini-2.5-flash kullanılıyor
      final modelInstance = GenerativeModel(
        model: 'gemini-2.5-flash', 
        apiKey: apiKey,
      );
      
      final prompt = '''
      Bu araç için bilinen en yaygın kronik sorunları ve çözüm önerilerini JSON formatında döndür:
      Marka: $make, Model: $model, Yıl: $year, Motor: $engine

      Her sorun için şu bilgileri içeren bir liste döndür:
      - title: Sorun başlığı
      - description: Sorun açıklaması (Kısa ve öz)
      - riskLevel: "Düşük", "Orta", "Yüksek" (Türkçe olsun)
      - solution: Çözüm önerisi

      Sadece saf JSON array döndür, markdown (```json) kullanma.
      Format: [{"title": "...", "description": "...", "riskLevel": "...", "solution": "..."}]
      ''';

      final content = [Content.text(prompt)];
      final response = await modelInstance.generateContent(content);

      if (response.text != null) {
        // Gelen veriyi temizle
        final cleanJson = response.text!
            .replaceAll('```json', '')
            .replaceAll('```', '')
            .trim();
            
        final List<dynamic> issues = jsonDecode(cleanJson);
        return issues.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      debugPrint('Gemini API Hatası: $e');
      return [];
    }
  }
}