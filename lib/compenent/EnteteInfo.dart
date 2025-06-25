import 'package:flutter/material.dart';

Widget enteteInfo(String title){

  return  Text(
    title,
    style: TextStyle(
      color: Colors.orange,
      fontSize: 18,
      fontWeight: FontWeight.bold,
    ),
  );
}