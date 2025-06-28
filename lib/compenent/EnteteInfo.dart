import 'package:flutter/material.dart';

Widget enteteInfo(String title,{color =Colors.orange,size=18.0}){

  return  Text(
    title,
    style: TextStyle(
      color: color,
      fontSize: size.toDouble(),
      fontWeight: FontWeight.bold,
    ),
  );
}