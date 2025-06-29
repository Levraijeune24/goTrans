
import 'package:flutter/material.dart';

class ButtonClient {

  String libelle;
  bool isSelected=true;
  final  VoidCallback action;
  double width,height;
  double paddingHorizontale;
  dynamic color ;

  bool isnotwifiation;

  ButtonClient({required this.libelle,required this.action,
    this.color=Colors.orange,
    this.isnotwifiation=false,

    this.isSelected=true, this.width=10, this.height=30,this.paddingHorizontale=16
  });


  run(){
    print(isnotwifiation);
    print("dddddd");

    return GestureDetector(
      onTap: action,
      child:Stack(
        children: [

          Container(
            margin:  EdgeInsets.symmetric( horizontal: 0),
            constraints: const BoxConstraints(minWidth: 100),
            height:height ,
            width: width,
            decoration: BoxDecoration(
                color: isSelected ? color :  Color(0xF5F5F5),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,

                    offset: const Offset(0, 1),
                  ),
                ]
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
          isnotwifiation==true?
          Container(
            height: 10,
            width: 10,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.red
            ),
          ):Center(),
        ],
      )
    );

  }
}