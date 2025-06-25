import 'package:flutter/material.dart';




class AppBarCostum {

  late String libelle;

  late BuildContext context;

  AppBarCostum({required this.context,required this.libelle});

  PreferredSizeWidget  run(){

    return AppBar(
      elevation: 0,
      backgroundColor: Colors.orange,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(libelle, style: TextStyle(color: Colors.white)),
    );
  }

}