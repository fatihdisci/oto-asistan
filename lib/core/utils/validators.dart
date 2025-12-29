class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'E-posta adresi gereklidir';
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) return 'Geçerli bir e-posta adresi giriniz';
    return null;
  }

  static String? validatePlate(String? value) {
    if (value == null || value.isEmpty) return 'Plaka gereklidir';
    final plateRegex = RegExp(r'^\d{2}\s?[A-Z]{1,3}\s?\d{2,4}$');
    if (!plateRegex.hasMatch(value.replaceAll(' ', ''))) return 'Geçerli bir plaka formatı giriniz';
    return null;
  }

  static String? validateKm(String? value) {
    if (value == null || value.isEmpty) return 'Kilometre gereklidir';
    if (int.tryParse(value) == null) return 'Geçerli bir rakam giriniz';
    return null;
  }
}