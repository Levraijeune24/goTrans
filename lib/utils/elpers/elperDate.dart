import 'package:intl/date_symbol_data_file.dart';
import 'package:intl/intl.dart';

String dateDuJour() {
  return DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
}

Future<void> initLocale() async {
  await initializeDateFormatting('fr_FR','');
}





String formaterDate(String inputDate, {int heure = 9, int minute = 0}) {
  try {
    // Parse la date yyyy-MM-dd
    List<String> parts = inputDate.split('-');
    if (parts.length != 3) return "Date invalide";

    int year = int.parse(parts[0]);
    int month = int.parse(parts[1]);
    int day = int.parse(parts[2]);

    // Tableau des mois en français
    List<String> mois = [
      'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
      'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'
    ];

    if (month < 1 || month > 12) return "Date invalide";

    // Formate heure et minute avec deux chiffres
    String hh = heure.toString().padLeft(2, '0');
    String mm = minute.toString().padLeft(2, '0');

    // Construire la chaîne formatée
    String resultat = '$day ${mois[month - 1]} $year ';

    return resultat;
  } catch (e) {
    return "Date invalide";
  }
}

