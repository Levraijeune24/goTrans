import 'package:intl/intl.dart';

String dateDuJour() {
  return DateFormat('dd-MM-yyyy HH:mm:ss').format(DateTime.now());
}