
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:menji/view/client/pageAccueille.dart';
import 'package:menji/services/ApiLivraison.dart';
import 'package:menji/view/client/commander.dart';

import '../serviceAu/local_storage_service.dart';




class Typevehiculecontroller {

  String? token;
  Apilivraison v= Apilivraison();

  setToken() async{
    String? token= await LocalStorageService().getToken();
    v.setToken(token!);
  }

  Typevehiculecontroller(){
    this.setToken();
  }




  Future<List<Map<String,String>>> AllTypeVehicule() async{
    final typeVehicules= await v.typeVehicule();
    return typeVehicules;
  }





}

