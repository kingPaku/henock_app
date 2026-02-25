import 'package:intl/intl.dart';

// Formatage du prix
String formatPrix(double prix) {
  final formatter = NumberFormat.currency(
    symbol: '\$',
    decimalDigits: 0,
    locale: 'fr_FR',
  );
  return formatter.format(prix);
}

// Formatage de la date
String formatDate(DateTime date) {
  return DateFormat('dd/MM/yyyy', 'fr_FR').format(date);
}
