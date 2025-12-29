import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  final String apiKey;
  
  // Model ismini sabit olarak tanımladık, ileride değiştirmek kolay olsun.
  // Not: Şu an stabil sürüm 'gemini-2.5-flash'. 
  // Google yeni sürüm yayınladığında burayı güncellemen yeterli.
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
      // 1. Model Yapılandırması
      final modelInstance = GenerativeModel(
        model: _modelName,
        apiKey: apiKey,
        // AI'ın daha tutarlı cevap vermesi için generationConfig eklenebilir
        generationConfig: GenerationConfig(
          temperature: 0.4, // Daha az yaratıcı, daha teknik ve tutarlı cevaplar için düşük sıcaklık
        ),
      );
      
      // 2. Prompt (Senin yazdığın prompt gayet başarılı, aynen koruyoruz)
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
      2. Aracın yaşına ve kilometresine bağlı olarak spesifik riskleri değerlendir.
      3. Bu kilometre bandında yapılması gereken "hayat kurtarıcı" önleyici bakım tavsiyelerini listele.
      
      ÇIKTI FORMATI:
      Sadece saf JSON array yapısında cevap ver. Markdown, ```json``` etiketi veya ek açıklama KULLANMA.
      [
        {
          "title": "Sorun Başlığı",
          "description": "Teknik açıklama.",
          "riskLevel": "Yüksek", 
          "solution": "Çözüm önerisi"
        }
      ]
      ''';

      final content = [Content.text(prompt)];
      
      // 3. İstek Gönderimi
      debugPrint('Gemini Analizi Başlatılıyor: $make $model ($currentKm km)');
      final response = await modelInstance.generateContent(content);

      if (response.text == null) {
        throw Exception('AI boş yanıt döndürdü.');
      }

      // 4. Güvenli Temizlik (Sanitization)
      // Bazen AI ```json ... ``` formatında, bazen düz metin gönderir.
      // Bu temizlik işlemi her iki durumu da kurtarır.
      String cleanJson = response.text!
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();
      
      // Olası tırnak işareti hatalarını veya baştaki/sondaki boşlukları temizler
      if (cleanJson.startsWith('json')) {
        cleanJson = cleanJson.substring(4).trim();
      }

      // 5. JSON Dönüştürme (Parsing)
      final List<dynamic> decodedList = jsonDecode(cleanJson);
      
      // Gelen verinin gerçekten beklediğimiz yapıda (Map listesi) olduğunu doğrula
      return decodedList.cast<Map<String, dynamic>>();

    } catch (e) {
      // Hata durumunda uygulama çökmez, boş liste döner ve hatayı loglar.
      debugPrint('Gemini Servis Hatası: $e');
      // İleride buraya kullanıcıya hata mesajı gösterecek bir mekanizma eklenebilir.
      return []; 
    }
  }
}