import 'dart:math';

import 'package:intl/intl.dart';

String genererCodeLivraison() {
  final now = DateTime.now();
  final formattedDate = DateFormat('yyyyMMdd-HHmmss').format(now);
  final random = Random();
  final randomCode = String.fromCharCodes(List.generate(3, (_) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return chars.codeUnitAt(random.nextInt(chars.length));
  }));
  return 'LIV-$formattedDate-$randomCode';
}