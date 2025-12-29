import 'package:intl/intl.dart';

class DateFormatters {
  static String formatDate(DateTime date) {
    return DateFormat('dd.MM.yyyy', 'tr_TR').format(date);
  }

  static String formatRelativeDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) return 'Bugün';
    if (difference.inDays == 1) return 'Dün';
    if (difference.inDays < 7) return '${difference.inDays} gün önce';
    if (difference.inDays < 30) return '${(difference.inDays / 7).floor()} hafta önce';
    return '${(difference.inDays / 30).floor()} ay önce';
  }
}