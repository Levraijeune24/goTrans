import 'package:intl/intl.dart';

String dateDuJour() {
  return DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
}