
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:menji/view/client/pageAccueille.dart';
import 'package:menji/services/ApiLivraison.dart';
import 'package:menji/view/client/commander.dart';




class Typevehiculecontroller {




  Typevehiculecontroller();

  Future<List<Map<String,String>>> AllTypeVehicule() async{
    final typeVehicules= await Apilivraison().typeVehicule();

    return typeVehicules;
  }





}

