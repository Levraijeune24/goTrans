import 'package:flutter/material.dart';



class TextBienvenue{

  late String name;

  TextBienvenue({required this.name});

  run(){

    return  RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 24),
        children: [
          const TextSpan(
            text: 'Bienvenu  ',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black
            ),
          ),
          TextSpan(
            text:name,
            style: const TextStyle(color: Colors.orange),
          ),
        ],
      ),
    );

  }





}
