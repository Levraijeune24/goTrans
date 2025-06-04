
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:menji/view/client/pageAccueille.dart';
import 'package:menji/services/ApiServiceLivraison.dart';
import 'package:menji/view/client/commander.dart';

import '../serviceAu/local_storage_service.dart';




class Typevehiculecontroller {

  String? token;
  late Apilivraison v;

  Future<void> init () async {
    v = Apilivraison();
    await v.init();
  }


  Future<List<Map<String,String>>> AllTypeVehicule() async{
    print(v.token);
    print("vvvvvvvvvv");
    final typeVehicules= await v.typeVehicule();
    return typeVehicules;
  }





}

