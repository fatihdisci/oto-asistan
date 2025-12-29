class HighwayCalculator {
  static double calculateHighwayFee({required double distance, int vehicleClass = 1}) {
    double multiplier = 1.0;
    // DÜZELTME: If bloklarına süslü parantez eklendi
    if (vehicleClass == 2) {
      multiplier = 1.5;
    } else if (vehicleClass == 3) {
      multiplier = 2.0;
    } else if (vehicleClass == 4) {
      multiplier = 3.0;
    }
    
    return (distance * 0.15 * multiplier).roundToDouble();
  }

  static Map<String, double> getPopularRoutes() {
    return {
      'İstanbul - Ankara': 454 * 0.15,
      'İstanbul - İzmir': 565 * 0.15,
      'Ankara - İzmir': 584 * 0.15,
    };
  }
}