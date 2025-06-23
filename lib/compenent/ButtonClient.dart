
import 'package:flutter/material.dart';

class ButtonClient {

  String libelle;
  bool isSelected=true;
  final  VoidCallback action;
  double width,height;

  ButtonClient({required this.libelle,required this.action,
    this.isSelected=true, this.width=10, this.height=30
  });


  run(){

    return GestureDetector(
      onTap: action,
      child: Container(
        padding: const EdgeInsets.symmetric( horizontal: 16),
        constraints: const BoxConstraints(minWidth: 100),
        height:height ,
        width: width,
        decoration: BoxDecoration(
          color: isSelected ? Colors.orange : const Color.fromRGBO(245, 240, 250, 1.0),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            libelle,
            style: TextStyle(
              fontSize: (height+width)/3,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );

  }
}