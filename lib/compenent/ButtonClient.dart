
import 'package:flutter/material.dart';

class ButtonClient {

  String libelle;
  bool isSelected=true;
  final  VoidCallback action;
  double width,height;
  double paddingHorizontale;
  dynamic color ;

  ButtonClient({required this.libelle,required this.action,
    this.color=Colors.orange,

    this.isSelected=true, this.width=10, this.height=30,this.paddingHorizontale=16
  });


  run(){

    return GestureDetector(
      onTap: action,
      child: Container(
          margin:  EdgeInsets.symmetric( horizontal: 0),

        constraints: const BoxConstraints(minWidth: 100),
        height:height ,
        width: width,
        decoration: BoxDecoration(
          color: isSelected ? color : const Color.fromRGBO(245, 240, 250, 1.0),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            libelle,
            style: TextStyle(
              fontSize: (height+width)/3,
              fontWeight: FontWeight.w400,
              color: isSelected ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );

  }
}